//
//  PlexSearchController.m
//  plex
//
//  Created by Serendipity on 29/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlexSearchController.h"
#import "Constants.h"
#import <plex-oss/Machine.h>

@implementation PlexSearchController
@synthesize datasource, header, totalResults, textEntry, arrow, previewControl;
@synthesize machine;

- (id)initWithMachine:(Machine *)aMachine {
    self = [super init];
    if (self) {
        self.machine = aMachine;
        [self.list setDatasource:self];
        self.datasource = self;
        
        PlexMediaContainer *librarySections = self.machine.librarySections;
        NSArray *directories = [[librarySections directories] retain];
        PlexMediaObject *disney = [[directories objectAtIndex:0]retain];
        
        PlexMediaContainer *allFilters = [[disney contents]retain];
        NSArray *filters = [[allFilters directories]retain];
        PlexMediaObject *allDisney = [[filters objectAtIndex:0]retain];
        pmc = [[allDisney contents] retain];
    }
    return self;
}

-(void)dealloc {
    self.datasource = nil;
    self.header = nil;
    self.totalResults = nil;
    self.textEntry = nil;
    self.arrow = nil;
    self.previewControl = nil;
    
    self.machine = nil;
    [super dealloc];
}

- (void)layoutSubcontrols {
    [super layoutSubcontrols];
    
    CGRect masterFrame = [BRWindow interfaceFrame];
	
    //============================ TEXT ENTRY ============================
    if (!self.textEntry) {
        BRTextEntryControl *aTextEntry = [[BRTextEntryControl alloc] initWithTextEntryStyle:2];
        aTextEntry.frame = CGRectMake(108, 
                                      70, 
                                      460, 
                                      499);
        [self addControl:aTextEntry];
        self.textEntry = aTextEntry;
        [aTextEntry release];
        [self setFocusedControl:self.textEntry];
    }
    
    //============================ TOTAL RESULTS ============================
    
    if (!self.totalResults) {
        BRTextControl *aTextControl = [[BRTextControl alloc] init];
        [aTextControl setText:@"10000 Results" withAttributes:[[BRThemeInfo sharedTheme] metadataLabelAttributes]];
        CGFloat width = 148.0f; //room for 7 digit result
        CGFloat height = 24.0f;
        aTextControl.frame = CGRectMake(CGRectGetMaxX(self.textEntry.frame)-width, 
                                        CGRectGetMaxY(self.textEntry.frame), 
                                        width, 
                                        height);
        [self addControl:aTextControl];
        self.totalResults = aTextControl;
        [aTextControl release];
    }
    
    
    //============================ ARROW IMAGE ============================
    if (!self.arrow) {
        BRImageControl *anArrow = [[BRImageControl alloc] init];
        BRImage *arrowImageON = [BRImage imageWithPath:[[NSBundle bundleForClass:[BRThemeInfo class]]pathForResource:@"Arrow_ON" ofType:@"png"]];
        [anArrow setImage:arrowImageON];
        anArrow.frame = CGRectMake(CGRectGetMaxX(self.textEntry.frame), 
                                   CGRectGetMidY(self.textEntry.frame)-55, 
                                   46, 
                                   46);
        [self addControl:anArrow];
        self.arrow = anArrow;
        [anArrow release];
    }    
    
	//============================ HEADER TITLE ============================
	if (!self.header) {
        BRHeaderControl *headerControl = [[BRHeaderControl alloc] init];
        [headerControl setTitle:[self.datasource headerTitleForSearchController:self] withAttributes:[[BRThemeInfo sharedTheme] menuTitleTextAttributes]];
        
        //============================ HEADER ICON =========================    
        if ([self.datasource respondsToSelector:@selector(headerIconForSearchController:)]) {
            BRImage *headerIcon = [self.datasource headerIconForSearchController:self];
            [headerControl setIcon:headerIcon position:2 edgeSpace:64];
        }    
        
        headerControl.frame = CGRectMake(0, CGRectGetMaxY(masterFrame)-95, CGRectGetWidth(masterFrame), 51);
        [self addControl:headerControl];
        self.header = headerControl;
        [headerControl release];
    }
    
    
    //======================== MODIFY CURRENT CONTROLS ========================
    
    //============================ LIST ============================
    self.list.frame = CGRectMake(CGRectGetMaxX(self.arrow.frame)-16, 
                                 CGRectGetMinY(self.textEntry.frame), 
                                 640, 
                                 540);
    
    //============================ PREVIEW ============================
    if (!self.previewControl) {
        self.previewControl = [self valueForKey:@"_previewControl"];
        self.previewControl.hidden = YES;
    }
}



#pragma mark -
#pragma mark Event Handling
//-(BOOL)brEventAction:(BREvent *)action
//{
//    int remoteAction = [event remoteAction];
//    if ([(BRControllerStack *)[self stack] peekController] != self)
//		remoteAction = 0;
//
//    int itemCount = [[(BRListControl *)[self list] datasource] itemCount];
//    switch (remoteAction)
//    {	
//        case kBREventRemoteActionMenu:
//            break;
//        case kBREventRemoteActionSwipeLeft:
//        case kBREventRemoteActionLeft:
//            if([event value] == 1)
//                [self leftActionForRow:[self getSelection]];
//            return YES;
//            break;
//        case kBREventRemoteActionSwipeRight:
//        case kBREventRemoteActionRight:
//            if([event value] == 1)
//                [self rightActionForRow:[self getSelection]];
//            return YES;
//            break;
//        case kBREventRemoteActionPlayPause:
//            if([event value] == 1)
//                [self playPauseActionForRow:[self getSelection]];
//            return YES;
//            break;
//        case 21:
//            if (self.popupControl!=nil) {
//                if (![[self controls]containsObject:self.popupControl])
//                    [self showPopup];
//                return YES;
//            }
//            break;
//		case kBREventRemoteActionUp:
//		case kBREventRemoteActionHoldUp:
//			if([self getSelection] == 0 && [event value] == 1 && [self focusedControl]==[self list])
//			{
//				[self setSelection:itemCount-1];
//				return YES;
//			}
//			break;
//		case kBREventRemoteActionDown:
//		case kBREventRemoteActionHoldDown:
//			if([self getSelection] == itemCount-1 && [event value] == 1&& [self focusedControl]==[self list])
//			{
//				[self setSelection:0];
//				return YES;
//			}
//			break;
//    }
//	return [super brEventAction:event];
//}



#pragma mark -
#pragma mark datasource
- (NSString *)headerTitleForSearchController:(PlexSearchController *)searchController {
    return @"Search";
}

- (BRImage *)headerIconForSearchController:(PlexSearchController *)searchController {
    NSString *headerIcon = [[NSBundle bundleForClass:[PlexSearchController class]] pathForResource:@"PlexTextLogo" ofType:@"png"];
	return [BRImage imageWithPath:headerIcon];
}



#pragma mark -
#pragma mark list
- (float)heightForRow:(long)row {
    return 105.0f;
}

- (long)itemCount {
    return [pmc.directories count];
}

- (id)itemForRow:(long)row {    
    BRMenuItem *menuItem = [[NSClassFromString(@"BRPlayButtonEnabledMenuItem") alloc] init];
    
    [menuItem setText:[self.list.datasource titleForRow:row] withAttributes:nil];
    [menuItem setDetailedText:@"2009" withAttributes:nil];
    [menuItem addAccessoryOfType:11];
    return menuItem;
}

- (BOOL)rowSelectable:(long)selectable {
    return YES;
}

- (id)previewControlForItem:(long)item {
    PlexMediaObject *pmo = [pmc.directories objectAtIndex:item];
    
    NSURL* mediaURL = [pmo mediaStreamURL];
    PlexPreviewAsset* pma = [[PlexPreviewAsset alloc] initWithURL:mediaURL mediaProvider:nil mediaObject:pmo];
    
    BRMetadataPreviewControl *preview = [[BRMetadataPreviewControl alloc] init];
    [preview setShowsMetadataImmediately:YES];
    [preview setAsset:pma];
    [pma release];
    
    return [preview autorelease];
    
//    SMFMediaPreview *preview = [SMFMediaPreview mediaPreview];
//    
//    SMFBaseAsset *a = [SMFBaseAsset asset];
//    
//    [a setCustomKeys:[NSArray arrayWithObjects:@"Key",@"Value",@"Class",nil]
//          forObjects:[NSArray arrayWithObjects:
//                      @"key value",
//                      @"value value",
//                      @"class value",
//                      nil]];
//    [a setTitle:@"title"];
//    [a setCoverArt:[[BRThemeInfo sharedTheme]appleTVIcon]];
//    [preview setAsset:a];
//    return preview;
}

- (id)titleForRow:(long)row {
    PlexMediaObject *pmo = [pmc.directories objectAtIndex:row];
	return pmo.name;
}

@end
