//
//  PlexSearchController.h
//  plex
//
//  Created by Serendipity on 29/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexRequest + Security.h>
#import "PlexPreviewAsset.h"
@class PlexSearchController;

@protocol PlexSearchControllerDatasource
- (NSString *)headerTitleForSearchController:(PlexSearchController *)searchController;
@optional
- (BRImage *)headerIconForSearchController:(PlexSearchController *)searchController;
@end



@class Machine;
@interface PlexSearchController : BRMediaMenuController <BRMenuListItemProvider, PlexSearchControllerDatasource> {
    
@private
    PlexMediaContainer *pmc;
}
@property (assign) NSObject <PlexSearchControllerDatasource> *datasource;
//@property (assign) NSObject <PlexSearchControllerDelegate> *delegate;

@property (retain) BRHeaderControl *header;
@property (retain) BRTextControl *totalResults;
@property (retain) BRTextEntryControl *textEntry;
@property (retain) BRImageControl *arrow;
@property (retain) BRControl *previewControl;

- (id)initWithMachine:(Machine *)aMachine;


@property (retain) Machine *machine;
@end
