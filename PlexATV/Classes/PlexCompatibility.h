//
//  PlexCompatibility.h
//  plex
//
//  Created by bob on 2011-11-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

//  BASED ON: 
//  SMFCompatibility.h
//  SMFramework
//
//  Created by Thomas Cool on 7/13/11.
//  Copyright 2011 tomcool.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlexCompatibility : NSObject
{
    BOOL _usingFourPointTwo;
    BOOL _usingFourPointThree;
    BOOL _usingFourPointFour;
}
+(PlexCompatibility *)compat;
-(BOOL)usingFourPointTwo;
-(BOOL)usingFourPointThree;
-(BOOL)usingFourPointFour;
@end

#define PLEX_COMPAT [PlexCompatibility compat]

