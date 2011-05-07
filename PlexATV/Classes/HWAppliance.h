/*
 *  HWAppliance.h
 *  atvTwo
 *
 *  Created by Frank Bauer on 15.01.11.
 *  Modified by ccjensen
 */


#import "BackRowExtras.h"
@class PlexTopShelfController, PlexMediaContainer;

@interface PlexAppliance: BRBaseAppliance <MachineManagerDelegate> {
	PlexTopShelfController *_topShelfController;
	NSMutableArray *_applianceCategories;
	
	BRApplianceCategory *otherServersApplianceCategory;
	BRApplianceCategory *settingsApplianceCategory;
}
@property(nonatomic, readonly, retain) id topShelfController;
@property(retain) NSMutableArray *applianceCat;

@end