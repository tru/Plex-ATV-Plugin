//
//  Plex_SMFMoviePreviewController.h
//  plex
//
//  Created by ccjensen on 04/04/2011.
//

#import <Foundation/Foundation.h>
#import "Sub_SMFMoviePreviewController.h"

@protocol Plex_SMFMoviePreviewControllerDatasource <Sub_SMFMoviePreviewControllerDatasource>
- (NSURL *)backgroundImageUrl;
- (NSArray *)flags;
@end

@protocol Plex_SMFMoviePreviewControllerDelegate <Sub_SMFMoviePreviewControllerDelegate>
@optional
-(void)controller:(Sub_SMFMoviePreviewController *)c playButtonEventOnButtonAtIndex:(int)index;
-(void)controller:(Sub_SMFMoviePreviewController *)c playButtonEventInShelf:(BRMediaShelfControl *)shelfControl;
@end

@interface Plex_SMFMoviePreviewController : Sub_SMFMoviePreviewController {}
@property (retain) NSObject<Plex_SMFMoviePreviewControllerDatasource> *datasource;
@property (retain) NSObject<Plex_SMFMoviePreviewControllerDelegate> *delegate;
@property (retain) NSArray *flags;

@end
