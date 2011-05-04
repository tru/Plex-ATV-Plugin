//
//  PlexMediaObject+Assets.m
//  plex
//
//  Created by ccjensen on 03/05/2011.
//

#import "PlexMediaObject+Assets.h"
#import "PlexPreviewAsset.h"
#import "PlexMediaAsset.h"
#import "PlexSongAsset.h"

@implementation PlexMediaObject (Assets)

- (PlexPreviewAsset *)previewAsset {
    return [[[PlexPreviewAsset alloc] initWithURL:nil mediaProvider:nil mediaObject:self] autorelease];
}

- (PlexMediaAsset *)mediaAsset {
    return [[[PlexMediaAsset alloc] initWithURL:nil mediaProvider:nil mediaObject:self] autorelease];
}

//- (PlexSongAsset *)songAsset {
//    
//}

@end
