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
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexMediaObject.h>
#import "PlexMediaObject+Assets.h"
#import "PlexNavigationController.h"

#pragma mark -
#pragma mark BRTopShelfView Category
@interface BRTopShelfView (specialAdditions)
- (BRImageControl *)productImage;
@end

@implementation BRTopShelfView (specialAdditions)
- (BRImageControl *)productImage {
	return MSHookIvar<BRImageControl *>(self, "_productImage");
}
@end



#pragma mark -
#pragma mark PlexTopShelfController Implementation
@implementation PlexTopShelfController
@synthesize mediaContainer;


#pragma mark -
#pragma mark Object/Class Lifecycle
- (void)dealloc {
	[topShelfView release];
	self.mediaContainer = nil;
	
	[super dealloc];
}

- (BRTopShelfView *)topShelfView {
    if (!topShelfView) {
        topShelfView = [[BRTopShelfView alloc] init];
        
        BRImageControl *imageControl = [topShelfView productImage];
        BRImage *theImage = [BRImage imageWithPath:[[NSBundle bundleForClass:[PlexTopShelfController class]] pathForResource:@"PlexLogo" ofType:@"png"]];
        [imageControl setImage:theImage];
        
        shelfView = MSHookIvar<BRMediaShelfView*>(topShelfView, "_shelf");
        shelfView.scrollable = YES;
        shelfView.dataSource = self;
        shelfView.delegate = self;
    }
    
	//[self refresh];
	return topShelfView;
}

-(void)refresh {
    if ([self.mediaContainer.directories count] > 0) {
		[topShelfView setState:1];
		[shelfView reloadData];
	} else {
		[topShelfView setState:0];
	}
}


#pragma mark -
#pragma mark BRMediaShelf Datasource Methods
-(long)numberOfFlatColumnsInMediaShelf:(BRMediaShelfView *)view {
    return 7;
}

-(long)numberOfSectionsInMediaShelf:(BRMediaShelfView *)view {
    return 2;
}

-(id)mediaShelf:(BRMediaShelfView *)view sectionHeaderForSection:(long)section {
    return nil;
}

-(id)mediaShelf:(BRMediaShelfView *)view titleForSectionAtIndex:(long)section {
    BRTextControl *title = [[BRTextControl alloc] init];
    [title setText:@"Recently Added" withAttributes:[[BRThemeInfo sharedTheme] metadataTitleAttributes]];
	return [title autorelease];
}

-(long)mediaShelf:(BRMediaShelfView *)view numberOfColumnsInSection:(long)section {
    return 10;//[self.mediaContainer.directories count];
}

-(float)horizontalGapForMediaShelf:(BRMediaShelfView *)view {
    return 30.0f;
}

-(float)coverflowMarginForMediaShelf:(BRMediaShelfView *)view {
    return 0.05000000074505806;
}

-(id)mediaShelf:(BRMediaShelfView *)view itemAtIndexPath:(NSIndexPath *)indexPath {
    //int section = [indexPath indexAtPosition:0];
    int row = [indexPath indexAtPosition:1];
    
    PlexMediaObject *pmo = [self.mediaContainer.directories objectAtIndex:row];
    PlexPreviewAsset *asset = pmo.previewAsset;
	NSString *title = nil;
    
	if ([asset.pmo isSeason]) {
		title = [NSString stringWithFormat:@"%@ - %@", [asset.pmo.attributes objectForKey:@"parentTitle"] , [asset title]];
	} else {
		title = [asset title];
	}
    
    BRPosterControl *poster = [[BRPosterControl alloc] init];
    poster.posterStyle = 1;
    poster.cropAspectRatio = 0.66470599174499512;
    
    poster.imageProxy = [asset imageProxy];
    poster.defaultImage = [asset defaultImage];
    poster.reflectionAmount = 0.10000000149011612;
    poster.reflectionBaseline = 0.072999998927116394;
    
    poster.titleVerticalOffset = 0.039999999105930328;
    [poster setNonAttributedTitleWithCrossfade:title];
    
    //poster.image = [asset coverArt];
    
    return poster;
}


#pragma mark -
#pragma mark BRMediaShelf Delegate Methods
- (void)mediaShelf:(id)shelf didSelectItemAtIndexPath:(id)indexPath {
    DLog(@"select event");
    //int section = [indexPath indexAtPosition:0];
    int row = [indexPath indexAtPosition:1];
    
    PlexMediaObject* pmo = [self.mediaContainer.directories objectAtIndex:row];
    [[SMFThemeInfo sharedTheme] playSelectSound];
    [[PlexNavigationController sharedPlexNavigationController] navigateToObjectsContents:pmo];
}

- (void)mediaShelf:(id)shelf didPlayItemAtIndexPath:(id)indexPath {
    DLog(@"play event");
    //int section = [indexPath indexAtPosition:0];
    int row = [indexPath indexAtPosition:1];
    
    PlexMediaObject* pmo = [self.mediaContainer.directories objectAtIndex:row];
    if (pmo.hasMedia) {
        //play media
        [[PlexNavigationController sharedPlexNavigationController] initiatePlaybackOfMediaObject:pmo];
    } else {
        //not media, pretend it was a selection
        [self mediaShelf:shelf didSelectItemAtIndexPath:indexPath];
    }
}

//methods below are never called
- (void)mediaShelf:(id)shelf didFocusItemAtIndexPath:(id)indexPath {
	DLog(@"didFocusItemAtIndexPath never called");
    //int section = [indexPath indexAtPosition:0];
    //int row = [indexPath indexAtPosition:1];
}

- (BOOL)handleObjectSelection:(id)selection userInfo:(id)info {
	DLog(@"handleObjectSelection never called");
    return NO;
}

- (void)selectCategoryWithIdentifier:(id)identifier {
	DLog(@"selectCategoryWithIdentifier never called");
}

@end