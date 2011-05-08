//
//  PlexAudioSettingsController.m
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

#import "PlexPlaybackSettingsController.h"
#import "HWUserDefaults.h"
#import "Constants.h"

@implementation PlexPlaybackSettingsController

//----------- audio -----------
#define AudioEnableAC3Index  0
#define AudioEnableDTSIndex  1
//----------- video -----------
#define VideoQualityIndex    2
#define VideoBitrateIndex    3

#pragma mark -
#pragma mark Object/Class Lifecycle
- (id) init {
	if((self = [super init]) != nil) {
		[self setLabel:@"Plex Playback Settings"];
		[self setListTitle:@"Plex Playback Settings"];
		
		[self setupList];
        
        [[self list] addDividerAtIndex:0 withLabel:@"Audio"];
        [[self list] addDividerAtIndex:2 withLabel:@"Video"];
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
	
    // =========== AUDIO SETTINGS ===========
	// =========== enable ac3 ===========
	SMFMenuItem *ac3MenuItem = [SMFMenuItem menuItem];
	
	[ac3MenuItem setTitle:@"Dolby™ AC3 capable receiver"];
	NSString *ac3Options = [[HWUserDefaults preferences] boolForKey:PreferencesPlaybackAudioEnableAC3] ? @"Yes" : @"No";
    [ac3MenuItem setRightText:ac3Options];
	[_items addObject:ac3MenuItem];
	
	
	// =========== enable dts ===========
	SMFMenuItem *dtsMenuItem = [SMFMenuItem menuItem];
	
   	[dtsMenuItem setTitle:@"DTS™ capable receiver"];
	NSString *dtsOptions = [[HWUserDefaults preferences] boolForKey:PreferencesPlaybackAudioEnableDTS] ? @"Yes" : @"No";
    [dtsMenuItem setRightText:dtsOptions];
	[_items addObject:dtsMenuItem];
    

    
    // =========== VIDEO SETTINGS ===========
	// =========== quality setting ===========
	SMFMenuItem *qualitySettingMenuItem = [SMFMenuItem menuItem];
	
	[qualitySettingMenuItem setTitle:@"Quality Setting"];
    NSString *qualitySetting = [[HWUserDefaults preferences] objectForKey:PreferencesPlaybackVideoQuality];	
    if (!qualitySetting) {
        NSString *defaultSetting = [[HWUserDefaults defaultValues] objectForKey:PreferencesPlaybackVideoQuality];
        [[HWUserDefaults preferences] setObject:defaultSetting forKey:PreferencesPlaybackVideoQuality];
        qualitySetting = [[HWUserDefaults preferences] objectForKey:PreferencesPlaybackVideoQuality];
    }
    [qualitySettingMenuItem setRightText:qualitySetting];
	[_items addObject:qualitySettingMenuItem];
    
    
    // =========== bitrate setting ===========
	SMFMenuItem *bitrateSettingMenuItem = [SMFMenuItem menuItem];
	
	[bitrateSettingMenuItem setTitle:@"Quality Setting"];
	float bitrate = [[HWUserDefaults preferences] floatForKey:PreferencesPlaybackVideoBitrate];
    if (bitrate < 0.5) {
        float defaultSetting = 12.0f;
        [[HWUserDefaults preferences] setFloat:defaultSetting forKey:PreferencesPlaybackVideoBitrate];
        bitrate = [[HWUserDefaults preferences] floatForKey:PreferencesPlaybackVideoBitrate];
    }
    [bitrateSettingMenuItem setRightText:[NSString stringWithFormat:@"%2.1f Mbps", bitrate]];
	[_items addObject:bitrateSettingMenuItem];
}


#pragma mark -
#pragma mark List Delegate Methods
- (void)itemSelected:(long)selected {
	switch (selected) {
		case AudioEnableAC3Index: {
			// =========== enable ac3 menu ===========
			BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesPlaybackAudioEnableAC3];
			[[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesPlaybackAudioEnableAC3];			
			[self setupList];
			[self.list reload];
			break;
		}
		case AudioEnableDTSIndex: {
			// =========== enable dts ===========
			BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesPlaybackAudioEnableDTS];
			[[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesPlaybackAudioEnableDTS];			
			[self setupList];
			[self.list reload];
			break;
		}
		case VideoQualityIndex: {
			NSString *qualitySetting = [[HWUserDefaults preferences] objectForKey:PreferencesPlaybackVideoQuality];
			
			if ([qualitySetting isEqualToString:@"Good"]) {
				qualitySetting = @"Better";
			} else if ([qualitySetting isEqualToString:@"Better"]) {
				qualitySetting = @"Best";
			} else {
				qualitySetting = @"Good";
			}
            [[HWUserDefaults preferences] setObject:qualitySetting forKey:PreferencesPlaybackVideoQuality];
			
			[self setupList];
			[self.list reload];
			break;
		}
		case VideoBitrateIndex: {
			float bitrate = [[HWUserDefaults preferences] floatForKey:PreferencesPlaybackVideoBitrate];
			float maxBitrate = 12.0f;
            if (bitrate == maxBitrate) {
                bitrate = 0.5;
            } else {
                bitrate += 0.5;
            }
            [[HWUserDefaults preferences] setFloat:bitrate forKey:PreferencesPlaybackVideoBitrate];
			
			[self setupList];
			[self.list reload];
			break;
		}
		default:
			break;
	}
  
  //re-send the caps to the PMS
  [HWUserDefaults setupPlexClient];
}


-(id)previewControlForItem:(long)item
{
	SMFBaseAsset *asset = [[SMFBaseAsset alloc] init];
	switch (item) {
		case AudioEnableAC3Index: {
			[asset setTitle:@"Toggles whether you want AC3 sound output or not"];
			[asset setSummary:@"Enables your AppleTV to receive AC3 sound when available in your videos"];
			break;
		}
		case AudioEnableDTSIndex: {	
			[asset setTitle:@"Toggles whether you want DTS sound output or not"];
			[asset setSummary:@"Enables your AppleTV to receive DTS sound when available in your videos"];
			break;
		}
		case VideoQualityIndex: {
			[asset setTitle:@"Select the video quality"];
			[asset setSummary:@"Sets the quality of the streamed video.                                        Good: 720p 1500 kbps, Better: 720p 4000 kbps, Best: 1080p 10Mbps"];
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
