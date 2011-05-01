//
//  HWUserDefaults.h
//  atvTwo
//
//  Created by ccjensen on 24/01/2011.
//

#import <Foundation/Foundation.h>

@interface HWUserDefaults : PlexPrefs {}

+ (SMFPreferences *)preferences;
+ (void)setupPlexClient;

//plex prefs methods
-(void)setObject:(id)obj forKey:(NSString*)key;
-(id)objectForKey:(NSString*)key;
-(void)setInteger:(NSInteger)v forKey:(NSString*)key;
-(NSInteger)integerForKey:(NSString*)key;
-(void)syncSettings;
-(void)_setDefaults;

@end
