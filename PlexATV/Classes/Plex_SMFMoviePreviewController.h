//
//  Plex_SMFMoviePreviewController.h
//  plex
//
//  Created by ccjensen on 04/04/2011.
//

#import <Foundation/Foundation.h>
#import "Backrow/BRMediaShelfControl.h"

@protocol Plex_SMFMoviePreviewControllerDatasource <SMFMoviePreviewControllerDatasource>
- (NSURL *)backgroundImageUrl;
- (NSArray *)flags;
@end

@protocol Plex_SMFMoviePreviewControllerDelegate <SMFMoviePreviewControllerDelegate>
@optional
-(void)controller:(SMFMoviePreviewController *)c playButtonEventOnButtonAtIndex:(int)index;
-(void)controller:(SMFMoviePreviewController *)c playButtonEventInShelf:(BRMediaShelfControl *)shelfControl;
@end

@interface Plex_SMFMoviePreviewController : SMFMoviePreviewController {}
@property (retain) NSObject<Plex_SMFMoviePreviewControllerDatasource> *datasource;
@property (retain) NSObject<Plex_SMFMoviePreviewControllerDelegate> *delegate;
@property (retain) NSArray *flags;

@end
