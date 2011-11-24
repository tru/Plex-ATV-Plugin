//
//  PlexTVEpisodeMetadataAsset.m
//  plex
//
//  Created by ccjensen on 14/06/2011.
//

#import "PlexTVEpisodeMetadataAsset.h"
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexRequest.h>
//#import <plex-oss/Machine.h>
//#import <plex-oss/PlexImage.h>

@implementation PlexTVEpisodeMetadataAsset
@synthesize tvshowObject;

#pragma mark -
#pragma mark Object/Class Lifecycle
- (id)initWithURL:(NSURL*)u mediaProvider:(id)mediaProvider mediaObject:(PlexMediaObject*)obj {
	self = [super initWithURL:u mediaProvider:mediaProvider mediaObject:obj];
	if (self) {
        [self setupTvshowObject];
	}
	return self;
}

- (void)dealloc {
    self.tvshowObject = nil;
	[super dealloc];
}

- (void)setupTvshowObject {
    NSString *grandparentKey = [self.pmo.attributes objectForKey:@"grandparentKey"];
    if (grandparentKey) {
        //mixed
        PlexMediaContainer *tvshowContainer = [self.pmo.request query:grandparentKey callingObject:nil ignorePresets:YES timeout:20 cachePolicy:NSURLRequestUseProtocolCachePolicy];
        if ([tvshowContainer.directories count] == 1) {
            self.tvshowObject = [tvshowContainer.directories objectAtIndex:0];
        }
    } else {
        //hierarchial
        if ([self.pmo.parentObject isKindOfClass:[PlexMediaObject class]]) {
            PlexMediaObject *parent = self.pmo.parentObject;
            if ([parent.parentObject isKindOfClass:[PlexMediaObject class]]) {
                self.tvshowObject = parent.parentObject;
            }
        }
    }
}

#pragma mark -
#pragma mark BRMediaAsset
- (id)genres {    
    NSString *result = [self.tvshowObject listSubObjects:@"Genre" usingKey:@"tag"];
	return [result componentsSeparatedByString:@", "];
}

- (id)primaryGenre {
	NSArray *allGenres = [self genres];
	BRGenre *result = nil;
	if ([allGenres count] > 0) {
		result = [[[BRGenre alloc] initWithString:[allGenres objectAtIndex:0]] autorelease];
	}
	return result;
}


@end
