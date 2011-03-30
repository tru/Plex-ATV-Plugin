//
//  HWTVShowsController.m
//  plex
//
//  Created by ccjensen on 26/02/2011.
//

#import "HWTVShowsController.h"
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexMediaObject.h>
#import "PlexPreviewAsset.h"
#import "HWPlexDir.h"

@interface BRThemeInfo (PlexExtentions)
- (id)storeRentalPlaceholderImage;
@end

@implementation HWTVShowsController

#warning this is a hack to make sure all the shelfs are loaded correctly
-(BOOL)brEventAction:(BREvent *)action {
    if (!allShelvesLoaded) {
        NSArray *shelves = [self valueForKey:@"_shelfControls"];
        int shelfCount = [shelves count];
        int firstShelfToReload = [shelves count];
        
        //we only need to reload ~ the last half of the shelves
        if (shelfCount > 4) {
            firstShelfToReload = ceil(shelfCount/2);
            //examples:
            // ceil(5/2)   =   firstShelfToReload=3
            // ceil(6/2)   =   firstShelfToReload=3
        } else {
            //allShelvesLoaded = YES;
            DLog(@"Shelf count is %d. No reloading needed", shelfCount);
        }
        //if 4 or less, then this won't loop at all
        int startIndex = firstShelfToReload - 2; // -2 since we are wish to reload i+2
        for (int i = startIndex; i<shelfCount; i++) {
            BRMediaShelfControl *shelf = [shelves objectAtIndex:i];
            if ([shelf isFocused]) {
                if (i+2 == shelfCount) {
                    //last item, all prior ones will have been re-layout too. 
                    //Will not need to redo this hack again until view is reloaded
                    allShelvesLoaded = YES;
                    DLog(@"Reloaded last shelf. Our work here is done");
                } else {
                    DLog(@"Reloading shelf at index %d/%d", i+2, shelfCount-1);
                    [[shelves objectAtIndex:i+2] setNeedsLayout];
                }
                break; //only need to refresh one
            }
        }
    }
    return [super brEventAction:action];
}

#pragma mark -
#pragma mark Object/Class Lifecycle
- (id)initWithPlexAllTVShows:(PlexMediaContainer *)allTVShows {
	if ((self = [super init])) {
		tvShows = [allTVShows retain];
		allTvShowsSeasonsPlexMediaContainer = [[NSMutableArray alloc] init];
		self.datasource = self;
		self.delegate = self;
	}
	return self;
}

- (void)dealloc {
	self.datasource = nil;
	self.delegate = nil;
	
	[allTvShowsSeasonsPlexMediaContainer release];
	[tvShows release];
	
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

#pragma mark -
#pragma mark SMFBookcaseController Datasource Methods
- (NSString *)headerTitleForBookcaseController:(SMFBookcaseController *)bookcaseController {
	return @"TV Shows";
}

- (BRImage *)headerIconForBookcaseController:(SMFBookcaseController *)bookcaseController {
	NSString *headerIcon = [[NSBundle bundleForClass:[HWTVShowsController class]] pathForResource:@"PlexTextLogo" ofType:@"png"];
	return [BRImage imageWithPath:headerIcon];
}

- (NSInteger)numberOfShelfsInBookcaseController:(SMFBookcaseController *)bookcaseController {
	[allTvShowsSeasonsPlexMediaContainer removeAllObjects];
  DLog(@"tvShows.directories: %d",[tvShows.directories count]);
	return [tvShows.directories count];
}

- (NSString *)bookcaseController:(SMFBookcaseController *)bookcaseController titleForShelfAtIndex:(NSInteger)index {
	PlexMediaObject *tvshow = [tvShows.directories objectAtIndex:index];
	return tvshow.name;
}

- (BRPhotoDataStoreProvider *)bookcaseController:(SMFBookcaseController *)bookcaseController datastoreProviderForShelfAtIndex:(NSInteger)index {
	NSSet *_set = [NSSet setWithObject:[BRMediaType photo]];
	NSPredicate *_pred = [NSPredicate predicateWithFormat:@"mediaType == %@",[BRMediaType photo]];
	BRDataStore *store = [[BRDataStore alloc] initWithEntityName:@"Hello" predicate:_pred mediaTypes:_set];
	
	
	PlexMediaObject *tvshow = [tvShows.directories objectAtIndex:index];
	PlexMediaContainer *seasonsContainer = [tvshow contents];
	[allTvShowsSeasonsPlexMediaContainer addObject:seasonsContainer];
	NSArray *seasons = [seasonsContainer directories];
  DLog(@"index: %d, seasons: %d", index, [seasons count]);
	for (PlexMediaObject *season in seasons) {		
		NSURL* mediaURL = [season mediaStreamURL];
		PlexPreviewAsset* ppa = [[PlexPreviewAsset alloc] initWithURL:mediaURL mediaProvider:nil mediaObject:season];
		[store addObject:ppa];
		[ppa release];
	}
	
	SMFControlFactory *controlFactory = [SMFControlFactory posterControlFactory];
	controlFactory.favorProxy = YES;
	controlFactory.defaultImage = [[BRThemeInfo sharedTheme] storeRentalPlaceholderImage];
	DLog(@"store size: %ld",[store count]);
	id provider = [BRPhotoDataStoreProvider providerWithDataStore:store controlFactory:controlFactory];
	[store release];
	return provider; 
}


#pragma mark -
#pragma mark SMFBookcaseController Delegate Methods
-(BOOL)bookcaseController:(SMFBookcaseController *)bookcaseController allowSelectionForShelf:(BRMediaShelfControl *)shelfControl atIndex:(NSInteger)index {
    return YES;
}

-(void)bookcaseController:(SMFBookcaseController *)bookcaseController selectionWillOccurInShelf:(BRMediaShelfControl *)shelfControl atIndex:(NSInteger)index {
	DLog(@"select will occur");
}

-(void)bookcaseController:(SMFBookcaseController *)bookcaseController selectionDidOccurInShelf:(BRMediaShelfControl *)shelfControl atIndex:(NSInteger)index {
	DLog(@"select did occur at index: %d and shelfindex: %ld",index, [shelfControl focusedIndex]);	
    
    PlexMediaObject *tvshow = [tvShows.directories objectAtIndex:index];  
    PlexMediaObject *season = [[tvshow contents].directories objectAtIndex:[shelfControl focusedIndex]];
    if ([season contents].hasOnlyEpisodes) {
        HWPlexDir* menuController = [[HWPlexDir alloc] initWithRootContainer:[season contents]];
        [[[BRApplicationStackManager singleton] stack] pushController:menuController];
        [menuController autorelease];    
    }
}

@end
