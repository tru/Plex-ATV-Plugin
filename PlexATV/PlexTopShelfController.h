//
//  PlexTopShelfController.h
//  plex
//
//  Created by tomcool
//  Modified by ccjensen
//

#import <Foundation/Foundation.h>

@interface PlexTopShelfController : NSObject {
	BRTopShelfView *topShelfView;
	BRImageControl *imageControl;
	NSArray *assets;
    BRMediaShelfView *shelfView;
}
@property (retain) NSArray *assets;
- (void)selectCategoryWithIdentifier:(id)identifier;
- (id)topShelfView;
- (void)refresh;
@end