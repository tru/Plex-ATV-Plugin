//
//  PlexMoreInfoController.h
//  plex
//
//  Created by ccjensen on 5/26/11.
//

#import <Foundation/Foundation.h>
@class PlexMediaContainer, PlexMediaObject;

@interface PlexMoreInfoController : BRController {
    
}
@property (retain) BRListControl *list;
@property (retain) BRPanelControl *contentContainer;
@property (retain) BRMetadataTitleControl *metadataTitleControl;
@property (retain) BRGridControl *gridControl;

@property (retain) PlexMediaContainer *moreInfoContainer;
@property (retain) PlexMediaObject *mediaObject;
@property (retain) NSArray *items;
@property (retain) NSArray *menuItems;

- (void)setupListForMediaObject:(PlexMediaObject *)aMediaObject;

//list methods
-(void)playPauseActionForRow:(long)row;
- (void)setSelection:(int)selection;
- (int)getSelection;

@end
