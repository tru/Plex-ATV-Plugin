//
//  PlexSearchController.h
//  plex
//
//  Created by Serendipity on 29/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Machine;

@interface PlexSearchController : BRController {
	//NSObject<SMFBookcaseControllerDatasource> *datasource;
    //NSObject<SMFBookcaseControllerDelegate> *delegate;
	
@private
	//datasource variables
	NSInteger numberOfShelfControls;
	NSMutableArray *_shelfTitles;
	
	//ui controls
	NSMutableArray *_shelfControls;
	BRPanelControl *_panelControl;
}
@property (retain) Machine *machine;

- (id)initWithMachine:(Machine *)aMachine;
- (void)rebuildInterface;
@end
