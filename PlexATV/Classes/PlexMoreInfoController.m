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
#import <plex-oss/PlexRequest.h>
#import "PlexMediaObject+Assets.h"
#import "PlexNavigationController.h"
#import "PlexMoreInfoMenuItem.h"
#import "PlexControlFactory.h"

//these are in the AppleTV.framework, but cannot #import <AppleTV/AppleTV.h> due to
//naming conflicts with Backrow.framework. below is a hack!
@interface BRThemeInfo (PlexExtentions)
- (id)storeRentalPlaceholderImage;
@end

@implementation PlexMoreInfoController
@synthesize scrollControl, cursorControl, innerPanelControl, spacerTopControl, metadataControl, metadataTitleControl, spacerTitleGridControl, gridControl, spacerBottom;
@synthesize waitSpinnerControl;
@synthesize moreInfoContainer, mediaObject, menuItems; 
@synthesize currentGridContentMediaContainer, currentGridContent;

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
    self.cursorControl = nil;
    self.innerPanelControl = nil;
    self.spacerTopControl = nil;
    self.metadataControl = nil;
    self.metadataTitleControl = nil;
    self.spacerTitleGridControl = nil;
    self.gridControl = nil;
    self.spacerBottom = nil;
    
    self.waitSpinnerControl = nil;
    
    self.moreInfoContainer = nil;
    self.mediaObject = nil;
    self.menuItems = nil;
    self.currentGridContentMediaContainer = nil;
    self.currentGridContent = nil;
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
     Panel Control                 {origin:{x:395,y:0},size:{width:855,height:720}}
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
    self.scrollControl = aScrollControl;
    [aScrollControl release];
    
    self.scrollControl.frame = CGRectMake(0.0f, 0.0f, 855.0f, 720.0f);
    [self.scrollControl setDefaultAnimationMode:0 fastScrollingAnimationMode:1];
    
//    BRCursorControl *aCursorControl = [[BRCursorControl alloc] init];
//    self.cursorControl = aCursorControl;
//    [aCursorControl release];
    
}

- (void)newGrid {    
    //============================ SPACER CONTROL ============================
    BRSpacerControl *aSpacerControl = [BRSpacerControl spacerWithPixels:44.0f];
    self.spacerTopControl = aSpacerControl;
    self.spacerTopControl.acceptsFocus = NO;
    
    
    //============================ CONTROL ============================
    BRControl *aControl = [[BRControl alloc] init];
    self.metadataControl = aControl;
    [aControl release];
    
    self.metadataControl.frame = CGRectMake(0.0f, 776.0f, 855.0f, 51.0f);
    self.metadataControl.acceptsFocus = NO;
    
    
    //============================ METADATA TITLE CONTROL ============================
    BRMetadataTitleControl *aMetadataTitleControl = [[BRMetadataTitleControl alloc] init];
    self.metadataTitleControl = aMetadataTitleControl;
    [aMetadataTitleControl release];
    
    self.metadataTitleControl.frame = CGRectMake(51.0f, 0.0f, 855.0f, 51.0f);
    self.metadataTitleControl.acceptsFocus = NO;
    
    [self.metadataControl addControl:self.metadataTitleControl];
    [self.innerPanelControl addControl:self.metadataControl];
    
    
    //============================ SPACER CONTROL ============================
    BRSpacerControl *aSpacerControl1 = [BRSpacerControl spacerWithPixels:18.0f];
    self.spacerTitleGridControl = aSpacerControl1;
    self.spacerTitleGridControl.acceptsFocus = NO;
    
    
    
    //============================ GRID CONTROL ============================
    BRGridControl *aGridControl = [[BRGridControl alloc] init];
    self.gridControl = aGridControl;
    [aGridControl release];
    
    self.gridControl.frame = CGRectMake(0.0f, 0.0f, 855.0f, 206.0f);
	[self.gridControl setColumnCount:5];
	[self.gridControl setWrapsNavigation:NO];
	[self.gridControl setHorizontalGap:0];
	[self.gridControl setVerticalGap:20.0f];
	[self.gridControl setLeftMargin:0.05000000074505806];
	[self.gridControl setRightMargin:0.05000000074505806];
	[self.gridControl setAcceptsFocus:YES];
    
    //============================ SPACER CONTROL ============================
    BRSpacerControl *aSpacerControl2 = [BRSpacerControl spacerWithPixels:44.0f];
    self.spacerBottom = aSpacerControl2;
    self.spacerBottom.acceptsFocus = NO;


    
    //============================ INNER PANEL CONTROL ============================
    BRPanelControl *aPanelControl = [[BRPanelControl alloc] init];
    self.innerPanelControl = aPanelControl;
    [aPanelControl release];
    
    self.innerPanelControl.panelMode = 1;
    self.innerPanelControl.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.innerPanelControl.frame = CGRectMake(0.0f, 0.0f, 855.0f, 395.0f);
    self.innerPanelControl.acceptsFocus = YES;
 
    [self.innerPanelControl addControl:self.spacerTopControl];
    [self.innerPanelControl addControl:self.metadataControl];
    [self.innerPanelControl addControl:self.spacerTitleGridControl];
    [self.innerPanelControl addControl:self.gridControl];
    [self.innerPanelControl addControl:self.spacerBottom];
    
    self.scrollControl.content = self.innerPanelControl;
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
    previewContainer.acceptsFocus = YES;
    
    if (!self.cursorControl) {
        BRCursorControl *aCursorControl = [[BRCursorControl alloc] init];
        self.cursorControl = aCursorControl;
        [aCursorControl release];
        
        [previewContainer addControl:self.cursorControl];
    }
    
    if (!self.waitSpinnerControl) {
        BRWaitSpinnerControl *spinner = [[BRWaitSpinnerControl alloc] init];
        CGPoint centerOfPreviewContainer = CGPointMake(CGRectGetMidX(previewContainer.frame), 
                                                       CGRectGetMidY(previewContainer.frame));
        CGFloat spinnerDimension = 86.0f;
        spinner.frame = CGRectMake(centerOfPreviewContainer.x-(spinnerDimension/2), 
                                   centerOfPreviewContainer.y-(spinnerDimension/2), 
                                   spinnerDimension, spinnerDimension);
        spinner.spins = NO;
        [self addControl:spinner];
        self.waitSpinnerControl = spinner;
        [spinner release];
    }
}


-(BOOL)brEventAction:(BREvent *)action
{
    int remoteAction = [action remoteAction];
    if ([(BRControllerStack *)[self stack] peekController] != self)
		remoteAction = 0;
    
    switch (remoteAction) {
		case kBREventRemoteActionUp:
		case kBREventRemoteActionHoldUp:
//			if([self getSelection] == 0 && [action value] == 1 && [self focusedControl]==[self list])
//			{
//				[self setSelection:itemCount-1];
//				return YES;
//			}
//			break;
        case kBREventRemoteActionPlayPause:
            if (self.list.focused) {
                if([action value] == 1)
                    [self playPauseActionForRow:[self getSelection]];
                return YES;
            }
            break;
    }
	return [super brEventAction:action];
}


#pragma mark -
#pragma mark Grid UI Methods
- (void)refreshGrid {
    [self.gridControl setProvider:[self gridProvider]];
    [self.gridControl setProviderRequester:self.gridControl];
}

- (id)gridProvider {
	NSSet *_set = [NSSet setWithObject:[BRMediaType movie]];
	NSPredicate *_pred = [NSPredicate predicateWithFormat:@"mediaType == %@",[BRMediaType movie]];
	BRDataStore *store = [[BRDataStore alloc] initWithEntityName:@"Hello2" predicate:_pred mediaTypes:_set];
	
	for (int i=0;i<[self.currentGridContent count];i++)
	{
		PlexMediaObject *pmo = [self.currentGridContent objectAtIndex:i];
		[store addObject:pmo.previewAsset];
	}
#if LOCAL_DEBUG_ENABLED
	DLog(@"getProviderForGrid - have assets, creating datastore and provider");
#endif
    
    
    PlexControlFactory *controlFactory = [[PlexControlFactory alloc] initForMainMenu:NO];
	controlFactory.defaultImage = [[BRThemeInfo sharedTheme] storeRentalPlaceholderImage];
	
    BRPhotoDataStoreProvider* provider = [BRPhotoDataStoreProvider providerWithDataStore:store 
																		  controlFactory:controlFactory];
    [controlFactory release];
    [store release];
	
	return provider;
}


#pragma mark - 
#pragma mark Grid Content Methods

#define kContentsForDirectoryRequestKey @"kContentsForDirectoryRequestKey"
#define kContentsForDirectoryQueryKey @"kContentsForDirectoryQueryKey"
#define kContentsForDirectoryKey @"kContentsForDirectoryKey"
- (void)finishedRetrivalOfContentsForDirectoryWithData:(NSDictionary *)data {
    self.waitSpinnerControl.spins = NO;
    
    self.currentGridContentMediaContainer = [data objectForKey:kContentsForDirectoryKey];
    self.currentGridContent = self.currentGridContentMediaContainer.directories;
    
#if LOCAL_DEBUG_ENABLED
    DLog(@"retrieved grid content [%@] with items [%@]", self.currentGridContentMediaContainer, self.currentGridContent);
#endif
    
    [self.metadataTitleControl setTitleSubtext:[NSString stringWithFormat:@"%d Items", [self.currentGridContent count]]];
    //free the passed data
    [data release];
    
    [self refreshGrid];
}

- (void)performRetrivalOfContentsForDirectoryWithData:(NSMutableDictionary *)data {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *gridContentQuery = [data objectForKey:kContentsForDirectoryQueryKey];
    PlexRequest* gridContentRequest = [data objectForKey:kContentsForDirectoryRequestKey];
    
#if LOCAL_DEBUG_ENABLED
    DLog(@"retrieving grid content with request [%@] and query [%@]", gridContentRequest, gridContentQuery);
#endif
    
    PlexMediaContainer *gridContent = [gridContentRequest query:gridContentQuery callingObject:nil ignorePresets:YES timeout:20 cachePolicy:NSURLRequestUseProtocolCachePolicy];
    
    [data setObject:gridContent forKey:kContentsForDirectoryKey];
    [self performSelectorOnMainThread:@selector(finishedRetrivalOfContentsForDirectoryWithData:) withObject:data waitUntilDone:YES];
    [pool drain];
}

- (void)startRetrievalOfContentsForDirectory:(PlexDirectory *)directory {
    [self.metadataTitleControl setTitle:[directory.attributes objectForKey:@"tag"]];
    
    NSMutableString *directoryContentsQuery = [NSMutableString stringWithString:@"/library"];
    if ([directory.containerType isEqualToString:@"Role"] ||
        [directory.containerType isEqualToString:@"Writer"] ||
        [directory.containerType isEqualToString:@"Director"]) {
        //  /library/people/956/media
        [directoryContentsQuery appendFormat:@"/people/%@/media", [directory.attributes objectForKey:@"id"]];
        
    } else if ([directory.containerType isEqualToString:@"Genre"]) {
        // /library/sections/28/genre/174
        [directoryContentsQuery appendFormat:@"/sections/%d/genre/%@", directory.sectionKey, [directory.attributes objectForKey:@"id"]];
        
    } else {
        //invalid query
#if LOCAL_DEBUG_ENABLED
        DLog(@"failed to generate query for containerType: [%@]", directory.containerType);
#endif
        [self.metadataTitleControl setTitleSubtext:@"failed to load"];
        return;
    }
    
    //start spinner
    self.waitSpinnerControl.spins = YES;
    [self.metadataTitleControl setTitleSubtext:@"loading..."];
    
    PlexRequest* directoryContentsRequest = directory.request;
    
    //is freed after the search finished
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:directoryContentsQuery, kContentsForDirectoryQueryKey, directoryContentsRequest, kContentsForDirectoryRequestKey, nil];
    [self performSelectorInBackground:@selector(performRetrivalOfContentsForDirectoryWithData:) withObject:data];
}



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
    
    [self newGrid];
    [self startRetrievalOfContentsForDirectory:directory];
    
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