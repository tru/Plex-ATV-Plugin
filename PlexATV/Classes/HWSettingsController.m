//
//  HWSettingsController.m
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

#import "HWSettingsController.h"
#import "HWServersController.h"
#import "HWAdvancedSettingsController.h"
#import "PlexAudioSettingsController.h"
#import "HWUserDefaults.h"
#import "Constants.h"

@implementation HWSettingsController
@synthesize topLevelController;

#define PlexPluginVersion @"0.7.1b4"

#define ServersIndex 0
#define QualitySettingIndex 1
#define ViewTypeSettingIndex 2
#define AudioSettingsIndex 3
#define AdvancedSettingsIndex 4
#define PluginVersionNumberIndex 5


#pragma mark -
#pragma mark Object/Class Lifecycle
- (id) init {
	if((self = [super init]) != nil) {
		topLevelController = nil;
		[self setLabel:@"Plex Settings"];
		[self setListTitle:@"Plex Settings"];
		
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
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:YES];
	[topLevelController reloadCategories];
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
	
	// =========== servers ===========
	SMFMenuItem *serversMenuItem = [SMFMenuItem folderMenuItem];
	[serversMenuItem setTitle:@"Manage server list"];
	[_items addObject:serversMenuItem];
	
	
	// =========== quality setting ===========
	SMFMenuItem *qualitySettingMenuItem = [SMFMenuItem menuItem];
	
	NSString *qualitySetting = [[HWUserDefaults preferences] objectForKey:PreferencesQualitySetting];
	if (qualitySetting == nil) {
		[[HWUserDefaults preferences] setObject:@"Better" forKey:PreferencesQualitySetting];
		qualitySetting = [[HWUserDefaults preferences] objectForKey:PreferencesQualitySetting];
	}
	
	NSString *qualitySettingTitle = [[NSString alloc] initWithFormat:@"Quality Setting:   %@", qualitySetting];
	[qualitySettingMenuItem setTitle:qualitySettingTitle];
	[qualitySettingTitle release];
	[_items addObject:qualitySettingMenuItem];
	

  	// =========== view type setting ===========
	SMFMenuItem *viewTypeSettingMenuItem = [SMFMenuItem menuItem];
	
	NSString *viewTypeSetting = [[HWUserDefaults preferences] objectForKey:PreferencesViewTypeSetting];
	if (viewTypeSetting == nil) {
		[[HWUserDefaults preferences] setObject:@"Grid" forKey:PreferencesViewTypeSetting];
		viewTypeSetting = [[HWUserDefaults preferences] objectForKey:PreferencesViewTypeSetting];
	}
	
	NSString *viewTypeSettingTitle = [[NSString alloc] initWithFormat:@"Video view:   %@", viewTypeSetting];
	[viewTypeSettingMenuItem setTitle:viewTypeSettingTitle];
	[viewTypeSettingTitle release];
	[_items addObject:viewTypeSettingMenuItem];
	
  // =========== audio settings ===========
	SMFMenuItem *audioSettingsMenuItem = [SMFMenuItem folderMenuItem];
	[audioSettingsMenuItem setTitle:@"Audio settings"];
	[_items addObject:audioSettingsMenuItem];
  
	// =========== advanced settings ===========
	SMFMenuItem *advancedSettingsMenuItem = [SMFMenuItem folderMenuItem];
	[advancedSettingsMenuItem setTitle:@"Advanced settings"];
	[_items addObject:advancedSettingsMenuItem];
	
	// =========== version number ===========
	SMFMenuItem *pluginVersionNumberMenuItem = [SMFMenuItem menuItem];
	
	NSString *pluginVersionNumber = PlexPluginVersion;
	NSString *pluginVersionNumberTitle = [[NSString alloc] initWithFormat:@"Version:   %@", pluginVersionNumber];
	[pluginVersionNumberMenuItem setTitle:pluginVersionNumberTitle];
	[pluginVersionNumberTitle release];
	[_items addObject:pluginVersionNumberMenuItem];
	
	//this code can be used to find all the accessory types
//	for (int i = 0; i<32; i++) {
//		BRMenuItem *tempSettingMenuItem = [[BRMenuItem alloc] init];
//		[tempSettingMenuItem addAccessoryOfType:i];
//		
//		NSString *tempSettingTitle = [[NSString alloc] initWithFormat:@"temp %d", i];
//		[tempSettingMenuItem setText:tempSettingTitle withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
//		[tempSettingTitle release];
//		[_items addObject:tempSettingMenuItem];
//	}
}

#pragma mark -
#pragma mark List Delegate Methods
- (void)itemSelected:(long)selected {
	switch (selected) {
		case ServersIndex: {
			// =========== remote servers ===========
			HWServersController* menuController = [[HWServersController alloc] init];
			[[[BRApplicationStackManager singleton] stack] pushController:menuController];
			[menuController autorelease];
			break;
		}
		case QualitySettingIndex: {
			// =========== quality setting ===========
			NSString *qualitySetting = [[HWUserDefaults preferences] objectForKey:PreferencesQualitySetting];
			
			if ([qualitySetting isEqualToString:@"Good"]) {
				[[HWUserDefaults preferences] setObject:@"Better" forKey:PreferencesQualitySetting];
			} else if ([qualitySetting isEqualToString:@"Better"]) {
				[[HWUserDefaults preferences] setObject:@"Best" forKey:PreferencesQualitySetting];
			} else {
				[[HWUserDefaults preferences] setObject:@"Good" forKey:PreferencesQualitySetting];
			}
			
			[self setupList];
			[self.list reload];
			break;
		}
    case ViewTypeSettingIndex: {
        // =========== view type setting ===========
			NSString *viewTypeSetting = [[HWUserDefaults preferences] objectForKey:PreferencesViewTypeSetting];
			
			if ([viewTypeSetting isEqualToString:@"List"]) {
				[[HWUserDefaults preferences] setObject:@"Grid" forKey:PreferencesViewTypeSetting];
        DLog(@"changin view type to grid view");
			} else {
				[[HWUserDefaults preferences] setObject:@"List" forKey:PreferencesViewTypeSetting];
        DLog(@"changin view type to list view");
			}

      
			[self setupList];
			[self.list reload];      
      break;
    }
    case AudioSettingsIndex: {
			// =========== audio settings ===========
			PlexAudioSettingsController* menuController = [[PlexAudioSettingsController alloc] init];
			[[[BRApplicationStackManager singleton] stack] pushController:menuController];
			[menuController autorelease];
			break;
      
    }
		case AdvancedSettingsIndex: {
			// =========== advanced settings ===========
			HWAdvancedSettingsController* menuController = [[HWAdvancedSettingsController alloc] init];
			[[[BRApplicationStackManager singleton] stack] pushController:menuController];
			[menuController autorelease];
			break;
		}
		case PluginVersionNumberIndex: {
			//do nothing
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
		case ServersIndex: {
			// =========== servers ===========
			[asset setTitle:@"Manage server list"];
			[asset setSummary:@"Add new or modify current servers, their connections and their 'inclusion in main menu' status"];
			break;
		}
		case QualitySettingIndex: {
			// =========== quality setting ===========
			[asset setTitle:@"Select the video quality"];
			[asset setSummary:@"Sets the quality of the streamed video.                                        Good: 720p 1500 kbps, Better: 720p 2300 kbps, Best: 720p 4000 kbps"];
			break;
		}
		case ViewTypeSettingIndex: {
        // =========== view type setting ===========
			[asset setTitle:@"Select the video listing view type"];
			[asset setSummary:@"Sets the type of view for videos, choose between list view or grid view ie. cover art view."];
			break;
		}
		case AudioSettingsIndex: {
			// =========== audio settings ===========
			[asset setTitle:@"Modify audio output settings"];
			[asset setSummary:@"Setup the kind of multi-channel audio you want to output"];
			break;
		}
		case AdvancedSettingsIndex: {
			// =========== advanced settings ===========
			[asset setTitle:@"Modify advanced settings"];
			[asset setSummary:@"Alter UI behavior, enable debug mode, etc."];
			break;
		}
		case PluginVersionNumberIndex: {
			// =========== quality setting ===========
			[asset setTitle:@"Credit to:"];
			[asset setSummary:@"quequick, b0bben and ccjensen"];
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
