//
//  HWTVShowsController.h
//  plex
//
//  Created by ccjensen on 26/02/2011.
//

#import <Foundation/Foundation.h>
#import <SMFramework/SMFBookcaseController.h>

@class PlexMediaContainer;
@interface HWTVShowsController : SMFBookcaseController <SMFBookcaseControllerDatasource, SMFBookcaseControllerDelegate> {
	PlexMediaContainer *tvShows;
	NSMutableArray *allTvShowsSeasonsPlexMediaContainer;
    
    BOOL allShelvesLoaded;
}
@property (nonatomic, retain) PlexMediaContainer *seasonsForSelectedTVShow;

- (id)initWithPlexAllTVShows:(PlexMediaContainer *)allTVShows;

@end
