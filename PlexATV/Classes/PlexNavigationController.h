//
//  PlexNavigationController.h
//  plex
//
//  Created by ccjensen on 18/04/2011.
//

#import <Foundation/Foundation.h>
#import <plex-oss/PlexMediaObject.h>

@interface PlexNavigationController : BRController {}

@property (retain) BRWaitPromptControl *waitControl;
@property (retain) PlexMediaObject *targetMediaObject;
@property (retain) BRController *targetController;
@property (retain) NSString *promptText;

+ (PlexNavigationController *)sharedPlexNavigationController;

//Navigation Methods
- (void)navigateToObjectsContents:(PlexMediaObject *)aMediaObject;
- (void)navigateToDetailedMetadataController:(NSArray *)previewAssets withSelectedIndex:(int)selectedIndex;
- (void)navigateToChannelsForMachine:(Machine *)aMachine;
- (void)navigateToSettingsWithTopLevelController:(BRBaseAppliance *)topLevelController;
- (void)navigateToServerList;

//Determine View Type Methods
- (BRController *)newControllerForObject:(PlexMediaObject *)aMediaObject;

//Container Manipulation Methods
- (BRController *)newTVShowsController:(PlexMediaContainer *)tvShowCategory;
- (BRController *)newMoviesController:(PlexMediaContainer*)movieCategory;

@end
