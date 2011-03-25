//
//  HWAdvancedSettingsController.m
//  atvTwo
//
//  Created by ccjensen on 10/01/2011.
//
//  Inspired by 
//
//		MLoader.m
//		MextLoader
//
//		Created by Thomas Cool on 10/22/10.
//		Copyright 2010 tomcool.org. All rights reserved.
//

#import "PlexViewSettingsController.h"
#import "HWUserDefaults.h"
#import "Constants.h"

@implementation PlexViewSettingsController

#define EnableSkipFilteringOptionsMenu 0
#define DisablePosterZoomingInListView 1

#pragma mark -
#pragma mark Object/Class Lifecycle
- (id) init {
	if((self = [super init]) != nil) {
		[self setLabel:@"Plex View Settings"];
		[self setListTitle:@"Plex View Settings"];
		
		[self setupList];
	}	
	return self;
}

- (void)dealloc {
	[super dealloc];	
}


#pragma mark -
#pragma mark Controller Lifecycle behaviour
- (void)wasPushed {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
	[super wasPushed];
}

- (void)wasPopped {
	[super wasPopped];
}

- (void)wasExhumed {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
	[self setupList];
	[self.list reload];
	[super wasExhumed];
}

- (void)wasBuried {
	[super wasBuried];
}

- (void)setupList {
	[_items removeAllObjects];
	
	// =========== enable "skip filtering options" menu ===========
	SMFMenuItem *skipFilteringOptionsMenuItem = [SMFMenuItem menuItem];
	
	NSString *skipFilteringOptions = [[HWUserDefaults preferences] boolForKey:PreferencesViewEnableSkipFilteringOptionsMenu] ? @"Enabled" : @"Disabled";
	NSString *skipFilteringOptionsTitle = [[NSString alloc] initWithFormat:@"Filtering menu:    %@", skipFilteringOptions];
	[skipFilteringOptionsMenuItem setTitle:skipFilteringOptionsTitle];
	[skipFilteringOptionsTitle release];
	[_items addObject:skipFilteringOptionsMenuItem];
	
	
	// =========== disable poster zooming in list view ===========
	SMFMenuItem *enableDebugMenuItem = [SMFMenuItem menuItem];
	
	NSString *enableDebug = [[HWUserDefaults preferences] boolForKey:PreferencesViewDisablePosterZoomingInListView] ? @"Enabled" : @"Disabled";
	NSString *enableDebugTitle = [[NSString alloc] initWithFormat:@"Poster zoom: %@", enableDebug];
	[enableDebugMenuItem setTitle:enableDebugTitle];
	[enableDebugTitle release];
	[_items addObject:enableDebugMenuItem];
}


#pragma mark -
#pragma mark List Delegate Methods
- (void)itemSelected:(long)selected {
	switch (selected) {
		case EnableSkipFilteringOptionsMenu: {
			// =========== enable "skip filtering options" menu ===========
			BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesViewEnableSkipFilteringOptionsMenu];
			[[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesViewEnableSkipFilteringOptionsMenu];			
			[self setupList];
			[self.list reload];
			break;
		}
		case DisablePosterZoomingInListView: {
			// =========== enable poster zooming in list view ===========
			BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesViewDisablePosterZoomingInListView];
			[[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesViewDisablePosterZoomingInListView];			
			[self setupList];
			[self.list reload];
			break;
		}
		default:
			break;
	}
}


-(id)previewControlForItem:(long)item
{
	SMFBaseAsset *asset = [[SMFBaseAsset alloc] init];
	switch (item) {
		case EnableSkipFilteringOptionsMenu: {
			// =========== enable "skip filtering options" menu ===========
			[asset setTitle:@"Toggles whether to skip the menu"];
			[asset setSummary:@"Enables/Disables the skipping of the menus with 'all', 'unwatched', 'newest', etc. (currently experimental)"];
			break;
		}
		case DisablePosterZoomingInListView: {	
			// =========== enable poster zooming in list view ===========
			[asset setTitle:@"Toggles whether to zoom the poster"];
			[asset setSummary:@"Enables/Disables the image starting out full screen and animating to show the metadata"];
			break;
		}
		default:
			break;
	}
	[asset setCoverArt:[BRImage imageWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"PlexSettings" ofType:@"png"]]];
	SMFMediaPreview *p = [[SMFMediaPreview alloc] init];
	[p setShowsMetadataImmediately:YES];
	[p setAsset:asset];
	[asset release];
	return [p autorelease];  
}


@end
