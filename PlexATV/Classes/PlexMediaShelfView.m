//
//  PlexMediaShelfView.m
//  plex
//
//  Created by Tobias Hieta on 8/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlexMediaShelfView.h"

@implementation PlexMediaShelfView
@synthesize adapter;

- (id)init {

    Class cls = NSClassFromString(@"ATVVersionInfo");
    if (cls != nil && [[cls currentOSVersion] isEqualToString:@"5.0"])
    {
        self = [super init];
    } else {
        self = [[NSClassFromString (@"BRMediaShelfControl")alloc] init];
    }
    if (self) {
    }
    return self;
}

- (id)provider {
    return nil;
}

- (void)dealloc {
    [adapter release];
    [super dealloc];
}

- (void)setProvider:(id)provider {

    Class cls = NSClassFromString(@"ATVVersionInfo");
    if (cls != nil && [[cls currentOSVersion] isEqualToString:@"5.0"])
    {
        DLog(@"Using 4.4 provider settings!");
        BRProviderDataSourceAdapter *_adapter = [[NSClassFromString (@"BRProviderDataSourceAdapter")alloc] init];
        [_adapter setProviders:[NSArray arrayWithObjects:provider, nil]];
        [self setDelegate:_adapter];
        [self setDataSource:_adapter];
        self.adapter = _adapter;
        [_adapter release];
    } else {
        [(id) self setProvider:provider];
    }
}

- (id)focusedIndexCompat {
    Class cls = NSClassFromString(@"ATVVersionInfo");
    if (cls != nil && [[cls currentOSVersion] isEqualToString:@"5.0"])
    {
        return [self focusedIndexPath];
    } else {
        return [(id) self focusedIndex];
    }
}

- (void)setFocusedIndexCompat:(id)focusedIndexCompat {
    Class cls = NSClassFromString(@"ATVVersionInfo");
    if (cls != nil && [[cls currentOSVersion] isEqualToString:@"5.0"])
    {
        self.focusedIndexPath = focusedIndexCompat;
    } else {
        [(id) self setFocusedIndex:focusedIndexCompat];
    }
}

@end
