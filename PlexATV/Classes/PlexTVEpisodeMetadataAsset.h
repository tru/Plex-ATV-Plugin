//
//  PlexTVEpisodeMetadataAsset.h
//  plex
//
//  Created by ccjensen on 14/06/2011.
//

#import <Foundation/Foundation.h>
#import "PlexPreviewAsset.h"

@interface PlexTVEpisodeMetadataAsset : PlexPreviewAsset {}
@property (nonatomic, retain) PlexMediaObject* tvshowObject;

- (void)setupTvshowObject;

@end
