//
//  Plex_SMFMoviePreviewController.h
//  plex
//
//  Created by ccjensen on 04/04/2011.
//

#import <Foundation/Foundation.h>

@protocol Plex_SMFMoviePreviewControllerDatasource <SMFMoviePreviewControllerDatasource>
- (NSURL *)backgroundImageUrl;
@end

@interface Plex_SMFMoviePreviewController : SMFMoviePreviewController {
    BRControl *_summaryControlBackground;
}
@property(retain) NSObject<Plex_SMFMoviePreviewControllerDatasource> *datasource;

@end
