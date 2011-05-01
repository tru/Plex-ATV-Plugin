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

@synthesize machine;

- (id)initWithMachine:(Machine *)aMachine {
    self = [super init];
    if (self) {
        self.machine = aMachine;
    }
    return self;
}

-(void)dealloc {
    self.machine = nil;
    [super dealloc];
}

-(void)controlWasActivated {
    [self rebuildInterface];
    [super controlWasActivated];
}

- (void)rebuildInterface {
	[self _removeAllControls];
	
    /* View layout:
	 * Empty space (95px)
	 * Header (51 px)
	 * - title  |  image (optional)
	 * Empty space (19px)
     * Total results (20 px)
     *  - *
	 * - Bottom Spacer (44px)
	 */
    
    
	CGRect masterFrame = [BRWindow interfaceFrame];
	
    //============================ TEXT ENTRY ============================
    BRTextEntryControl *textEntry = [[BRTextEntryControl alloc] initWithTextEntryStyle:2];
    textEntry.frame = CGRectMake(108, 
                                 70, 
                                 460, 
                                 499);
    [self addControl:textEntry];
    [textEntry release];
    
    //============================ TOTAL RESULTS ============================
    BRTextControl *totalResults = [[BRTextControl alloc] init];
    [totalResults setText:@"10000 Results" withAttributes:[[BRThemeInfo sharedTheme] metadataLabelAttributes]];
    CGFloat width = 148.0f; //room for 7 digit result
    CGFloat height = 24.0f;
    totalResults.frame = CGRectMake(CGRectGetMaxX(textEntry.frame)-width, 
                                    CGRectGetMaxY(textEntry.frame), 
                                    width, 
                                    height);
    [self addControl:totalResults];
    
    
    //============================ ARROW IMAGE ============================
    BRImageControl *arrow = [[BRImageControl alloc] init];
    BRImage *arrowImageON = [BRImage imageWithPath:[[NSBundle bundleForClass:[BRThemeInfo class]]pathForResource:@"Arrow_ON" ofType:@"png"]];
    [arrow setImage:arrowImageON];
    arrow.frame = CGRectMake(CGRectGetMaxX(textEntry.frame), 
                             CGRectGetMidY(textEntry.frame)-55, 
                             46, 
                             46);
    [self addControl:arrow];
    
    
    //============================ LIST ============================
    BRListControl *list = [[BRListControl alloc] init];
    list.firstDividerVisible = YES;
    
    list.frame = CGRectMake(CGRectGetMaxX(arrow.frame)-16, 
                            CGRectGetMinY(textEntry.frame), 
                            640, 
                            540);
    [self addControl:list];
    [list setDatasource:self];
    
    
	//============================ HEADER TITLE ============================
	BRHeaderControl *headerControl = [[BRHeaderControl alloc] init];
    [headerControl setTitle:@"Search" withAttributes:[[BRThemeInfo sharedTheme] menuTitleTextAttributes]];
	
	//============================ HEADER ICON ============================	
    NSString *headerIconString = [[NSBundle bundleForClass:[PlexSearchController class]] pathForResource:@"PlexTextLogo" ofType:@"png"];
	BRImage *headerIcon = [BRImage imageWithPath:headerIconString];
    [headerControl setIcon:headerIcon position:2 edgeSpace:64];
    
    headerControl.frame = CGRectMake(0, CGRectGetMaxY(masterFrame)-95, CGRectGetWidth(masterFrame), 51);
    [self addControl:headerControl];
	
	[self layoutSubcontrols];
}

- (float)heightForRow:(long)row {
    return 105.0f;
}

- (long)itemCount {
    return 10;
}

- (id)itemForRow:(long)row {
    BRMenuItem *menuItem = [[NSClassFromString(@"BRPlayButtonEnabledMenuItem") alloc] init];
    
    [menuItem setText:[NSString stringWithFormat:@"Row %ld", row] withAttributes:nil];
    [menuItem setDetailedText:@"2009" withAttributes:nil];
    [menuItem addAccessoryOfType:11];
    return menuItem;
}

- (BOOL)rowSelectable:(long)selectable {
    return YES;
}

@end
