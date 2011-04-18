//
//  PlexNavigationController.h
//  plex
//
//  Created by ccjensen on 18/04/2011.
//

#import <Foundation/Foundation.h>
#import <plex-oss/PlexMediaContainer.h>

@interface PlexNavigationController : BRController {}

@property (retain) PlexMediaContainer *rootContainer;
@property (retain) BRWaitPromptControl *waitControl;

+ (PlexNavigationController *)sharedPlexNavigationController;
- (void)navigateToContainer:(PlexMediaContainer *)aContainer;

@end
