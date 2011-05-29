//
//  PlexMoreInfoController.m
//  plex
//
//  Created by ccjensen on 5/26/11.
//

#define LOCAL_DEBUG_ENABLED 1

#import "PlexMoreInfoController.h"
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import "PlexNavigationController.h"
#import "PlexMoreInfoMenuItem.h"


@implementation PlexMoreInfoController
@synthesize scrollControl, metadataTitleControl, gridControl;
@synthesize moreInfoContainer, mediaObject, menuItems;

#pragma mark -
#pragma mark Object/Class Lifecycle

- (id)initWithMoreInfoContainer:(PlexMediaContainer *)mediaContainer {
    self = [self init];
    if (self) {
        self.moreInfoContainer = mediaContainer;
        
        NSArray *mediaObjects = self.moreInfoContainer.directories;
#if LOCAL_DEBUG_ENABLED
        DLog(@"mediaObjects: [%@]", mediaObjects);
#endif
        if ([mediaObjects count] == 1) {
            self.mediaObject = [mediaObjects objectAtIndex:0];
            DLog(@"mediaObject: [%@]", self.mediaObject);
            [self setupListForMediaObject:self.mediaObject];
        }
        [self setupPreviewControl];
        [self.list setDatasource:self];
    }
    return self;
}

- (void)setupListForMediaObject:(PlexMediaObject *)aMediaObject {
    //possible contents: genre, writer, director, role (cast)
    NSMutableArray *newMenuItems = [NSMutableArray array];
    
    if (self.mediaObject) {        
        [self addCreditsSectionToArray:newMenuItems ForKey:@"Role" withLabel:@"Actors"];
        [self addCreditsSectionToArray:newMenuItems ForKey:@"Genre" withLabel:@"Categories"];
        [self addCreditsSectionToArray:newMenuItems ForKey:@"Director" withLabel:@"Directors"];
        [self addCreditsSectionToArray:newMenuItems ForKey:@"Writer" withLabel:@"Writers"];
    }
    
    self.menuItems = newMenuItems;
}

- (void)addCreditsSectionToArray:(NSMutableArray *)creditsSectionArray ForKey:(NSString *)key withLabel:(NSString *)label {
    NSMutableDictionary *dividerTextAttributes = [NSMutableDictionary dictionary];
    [dividerTextAttributes setValue:@"HelveticaNeue-Bold" forKey:@"BRFontName"];
    [dividerTextAttributes setValue:[NSNumber numberWithInt:23] forKey:@"BRFontPointSize"];
    [dividerTextAttributes setValue:[NSNumber numberWithInt:4] forKey:@"BRLineBreakModeKey"];
    [dividerTextAttributes setValue:[NSNumber numberWithInt:0] forKey:@"BRTextAlignmentKey"];
    [dividerTextAttributes setValue:(id)[[UIColor colorWithRed:0.26f green:0.26f blue:0.26f alpha:1.0f] CGColor] forKey:@"CTForegroundColor"];
    
    NSDictionary *subObjects = self.mediaObject.subObjects;
    
    NSArray *creditItems = [subObjects objectForKey:key];
#if LOCAL_DEBUG_ENABLED
    DLog(@"Credit items for key [%@] with label [%@] : [%@]", key, label, creditItems);
#endif
    if ([creditItems count] > 0) {
        BRDividerControl *dividerControl = [[BRDividerControl alloc] init];
        dividerControl.dividerHeightStyle = 1;
        dividerControl.drawsLine = NO;
        [dividerControl setStartOffsetText:0.0f];
        [dividerControl setLabel:label withAttributes:dividerTextAttributes];
        [creditsSectionArray addObject:dividerControl];
        [dividerControl release];
        
        for (PlexDirectory *directory in creditItems) {
            PlexMoreInfoMenuItem *menuItem = [PlexMoreInfoMenuItem menuItemForDirectory:directory];
            [creditsSectionArray addObject:menuItem];
        }
    }
}

-(void)dealloc {
    self.scrollControl = nil;
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
    CATransition *transition = [CATransition animation];
    transition.type = @"push";
    transition.subtype = kCATransitionFromBottom;
    transition.duration = 0.75f;
    [[[BRApplicationStackManager singleton] stack] setActions:[NSDictionary dictionaryWithObject:transition forKey:@"sublayers"]];
    
    [super controlWasActivated];
}

#pragma mark -
#pragma mark Controller Drawing and Events
- (void)setupPreviewControl {
    /*
     - Scroll Control              {origin:{x:0,y:0},size:{width:855,height:720}}
     -- Panel Control              {origin:{x:0,y:325},size:{width:855,height:395}}
     --- Spacer                    {origin:{x:405,y:827},size:{width:44,height:44}}
     --- Control                   {origin:{x:0,y:776},size:{width:855,height:51}}
     ---- Metadata Title Control   {origin:{x:51,y:0},size:{width:855,height:51}}
     ----- Title and Subtext
     --- Spacer                    {origin:{x:418,y:758},size:{width:18,height:18}}
     --- Grid                      {origin:{x:0,y:44},size:{width:855,height:714}}
     --- Spacer                    {origin:{x:405,y:0},size:{width:44,height:44}}
     */
    
    
    //============================ SCROLL CONTROL ============================
    BRScrollControl *aScrollControl = [[BRScrollControl alloc] init];
    aScrollControl.frame = CGRectMake(0.0f, 0.0f, 855.0f, 720.0f);
    
    
    
    //============================ INNER PANEL CONTROL ============================
    BRPanelControl *innerPanelControl = [[BRPanelControl alloc] init];
    innerPanelControl.panelMode = 1;
    innerPanelControl.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    innerPanelControl.frame = CGRectMake(0.0f, 0.0f, 855.0f, 395.0f);
    
    
    
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
    
    self.scrollControl = aScrollControl;
    [aScrollControl release];
}

- (void)layoutSubcontrols {
    [super layoutSubcontrols];
    /*
     - Left half: List Control      {origin:{x:39,y:0},size:{width:372,height:700}}
     - Right half: Preview Control  {origin:{x:395,y:0},size:{width:855,height:720}}
     */
    
    //CGRect masterFrame = [BRWindow interfaceFrame];
	
    //============================ LIST ============================
    self.list.frame = CGRectMake(39.0f, 0.0f, 372.0f, 700.0f);
    
    BRControl *previewContainer = [self valueForKey:@"_previewContainer"];
    previewContainer.frame = CGRectMake(395.0f, 0.0f, 855.0f, 720.0f);
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
		case kBREventRemoteActionHoldUp: {
//            BRControl *old = [self focusedControl];
//            BOOL r = [super brEventAction:action];
//            BRControl *new = [self focusedControl];
//            if (old==self.textEntry && new!=self.textEntry) {
//                [self hideSearchInterface:YES];
//            }
//            return r;
			break;
        }
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
    return 43.599998474121094;
}

- (long)itemCount {
    return [self.menuItems count];
}

- (id)itemForRow:(long)row {
    return [self.menuItems objectAtIndex:row];
}

- (id)titleForRow:(long)row {
    return [[self.menuItems objectAtIndex:row] text];
}

- (id)previewControlForItem:(long)item {
    PlexMoreInfoMenuItem *menuItem = [self.menuItems objectAtIndex:item];
    PlexDirectory *directory = menuItem.directory;
    
    [self.metadataTitleControl setTitle:[directory.attributes objectForKey:@"tag"]];
    [self.metadataTitleControl setTitleSubtext:[NSString stringWithFormat:@"%d Items", 10]];
    
    return self.scrollControl;
}


#pragma mark -
#pragma mark BRMenuListItemProvider Delegate
- (BOOL)rowSelectable:(long)selectable {
	return NO;
}

- (void)itemSelected:(long)selected {
#if LOCAL_DEBUG_ENABLED
    DLog(@"List menu item selected at row %ld: [%@]", selected, [self.menuItems objectAtIndex:selected]);
#endif
    PlexMoreInfoMenuItem *menuItem = [self.menuItems objectAtIndex:selected];
}

-(void)playPauseActionForRow:(long)row {
#if LOCAL_DEBUG_ENABLED
    DLog(@"List menu item play/paused at row %ld: [%@]", row, [self.menuItems objectAtIndex:row]);
#endif
    //not media, pretend it was a selection
    [self.list.datasource itemSelected:row];
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
