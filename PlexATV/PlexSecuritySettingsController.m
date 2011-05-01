//
//  PlexSecuritySettingsController.m
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

#import "PlexSecuritySettingsController.h"
#import "HWUserDefaults.h"
#import "Constants.h"

@implementation PlexSecuritySettingsController

#define SetSecurityPasscode 0
#define EnableSettingsLock 1

#pragma mark -
#pragma mark Object/Class Lifecycle
- (id) init {
	if((self = [super init]) != nil) {
		[self setLabel:@"Plex Security Settings"];
		[self setListTitle:@"Plex Security Settings"];
		
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
	
	// =========== set security passcode ===========
	SMFMenuItem *securityPasscodeMenuItem = [SMFMenuItem folderMenuItem];
	
	NSInteger securityPasscode = [[HWUserDefaults preferences] integerForKey:PreferencesSecurityPasscode];
	NSString *securityPasscodeTitle = [[NSString alloc] initWithFormat:@"Security Passcode:    %04d", securityPasscode];
	[securityPasscodeMenuItem setTitle:securityPasscodeTitle];
	[securityPasscodeTitle release];
	[_items addObject:securityPasscodeMenuItem];
	
	
	// =========== enable settings lock ===========
	SMFMenuItem *settingsLockMenuItem = [SMFMenuItem menuItem];
	
	NSString *settingsLockOptions = [[HWUserDefaults preferences] boolForKey:PreferencesSettingsEnableLock] ? @"Yes" : @"No";
	NSString *settingsLockOptionsTitle = [[NSString alloc] initWithFormat:@"Security Locked:        %@", settingsLockOptions];
	[settingsLockMenuItem setTitle:settingsLockOptionsTitle];
	[settingsLockOptionsTitle release];
	[_items addObject:settingsLockMenuItem];
}


#pragma mark -
#pragma mark List Delegate Methods
- (void)itemSelected:(long)selected {
	switch (selected) {
		case SetSecurityPasscode: {
			// =========== set security passcode ===========            
            SMFPasscodeController *passcodeController = [SMFPasscodeController passcodeWithTitle:@"Security Passcode" 
                                                                                 withDescription:@"Please Select Plex's Security Passcode"
                                                                                       withBoxes:4 
                                                                                    withDelegate:self];
            NSInteger securityPasscode = [[HWUserDefaults preferences] integerForKey:PreferencesSecurityPasscode];
            [passcodeController setInitialValue:securityPasscode];
            [[[BRApplicationStackManager sharedInstance] stack] pushController:passcodeController];
            break;
			break;
		}
		case EnableSettingsLock: {
			// =========== enable settings lock ===========
			BOOL isTurnedOn = [[HWUserDefaults preferences] boolForKey:PreferencesSettingsEnableLock];
			[[HWUserDefaults preferences] setBool:!isTurnedOn forKey:PreferencesSettingsEnableLock];
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


-(id)previewControlForItem:(long)item {
	SMFBaseAsset *asset = [[SMFBaseAsset alloc] init];
	switch (item) {
		case SetSecurityPasscode: {
			// =========== set security passcode ===========
			[asset setTitle:@"Set a custom security passcode"];
			[asset setSummary:@"Lets you customize the plex passcode for any locked screens"];
			break;
		}
		case EnableSettingsLock: {	
			// =========== enable settings lock ===========
			[asset setTitle:@"Toggles the Settings lock"];
			[asset setSummary:@"Locks the settings menu option using the security passcode"];
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


#pragma mark -
#pragma mark SMFPasscodeControllerDelegate methods
- (void)textDidChange:(id)sender {}

- (void)textDidEndEditing:(id)sender {
    NSInteger newPasscode = [[sender stringValue] intValue];
    [[HWUserDefaults preferences] setInteger:newPasscode forKey:PreferencesSecurityPasscode];
    [self.list reload];
    [[[BRApplicationStackManager sharedInstance] stack] popController];	
}


@end
