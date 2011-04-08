//
//  Plex_SMFControlFactory.m
//  plex
//
//  Created by bob on 2011-04-08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Plex_SMFControlFactory.h"


@implementation Plex_SMFControlFactory


-(BRControl *)controlForImageProxy:(BRURLImageProxy *)imageProxy title:(NSString *)title
{
  if (_poster==YES) {
    DLog(@"plex ext of smfcontrolfactory");
    BRPosterControl *returnObj=[[BRPosterControl alloc] init];
    returnObj.posterStyle = 1;
    returnObj.title = [[NSAttributedString alloc]initWithString:title attributes:[[BRThemeInfo sharedTheme] menuItemSmallTextAttributes]];
    returnObj.imageProxy=imageProxy;
    returnObj.defaultImage=self.defaultImage;
    DLog(@"image size: %@", self.defaultImage);
    returnObj.alwaysShowTitles=self._alwaysShowTitles;
    returnObj.posterBorderWidth=1.0;
    returnObj.titleWidthScale=2.0;
    returnObj.titleVerticalOffset=-0.050500000566244125;
    returnObj.reflectionAmount=0.15000000596046448;
    return [returnObj autorelease];
  }
  else {
    BRAsyncImageControl *returnObj = [BRAsyncImageControl imageControlWithImageProxy:imageProxy];
    //#warning did not test this one, but seemed to make sense for it to use the proxy too ^^
    [returnObj setAcceptsFocus:YES];
    return returnObj;
  }
}

@end
