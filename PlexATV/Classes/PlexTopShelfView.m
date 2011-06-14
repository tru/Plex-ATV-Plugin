//
//  PlexTopShelfView.m
//  plex
//
//  Created by ccjensen on 13/06/2011.
//

#import "PlexTopShelfView.h"


@implementation PlexTopShelfView
@synthesize delegate;

//for some reason the atv inner bits calls this method with a 0, 
//even though we have specifically set it
- (void)setState:(int)state {
    if ([self.delegate plexTopShelfView:self shouldSwitchToState:state]) {
        [super setState:state];
    }
}

@end
