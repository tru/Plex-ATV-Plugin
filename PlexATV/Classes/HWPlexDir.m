//
//  HWPlexDir.m
//  atvTwo
//
//  Created by Frank Bauer on 22.10.10.
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  

#import "HWPlexDir.h"
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
#import "HWUserDefaults.h"
#import "PlexPlaybackController.h"
#import "PlexNavigationController.h"

#define LOCAL_DEBUG_ENABLED 1
#define ModifyViewStatusOptionDialog @"ModifyViewStatusOptionDialog"

@implementation HWPlexDir
@synthesize rootContainer;
@synthesize tabBar;
@synthesize items;

#pragma mark -
#pragma mark Object/Class Lifecycle

- (id)init {
    self = [super init];
    if (self) {
        [self setListTitle:@"PLEX"];
		
		NSString *plexIcon = [[NSBundle bundleForClass:[HWPlexDir class]] pathForResource:@"PlexIcon" ofType:@"png"];
		BRImage *listIcon = [BRImage imageWithPath:plexIcon];
		[self setListIcon:listIcon horizontalOffset:0.0 kerningFactor:0.15];
        
		rootContainer = nil;        
        [self.list setDatasource:self];
    }
    return self;
}

- (id)initWithRootContainer:(PlexMediaContainer*)container andTabBar:(BRTabControl *)aTabBar {
	self = [self init];
	self.rootContainer = container;
    self.listTitle = self.rootContainer.name;
    self.items = [self.rootContainer directories];
    self.tabBar = aTabBar;
    if (self.tabBar) {
        [self.tabBar setAcceptsFocus:NO];
        [self.tabBar setTabControlDelegate:self];
        [self addControl:self.tabBar];
    }
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
    [tabBar release];
    [items release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Controller Lifecycle behaviour
- (void)wasPushed {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
	[super wasPushed];
}

- (void)wasPopped {
  BRMediaPlayer *player = [[BRMediaPlayerManager singleton] activeAudioPlayer];
  [player setState:kBRMediaPlayerStateStopped error:nil];
	[super wasPopped];
}

- (void)wasExhumed {
	[[MachineManager sharedMachineManager] setMachineStateMonitorPriority:NO];
    
    //refresh scope bar in case any items have changed
    [self reselectCurrentTabBarItem];
	[super wasExhumed];
}

- (void)wasBuried {
	[super wasBuried];
}

-(void)controlWasActivated
{
	DLog(@"%@",self.rootContainer.viewGroup);
  DLog(@"%@",[self.rootContainer.attributes valueForKey:@"theme"]);
  if ([self.rootContainer.attributes valueForKey:@"theme"] != nil){
    NSString *themeUrlAsString = [self.rootContainer.request buildAbsoluteKey: [self.rootContainer.attributes valueForKey:@"theme"]];

    NSURL *themeUrl = [NSURL URLWithString:themeUrlAsString];
    DLog(@"themeUrl: %@",themeUrl);
    
    NSError *error;
    PlexSongAsset *psa = [[PlexSongAsset alloc] initWithURL:themeUrl mediaProvider:nil mediaObject:[self.rootContainer.directories objectAtIndex:0]];

    BRMediaPlayerManager* mgm = [BRMediaPlayerManager singleton];
    BRMediaPlayer *playa = [mgm playerForMediaAsset:psa error:&error];
    
    mgm.autoPresentTimeout = 0;
    playa.repeatMode = 1;
    [playa cueMediaWithError:nil];
    [self performSelector:@selector(startPlayingThemeMusic) withObject:nil afterDelay:5.0];   
  }
 	[super controlWasActivated];
	
}

-(void)startPlayingThemeMusic {
  DLog();
  BRMediaPlayer *player = [[BRMediaPlayerManager singleton] activeAudioPlayer];
  [player setState:kBRMediaPlayerStatePlaying error:nil];
}

#pragma mark -
#pragma mark Controller Drawing and Events
-(void)layoutSubcontrols {
    [super layoutSubcontrols];
    
    if (self.tabBar) {
        //if there is a tab bar, move the list down to make room for it
        //thanks to tom for the layout code
        CGRect listFrame = [self list].frame;
        listFrame.size.height = 550.0f;
        listFrame.size.width = listFrame.size.width; //don't change the width
        listFrame.origin.x = listFrame.origin.x;
        id l = [self list];
        [l setFrame:listFrame];
        
        //tab bar same width as list
        [self.tabBar setFrame:CGRectMake(listFrame.origin.x, 567.f, listFrame.size.width, 25.f)];
    }
}

//handle custom event
-(BOOL)brEventAction:(BREvent *)event {
	int remoteAction = [event remoteAction];
	if ([(BRControllerStack *)[self stack] peekController] != self)
		remoteAction = 0;
	
	int listItemCount = [[(BRListControl *)[self list] datasource] itemCount];
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
            if([event value] == 1) {
                [self.tabBar selectPreviousTabItem];
                return YES;
            }
			break;
		case kBREventRemoteActionSwipeRight:
		case kBREventRemoteActionRight:
            if([event value] == 1) {
                [self.tabBar selectNextTabItem];
                return YES;
            }
			break;
		case kBREventRemoteActionPlayPause:
			DLog(@"play/pause event");
			if([event value] == 1) {
				[self playPauseActionForRow:[self getSelection]];
      }
			return YES;
			break;
		case kBREventRemoteActionUp:
		case kBREventRemoteActionHoldUp:
			if([self getSelection] == 0 && [event value] == 1)
			{
				[self setSelection:listItemCount-1];
				return YES;
			}
			break;
		case kBREventRemoteActionDown:
		case kBREventRemoteActionHoldDown:
			if([self getSelection] == listItemCount-1 && [event value] == 1)
			{
				[self setSelection:0];
				return YES;
			}
			break;
	}
	return [super brEventAction:event];
}


#pragma mark -
#pragma mark BRTabBarControllerDelegate Methods
- (void)tabControl:(id)control willSelectTabItem:(id)item {
    //nothing needed
}

- (void)tabControl:(id)control didSelectTabItem:(id)item {
    //change scope
    NSInteger newScopeSelection = [self.tabBar selectedTabItemIndex];

    NSArray *allItems = self.rootContainer.directories;    
    switch (newScopeSelection) {
        case ScopeBarCurrentItemsIndex: {
            self.items = allItems;
            break;
        }
        case ScopeBarUnwatchedItemsIndex: {
            NSPredicate *unwatchedItemsPredicate = [NSPredicate predicateWithFormat:@"seenState != %d", PlexMediaObjectSeenStateSeen];
            self.items = [allItems filteredArrayUsingPredicate:unwatchedItemsPredicate];
            break;
        }
        case ScopeBarOtherFiltersItemsIndex: {
            PlexMediaContainer *filters = (PlexMediaContainer *)[item identifier];
            self.items = filters.directories;
            break;
        }
    }
    [self.list reload];
}

- (void)tabControlDidChangeNumberOfTabItems:(id)tabControl {
    //not possible at this stage
}

- (void)reselectCurrentTabBarItem {
    //call the delegate methods to kick of a refresh of what items should be listed in the list
    [self tabControl:self.tabBar willSelectTabItem:[self.tabBar selectedTabItem]];
    [self tabControl:self.tabBar didSelectTabItem:[self.tabBar selectedTabItem]];
}

#pragma mark -
#pragma mark BRMenuListItemProvider Datasource
- (long)itemCount {
	return [self.items count];
}

- (float)heightForRow:(long)row {	
	float height;
	
	PlexMediaObject *pmo = [self.items objectAtIndex:row];
	if (pmo.hasMedia || [@"Video" isEqualToString:pmo.containerType]) {
		height = 70.0f;
	} else {
		height = 0.0f;
	}
	return height;
}

- (id)titleForRow:(long)row {
	PlexMediaObject *pmo = [self.items objectAtIndex:row];
	return pmo.name;
}

- (id)itemForRow:(long)row {
	if(row > [self.items count])
		return nil;
	
	id result;
	
	PlexMediaObject *pmo = [self.items objectAtIndex:row];
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
            NSString *detailedText = [NSString stringWithFormat:@"Season %d, Episode %d (%@)", [previewData season], [previewData episode], [previewData seriesName]];
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

- (id)previewControlForItem:(long)item {
    id preview = nil;
	PlexMediaObject* pmo = [self.items objectAtIndex:item];
    
#if LOCAL_DEBUG_ENABLED
	DLog(@"media object: %@", pmo);
#endif
    
    if ([tabBar selectedTabItemIndex] == ScopeBarOtherFiltersItemsIndex) {
        //cascading
        NSMutableArray *imageProxies = [NSMutableArray array];
        PlexMediaContainer *subItemsContainer = [pmo contents];
        NSArray *subItems = subItemsContainer.directories;
        
        for (PlexMediaObject *pmo in subItems) {
            NSURL* mediaURL = [pmo mediaStreamURL];
            PlexPreviewAsset* pma = [[PlexPreviewAsset alloc] initWithURL:mediaURL mediaProvider:nil mediaObject:pmo];
            [imageProxies addObject:[pma imageProxy]];
            [pma release];
        }   
        preview = [[BRMediaParadeControl alloc] init];
        [preview setImageProxies:imageProxies];
        
    } else {
        
        //single covert
        NSURL* mediaURL = [pmo mediaStreamURL];
        PlexPreviewAsset* pma = [[PlexPreviewAsset alloc] initWithURL:mediaURL mediaProvider:nil mediaObject:pmo];
        
        preview = [[BRMetadataPreviewControl alloc] init];
        [preview setShowsMetadataImmediately:[[HWUserDefaults preferences] boolForKey:PreferencesViewDisablePosterZoomingInListView]];
        [preview setAsset:pma];
        [pma release];
    }
	return [preview autorelease];
}

#pragma mark -
#pragma mark BRMenuListItemProvider Delegate
- (BOOL)rowSelectable:(long)selectable {
	return TRUE;
}

- (void)itemSelected:(long)selected; {
	PlexMediaObject* pmo = [self.items objectAtIndex:selected];
    [[PlexNavigationController sharedPlexNavigationController] navigateToObjectsContents:pmo];
}



#pragma mark -
#pragma mark Actions
- (void)showModifyViewedStatusViewForRow:(long)row {
    //get the currently selected row
	PlexMediaObject* pmo = [self.items objectAtIndex:row];
	NSString *plexMediaObjectType = [pmo.attributes valueForKey:@"type"];
	
	DLog(@"HERE: %@", plexMediaObjectType);
	
	if (pmo.hasMedia 
		|| [@"Video" isEqualToString:pmo.containerType]
		|| [@"show" isEqualToString:plexMediaObjectType]
		|| [@"season" isEqualToString:plexMediaObjectType]) {
		//show dialog box
		BROptionDialog *optionDialogBox = [[BROptionDialog alloc] init];
		[optionDialogBox setIdentifier:ModifyViewStatusOptionDialog];
		
		[optionDialogBox setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
									  pmo, @"mediaObject",
									  nil]];
		
		[optionDialogBox setPrimaryInfoText:@"Modify View Status"];
		[optionDialogBox setSecondaryInfoText:pmo.name];
		
		
		NSString *watchOption = nil;
		NSString *unwatchOption = nil;
		if (pmo.hasMedia || [@"Video" isEqualToString:pmo.containerType]) {
			//modify single media item
			watchOption = @"Mark as Watched";
			unwatchOption = @"Mark as Unwatched";
		} else if (!pmo.hasMedia && [@"show" isEqualToString:plexMediaObjectType]) {
			//modify all seasons within show
			watchOption = @"Mark entire show as Watched";
			unwatchOption = @"Mark entire show as Unwatched";
		} else if (!pmo.hasMedia && [@"season" isEqualToString:plexMediaObjectType]) {
			//modify all episodes within season
			watchOption = @"Mark entire season as Watched";
			unwatchOption = @"Mark entire season as Unwatched";
		}
		
		[optionDialogBox addOptionText:watchOption];
		[optionDialogBox addOptionText:unwatchOption];
		[optionDialogBox addOptionText:@"Go back"];
		[optionDialogBox setActionSelector:@selector(optionSelected:) target:self];
		[[self stack] pushController:optionDialogBox];
		[optionDialogBox autorelease];
	}
}

- (void)optionSelected:(id)sender {
	BROptionDialog *option = sender;
	PlexMediaObject *pmo = [option.userInfo objectForKey:@"mediaObject"];
	if ([option.identifier isEqualToString:ModifyViewStatusOptionDialog]) {		
		if([[sender selectedText] hasSuffix:@"Watched"]) {
			//mark item(s) as watched
			[[[BRApplicationStackManager singleton] stack] popController]; //need this so we don't go back to option dialog when going back
			DLog(@"Marking as watched: %@", pmo.name);
            [pmo markSeen];            
            [self reselectCurrentTabBarItem];
		} else if ([[sender selectedText] hasSuffix:@"Unwatched"]) {
			//mark item(s) as unwatched
			[[self stack] popController]; //need this so we don't go back to option dialog when going back
			DLog(@"Marking as unwatched: %@", pmo.name);
			[pmo markUnseen];
            [self reselectCurrentTabBarItem];
            //[self tabControlChangedTo:[self.tabBar selectedTabItemIndex]];
		} else if ([[sender selectedText] isEqualToString:@"Go back"]) {
			//go back to movie listing...
			[[[BRApplicationStackManager singleton] stack] popController];
		}
	}
}

@end
