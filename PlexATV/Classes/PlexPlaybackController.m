//
//  PlexPlaybackController.m
//  plex
//
//  Created by Bob Jelica on 22.02.2011.
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

#import "PlexPlaybackController.h"
#import "Constants.h"
#import "HWUserDefaults.h"
#import <plex-oss/PlexMediaObject.h>
#import <plex-oss/PlexMediaContainer.h>
#import <plex-oss/PlexImage.h>
#import <plex-oss/PlexRequest.h>
#import <plex-oss/Preferences.h>
#import <plex-oss/PlexStreamingQuality.h>
#import "PlexMediaProvider.h"
#import "PlexMediaAsset.h"
#import "PlexMediaAssetOld.h"
#import "PlexPreviewAsset.h"
#import "PlexSongAsset.h"

#define LOCAL_DEBUG_ENABLED 1


PlexMediaProvider* __provider = nil;

#define ResumeOptionDialog @"ResumeOptionDialog"

#define kStartTrackingProgressTime 120.0f
#define kEndTrackingProgressTime 120.0f
#define kEndTrackingProgressPercentageCompleted 0.95f

@implementation PlexPlaybackController

#pragma mark -
#pragma mark Object/Class Lifecycle
- (id) init
{
	self = [super init];
	if (self != nil) {
		//register for notifications when a movie has finished playing properly to the end.
		//used to mark movie as seen
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinished:) name:@"AVPlayerItemDidPlayToEndTimeNotification" object:nil];
    
	}
	return self;
}

- (void)myMethod:(NSNotification *)notification {
  DLog(@"notification received: %@", notification);
}

-(id)initWithPlexMediaObject:(PlexMediaObject*)mediaObject {
	[self init];
	
	if (self != nil) {
		pmo = [mediaObject retain];
	}
	
	return self;
}

- (void) dealloc {
	DLog(@"deallocing player controller for %@", pmo.name);
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
  
	[pmo autorelease];
	[super dealloc];
}


#pragma mark -
#pragma mark Controller Lifecycle behaviour
- (void)wasPushed {
	DLog(@"activating plex_playback controller");
	[self startPlaying];	
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
#pragma mark Playback Methods
-(void)startPlaying {
	
	if ([@"Track" isEqualToString:pmo.containerType]){
		DLog(@"ITS A TRAP(CK)!");
		[self playbackAudio];
	}
	else {
		DLog(@"viewOffset: %@", [pmo.attributes valueForKey:@"viewOffset"]);
		
        NSNumber *viewOffset = [NSNumber numberWithInt:[[pmo.attributes valueForKey:@"viewOffset"] intValue]];

        float totalOffsetInSeconds = [viewOffset intValue] / 1000.0f;
        //if progress is less than start tracking time, don't even bother to ask if video should be resumed.
        if (totalOffsetInSeconds < kStartTrackingProgressTime) {
            viewOffset = [NSNumber numberWithInt:0];
        }
        
		//we have offset, ie. already watched a part of the movie, show a dialog asking if you want to resume or start over
		if ([viewOffset intValue] > 0) {
			NSNumber *viewOffset = [NSNumber numberWithInt:[[pmo.attributes valueForKey:@"viewOffset"] intValue]];
			
			BROptionDialog *option = [[BROptionDialog alloc] init];
			[option setIdentifier:ResumeOptionDialog];
			
			[option setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                           viewOffset, @"viewOffset", 
                           pmo, @"mediaObject",
                           nil]];
			[option setPrimaryInfoText:@"You have already watched a part of this video.\nWould you like to continue where you left off, or start from beginning?"];
			[option setSecondaryInfoText:pmo.name];
			
			int offsetInHrs = [viewOffset intValue] / (1000*60*60);
			int offsetInMins = ([viewOffset intValue] % (1000*60*60)) / (1000*60);
			int offsetInSecs = (([viewOffset intValue] % (1000*60*60)) % (1000*60)) / 1000;
			
			if (offsetInHrs > 0)
				[option addOptionText:[NSString stringWithFormat:@"Resume from %d hrs %d mins %d secs", offsetInHrs, offsetInMins, offsetInSecs]];
			else
				[option addOptionText:[NSString stringWithFormat:@"Resume from %d mins %d secs", offsetInMins, offsetInSecs]];
			
			[option addOptionText:@"Play from the beginning"];
			[option addOptionText:@"Go back"];
			[option setActionSelector:@selector(optionSelected:) target:self];
			[[[BRApplicationStackManager singleton] stack] pushController:option];
			[option release];
		}
		else {
			[self playbackVideoWithOffset:0]; //just start playback from beginning
		}
	}
}

-(void)playbackVideoWithOffset:(int)offset {
	DLog(@"playback of video initiated, tell MM to chill");
	//playback started, tell MM to chill
	[[MachineManager sharedMachineManager] stopAutoDetection];
	[[MachineManager sharedMachineManager] stopMonitoringMachineState];
	
	[pmo.attributes setObject:[NSNumber numberWithInt:offset] forKey:@"viewOffset"]; //set where in the video we want to start...
	
  //determine the user selected quality setting
	NSString *qualitySetting = [[HWUserDefaults preferences] objectForKey:PreferencesQualitySetting];
	PlexStreamingQualityDescriptor *streamQuality;
	if ([qualitySetting isEqualToString:@"Good"]) {
		streamQuality = [PlexStreamingQualityDescriptor qualityiPadWiFi];
	} else 	if ([qualitySetting isEqualToString:@"Best"]) {
		streamQuality = [PlexStreamingQualityDescriptor quality1080pLow];
	} else { //medium (default)
		streamQuality = [PlexStreamingQualityDescriptor quality720pHigh];
	}
	pmo.request.machine.streamQuality = streamQuality;
	
	DLog(@"streaming bitrate: %d", pmo.request.machine.streamingBitrate);	
	DLog(@"Quality: %@", pmo.request.machine.streamQuality);
	//DLog(@"%@", pmo.request.machine.capabilities.qualities);
	NSURL* mediaURL = [pmo mediaURL];
	
	DLog(@"Starting Playback of %@", mediaURL);
	
	BOOL didTimeOut = NO;
#warning what cache policy should we use??
  [pmo.request dataForURL:mediaURL authenticateStreaming:YES timeout:0 didTimeout:&didTimeOut cachePolicy:NSURLCacheStorageNotAllowed];
	
	
	
	if (__provider==nil){
		__provider = [[PlexMediaProvider alloc] init];
		BRMediaHost* mh = [[BRMediaHost mediaHosts] objectAtIndex:0];
		[mh addMediaProvider:__provider];
    [__provider release];
	}
	
	if (playProgressTimer){
		[playProgressTimer invalidate];
		[playProgressTimer release];
		playProgressTimer = nil;
	}
	
	BRBaseMediaAsset* pma = nil;
	if ([[[UIDevice currentDevice] systemVersion] isEqualToString:@"4.1"]){
		pma = [[PlexMediaAssetOld alloc] initWithURL:mediaURL mediaProvider:nil mediaObject:pmo];
	} else {
		pma = [[PlexMediaAsset alloc] initWithURL:mediaURL mediaProvider:nil mediaObject:pmo];
	}
	
  //DLog(@"mediaItem: %@", [pma mediaItemRef]);
	
	BRMediaPlayerManager* mgm = [BRMediaPlayerManager singleton];
	NSError * error = nil;
	BRMediaPlayer * player = [mgm playerForMediaAsset:pma error: &error];
	
	DLog(@"pma=%@, prov=%@, mgm=%@, play=%@, err=%@", pma, __provider, mgm, player, error);
	
	if ( error != nil ){
		DLog(@"b0bben: error in brmediaplayer, aborting");
		[pma release];
		return ;
	}
	
	
  //[mgm presentMediaAsset:pma options:0];
	[mgm presentPlayer:player options:0];
  
	DLog(@"presented player");
  playProgressTimer = [[NSTimer scheduledTimerWithTimeInterval:10.0f 
                                                        target:self 
                                                      selector:@selector(reportProgress:) 
                                                      userInfo:nil 
                                                       repeats:YES] retain];
  
  //we need all the memory we can spare so we don't get killed by the OS
	[pma release];
  [pmo.thumb release];
  [pmo.art release];
  [pmo.banner release];
  [pmo.parentObject release];
  //we'll use this notification to catch the menu-ing out of a movie, ie. the stopped notification from the main player instead of relying on our timer
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStateChanged:) name:@"BRMPStateChanged" object:nil];
}

-(void)playbackAudio {
	DLog(@"playback of audio initiated, tell MM to chill");
	//playback started, tell MM to chill
	[[MachineManager sharedMachineManager] stopAutoDetection];
	[[MachineManager sharedMachineManager] stopMonitoringMachineState];
	
	NSError *error;
	
	DLog(@"track_url: %@", [pmo mediaStreamURL]);
	DLog(@"key: %@", [pmo.attributes objectForKey:@"key"]);
	
	PlexSongAsset *psa = [[PlexSongAsset alloc] initWithURL:[pmo.attributes objectForKey:@"key"] mediaProvider:nil mediaObject:pmo];
	
	BRMediaPlayer *player = [[BRMediaPlayerManager singleton] playerForMediaAsset:psa error:&error];
	[psa release];
	
	[[BRMediaPlayerManager singleton] presentPlayer:player options:nil];
	
	DLog(@"presented audio player");
}

-(void)reportProgress:(NSTimer*)tm {
	BRMediaPlayer *playa = [[BRMediaPlayerManager singleton] activePlayer];

	switch (playa.playerState) {
		case kBRMediaPlayerStatePlaying: {
			//report time back to PMS so we can continue in the right spot
			float current = playa.elapsedTime;
			float total = [[[pmo mediaResource] attributes] integerForKey:@"duration"]/1000.0f;

			// Ignore time at start and at the end, or when an item is a certain percentage completed            
            if (current > kStartTrackingProgressTime 
                && total - current > kEndTrackingProgressTime 
                && kEndTrackingProgressPercentageCompleted > current/total) {
                DLog(@"posting progress [%f]", current);
				[pmo postMediaProgress:playa.elapsedTime];
			}
            
            //if not already marked as seen, and when an item is a certain percentage completed
            if ( [pmo seenState] != PlexMediaObjectSeenStateSeen 
                && kEndTrackingProgressPercentageCompleted < current/total) {
                DLog(@"more than %f completed, mark as watched", kEndTrackingProgressPercentageCompleted);
                [pmo markSeen];
            }
            
            NSString *seenState;
            if ([pmo seenState] == PlexMediaObjectSeenStateUnseen) {
                seenState = @"unwatched";
            } else if ([pmo seenState] == PlexMediaObjectSeenStateInProgress) {
                seenState = @"partial";
            } else if ([pmo seenState] == PlexMediaObjectSeenStateSeen) {
                seenState = @"watched";
            } else {
                seenState = @"unknown";
            }
            DLog(@"current [%f] out of a total [%f] (%f2 percentage). watched status [%@]", current, total, (current/total)*100.f, seenState);
            
			break;
		}
		case kBRMediaPlayerStatePaused:
			DLog(@"paused playback, pinging transcoder");
			[pmo.request pingTranscoder];
			break;
		default:
			break;
	}
}

-(void)movieFinished:(NSNotification*)event {
    [pmo markSeen];
    [[[BRApplicationStackManager singleton] stack] popController];
}

-(void)playerStateChanged:(NSNotification*)event {
  //DLog(@"%@", event)
  BRMediaPlayer *playa = [[BRMediaPlayerManager singleton] activePlayer];
  switch (playa.playerState) {
    case kBRMediaPlayerStateStopped:
      DLog(@"stopping the transcoder");
      
      //stop the transcoding on PMS
      [pmo.request stopTranscoder];
      DLog(@"transcoder stopped");
      
      if (playProgressTimer && [playProgressTimer isValid]){
        [playProgressTimer invalidate];
        [playProgressTimer release];
        playProgressTimer = nil;
        DLog(@"stopped progress timer");
      }
      
      DLog(@"Finished Playback, fire up MM");
      //playback stopped, tell MM to fire up again
      [[MachineManager sharedMachineManager] startAutoDetection];
      [[MachineManager sharedMachineManager] startMonitoringMachineState];
      [[[BRApplicationStackManager singleton] stack] popController];
      break;
      
    default:
      break;
  }
  
}

#pragma mark -
#pragma mark BROptionDialog handler
- (void)optionSelected:(id)sender {
	BROptionDialog *option = sender;
	if ([option.identifier isEqualToString:ResumeOptionDialog]) {
		NSNumber *viewOffset = [option.userInfo objectForKey:@"viewOffset"];
		
		if([[sender selectedText] hasPrefix:@"Resume from"]) {
			[[[BRApplicationStackManager singleton] stack] popController]; //need this so we don't go back to option dialog when going back
			DLog(@"Resuming from %d ms", [viewOffset intValue]);
			[self playbackVideoWithOffset:[viewOffset intValue]];
		} else if ([[sender selectedText] isEqualToString:@"Play from the beginning"]) {
			[[[BRApplicationStackManager singleton] stack] popController]; //need this so we don't go back to option dialog when going back
			[self playbackVideoWithOffset:0]; //0 offset is beginning, mkay?
		} else if ([[sender selectedText] isEqualToString:@"Go back"]) {
			//go back to movie listing...
			[[[BRApplicationStackManager singleton] stack] popController];
		}
	}
}


@end
