//
//  PlexChannelsController.m
//  plex
//
//  Created by Serendipity on 13/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlexChannelsController.h"
#import "Constants.h"
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexImage.h>
#import <plex-oss/PlexRequest.h>
#import <plex-oss/Preferences.h>
#import "PlexMediaProvider.h"
#import "PlexMediaAsset.h"
#import "PlexMediaAssetOld.h"
#import "PlexPreviewAsset.h"
#import "PlexSongAsset.h"
#import "SongListController.h"
#import "HWUserDefaults.h"
#import "HWMediaGridController.h"
#import "HWDetailedMovieMetadataController.h"
#import "PlexPlaybackController.h"

#define LOCAL_DEBUG_ENABLED 1

@implementation PlexChannelsController
@synthesize rootContainer;


#pragma mark -
#pragma mark Object/Class Lifecycle
- (id) init
{
	if((self = [super init]) != nil) {
		[self setListTitle:@"PLEX"];
		
		NSString *settingsPng = [[NSBundle bundleForClass:[HWPlexDir class]] pathForResource:@"PlexIcon" ofType:@"png"];
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
			if([event value] == 1) {
				//get the index of currently selected row
				long selected = [self getSelection];
				[self showModifyViewedStatusViewForRow:selected];
			}
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
	
	NSString* type = [pmo.attributes objectForKey:@"type"];
	if ([type empty]) type = pmo.containerType;
	type = [type lowercaseString];
    
    NSString *viewTypeSetting = [[HWUserDefaults preferences] objectForKey:PreferencesViewTypeSetting];
	
	DLog(@"Item Selected: %@, type:%@", pmo.debugSummary, type);
	
	DLog(@"viewgroup: %@, viewmode:%@",pmo.mediaContainer.viewGroup, pmo.containerType);
	
	if ([PlexViewGroupAlbum isEqualToString:pmo.mediaContainer.viewGroup] || [@"albums" isEqualToString:pmo.mediaContainer.content] || [@"playlists" isEqualToString:pmo.mediaContainer.content]) {
		DLog(@"Accessing Artist/Album %@", pmo);
		SongListController *songlist = [[SongListController alloc] initWithPlexContainer:[pmo contents] title:pmo.name];
		[[[BRApplicationStackManager singleton] stack] pushController:songlist];
		[songlist autorelease];
	}
	else if (pmo.hasMedia || [@"Video" isEqualToString:pmo.containerType] || [@"Track" isEqualToString:pmo.containerType]){
#if LOCAL_DEBUG_ENABLED
		DLog(@"got some media, switching to PlexPlaybackController");
#endif
		PlexPlaybackController *player = [[PlexPlaybackController alloc] initWithPlexMediaObject:pmo];
		//[player startPlaying];
		[[[BRApplicationStackManager singleton] stack] pushController:player];
        [player autorelease];
	}
    else if ([@"movie" isEqualToString:type] && [viewTypeSetting isEqualToString:@"Grid"]) {
		[self showGridListControl:[pmo contents]];
	}
	else 
    {
		HWPlexDir* menuController = [[HWPlexDir alloc] initWithRootContainer:[pmo contents]];
		[[[BRApplicationStackManager singleton] stack] pushController:menuController];
		
		[menuController autorelease];
	}
}


- (float)heightForRow:(long)row {	
	float height;
	
	PlexMediaObject *pmo = [rootContainer.directories objectAtIndex:row];
	if (pmo.hasMedia || [@"Video" isEqualToString:pmo.containerType]) {
		height = 70.0f;
	} else {
		height = 0.0f;
	}
	return height;
}

- (long)itemCount {
	return [rootContainer.directories count];
}

- (id)itemForRow:(long)row {
	if(row > [rootContainer.directories count])
		return nil;
	
	id result;
	
	PlexMediaObject *pmo = [rootContainer.directories objectAtIndex:row];
	NSString *mediaType = [pmo.attributes valueForKey:@"type"];
    
	if (pmo.hasMedia || [@"Video" isEqualToString:mediaType]) {
		BRMenuItem *menuItem = [[NSClassFromString(@"BRPlayButtonEnabledMenuItem") alloc] init];
        
		if ([pmo seenState] == PlexMediaObjectSeenStateUnseen) {
            [menuItem setImage:[[BRThemeInfo sharedTheme] unplayedVideoImage]];
		} else if ([pmo seenState] == PlexMediaObjectSeenStateInProgress) {
            [menuItem setImage:[[BRThemeInfo sharedTheme] partiallyplayedVideoImage]];
		} else {
            //image will be invisible, but we need it to get the text to line up with ones who have a
            //visible image
			[menuItem setImage:[[BRThemeInfo sharedTheme] partiallyplayedVideoImage]];
            BRImageControl *imageControl = [menuItem valueForKey:@"_imageControl"];
            [imageControl setHidden:YES];
		}
        [menuItem setImageAspectRatio:0.5];
		
        [menuItem setText:[pmo name] withAttributes:nil];
		//used to get details about the show, instead of gettings attrs here manually
		PlexPreviewAsset *previewData = [[PlexPreviewAsset alloc] initWithURL:nil mediaProvider:nil mediaObject:pmo];
		if ([mediaType isEqualToString:PlexMediaObjectTypeEpisode]) {
            NSString *detailedText = [NSString stringWithFormat:@"%@, Season %d, Episode %d",[previewData seriesName] ,[previewData season],[previewData episode]];
			[menuItem setDetailedText:detailedText withAttributes:nil];
            [menuItem setRightJustifiedText:[previewData datePublishedString] withAttributes:nil];
		} else {
            NSString *detailedText = previewData.year ? previewData.year : @" ";
			[menuItem setDetailedText:detailedText withAttributes:nil];
            if ([previewData isHD]) {
                [menuItem addAccessoryOfType:11];
            }
		}
		[previewData release];
		
		result = [menuItem autorelease];
	} else {
		BRMenuItem * menuItem = [[BRMenuItem alloc] init];
		
		if ([mediaType isEqualToString:PlexMediaObjectTypeShow] || [mediaType isEqualToString:PlexMediaObjectTypeSeason]) {
			if ([pmo.attributes valueForKey:@"agent"] == nil) {
				if ([pmo seenState] == PlexMediaObjectSeenStateUnseen) {
					[menuItem addAccessoryOfType:15];
				} else if ([pmo seenState] == PlexMediaObjectSeenStateInProgress) {
					[menuItem addAccessoryOfType:16];
				}
			}
		}
		
		[menuItem setText:[pmo name] withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
		
		[menuItem addAccessoryOfType:1];
		result = [menuItem autorelease];
	}
	return result;
}

- (BOOL)rowSelectable:(long)selectable {
	return TRUE;
}

- (id)titleForRow:(long)row {
	PlexMediaObject *pmo = [rootContainer.directories objectAtIndex:row];
	return pmo.name;
}

@end
