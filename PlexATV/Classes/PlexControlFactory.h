//
//  Plex_SMFControlFactory.h
//  plex
//
//  Created by bob on 2011-04-08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PlexControlFactory : BRPhotoControlFactory {
    BOOL _alwaysShowTitles;
    BRImage *_defaultImage;
}

@property (assign)BOOL _alwaysShowTitles;
@property (retain)BRImage *defaultImage;

-(BRControl *)controlForImageProxy:(BRURLImageProxy *)imageProxy title:(NSString *)title;
@end
