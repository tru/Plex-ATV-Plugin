//
//  PlexNavigationController.h
//  plex
//
//  Created by ccjensen on 18/04/2011.
//

#import <Foundation/Foundation.h>
#import <plex-oss/PlexMediaObject.h>

@interface PlexNavigationController : BRController {}

@property (retain) PlexMediaObject *targetMediaObject;
@property (retain) BRWaitPromptControl *waitControl;

+ (PlexNavigationController *)sharedPlexNavigationController;
- (void)navigateToObjectsContents:(PlexMediaObject *)aMediaObject;


- (BRController *)controllerForObject:(PlexMediaObject *)aMediaObject;

//Container Manipulation Methods
- (BRController *)newTVShowsController:(PlexMediaContainer *)tvShowCategory;
- (BRController *)newMoviesController:(PlexMediaContainer*)movieCategory;

@end
