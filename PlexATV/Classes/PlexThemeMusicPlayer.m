//
//  PlexThemeMusicPlayer.m
//  plex
//
//  Created by ccjensen on 06/05/2011.
//

#import "PlexThemeMusicPlayer.h"
#import "Plex_SynthesizeSingleton.h"
#import <plex-oss/PlexRequest + Security.h>
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import "HWUserDefaults.h"
#import "Constants.h"

@implementation PlexThemeMusicPlayer
@synthesize themeMusicPlayer;
@synthesize currentlyPlayingThemeUrl;


PLEX_SYNTHESIZE_SINGLETON_FOR_CLASS(PlexThemeMusicPlayer);


- (void)startPlayingThemeMusicIfAppropiateForMediaObject:(PlexMediaObject *)mediaObject {
    BOOL themeMusicEnabled = [[HWUserDefaults preferences] boolForKey:PreferencesViewThemeMusicEnabled];
    if (!themeMusicEnabled) {
        return;
    }
    
    BOOL hasThemeMusic = NO;
    NSString *themeUrlAsString = nil;
    //let's play theme music both in show view but also in season view, since we in grid mode always go to season view directly
    
    if (mediaObject.isTVShow && [mediaObject.attributes valueForKey:@"theme"] != nil) {
        //tv show with theme
        hasThemeMusic = YES;
        themeUrlAsString = [mediaObject.request buildAbsoluteKey: [mediaObject.attributes valueForKey:@"theme"]];
        
    } else if ((mediaObject.isSeason || mediaObject.isEpisode) && [mediaObject.mediaContainer.attributes valueForKey:@"theme"] != nil) {
        //season or episode with theme
        hasThemeMusic = YES;
        themeUrlAsString = [mediaObject.request buildAbsoluteKey: [mediaObject.mediaContainer.attributes valueForKey:@"theme"]];
        
    }
    
    if (hasThemeMusic && themeUrlAsString) {
        NSURL *themeUrl = [NSURL URLWithString:themeUrlAsString];
        
        if (!self.themeMusicPlayer) {
            self.currentlyPlayingThemeUrl = themeUrl;
            self.themeMusicPlayer = [AVQueuePlayer playerWithURL:themeUrl];
            [self.themeMusicPlayer setActionAtItemEnd:AVPlayerActionAtItemEndAdvance];
            [self.themeMusicPlayer pause];
            [self.themeMusicPlayer play];
        } else if (![self.currentlyPlayingThemeUrl isEqual:themeUrl]) {
            self.currentlyPlayingThemeUrl = themeUrl;
            AVPlayerItem *newItem = [AVPlayerItem playerItemWithURL:self.currentlyPlayingThemeUrl];
            [self.themeMusicPlayer insertItem:newItem afterItem:nil];
            DLog(@"rate [%f]", [self.themeMusicPlayer rate]);
            if ([self.themeMusicPlayer rate] == 0) {
                [self.themeMusicPlayer pause];
                [self.themeMusicPlayer play];
            }
        } else {
            //url is same, so music must be same, so don't do anything
        }
    }
}

- (void)stopPlayingThemeMusicForMediaObject:(PlexMediaObject *)aMediaObject {
    if(self.themeMusicPlayer && aMediaObject.isTVShow) {
        [self stopPlayingThemeMusic];
    }
}

- (void)stopPlayingThemeMusic {
    self.currentlyPlayingThemeUrl = nil;
    AVAsset *asset = [self.themeMusicPlayer.currentItem asset];
    NSArray *keys = [NSArray arrayWithObject:@"tracks"];
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^(void) {
        NSError *error = nil;
        // get the status to see if the asset was loaded
        AVKeyValueStatus trackStatus = [asset statusOfValueForKey:@"tracks" error:&error];
        switch (trackStatus) {
            case AVKeyValueStatusLoaded: {
                if(self.themeMusicPlayer) {
                    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeAudio];
                    NSMutableArray *allAudioParams = [NSMutableArray array];
                    
                    float fadeOutSeconds = 1.0f;
                    for (AVAssetTrack *t in tracks) {
                        AVMutableAudioMixInputParameters *params =[AVMutableAudioMixInputParameters audioMixInputParameters];
                        
                        [params setVolumeRampFromStartVolume:1.0 toEndVolume:0.0 timeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(fadeOutSeconds, 1))];
                        
                        [params setTrackID:[t trackID]];
                        [allAudioParams addObject:params];
                    }
                    AVMutableAudioMix *zeromix = [AVMutableAudioMix audioMix];
                    [zeromix setInputParameters:allAudioParams];
                    
                    [self.themeMusicPlayer.currentItem setAudioMix:zeromix];
                    //hack. we want the fade out finishing to pause the content
                    [self.themeMusicPlayer performSelector:@selector(advanceToNextItem) withObject:nil afterDelay:fadeOutSeconds+0.3];
                }
                break;
            }
            default:
                break;
        }
    }]; //end block
}

- (int)queueSize {
    return [[self.themeMusicPlayer items] count];
}

- (void)cancelAllQueuedPlayback {
    [self.themeMusicPlayer removeAllItems];
}

@end
