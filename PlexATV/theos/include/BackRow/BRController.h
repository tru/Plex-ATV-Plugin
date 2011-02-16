/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/BackRow.framework/BackRow
 */

#import "BRControl.h"

@class BRContextMenuControl, NSMutableDictionary, BRControllerStack;

@interface BRController : BRControl {
@private
	NSMutableDictionary *_labels;	// 40 = 0x28
	BRControllerStack *_stack;	// 44 = 0x2c
	BOOL _depthLimited;	// 48 = 0x30
	BRContextMenuControl *_contextMenu;	// 52 = 0x34
}
@property(assign) BOOL depthLimited;	// G=0x32d8f761; S=0x32d8f751; converted property
@property(retain) BRControllerStack *stack;	// G=0x32d749c9; S=0x32d5e8c5; converted property
+ (id)controllerWithContentControl:(id)contentControl;	// 0x32d8f885
- (id)init;	// 0x32d5e69d
- (void)_contextMenuCancelItemSelected:(id)selected;	// 0x32d8f7a9
- (void)addLabel:(id)label;	// 0x32d6cd85
- (BOOL)brEventAction:(id)action;	// 0x32d8f949
- (BOOL)canBeRemovedFromStack;	// 0x32d8f74d
- (int)contextMenuDimOption;	// 0x32d8f7a1
- (BOOL)contextMenuIsVisible;	// 0x32d8f831
- (id)controlForContextMenuPositioning;	// 0x32d8f795
- (id)controlForContextMenuStart;	// 0x32d8f799
- (id)controlToDim;	// 0x32d8f79d
- (void)controlWasDeactivated;	// 0x32d8fc01
- (void)dealloc;	// 0x32d6b1c5
// converted property getter: - (BOOL)depthLimited;	// 0x32d8f761
- (id)description;	// 0x32d7ee7d
- (void)dismissContextMenu;	// 0x32d8f7f1
- (long)errorNumberForNoContent;	// 0x32d8f775
- (BOOL)isLabelled:(id)labelled;	// 0x32d749d9
- (BOOL)isNetworkDependent;	// 0x32d5e949
- (BOOL)isValidAfterDataUpdate;	// 0x32d8f771
- (id)providersForContextMenu;	// 0x32d8f791
- (BOOL)recreateOnReselect;	// 0x32d792e9
- (void)removeLabel:(id)label;	// 0x32d77925
- (BOOL)requiresAuthentication:(id *)authentication mode:(int *)mode;	// 0x32d8f78d
// converted property setter: - (void)setDepthLimited:(BOOL)limited;	// 0x32d8f751
// converted property setter: - (void)setStack:(id)stack;	// 0x32d5e8c5
// converted property getter: - (id)stack;	// 0x32d749c9
- (BOOL)topOfStack;	// 0x32d8f859
- (id)transitionType;	// 0x32d8f77d
- (void)wasBuried;	// 0x32d8f7dd
- (void)wasExhumed;	// 0x32d8f7a5
- (void)wasPopped;	// 0x32d6b171
- (void)wasPushed;	// 0x32d6a89d
@end
