//
//  PlexNavigationController.m
//  plex
//
//  Created by ccjensen on 18/04/2011.
//

#import "PlexNavigationController.h"
#import "Plex_SynthesizeSingleton.h"
#import "Constants.h"
#import "HWUserDefaults.h"
#import <plex-oss/PlexRequest + Security.h>

//view/controller types
#import "HWSettingsController.h"
#import "PlexChannelsController.h"
#import "HWBasicMenu.h"
#import "HWPlexDir.h"
#import "PlexSongListController.h"
#import "HWTVShowsController.h"
#import "HWMediaGridController.h"
#import "HWDetailedMovieMetadataController.h"
#import <SMFramework/SMFControllerPasscodeController.h>

@implementation PlexNavigationController
@synthesize waitControl;
@synthesize targetMediaObject;
@synthesize targetController;
@synthesize promptText;

PLEX_SYNTHESIZE_SINGLETON_FOR_CLASS(PlexNavigationController);

- (id)init {
    self = [super init];
    if (self) {
        //this will allow us to have a nice 'wait spinner' when we
        //refactor the code so it can be loaded on a background thread
        self.waitControl = [[BRWaitPromptControl alloc] init];
        [self.waitControl setFrame:[BRWindow interfaceFrame]];
        [self addControl:self.waitControl];
    }
    return self;
}

#pragma mark -
#pragma mark Controller Lifecycle behaviour
- (void)wasPushed {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
	[super wasPushed];
    
    [self.waitControl setPromptText:self.promptText];
    
    //determine view/controller type for target container if not already determined before we were pushed
    //(some types are pre-set like settings, server list, etc)
    if (!self.targetController && self.targetMediaObject) {
        BRController *controller = [self newControllerForObject:self.targetMediaObject];
        self.targetController = controller;
        [controller release];
    }
    
    DLog(@"Navigating using controller type: [%@]", [self.targetController class]);
    [[[BRApplicationStackManager singleton] stack] swapController:self.targetController];
}

- (void)wasPopped {
    //called if user cancels load and goes back
	[super wasPopped];
}

- (void)wasExhumed {
    //should never get called as we always swap self out of the stack
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
	[super wasExhumed];
}

- (void)wasBuried {
    //should never get called as we always swap self out of the stack
	[super wasBuried];
}

#pragma mark -
#pragma mark Navigation Methods
- (void)navigateToObjectsContents:(PlexMediaObject *)aMediaObject {
    DLog(@"Navigating to: [%@]", aMediaObject);
    self.targetController = nil;
    self.targetMediaObject = aMediaObject;
    self.promptText = [NSString stringWithFormat:@"Loading \"%@\"...", self.targetMediaObject.name];
    
    [[[BRApplicationStackManager singleton] stack] pushController:self];
}

- (void)navigateToDetailedMetadataController:(NSArray *)previewAssets withSelectedIndex:(int)selectedIndex {
    DLog(@"Navigating to: [Detailed Metadata]");
    self.targetController = nil;
    self.targetMediaObject = nil;
    self.promptText = @"Loading \"Detailed Metadata\"...";
    
    HWDetailedMovieMetadataController* previewController = [[HWDetailedMovieMetadataController alloc] initWithPreviewAssets:previewAssets withSelectedIndex:selectedIndex];
    self.targetController = previewController;
    [previewController release];
    
    [[[BRApplicationStackManager singleton] stack] pushController:self];
}

- (void)navigateToChannelsForMachine:(Machine *)aMachine {
    DLog(@"Navigating to: [Channels], for machine: [%@]", aMachine.userName);
    self.targetController = nil;
    self.targetMediaObject = nil;
    self.promptText = @"Loading \"Channels\"...";
    
    PlexMediaContainer* channelsContainer = [aMachine.request query:@"/system/plugins/all" callingObject:nil ignorePresets:YES timeout:20 cachePolicy:NSURLRequestUseProtocolCachePolicy];
    PlexChannelsController *channelsController = [[PlexChannelsController alloc] initWithRootContainer:channelsContainer];
    self.targetController = channelsController;
    [channelsController release];
    
    [[[BRApplicationStackManager singleton] stack] pushController:self];
}

- (void)navigateToSettingsWithTopLevelController:(BRBaseAppliance *)topLevelController {
    DLog(@"Navigating to: [Settings]");
    self.targetController = nil;
    self.targetMediaObject = nil;
    self.promptText = @"Loading \"Settings\"...";
    
    HWSettingsController *settingsController = [[HWSettingsController alloc] init];
    settingsController.topLevelController = topLevelController;
    
    if ([[HWUserDefaults preferences] boolForKey:PreferencesSettingsEnableLock]) {
        NSInteger securityPasscode = [[HWUserDefaults preferences] integerForKey:PreferencesSecurityPasscode];
        SMFControllerPasscodeController *passcodeController = [[SMFControllerPasscodeController alloc] initForController:settingsController withPasscode:securityPasscode];
        [settingsController release];
        self.targetController = passcodeController;
        [passcodeController release];
    } else {
        self.targetController = settingsController;
        [settingsController release];
    }
    
    [[[BRApplicationStackManager singleton] stack] pushController:self];
}

- (void)navigateToServerList {
    DLog(@"Navigating to: [Server List]");
    self.targetController = nil;
    self.targetMediaObject = nil;
    self.promptText = @"Loading \"Server List\"...";
    
    HWBasicMenu *serverList = [[HWBasicMenu alloc] init];
    self.targetController = serverList;
    [serverList release];
    
    [[[BRApplicationStackManager singleton] stack] pushController:self];
}


#pragma mark -
#pragma mark Determine View Type Methods
- (BRController *)newControllerForObject:(PlexMediaObject *)aMediaObject {
    BRController *controller = nil;
    PlexMediaContainer *contents = [aMediaObject contents];
    
    contents = [self applySkipFilteringOnContainer:contents];
    
    if ([PlexViewGroupAlbum isEqualToString:aMediaObject.mediaContainer.viewGroup] 
        || [@"albums" isEqualToString:aMediaObject.mediaContainer.content] 
        || [@"playlists" isEqualToString:aMediaObject.mediaContainer.content]) {
        return [[PlexSongListController alloc] initWithPlexContainer:contents title:aMediaObject.name];
    }
    
    //determine the user selected view setting
    BRTabControl *tabBar = [self newTabBarForContents:contents];
    
    NSString *viewTypeSetting = [[HWUserDefaults preferences] objectForKey:PreferencesViewTypeSetting];
    if (viewTypeSetting == nil || [viewTypeSetting isEqualToString:@"Grid"]) {
        
        if (aMediaObject.isMovie) {
            controller = [self newMoviesController:contents];
        } else if (aMediaObject.isTVShow) {
            controller = [self newTVShowsController:contents];
        } else {
            controller = [[HWPlexDir alloc] initWithRootContainer:contents andTabBar:tabBar];
        }
        
    } else {
        controller = [[HWPlexDir alloc] initWithRootContainer:contents andTabBar:tabBar];
    }
    return controller;
}

- (BRTabControl *)newTabBarForContents:(PlexMediaContainer *)someContents {
    BRTabControl *tabBar = nil;
    DLog(@"tab bar for: [%@]", someContents);
    DLog(@"view group: [%@], [%@]", someContents.viewGroup, PlexViewGroupSecondary);
    if (![someContents.viewGroup isEqualToString:PlexViewGroupSecondary]) {
        tabBar = [[BRTabControl menuTabControl] retain];
        
        
        BRTabControlItem *i = [[BRTabControlItem alloc] init];
        NSString *currentlySelectedFilterName;
        if (someContents.parentFilterContainer) {
            currentlySelectedFilterName = someContents.parentObject.name;
        } else {
            currentlySelectedFilterName = @"All";
        }
        [i setLabel:currentlySelectedFilterName];
        [i setIdentifier:ScopeBarCurrentItemsIdentifier];
        [tabBar addTabItem:i];
        [i release];
        
        
        i = [[BRTabControlItem alloc] init];
        [i setLabel:@"Unwatched"];
        [i setIdentifier:ScopeBarUnwatchedItemsIdentifier];
        [tabBar addTabItem:i];
        [i release];
        
        
        if (someContents.parentFilterContainer) {
            //only add third item if we are navigating to one step below the filters (which we skip)
            //so this would be visible in the tv shows listing, movies listing, etc
            i = [[BRTabControlItem alloc] init];
            [i setLabel:@"Other Filters"];
            [i setIdentifier:someContents.parentFilterContainer];
            [tabBar addTabItem:i];
            [i release];
        }
    }
    return tabBar;
}


#pragma mark -
#pragma mark Container Manipulation Methods
- (BRController *)newTVShowsController:(PlexMediaContainer *)tvShowCategory {
	BRController *menuController = nil;
	PlexMediaObject *allTvShows=nil;
	if (tvShowCategory.directories > 0) {
		NSUInteger i, count = [tvShowCategory.directories count];
		for (i = 0; i < count; i++) {
			PlexMediaObject * obj = [tvShowCategory.directories objectAtIndex:i];
			NSString *key = [obj.attributes objectForKey:@"key"];
			DLog(@"obj_type: %@",key);
			if ([key isEqualToString:@"all"]) {
				allTvShows = obj;
				break;
			}
		}
	}
	
	if (allTvShows) {
		menuController = [[HWTVShowsController alloc] initWithPlexAllTVShows:[allTvShows contents]];
	}
	return menuController;
}

- (BRController *)newMoviesController:(PlexMediaContainer*)movieCategory {
	BRController *menuController = nil;
	PlexMediaObject *recent=nil;
	PlexMediaObject *allMovies=nil;
    //DLog(@"showGridListControl_movieCategory_directories: %@", movieCategory.directories);
	if (movieCategory.directories > 0) {
		NSUInteger i, count = [movieCategory.directories count];
		for (i = 0; i < count; i++) {
			PlexMediaObject * obj = [movieCategory.directories objectAtIndex:i];
			NSString *key = [obj.attributes objectForKey:@"key"];
			DLog(@"obj_type: %@",key);
			if ([key isEqualToString:@"all"])
				allMovies = obj;
			else if ([key isEqualToString:@"recentlyAdded"])
				recent = obj;
		}
	}
	
	if (recent && allMovies){
		menuController = [[HWMediaGridController alloc] initWithPlexAllMovies:[allMovies contents] andRecentMovies:[recent contents]];
	}
	return menuController;
}


- (PlexMediaContainer *)applySkipFilteringOnContainer:(PlexMediaContainer *)container {
	PlexMediaContainer *pmc = container;
	
	BOOL skipFilteringOptionsMenu = [[HWUserDefaults preferences] boolForKey:PreferencesViewEnableSkipFilteringOptionsMenu];
	DLog(@"skipFilteringOption: %@", skipFilteringOptionsMenu ? @"YES" : @"NO");
	
    skipFilteringOptionsMenu = YES;
	if (pmc.sectionRoot && !pmc.requestsMessage && skipFilteringOptionsMenu) { 
		//open "/library/section/x/all or the first item in the list"
		//bypass the first filter node
		
		/*
		 at some point wou will present the user a selection for the available filters, right?
		 when the user selects one, you should write to that preference so next time user comes back
		 ATV will use the last filter
		 */
		//[PlexPrefs defaultPreferences] filterForSection]
		Machine *currentMachine = container.request.machine;
		const NSString* filterWeAreLookingFor = [currentMachine filterForSection:pmc.key]; //all, unwatched, recentlyAdded, etc
		BOOL handled = NO;
		PlexMediaContainer* newPmc = nil;
		
		for(PlexMediaObject* po in pmc.directories){
			DLog(@"%@: %@ == %@", pmc.key, po.lastKeyComponent, filterWeAreLookingFor);
			if ([filterWeAreLookingFor isEqualToString:po.lastKeyComponent]) { //po.lastKeyComponent == one of [all, unwatched, recentlyAdded, etc]
				PlexMediaContainer* potentialNewPmc = [po contents]; //the contents like all the tv shows, movies, etc
				if (potentialNewPmc.directories.count>0) 
                    newPmc = potentialNewPmc; //if it contains at least some stuff, then use it
				handled = YES;
				break;
			}
		}
		
		DLog(@"handled: %@", handled ? @"YES" : @"NO");
		if (handled && newPmc==nil) 
            newPmc = [[pmc.directories objectAtIndex:0] contents]; //if we did find it, but it was empty, use the "default"
        
		if (newPmc==nil || newPmc.directories.count==0) { //if it wasn't "handled"
			for (PlexMediaObject* po in pmc.directories) { //iterate over all again
				PlexMediaContainer* potentialNewPmc = [po contents]; //the contents like all the tv shows, movies, etc
				if (potentialNewPmc.directories.count>0) { //find the first one who has some contents
					newPmc = potentialNewPmc;
					handled = YES;
					break;
				}
			}
		}
		
		if (newPmc) {
			pmc = newPmc; //if found, store it
		}
		
		if (!handled && pmc.directories.count>0) pmc = [[pmc.directories objectAtIndex:0] contents]; //we have failed, just use the "default
	}
	DLog(@"done filtering");
	return pmc;
}

@end
