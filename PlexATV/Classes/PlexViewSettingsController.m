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

//----------- general -----------
#define ViewTypeSettingIndex                0
#define ViewThemeMusicEnabledIndex          1
#define ViewThemeMusicLoopEnabledIndex      2
//----------- list -----------
#define ViewListPosterZoomingEnabledIndex   3
//----------- detailed metadata -----------
#define ViewPreplayFanartEnabledIndex       4

#pragma mark -
#pragma mark Object/Class Lifecycle
- (id) init {
	if((self = [super init]) != nil) {
		[self setLabel:@"Plex View Settings"];
		[self setListTitle:@"Plex View Settings"];
		
		[self setupList];
        [[self list] addDividerAtIndex:0 withLabel:@"General"];
        [[self list] addDividerAtIndex:3 withLabel:@"List"];
        [[self list] addDividerAtIndex:4 withLabel:@"Detailed Metadata"];
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
    
    // =========== general ===========
  	// =========== view type setting ===========
	SMFMenuItem *viewTypeSettingMenuItem = [SMFMenuItem menuItem];
	
	NSString *viewTypeSetting = [[HWUserDefaults preferences] objectForKey:PreferencesViewTypeSetting];
	[viewTypeSettingMenuItem setTitle:@"Video view"];
    [viewTypeSettingMenuItem setRightText:viewTypeSetting];
	[_items addObject:viewTypeSettingMenuItem];
    

    // =========== theme music enabled ===========
	SMFMenuItem *themeMusicMenuItem = [SMFMenuItem menuItem];
	
	[themeMusicMenuItem setTitle:@"Theme music"];
	NSString *themeMusic = [[HWUserDefaults preferences] boolForKey:PreferencesViewThemeMusicEnabled] ? @"Enabled" : @"Disabled";
    [themeMusicMenuItem setRightText:themeMusic];
	[_items addObject:themeMusicMenuItem];
    
    
    // =========== theme music looping ===========
	SMFMenuItem *themeMusicLoopingMenuItem = [SMFMenuItem menuItem];
	
	[themeMusicLoopingMenuItem setTitle:@"Theme music looping"];
	NSString *themeMusicLooping = [[HWUserDefaults preferences] boolForKey:PreferencesViewThemeMusicLoopEnabled] ? @"Enabled" : @"Disabled";
    [themeMusicLoopingMenuItem setRightText:themeMusicLooping];
	[_items addObject:themeMusicLoopingMenuItem];
    
    
    // =========== list ===========	
	// =========== poster zooming ===========
	SMFMenuItem *posterZoomMenuItem = [SMFMenuItem menuItem];
	
	[posterZoomMenuItem setTitle:@"Poster zoom"];
	NSString *posterZoom = [[HWUserDefaults preferences] boolForKey:PreferencesViewListPosterZoomingEnabled] ? @"Enabled" : @"Disabled";
    [posterZoomMenuItem setRightText:posterZoom];
	[_items addObject:posterZoomMenuItem];
    
    
    // =========== Preplay ===========
    // =========== fanart ===========
	SMFMenuItem *fanartMenuItem = [SMFMenuItem menuItem];
	
	[fanartMenuItem setTitle:@"Fanart"];
	NSString *fanart = [[HWUserDefaults preferences] boolForKey:PreferencesViewPreplayFanartEnabled] ? @"Enabled" : @"Disabled";
    [fanartMenuItem setRightText:fanart];
	[_items addObject:fanartMenuItem];
}

#pragma mark -
#pragma mark List Delegate Methods
- (void)itemSelected:(long)selected {
	switch (selected) {
        case ViewTypeSettingIndex: {
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
		case ViewThemeMusicEnabledIndex: {
			BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesViewThemeMusicEnabled];
			[[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesViewThemeMusicEnabled];			
			[self setupList];
			[self.list reload];
			break;
        }
		case ViewThemeMusicLoopEnabledIndex: {
			BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesViewThemeMusicLoopEnabled];
			[[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesViewThemeMusicLoopEnabled];			
			[self setupList];
			[self.list reload];
			break;
        }
        //--------------------- seperator ---------------------
		case ViewListPosterZoomingEnabledIndex: {
			BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesViewListPosterZoomingEnabled];
			[[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesViewListPosterZoomingEnabled];			
			[self setupList];
			[self.list reload];
			break;
        }
        //--------------------- seperator ---------------------
		case ViewPreplayFanartEnabledIndex: {
			BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesViewPreplayFanartEnabled];
			[[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesViewPreplayFanartEnabled];			
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
            [asset setTitle:@"Select the video listing view type"];
            [asset setSummary:@"Sets the type of view for videos, choose between list view or grid view ie. cover art view."];
            break;
        }
		case ViewThemeMusicEnabledIndex: {
			[asset setTitle:@"Toggles whether theme music plays"];
			[asset setSummary:@"Enables/Disables the playback of theme music upon entering a section that has theme music available"];
			break;
		}
		case ViewThemeMusicLoopEnabledIndex: {
			[asset setTitle:@"Toggles whether the theme music loops"];
			[asset setSummary:@"Enables/Disables the looping of theme music when playback of theme music completes"];
			break;
		}
		case ViewListPosterZoomingEnabledIndex: {
			[asset setTitle:@"Toggles whether to zoom the poster"];
			[asset setSummary:@"Enables/Disables the image starting out full screen and animating to show the metadata"];
			break;
		}
		case ViewPreplayFanartEnabledIndex: {
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
