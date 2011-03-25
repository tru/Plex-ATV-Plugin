//
//  HWAdvancedSettingsController.m
//  atvTwo
//
//  Created by bob on 10/01/2011.
//
//  Inspired by 
//
//		MLoader.m
//		MextLoader
//
//		Created by Thomas Cool on 10/22/10.
//		Copyright 2010 tomcool.org. All rights reserved.
//

#import "PlexAudioSettingsController.h"
#import "HWUserDefaults.h"
#import "Constants.h"

@implementation PlexAudioSettingsController

#define EnableAC3 0
#define EnableDTS 1

#pragma mark -
#pragma mark Object/Class Lifecycle
- (id) init {
	if((self = [super init]) != nil) {
		[self setLabel:@"Plex Audio Settings"];
		[self setListTitle:@"Plex Audio Settings"];
		
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
	
	// =========== enable ac3 ===========
	SMFMenuItem *ac3MenuItem = [SMFMenuItem menuItem];
	
	NSString *ac3Options = [[HWUserDefaults preferences] boolForKey:PreferencesAudioEnableAC3] ? @"Yes" : @"No";
	NSString *ac3OptionsTitle = [[NSString alloc] initWithFormat:@"Dolby™ AC3 capable receiver: %@", ac3Options];
	[ac3MenuItem setTitle:ac3OptionsTitle];
	[ac3OptionsTitle release];
	[_items addObject:ac3MenuItem];
	
	
	// =========== enable dts ===========
	SMFMenuItem *dtsMenuItem = [SMFMenuItem menuItem];
	
	NSString *dtsOptions = [[HWUserDefaults preferences] boolForKey:PreferencesAudioEnableDTS] ? @"Yes" : @"No";
	NSString *dtsOptionsTitle = [[NSString alloc] initWithFormat:@"DTS™ capable receiver:      %@", dtsOptions];
	[dtsMenuItem setTitle:dtsOptionsTitle];
	[dtsOptionsTitle release];
	[_items addObject:dtsMenuItem];
}


#pragma mark -
#pragma mark List Delegate Methods
- (void)itemSelected:(long)selected {
	switch (selected) {
		case EnableAC3: {
			// =========== enable ac3 menu ===========
			BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesAudioEnableAC3];
			[[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesAudioEnableAC3];			
			[self setupList];
			[self.list reload];
			break;
		}
		case EnableDTS: {
			// =========== enable dts ===========
			BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesAudioEnableDTS];
			[[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesAudioEnableDTS];			
			[self setupList];
			[self.list reload];
			break;
		}
		default:
			break;
	}
  
  //re-send the caps to the PMS
  [HWUserDefaults setupPlexClientCapabilities];
}


-(id)previewControlForItem:(long)item
{
	SMFBaseAsset *asset = [[SMFBaseAsset alloc] init];
	switch (item) {
		case EnableAC3: {
			// =========== enable ac3 menu ===========
			[asset setTitle:@"Toggles whether you want AC3 sound output or not"];
			[asset setSummary:@"Enables your AppleTV to receive AC3 sound when available in your videos"];
			break;
		}
		case EnableDTS: {	
			// =========== enable dts ===========
			[asset setTitle:@"Toggles whether you want DTS sound output or not"];
			[asset setSummary:@"Enables your AppleTV to receive DTS sound when available in your videos"];
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
