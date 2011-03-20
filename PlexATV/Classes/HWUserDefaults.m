//
//  HWUserDefaults.m
//  atvTwo
//
//  Created by ccjensen on 24/01/2011.
//

#import "HWUserDefaults.h"
#import "Constants.h"


@implementation HWUserDefaults
#pragma mark -
#pragma mark PlexPrefs Methods
- (void)setObject:(id)obj forKey:(NSString*)key {
	[[HWUserDefaults preferences] setObject:obj forKey:key];
}

- (id)objectForKey:(NSString*)key {
	return [[HWUserDefaults preferences] objectForKey:key];
}

- (void)setInteger:(NSInteger)v forKey:(NSString*)key {
	[[HWUserDefaults preferences] setInteger:v forKey:key];
}

- (NSInteger)integerForKey:(NSString*)key {
	return [[HWUserDefaults preferences] integerForKey:key];
}

- (void)syncSettings {
	[[HWUserDefaults preferences] synchronize];
}

- (void)_setDefaults {}


#pragma mark -
#pragma mark User Defaults Methods

+ (SMFPreferences *)preferences {
	static SMFPreferences *_preferences = nil;
    if(!_preferences) {
		//setup user preferences
        _preferences = [[SMFPreferences alloc] initWithPersistentDomainName:PreferencesDomain];		
		[_preferences registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
										[NSArray array], PreferencesMachinesExcludedFromServerList,
										@"Low", PreferencesQualitySetting,
										@"Grid", PreferencesViewTypeSetting,
										NO, PreferencesAdvancedEnableSkipFilteringOptionsMenu,
										NO, PreferencesAdvancedEnableDebug,
										nil]];
    }
    return _preferences;
}
@end
