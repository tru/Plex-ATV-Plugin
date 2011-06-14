//
//  PlexTopShelfView.h
//  plex
//
//  Created by ccjensen on 13/06/2011.
//

#import <Foundation/Foundation.h>

@class PlexTopShelfView;
@protocol PlexTopShelfViewDelegate
- (BOOL)plexTopShelfView:(PlexTopShelfView *)topShelfView shouldSwitchToState:(int)state;
@end

@interface PlexTopShelfView : BRTopShelfView {}
@property (assign) NSObject <PlexTopShelfViewDelegate> *delegate;
@end
