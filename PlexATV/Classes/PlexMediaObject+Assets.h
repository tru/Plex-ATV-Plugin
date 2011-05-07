//
//  PlexMediaObject+Assets.h
//  plex
//
//  Created by ccjensen on 03/05/2011.
//

#import <Foundation/Foundation.h>
#import <plex-oss/PlexMediaObject.h>

@class PlexPreviewAsset, PlexMediaAsset, PlexSongAsset;
@interface PlexMediaObject (Assets)

@property (readonly) PlexPreviewAsset *previewAsset;
@property (readonly) PlexMediaAsset *mediaAsset;
//@property (readonly) PlexSongAsset *songAsset;

@property (readonly) float heightForMenuItem;
@property (readonly) BRMenuItem *menuItem;
@property (readonly) id previewControl;

@end
