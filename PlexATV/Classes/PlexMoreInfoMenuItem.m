//
//  PlexMoreInfoMenuItem.m
//  plex
//
//  Created by ccjensen on 28/05/2011.
//

#import "PlexMoreInfoMenuItem.h"
#import <plex-oss/PlexDirectory.h>

@implementation PlexMoreInfoMenuItem
@synthesize directory;

+ (PlexMoreInfoMenuItem*)menuItemForDirectory:(PlexDirectory*)aDirectory {
    PlexMoreInfoMenuItem *menuItem = [[PlexMoreInfoMenuItem alloc] initWithDirectory:aDirectory];
    return [menuItem autorelease];
}

- (id)initWithDirectory:(PlexDirectory*)aDirectory {
    self = [super init];
    if (self) {
        self.directory = aDirectory;

        NSString *title = [self.directory.attributes objectForKey:@"tag"];
        [self setText:title withAttributes:nil];
    }
    return self;
}

- (void)dealloc {
    self.directory = nil;
    [super dealloc];
}

@end
