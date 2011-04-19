//
//  PlexChannelsController.m
//  plex
//
//  Created by ccjensen on 13/04/2011.
//

#import "PlexChannelsController.h"
#import "Constants.h"
#import <plex-oss/PlexRequest.h>
#import "PlexPreviewAsset.h"
#import "PlexPreviewAsset.h"
#import "HWPlexDir.h"
#import "HWUserDefaults.h"

#define LOCAL_DEBUG_ENABLED 1

@implementation PlexChannelsController
@synthesize rootContainer;


#pragma mark -
#pragma mark Object/Class Lifecycle
- (id) init
{
	if((self = [super init]) != nil) {
		[self setListTitle:@"PLEX"];
		
		NSString *settingsPng = [[NSBundle bundleForClass:[PlexChannelsController class]] pathForResource:@"PlexIcon" ofType:@"png"];
		BRImage *sp = [BRImage imageWithPath:settingsPng];
		
		[self setListIcon:sp horizontalOffset:0.0 kerningFactor:0.15];
		
		rootContainer = nil;
		[[self list] setDatasource:self];
		return ( self );
		
	}
	
	return ( self );
}

- (id) initWithRootContainer:(PlexMediaContainer*)container {
	self = [self init];
	self.rootContainer = container;
	return self;
}

- (void)log:(NSNotificationCenter *)note {
	DLog(@"note = %@", note);
}

-(void)dealloc
{
	DLog(@"deallocing HWPlexDir");
	[playbackItem release];
	[rootContainer release];
	
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
    [self.list reload];
	[super wasExhumed];
}

- (void)wasBuried {
	[super wasBuried];
}


//handle custom event
-(BOOL)brEventAction:(BREvent *)event
{
	int remoteAction = [event remoteAction];
	if ([(BRControllerStack *)[self stack] peekController] != self)
		remoteAction = 0;
	
	int itemCount = [[(BRListControl *)[self list] datasource] itemCount];
	switch (remoteAction)
	{
		case kBREventRemoteActionSelectHold: {
            return YES;
			break;
		}
		case kBREventRemoteActionSwipeLeft:
		case kBREventRemoteActionLeft:
			return YES;
			break;
		case kBREventRemoteActionSwipeRight:
		case kBREventRemoteActionRight:
			return YES;
			break;
		case kBREventRemoteActionPlayPause:
			DLog(@"play/pause event");
			if([event value] == 1)
				[self playPauseActionForRow:[self getSelection]];
			
			
			return YES;
			break;
		case kBREventRemoteActionUp:
		case kBREventRemoteActionHoldUp:
			if([self getSelection] == 0 && [event value] == 1)
			{
				[self setSelection:itemCount-1];
				return YES;
			}
			break;
		case kBREventRemoteActionDown:
		case kBREventRemoteActionHoldDown:
			if([self getSelection] == itemCount-1 && [event value] == 1)
			{
				[self setSelection:0];
				return YES;
			}
			break;
	}
	return [super brEventAction:event];
}

- (id)previewControlForItem:(long)item
{
    
	PlexMediaObject* pmo = [rootContainer.directories objectAtIndex:item];
    
#if LOCAL_DEBUG_ENABLED
	DLog(@"media object: %@", pmo);
#endif	
    
	NSURL* mediaURL = [pmo mediaStreamURL];
	PlexPreviewAsset* pma = [[PlexPreviewAsset alloc] initWithURL:mediaURL mediaProvider:nil mediaObject:pmo];
	BRMetadataPreviewControl *preview =[[BRMetadataPreviewControl alloc] init];
	[preview setShowsMetadataImmediately:[[HWUserDefaults preferences] boolForKey:PreferencesViewDisablePosterZoomingInListView]];
	[preview setAsset:pma];
    [pma release];
	
	return [preview autorelease];
}

#define ModifyViewStatusOptionDialog @"ModifyViewStatusOptionDialog"

- (void)itemSelected:(long)selected; {
	PlexMediaObject* pmo = [rootContainer.directories objectAtIndex:selected];
    PlexMediaContainer *channel = [pmo.request query:[pmo.attributes valueForKey:@"path"] callingObject:nil ignorePresets:YES timeout:20 cachePolicy:NSURLRequestUseProtocolCachePolicy];
    
    
    
	HWPlexDir* menuController = [[HWPlexDir alloc] initWithRootContainer:channel];
	[[[BRApplicationStackManager singleton] stack] pushController:menuController];
    
    [menuController autorelease];
}


- (float)heightForRow:(long)row {
	return 0.0f;
}

- (long)itemCount {
	return [rootContainer.directories count];
}

- (id)itemForRow:(long)row {
	if(row > [rootContainer.directories count])
		return nil;
	
	PlexMediaObject *pmo = [rootContainer.directories objectAtIndex:row];
    BRMenuItem *menuItem = [[BRMenuItem alloc] init];
    
    NSString *menuItemText = nil;
    NSString *path = [pmo.attributes valueForKey:@"path"];
    
    if ([path hasSuffix:@"iTunes"]) {
        NSString *type = nil;
        if ([path hasPrefix:@"/video"]) {
            type = @"video";
        } else {
            type = @"music";
        }
        menuItemText = [NSString stringWithFormat:@"%@ (%@)", [pmo name], type];
    } else {
        menuItemText = [pmo name];
    }
    
    [menuItem setText:menuItemText withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
    [menuItem addAccessoryOfType:1];
	return [menuItem autorelease];
}

- (BOOL)rowSelectable:(long)selectable {
	return TRUE;
}

- (id)titleForRow:(long)row {
	PlexMediaObject *pmo = [rootContainer.directories objectAtIndex:row];
	return pmo.name;
}

@end