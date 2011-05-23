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
        
        if (![themeUrl isEqual:self.currentlyPlayingThemeUrl]) {
            self.currentlyPlayingThemeUrl = themeUrl;
            
            //TODO: should this be a user setting or a sensible default?
            CGFloat requestedVolume = 0.6;
            if (requestedVolume >= 1.0) {
                self.themeMusicPlayer = [AVPlayer playerWithURL:self.currentlyPlayingThemeUrl];
            } else {
                AVPlayerItem *playerItem = [self playerItemForURL:self.currentlyPlayingThemeUrl withVolumeAt:requestedVolume];
                self.themeMusicPlayer = [AVPlayer playerWithPlayerItem:playerItem];
            }
            
            
            [self.themeMusicPlayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];
            [self.themeMusicPlayer pause];
            if ([[HWUserDefaults preferences] boolForKey:PreferencesViewThemeMusicLoopEnabled]) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:)
                                                             name:AVPlayerItemDidPlayToEndTimeNotification object:[self.themeMusicPlayer currentItem]];
            }
            [self.themeMusicPlayer play];
        } else {
            //url is same, so music must be same, so don't do anything
        }
    }
}

- (void)stopPlayingThemeMusicForMediaObject:(PlexMediaObject *)aMediaObject {
    if(self.themeMusicPlayer && (!aMediaObject || aMediaObject.isTVShow)) {
        [self.themeMusicPlayer pause];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        self.currentlyPlayingThemeUrl = nil;
    }
}



//reduce volume
- (AVPlayerItem *)playerItemForURL:(NSURL *)url withVolumeAt:(CGFloat)requestedVolume {
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    AVAssetTrack *track = [audioTracks objectAtIndex:0];
    
    NSMutableArray *allAudioParams = [NSMutableArray array];
    AVMutableAudioMixInputParameters *audioInputParams = 
    [AVMutableAudioMixInputParameters audioMixInputParameters];
    
    [audioInputParams setVolume:requestedVolume atTime:kCMTimeZero];
    [audioInputParams setTrackID:[track trackID]];
    [allAudioParams addObject:audioInputParams];
    
    AVMutableAudioMix *audioZeroMix = [AVMutableAudioMix audioMix];
    [audioZeroMix setInputParameters:allAudioParams];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    [playerItem setAudioMix:audioZeroMix];
    return playerItem;
}

//used to loop the music if enabled
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero]; //start song over again
}

@end
