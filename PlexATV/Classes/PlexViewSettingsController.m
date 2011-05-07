//
//  PlexViewSettingsController.m
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

#define ViewTypeSettingIndex 0
//----------- list -----------
#define EnableSkipFilteringOptionsMenuIndex 1
#define DisablePosterZoomingInListViewIndex 2
//----------- detailed metadata -----------
#define DisableFanartInDetailedMetadataViewIndex 3

#pragma mark -
#pragma mark Object/Class Lifecycle
- (id) init {
	if((self = [super init]) != nil) {
		[self setLabel:@"Plex View Settings"];
		[self setListTitle:@"Plex View Settings"];
		
		[self setupList];
        [[self list] addDividerAtIndex:1 withLabel:@"List"];
        [[self list] addDividerAtIndex:3 withLabel:@"Detailed Metadata"];
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
    
  	// =========== view type setting ===========
	SMFMenuItem *viewTypeSettingMenuItem = [SMFMenuItem menuItem];
	
	NSString *viewTypeSetting = [[HWUserDefaults preferences] objectForKey:PreferencesViewTypeSetting];
	if (viewTypeSetting == nil) {
		[[HWUserDefaults preferences] setObject:@"Grid" forKey:PreferencesViewTypeSetting];
		viewTypeSetting = [[HWUserDefaults preferences] objectForKey:PreferencesViewTypeSetting];
	}

	NSString *viewTypeSettingTitle = [[NSString alloc] initWithFormat:@"Video view:                  %@", viewTypeSetting];
	[viewTypeSettingMenuItem setTitle:viewTypeSettingTitle];
	[viewTypeSettingTitle release];
	[_items addObject:viewTypeSettingMenuItem];
    
    
    
	// =========== "skip filtering options" menu ===========
	SMFMenuItem *skipFilteringOptionsMenuItem = [SMFMenuItem menuItem];
	
	NSString *skipFilteringOptions = [[HWUserDefaults preferences] boolForKey:PreferencesViewEnableSkipFilteringOptionsMenu] ? @"Yes" : @"No";
	NSString *skipFilteringOptionsTitle = [[NSString alloc] initWithFormat:@"Skip filtering menu:     %@", skipFilteringOptions];
	[skipFilteringOptionsMenuItem setTitle:skipFilteringOptionsTitle];
	[skipFilteringOptionsTitle release];
	[_items addObject:skipFilteringOptionsMenuItem];
	
	
	// =========== disable poster zooming in list view ===========
	SMFMenuItem *disablePosterZoomMenuItem = [SMFMenuItem menuItem];
	
	NSString *disablePosterZoom = [[HWUserDefaults preferences] boolForKey:PreferencesViewDisablePosterZoomingInListView] ? @"Yes" : @"No";
	NSString *disablePosterZoomTitle = [[NSString alloc] initWithFormat:@"Disable poster zoom:  %@", disablePosterZoom];
	[disablePosterZoomMenuItem setTitle:disablePosterZoomTitle];
	[disablePosterZoomTitle release];
	[_items addObject:disablePosterZoomMenuItem];
    
    
    // =========== disable fanart in detailed metadata view ===========
	SMFMenuItem *disableFanartInMetadataScreenMenuItem = [SMFMenuItem menuItem];
	
	NSString *disableFanartInMetadataScreen = [[HWUserDefaults preferences] boolForKey:PreferencesViewDisableFanartInDetailedMetadataView] ? @"Yes" : @"No";
	NSString *disableFanartInMetadataScreenTitle = [[NSString alloc] initWithFormat:@"Disable fanart:             %@", disableFanartInMetadataScreen];
	[disableFanartInMetadataScreenMenuItem setTitle:disableFanartInMetadataScreenTitle];
	[disableFanartInMetadataScreenTitle release];
	[_items addObject:disableFanartInMetadataScreenMenuItem];
}


#pragma mark -
#pragma mark List Delegate Methods
- (void)itemSelected:(long)selected {
	switch (selected) {
        case ViewTypeSettingIndex: {
            // =========== view type setting ===========
            NSString *viewTypeSetting = [[HWUserDefaults preferences] objectForKey:PreferencesViewTypeSetting];
            
            if ([viewTypeSetting isEqualToString:@"List"]) {
                [[HWUserDefaults preferences] setObject:@"Grid" forKey:PreferencesViewTypeSetting];
            } else {
                [[HWUserDefaults preferences] setObject:@"List" forKey:PreferencesViewTypeSetting];
            }
            
            
            [self setupList];
            [self.list reload];      
            break;
        }
		case EnableSkipFilteringOptionsMenuIndex: {
            // =========== "skip filtering options" menu ===========
			BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesViewEnableSkipFilteringOptionsMenu];
			[[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesViewEnableSkipFilteringOptionsMenu];			
			[self setupList];
			[self.list reload];
			break;
		}
		case DisablePosterZoomingInListViewIndex: {
            // =========== disable poster zooming in list view ===========
			BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesViewDisablePosterZoomingInListView];
			[[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesViewDisablePosterZoomingInListView];			
			[self setupList];
			[self.list reload];
			break;
        }
		case DisableFanartInDetailedMetadataViewIndex: {
            // =========== disable fanart in detailed metadata view ===========
			BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesViewDisableFanartInDetailedMetadataView];
			[[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesViewDisableFanartInDetailedMetadataView];			
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
        case ViewTypeSettingIndex: {
            // =========== view type setting ===========
            [asset setTitle:@"Select the video listing view type"];
            [asset setSummary:@"Sets the type of view for videos, choose between list view or grid view ie. cover art view."];
            break;
        }
		case EnableSkipFilteringOptionsMenuIndex: {
            // =========== "skip filtering options" menu ===========
			[asset setTitle:@"Toggles whether to skip the menu"];
			[asset setSummary:@"Enables/Disables the skipping of the menus with 'all', 'unwatched', 'newest', etc. (currently experimental)"];
			break;
		}
		case DisablePosterZoomingInListViewIndex: {
            // =========== disable poster zooming in list view ===========
			[asset setTitle:@"Toggles whether to zoom the poster"];
			[asset setSummary:@"Enables/Disables the image starting out full screen and animating to show the metadata"];
			break;
		}
		case DisableFanartInDetailedMetadataViewIndex: {
            // =========== disable fanart in detailed metadata view ===========
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
