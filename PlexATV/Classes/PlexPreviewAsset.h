//
//  PlexMediaAsset.h
//  atvTwo
//
//  Created by Frank Bauer on 27.10.10.
//      Modified by ccjensen
//
//
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

#import <Foundation/Foundation.h>
#import <Backrow/Backrow.h>

@class PlexMediaObject;

//needs to be a subclass of photo media asset to enable supercharged grid
@interface PlexPreviewAsset : BRPhotoMediaAsset<BRMediaAsset> {
	NSURL *url;
	PlexMediaObject *pmo;
	NSDateFormatter *shortDateFormatter;
}
@property (nonatomic, retain) PlexMediaObject *pmo;

- (id)initWithURL:(NSURL*)url mediaProvider:(id)mediaProvider mediaObject:(PlexMediaObject*)pmo;
- (NSDate*)dateFromPlexDateString:(NSString*)dateString;

//other metadata methods
@property (readonly) NSURL *coverArtRealURL;
@property (readonly) NSURL *seasonCoverArtRealURL;
@property (readonly) NSURL *fanartUrl;
@property (readonly) BOOL hasClosedCaptioning;
@property (readonly) BOOL hasDolbyDigitalAudioTrack;
@property (readonly) NSString *mediaURL;
@property (readonly) BRImage *starRatingImage;
@property (readonly) NSArray *writers;
@property (readonly) NSString *year;

@end
