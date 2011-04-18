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

//view/controller types
#import "HWPlexDir.h"
#import "HWTVShowsController.h"
#import "HWMediaGridController.h"

@implementation PlexNavigationController
@synthesize waitControl;
@synthesize targetMediaObject;

PLEX_SYNTHESIZE_SINGLETON_FOR_CLASS(PlexNavigationController);

- (id)init {
    self = [super init];
    if (self) {
        self.waitControl = [[BRWaitPromptControl alloc] init];
        [self.waitControl setFrame:[BRWindow interfaceFrame]];
        [self addControl:self.waitControl];
    }
    return self;
}

- (void)navigateToObjectsContents:(PlexMediaObject *)aMediaObject {
    self.targetMediaObject = aMediaObject;
    NSString *promptText = [NSString stringWithFormat:@"Loading \"%@\"...", self.targetMediaObject.name];
    [self.waitControl setPromptText:promptText];
    [[[BRApplicationStackManager singleton] stack] pushController:self];
}

#pragma mark -
#pragma mark Controller Lifecycle behaviour
- (void)wasPushed {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
	[super wasPushed];
    
    DLog(@"Navigating to: [%@]", self.targetMediaObject);
    //determine view/controller type for target container
    
    BRController *controller = [self controllerForObject:self.targetMediaObject];
    [[[BRApplicationStackManager singleton] stack] swapController:controller];
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
#pragma mark Determine View Type Methods
- (BRController *)controllerForObject:(PlexMediaObject *)aMediaObject {
    BRController *controller = nil;
    
    //determine the user selected view setting
    NSString *viewTypeSetting = [[HWUserDefaults preferences] objectForKey:PreferencesViewTypeSetting];
    if (viewTypeSetting == nil || [viewTypeSetting isEqualToString:@"Grid"]) {
        if (aMediaObject.isMovie) {
            controller = [self newMoviesController:[aMediaObject contents]];
        } else if (aMediaObject.isTVShow) {
            controller = [self newTVShowsController:[aMediaObject contents]];
        } else {
            controller = [[HWPlexDir alloc] initWithRootContainer:[aMediaObject contents]];
        }
        
    } else {
        controller = [[HWPlexDir alloc] initWithRootContainer:[aMediaObject contents]];
    }
    return [controller autorelease];
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

@end
