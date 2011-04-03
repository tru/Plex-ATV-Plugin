//
//  PlexTopShelfController.m
//  plex
//
//  Created by tomcool
//  Modified by ccjensen
//

#define LOCAL_DEBUG_ENABLED 1

#import "PlexTopShelfController.h"
#import "HWAppliance.h"
#import "BackRowExtras.h"
#import "PlexPreviewAsset.h"
#import <plex-oss/PlexMediaObject.h>

@interface BRTopShelfView (specialAdditions)
- (BRImageControl *)productImage;
@end


@implementation BRTopShelfView (specialAdditions)
- (BRImageControl *)productImage {
	return MSHookIvar<BRImageControl *>(self, "_productImage");
}
@end

@implementation PlexTopShelfController
@synthesize assets;

- (void)initWithApplianceController:(id)applianceController {}

- (BRTopShelfView *)topShelfView {
	topShelfView = [[BRTopShelfView alloc] init];
	
	imageControl = [topShelfView productImage];
	BRImage *theImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[PlexTopShelfController class]] pathForResource:@"PlexLogo" ofType:@"png"]];
	[imageControl setImage:theImage];
	
    shelfView = MSHookIvar<BRMediaShelfView*>(topShelfView, "_shelf");
	shelfView.scrollable = YES;
    shelfView.dataSource=self;
    shelfView.delegate=self;
    
	[self refresh];
	return topShelfView;
}

- (void)dealloc {
	[topShelfView release];
	[shelfView release];
	[imageControl release];
	self.assets = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark Delegate Methods
-(long)numberOfSectionsInMediaShelf:(BRMediaShelfView *)view {
    return 1;
}

-(id)mediaShelf:(BRMediaShelfView *)view titleForSectionAtIndex:(long)section {
    BRTextControl *title = [[[BRTextControl alloc] init] autorelease];
	[title setText:@"Recently Added" withAttributes:[[BRThemeInfo sharedTheme] metadataTitleAttributes]];
	return title;
}

-(long)mediaShelf:(BRMediaShelfView *)view numberOfColumnsInSection:(long)section {
    return [self.assets count];
}

-(float)horizontalGapForMediaShelf:(BRMediaShelfView *)view {
    return 30.f;
}

-(float)coverflowMarginForMediaShelf:(BRMediaShelfView *)view {
    return 0.05000000074505806;
}

- (void)mediaShelf:(id)shelf didFocusItemAtIndexPath:(id)indexPath {
    NSLog(@"self: %@,path %@",shelf,indexPath);
}

-(void)refresh {
    if ([self.assets count] > 0) {
		[topShelfView setState:1];
		[shelfView reloadData];
	} else {
		[topShelfView setState:0];
	}
}

- (BOOL)handleObjectSelection:(id)selection userInfo:(id)info {
    NSLog(@"handleObjectSelection");
    return NO;
}

-(id)mediaShelf:(BRMediaShelfView *)view sectionHeaderForSection:(long)section {
    return nil;
}

-(long)numberOfFlatColumnsInMediaShelf:(BRMediaShelfView *)view {
    return 6;
}

-(id)mediaShelf:(BRMediaShelfView *)view itemAtIndexPath:(NSIndexPath *)path {
	NSLog(@"index: %d,count %d",[path indexAtPosition:1],[self.assets count]);
    PlexPreviewAsset *asset = [self.assets objectAtIndex:[path indexAtPosition:1]];
	//NSLog(@"asset coverart: %@",[asset coverArt]);
	NSString *title = nil;
    
	if ([asset.pmo isSeason]) {
		title = [NSString stringWithFormat:@"%@ - %@", [asset.pmo.attributes objectForKey:@"parentTitle"] , [asset title]];
	} else {
		title = [asset title];
	}
    
	
    id poster = [BRPosterControl posterButtonWithImage:[asset coverArt] title:title];
	NSLog(@"poster %@",poster);
    return poster;
}

- (void)selectCategoryWithIdentifier:(id)identifier {
	NSLog(@"selected with identifier %d", identifier);
}
@end