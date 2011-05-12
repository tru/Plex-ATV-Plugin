//
//  PlexTopShelfController.h
//  plex
//
//  Created by tomcool
//  Modified by ccjensen
//

#import <Foundation/Foundation.h>
@class PlexMediaContainer;

@interface PlexTopShelfController : NSObject {
	BRTopShelfView *topShelfView;
    BRMediaShelfView *shelfView;
}
@property (retain) PlexMediaContainer *mediaContainer;

- (void)selectCategoryWithIdentifier:(id)identifier;
- (id)topShelfView;
- (void)refresh;
@end