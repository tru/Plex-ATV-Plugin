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
            self.themeMusicPlayer = [AVPlayer playerWithURL:themeUrl];
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

//used to loop the music if enabled
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero]; //start song over again
} 

- (void)stopPlayingThemeMusicForMediaObject:(PlexMediaObject *)aMediaObject {
    if(self.themeMusicPlayer && (!aMediaObject || aMediaObject.isTVShow)) {
        [self.themeMusicPlayer pause];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        self.currentlyPlayingThemeUrl = nil;
    }
}

@end
