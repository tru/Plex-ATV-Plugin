//
//  Plex_SMFMoviePreviewController.m
//  plex
//
//  Created by ccjensen on 04/04/2011.
//

#import "Plex_SMFMoviePreviewController.h"
#import "HWUserDefaults.h"
#import "Constants.h"

@implementation Plex_SMFMoviePreviewController

@dynamic datasource;

-(void)controlWasActivated
{
    //these 2 are called in SMF on controlWasActivated, so don't call them again here...
    //[self reload];
    //[self reloadShelf];
    [self _removeAllControls];
    [super controlWasActivated];
}

-(void)layoutSubcontrols {
    [super layoutSubcontrols];
    
    //if fanart is not disabled
    if (![[HWUserDefaults preferences] boolForKey:PreferencesViewDisableFanartInDetailedMetadataView]) {
        //background image
        NSURL *artworkUrl = [self.datasource backgroundImageUrl];
        
        //no point in doing all the work if we have no hope of getting an image
        if (artworkUrl) {
            BRURLImageProxy *imageProxy = [BRURLImageProxy proxyWithURL:artworkUrl];
            //[imageProxy setDefaultImage:[[BRThemeInfo sharedTheme] storeRentalPlaceholderImage]];
            
            BRAsyncImageControl *backgroundImageControl = [[BRAsyncImageControl alloc] initWithImageProxy:imageProxy];
            backgroundImageControl.frame = [BRWindow interfaceFrame];
            backgroundImageControl.opacity = 0.5f;
            
#warning why is it not stretching?!
            [backgroundImageControl setContentMode:UIViewContentModeScaleAspectFill];
            
            [self insertControl:backgroundImageControl atIndex:0];
            [backgroundImageControl release];
            
            
            //shadings behind controls
            BRControl *control = [[BRControl alloc] init];
            control.backgroundColor = [[UIColor blackColor] CGColor];
            
            float minX = 60.0f;
            float maxX = 1240.0f;
            
            float minY = 15.0f;
            float maxY = 700.0f;
            
            control.frame = CGRectMake(minX, minY, maxX-minX, maxY-minY);
            [[control layer] setCornerRadius:5.0f];
            
            control.opacity = 0.5f;
            [self insertControl:control atIndex:1];
            [control release];
            
            //remove background from textbox
            _summaryControl.backgroundColor = [[UIColor clearColor] CGColor];
            
            if (_summaryToggled==YES) {
                if (!_summaryControlBackground) {
                    _summaryControlBackground = [[BRControl alloc] init];
                    _summaryControlBackground.backgroundColor = [[UIColor blackColor] CGColor];
                    _summaryControlBackground.borderColor = [[UIColor grayColor] CGColor];
                    _summaryControlBackground.borderWidth = 2.0f;
                    
                    [[_summaryControlBackground layer] setCornerRadius:5.0f];
                    
                    _summaryControlBackground.frame = CGRectMake(_summaryControl.frame.origin.x-10.0f, _summaryControl.frame.origin.y+2.0f, _summaryControl.frame.size.width+20.0f, _summaryControl.frame.size.height+4.0f);
                }
                [self insertControl:_summaryControlBackground below:_summaryControl];
                
            } else {
                [_summaryControlBackground removeFromParent];
            }
        }
    }
}

- (void)dealloc {
    [_summaryControlBackground release];
    [super dealloc];
}

@end
