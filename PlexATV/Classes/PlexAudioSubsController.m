//
//  PlexAudioSubsController.m
//  plex
//
//  Created by bob on 2011-05-03.
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  

#import "PlexAudioSubsController.h"
#import "Constants.h"
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaObject + VideoDetails.h>
#define LOCAL_DEBUG_ENABLED 1

@implementation PlexAudioSubsController
@synthesize playbackItem;
@synthesize detailedItem;
@synthesize items;

#pragma mark -
#pragma mark Object/Class Lifecycle

- (id)init {
  self = [super init];
  if (self) {
    [self setListTitle:@"PLEX"];
		
		NSString *plexIcon = [[NSBundle bundleForClass:[PlexAudioSubsController class]] pathForResource:@"PlexIcon" ofType:@"png"];
		BRImage *listIcon = [BRImage imageWithPath:plexIcon];
		[self setListIcon:listIcon horizontalOffset:0.0 kerningFactor:0.15];
		playbackItem = nil;        
    [self.list setDatasource:self];
  }
  return self;
}

- (id)initWithMediaObject:(PlexMediaObject*)mediaObject {
	self = [self init];
	self.playbackItem = mediaObject;
  
  self.listTitle = @"Audio & Video";
  [self populateListWithStreams];
  
#if LOCAL_DEBUG_ENABLED
  DLog(@"Audio Streams: %@", [detailedItem audioStreamsForLanguage:nil haveFallback:NO]);
  DLog(@"Sub Streams: %@", [detailedItem subtitleStreamsForLanguage:nil haveFallback:NO]);
  
  DLog(@"init done");
#endif
	return self;
}

- (void)populateListWithStreams {
  NSMutableArray *streams = [[NSMutableArray alloc] initWithCapacity:4];
  
  self.detailedItem = [self.playbackItem loadVideoDetails];
  
  [[self list] addDividerAtIndex:0 withLabel:@"Audio tracks"];
  [streams addObjectsFromArray:[detailedItem audioStreamsForLanguage:nil haveFallback:NO]];
  [[self list] addDividerAtIndex:[streams count] withLabel:@"Subtitles"];
  [streams addObjectsFromArray:[detailedItem subtitleStreamsForLanguage:nil haveFallback:NO]];
  
  self.items = [NSArray arrayWithArray:streams];
  [streams release];
}

- (void)log:(NSNotificationCenter *)note {
	DLog(@"note = %@", note);
}

-(void)dealloc
{
	DLog(@"deallocing PlexAudioSubsController");
	[playbackItem release];
  [self.items release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Controller Lifecycle behaviour
- (void)wasPushed {
	[super wasPushed];
}

- (void)wasPopped {
	[super wasPopped];
}

- (void)wasExhumed {
	[super wasExhumed];
}

- (void)wasBuried {
	[super wasBuried];
}

#pragma mark -
#pragma mark BRMenuListItemProvider Datasource
- (long)itemCount {
	return [self.items count];
}


- (float)heightForRow:(long)row {	
  float height;
  /* 
   PlexMediaObject *pmo = [self.items objectAtIndex:row];
   if (pmo.hasMedia || [@"Video" isEqualToString:pmo.containerType]) {
   height = 70.0f;
   } else {
   height = 0.0f;
   }
   */
  return 0.0f;
}


- (id)titleForRow:(long)row {
	PlexMediaStream *stream = [self.items objectAtIndex:row];
  return stream.streamDescription;
}

- (id)itemForRow:(long)row {
	if(row > [self.items count])
		return nil;
  
  PlexMediaStream *stream = [self.items objectAtIndex:row];
  BRMenuItem * menuItem = [[BRMenuItem alloc] init];
  
  NSString *streamInfo = [NSString stringWithFormat:@"%@ (%@)",stream.language,stream.streamDescription];

  //format the text
  if ([stream.streamDescription length] != 0)
    [menuItem setText:streamInfo withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];
  else
    [menuItem setText:stream.language withAttributes:[[BRThemeInfo sharedTheme] menuItemTextAttributes]];  

  //show which is selected by using the checkmark icon
  if (stream.selected)
    [menuItem addAccessoryOfType:17];
  else
    [menuItem addAccessoryOfType:0];
  return [menuItem autorelease];
  
}


- (id)previewControlForItem:(long)item {    
  return nil;
}

#pragma mark -
#pragma mark BRMenuListItemProvider Delegate
- (BOOL)rowSelectable:(long)selectable {
	return TRUE;
}

- (void)itemSelected:(long)selected; {
	DLog(@"selected: %@",[self.items objectAtIndex:selected]);
  PlexMediaStream *selectedStream = [self.items objectAtIndex:selected];
  
  if (selectedStream.streamType == PlexMediaStreamTypeAudio) {
    [self.detailedItem setAudioStream:selectedStream];
  } else if (selectedStream.streamType == PlexMediaStreamTypeSubtitle) {
    [self.detailedItem setSubtitleStream:selectedStream];
  }
  /*  WHY THE FUCK WON'T THIS WORK? IT IS INTEGER YOU STOOPID THING 
   switch (selectedStream.streamType) {
   case PlexMediaStreamTypeAudio:
   [self.detailedItem setAudioStream:selectedStream];
   break;
   case PlexMediaStreamTypeSubtitle:
   [self.detailedItem setSubtitleStream:selectedStream];
   break;
   
   default:
   break;
   }
   */
  
  
  //repopulate the list
  [self populateListWithStreams];
  
  //refresh the gui
  [self.list reload];
  
}


@end

