//
//  PlexMoreInfoMenuItem.h
//  plex
//
//  Created by ccjensen on 28/05/2011.
//

#import <Foundation/Foundation.h>
@class PlexDirectory;

@interface PlexMoreInfoMenuItem : BRMenuItem {}
@property (retain) PlexDirectory *directory;

+ (PlexMoreInfoMenuItem *)menuItemForDirectory:(PlexDirectory *)aDirectory;
- (id)initWithDirectory:(PlexDirectory *)aDirectory;
@end
