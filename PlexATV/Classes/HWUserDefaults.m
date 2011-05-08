//
//  HWUserDefaults.m
//  atvTwo
//
//  Created by ccjensen on 24/01/2011.
//

#import "HWUserDefaults.h"
#import <plex-oss/PlexClientCapabilities.h>
#import <plex-oss/PlexRequest + Security.h>
#import "Constants.h"


@implementation HWUserDefaults
#pragma mark -
#pragma mark PlexPrefs Methods
-(void)removeValueForKey:(NSString *)key {
	[[HWUserDefaults preferences] removeObjectForKey:key];
}


- (id)objectForKey:(NSString*)key {
	return [[HWUserDefaults preferences] objectForKey:key];
}

- (void)setObject:(id)obj forKey:(NSString*)key {
	[[HWUserDefaults preferences] setObject:obj forKey:key];
}


- (NSInteger)integerForKey:(NSString*)key {
	return [[HWUserDefaults preferences] integerForKey:key];
}

- (void)setInteger:(NSInteger)v forKey:(NSString*)key {
	[[HWUserDefaults preferences] setInteger:v forKey:key];
}


-(BOOL)boolForKey:(NSString *)key {
    return [[HWUserDefaults preferences] boolForKey:key];
}

-(void)setBool:(BOOL)value forKey:(NSString *)key {
    [[HWUserDefaults preferences] setBool:value forKey:key];
}


-(double)doubleForKey:(NSString *)key {
    return [[HWUserDefaults preferences] doubleForKey:key];
}

-(void)setDouble:(double)value forKey:(NSString *)key {
    [[HWUserDefaults preferences] setDouble:value forKey:key];
}


-(float)floatForKey:(NSString *)key {
    return [[HWUserDefaults preferences] floatForKey:key];
}

-(void)setFloat:(float)value forKey:(NSString *)key {
    [[HWUserDefaults preferences] setFloat:value forKey:key];
}


#pragma mark -
#pragma mark User Defaults Methods

- (void)syncSettings {
	[[HWUserDefaults preferences] synchronize];
}

- (void)_setDefaults {}


+ (void)setupPlexClient {
    DLog(@"registering ourselves with the PMS");
    [PlexRequest setApplicationName:@"Plex-ATV" version:@"0.8"];
    
    DLog(@"setting up client caps");  
    BOOL wantsAC3 = [[HWUserDefaults preferences] boolForKey:PreferencesPlaybackAudioEnableAC3];
    BOOL wantsDTS = [[HWUserDefaults preferences] boolForKey:PreferencesPlaybackAudioEnableDTS];  
    
    //reset everything, we'll redo all that we need below
    [[PlexClientCapabilities sharedPlexClientCapabilities] resetCaps];
    
    if (wantsAC3) {
        DLog(@"wants AC3");
        [[PlexClientCapabilities sharedPlexClientCapabilities] setAudioDecoderForCodec:PlexClientDecoderName_AC3 bitrate:PlexClientBitrateAny channels:PlexClientAudioChannels_7_1Surround];
    } else {
        DLog(@"don't want AC3");
        [[PlexClientCapabilities sharedPlexClientCapabilities] removeAudioCodec:PlexClientDecoderName_AC3];
    }
    
    if (wantsDTS) {
        DLog(@"wants DTS");
        [[PlexClientCapabilities sharedPlexClientCapabilities] setAudioDecoderForCodec:PlexClientDecoderName_DTS bitrate:PlexClientBitrateAny channels:PlexClientAudioChannels_7_1Surround];
    } else {
        DLog(@"don't want DTS");
        [[PlexClientCapabilities sharedPlexClientCapabilities] removeAudioCodec:PlexClientDecoderName_DTS];
    }
    
    [[PlexClientCapabilities sharedPlexClientCapabilities] setAudioDecoderForCodec:PlexClientDecoderName_AAC bitrate:PlexClientBitrateAny channels:PlexClientAudioChannels_5_1Surround];
    
    [[PlexClientCapabilities sharedPlexClientCapabilities] supports:CLIENT_CAP_HTTP_LIVE_STREAMING];
    [[PlexClientCapabilities sharedPlexClientCapabilities] supports:CLIENT_CAP_720p_PLAYBACK];
    [[PlexClientCapabilities sharedPlexClientCapabilities] supports:CLIENT_CAP_HTTP_MP4_STREAMING];
    [[PlexClientCapabilities sharedPlexClientCapabilities] supports:CLIENT_CAP_DECODER_CAPS];
    
}

+ (NSDictionary *)defaultValues {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSArray array], PreferencesMachinesExcludedFromServerList,
            @"List", PreferencesViewTypeSetting,
            NO, PreferencesViewDisableThemeMusic,
            NO, PreferencesViewDisableFanartInDetailedMetadataView,
            NO, PreferencesViewEnableSkipFilteringOptionsMenu,
            NO, PreferencesViewDisablePosterZoomingInListView,
            NO, PreferencesPlaybackAudioEnableAC3,
            NO, PreferencesPlaybackAudioEnableDTS,
            @"Good", PreferencesPlaybackVideoQuality,
            12.0, PreferencesPlaybackVideoBitrate,
            0, PreferencesSecurityPasscode,
            NO, PreferencesSettingsEnableLock,
            nil];
}

+ (SMFPreferences *)preferences {
	static SMFPreferences *_preferences = nil;
    if(!_preferences) {
		//setup user preferences
        _preferences = [[SMFPreferences alloc] initWithPersistentDomainName:PreferencesDomain];		
		[_preferences registerDefaults:[HWUserDefaults defaultValues]];
        
    }
    return _preferences;
}
@end
