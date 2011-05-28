//
//  PlexMoreInfoController.m
//  plex
//
//  Created by ccjensen on 5/26/11.
//

#import "PlexMoreInfoController.h"
#import "PlexMediaObject+Assets.h"
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import "PlexNavigationController.h"
#import "PlexPreviewAsset.h"

@implementation PlexMoreInfoController
@synthesize list, contentContainer, metadataTitleControl, gridControl;
@synthesize moreInfoContainer, mediaObject, items, menuItems;

#pragma mark -
#pragma mark Object/Class Lifecycle

- (id)initWithMoreInfoContainer:(PlexMediaContainer *)mediaContainer {
    self = [self init];
    if (self) {
        self.moreInfoContainer = mediaContainer;
        
        NSArray *mediaObjects = self.moreInfoContainer.directories;
        if ([mediaObjects count] == 1) {
            self.mediaObject = [mediaObjects objectAtIndex:0];
//            [self setupListForMediaObject:self.mediaObject];
        }
    }
    return self;
}

- (void)setupListForMediaObject:(PlexMediaObject *)aMediaObject {
    //possible contents: genre, writer, director, role (cast)
    
    NSMutableArray *newItems = [NSMutableArray array];
    NSMutableArray *newMenuItems = [NSMutableArray array];
    
    if (self.mediaObject) {
        PlexPreviewAsset *previewAsset = self.mediaObject.previewAsset;
        
        if ([[previewAsset cast] count] > 0) {
            //we have actors
            
        }
        
        if ([[previewAsset cast] count] > 0) {
            //we have genres/categories
        }
        
        if ([[previewAsset cast] count] > 0) {
            //we have directors
        }
        
        if ([[previewAsset cast] count] > 0) {
            //we have writers
        }
    }
    self.items = newItems;
    self.menuItems = menuItems;
}

-(void)dealloc {
    self.list = nil;
    self.contentContainer = nil;
    self.metadataTitleControl = nil;
    self.gridControl = nil;
    
    self.menuItems = nil;
    self.moreInfoContainer = nil;
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
	[super wasExhumed];
}

- (void)wasBuried {
	[super wasBuried];
}

- (void)controlWasActivated {
    [super controlWasActivated];
}


#pragma mark -
#pragma mark Controller Drawing and Events
- (void)layoutSubcontrols {
    [super layoutSubcontrols];
    
    /*
     - Left half: List Control      {origin:{x:39,y:0},size:{width:372,height:700}}
     - Right half: Panel Control    {origin:{x:395,y:0},size:{width:855,height:720}}
     -- Scroll Control              {origin:{x:0,y:0},size:{width:855,height:720}}
     --- Panel Control              {origin:{x:0,y:325},size:{width:855,height:395}}
     ---- Spacer                    {origin:{x:405,y:827},size:{width:44,height:44}}
     ---- Control                   {origin:{x:0,y:776},size:{width:855,height:51}}
     ----- Metadata Title Control   {origin:{x:51,y:0},size:{width:855,height:51}}
     ------ Title and Subtext
     ---- Spacer                    {origin:{x:418,y:758},size:{width:18,height:18}}
     ---- Grid                      {origin:{x:0,y:44},size:{width:855,height:714}}
     ---- Spacer                    {origin:{x:405,y:0},size:{width:44,height:44}}
     */
    
    
    //CGRect masterFrame = [BRWindow interfaceFrame];
	
    //============================ LIST ============================
    if (!self.list) {
        BRListControl *aListControl = [[BRListControl alloc] init];
        aListControl.frame = CGRectMake(39.0f, 0.0f, 372.0f, 700.0f);
        
        self.list = aListControl;
        [aListControl release];
        [self.list setDatasource:self];
        [self addControl:self.list];
    }
    
    
    //============================ PANEL CONTROL ============================
    if (!self.metadataTitleControl) {
        //============================ OUTER PANEL CONTROL ============================
        BRPanelControl *outerPanelControl = [[BRPanelControl alloc] init];
        outerPanelControl.panelMode = 1;
        outerPanelControl.frame = CGRectMake(395.0f, 0.0f, 855.0f, 720.0f);
        
        
        
        //============================ SCROLL CONTROL ============================
        BRScrollControl *aScrollControl = [[BRScrollControl alloc] init];
        aScrollControl.frame = CGRectMake(0.0f, 0.0f, 855.0f, 720.0f);
        
        
        
        //============================ INNER PANEL CONTROL ============================
        BRPanelControl *innerPanelControl = [[BRPanelControl alloc] init];
        innerPanelControl.panelMode = 1;
        innerPanelControl.frame = CGRectMake(395.0f, 0.0f, 855.0f, 395.0f);
        
        
        
        //============================ SPACER CONTROL ============================
        BRSpacerControl *spacerTop = [BRSpacerControl spacerWithPixels:44.0f];
        [innerPanelControl addControl:spacerTop];
        
        
        //============================ CONTROL ============================
        BRControl *metadataControl = [[BRControl alloc] init];
        metadataControl.frame = CGRectMake(0.0f, 776.0f, 855.0f, 51.0f);
        
        
        
        //============================ METADATA TITLE CONTROL ============================
        BRMetadataTitleControl *aMetadataTitleControl = [[BRMetadataTitleControl alloc] init];
        aMetadataTitleControl.frame = CGRectMake(51.0f, 0.0f, 855.0f, 51.0f);
        
        [metadataControl addControl:aMetadataTitleControl];
        self.metadataTitleControl = aMetadataTitleControl;
        [aMetadataTitleControl release];
        
        [innerPanelControl addControl:metadataControl];
        [metadataControl release];
        
        
        
        //============================ SPACER CONTROL ============================
        BRSpacerControl *spacerTitleGrid = [BRSpacerControl spacerWithPixels:18.0f];
        [innerPanelControl addControl:spacerTitleGrid];
        
        
        
        //============================ GRID CONTROL ============================
        BRGridControl *aGridControl = [[BRGridControl alloc] init];
        aGridControl.frame = CGRectMake(0.0f, 44.0f, 855.0f, 714.0f);
        //TODO: setup delegate/datasource
        
        [innerPanelControl addControl:aGridControl];
        self.gridControl = aGridControl;
        [aGridControl release];
        
        
        
        //============================ SPACER CONTROL ============================
        BRSpacerControl *spacerBottom = [BRSpacerControl spacerWithPixels:44.0f];
        [innerPanelControl addControl:spacerBottom];
        
        
        
        
        [aScrollControl addControl:innerPanelControl];
        [innerPanelControl release];
        
        [outerPanelControl addControl:aScrollControl];
        [aScrollControl release];
        
        [self addControl:outerPanelControl];
        [outerPanelControl release];
    }
}


-(BOOL)brEventAction:(BREvent *)action
{
    int remoteAction = [action remoteAction];
    if ([(BRControllerStack *)[self stack] peekController] != self)
		remoteAction = 0;
    
    int itemCount = [[(BRListControl *)[self list] datasource] itemCount];
    switch (remoteAction)
    {	
        case kBREventRemoteActionMenu:
            break;
        case kBREventRemoteActionSwipeLeft:
        case kBREventRemoteActionLeft:
        {
//            BRControl *old = [self focusedControl];
//            BOOL r = [super brEventAction:action];
//            BRControl *new = [self focusedControl];
//            if (new==self.textEntry && old!=self.textEntry) {
//                [self hideSearchInterface:NO];
//                //TODO: should be improved, we want to focus clear action button
//                [self.textEntry setFocusToGlyphNamed:@"r"];
//            }
//            return r;
        }
        case kBREventRemoteActionSwipeRight:
        case kBREventRemoteActionRight:
        {
//            BRControl *old = [self focusedControl];
//            BOOL r = [super brEventAction:action];
//            BRControl *new = [self focusedControl];
//            if (old==self.textEntry && new!=self.textEntry) {
//                [self hideSearchInterface:YES];
//            }
//            return r;
        }
        case kBREventRemoteActionPlayPause:
            if (self.list.focused) {
                if([action value] == 1)
                    [self playPauseActionForRow:[self getSelection]];
                return YES;
            }
            break;
		case kBREventRemoteActionUp:
		case kBREventRemoteActionHoldUp:
			if([self getSelection] == 0 && [action value] == 1 && [self focusedControl]==[self list])
			{
				[self setSelection:itemCount-1];
				return YES;
			}
			break;
		case kBREventRemoteActionDown:
		case kBREventRemoteActionHoldDown:
			if([self getSelection] == itemCount-1 && [action value] == 1&& [self focusedControl]==[self list])
			{
				[self setSelection:0];
				return YES;
			}
			break;
    }
	return [super brEventAction:action];
}


#pragma mark - 
#pragma mark Grid Content Methods




#pragma mark -
#pragma mark List Provider Methods
- (float)heightForRow:(long)row {
    return 0.0f;
}

- (long)itemCount {
    return [self.menuItems count];
}

- (id)itemForRow:(long)row {
    
    
    PlexMediaObject *pmo = [self.menuItems objectAtIndex:row];
    return pmo.menuItem;
}

- (id)titleForRow:(long)row {
    PlexMediaObject *pmo = [self.menuItems objectAtIndex:row];
	return pmo.name;
}


#pragma mark -
#pragma mark BRMenuListItemProvider Delegate
- (BOOL)rowSelectable:(long)selectable {
	return YES;
}

- (void)itemSelected:(long)selected; {
	PlexMediaObject* pmo = [self.menuItems objectAtIndex:selected];
    [[PlexNavigationController sharedPlexNavigationController] navigateToObjectsContents:pmo];
}

-(void)playPauseActionForRow:(long)row {
    PlexMediaObject* pmo = [self.menuItems objectAtIndex:row];
    if (pmo.hasMedia) {
        //play media
        [[PlexNavigationController sharedPlexNavigationController] initiatePlaybackOfMediaObject:pmo];
    } else {
        //not media, pretend it was a selection
        [self.list.datasource itemSelected:row];
    }
}


#pragma mark -
#pragma mark List Action Methods
- (void)setSelection:(int)selection {
    NSMethodSignature *signature = [self.list methodSignatureForSelector:@selector(setSelection:)];
    NSInvocation *selInv = [NSInvocation invocationWithMethodSignature:signature];
    [selInv setSelector:@selector(setSelection:)];
    if(strcmp([signature getArgumentTypeAtIndex:2], "l"))
    {
        double dvalue = selection;
        [selInv setArgument:&dvalue atIndex:2];
    }
    else
    {
        long lvalue = selection;
        [selInv setArgument:&lvalue atIndex:2];
    }
    [selInv invokeWithTarget:self.list];
}

-(int)getSelection {
	int row;
	NSMethodSignature *signature = [self.list methodSignatureForSelector:@selector(selection)];
	NSInvocation *selInv = [NSInvocation invocationWithMethodSignature:signature];
	[selInv setSelector:@selector(selection)];
	[selInv invokeWithTarget:self.list];
	if([signature methodReturnLength] == 8)
	{
		double retDoub = 0;
		[selInv getReturnValue:&retDoub];
		row = retDoub;
	}
	else
		[selInv getReturnValue:&row];
	return row;
}

@end
