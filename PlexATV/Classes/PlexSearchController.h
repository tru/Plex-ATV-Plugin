//
//  PlexSearchController.h
//  plex
//
//  Created by ccjensen on 29/04/2011.
//

#import <Foundation/Foundation.h>
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexRequest + Security.h>
@class PlexSearchController;

@protocol PlexSearchControllerDatasource
- (NSString *)headerTitleForSearchController:(PlexSearchController *)searchController;
@optional
- (BRImage *)headerIconForSearchController:(PlexSearchController *)searchController;
@end



@class Machine;
@interface PlexSearchController : BRMediaMenuController <BRMenuListItemProvider, BRTextFieldDelegate, PlexSearchControllerDatasource> {}
@property (assign) NSObject <PlexSearchControllerDatasource> *datasource;
//@property (assign) NSObject <PlexSearchControllerDelegate> *delegate;

@property (retain) BRHeaderControl *header;
@property (retain) BRTextControl *totalResults;
@property (retain) BRTextEntryControl *textEntry;
@property (retain) BRImageControl *arrow;
@property (retain) BRImage *arrowOn;
@property (retain) BRImage *arrowOff;
@property (retain) BRControl *previewContainer;
@property (retain) NSString *currentSearchTerm;
@property (retain) NSArray *items;

- (void)hideSearchInterface:(BOOL)hide;
- (void)refresh;

//list methods
- (void)setSelection:(int)sel;
- (int)getSelection;
- (void)playPauseActionForRow:(long)row;



//custom
@property (retain) Machine *machine;
@property (retain) PlexMediaContainer *currentSearchMediaContainer;
- (id)initWithMachine:(Machine *)aMachine;

@end
