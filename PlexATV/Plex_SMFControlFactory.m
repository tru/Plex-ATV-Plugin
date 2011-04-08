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
  DLog(@"plex ext of smfcontrolfactory");
  if (_poster==YES) {
    BRPosterControl *returnObj=[[BRPosterControl alloc] init];
    returnObj.posterStyle = 0;
    returnObj.title = [[NSAttributedString alloc]initWithString:title attributes:[[BRThemeInfo sharedTheme] menuItemSmallTextAttributes]];
    returnObj.imageProxy=imageProxy;
    returnObj.defaultImage=self.defaultImage;
    returnObj.alwaysShowTitles=self._alwaysShowTitles;
    returnObj.posterBorderWidth=1.f;
    returnObj.titleWidthScale=1.3999999761581421;
    returnObj.titleVerticalOffset=0.054999999701976776;
    returnObj.reflectionAmount=0.14000000059604645;
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
