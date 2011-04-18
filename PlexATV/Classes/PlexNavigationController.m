//
//  PlexNavigationController.m
//  plex
//
//  Created by ccjensen on 18/04/2011.
//

#import "PlexNavigationController.h"
#import "Plex_SynthesizeSingleton.h"
#import "HWPlexDir.h"

@implementation PlexNavigationController
@synthesize waitControl;
@synthesize rootContainer;

PLEX_SYNTHESIZE_SINGLETON_FOR_CLASS(PlexNavigationController);

- (id)init {
    self = [super init];
    if (self) {
        self.waitControl = [[BRWaitPromptControl alloc] init];
        [self.waitControl setFrame:[[UIScreen mainScreen] applicationFrame]];
        [self addControl:self.waitControl];
    }
    return self;
}

- (void)navigateToContainer:(PlexMediaContainer *)aContainer {
    self.rootContainer = aContainer;
    [[[BRApplicationStackManager singleton] stack] pushController:self];
}

#pragma mark -
#pragma mark Controller Lifecycle behaviour
- (void)wasPushed {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
	[super wasPushed];
    
    //moved on target
    DLog(@"Navigating to: [%@]", self.rootContainer);
    HWPlexDir* menuController = [[HWPlexDir alloc] initWithRootContainer:self.rootContainer];
    
    [[[BRApplicationStackManager singleton] stack] swapController:menuController];
    
    
    [menuController release];
}

- (void)wasPopped {
	[super wasPopped];
}

- (void)wasExhumed {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
	[super wasExhumed];
}

- (void)wasBuried {
	[super wasBuried];
}

@end
