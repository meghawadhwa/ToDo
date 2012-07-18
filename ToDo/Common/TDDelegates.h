//
//  TDDelegates.h
//  TD
//
//  Created by Megha Wadhwa on 07/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TDListCustomRow;

@protocol TDDelegates <NSObject>

@end

@protocol TDCustomRowSwipedDelegate<NSObject>
- (void)TDCustomRowToBeDeleted:(BOOL)flag With:(TDListCustomRow *)senderRow bySwipe:(BOOL)Flag;
@end

@protocol TDCustomViewPulledDelegate<NSObject>
- (void)TDCustomViewPulledUp;
- (void)TDCustomViewPulledDownWithNewRow:(TDListCustomRow *)newRow;
- (BOOL)checkedRowsExist;
@end

@protocol TDCustomRowTappedDelegate<NSObject>
- (void)TDCustomRowTapped:(TDListCustomRow *)sender;
@end

@protocol TDCustomPinchOutDelegate<NSObject>
- (TDListCustomRow *)RowAtPoint:(CGPoint)point;
- (int)getRowIndexFromCustomArrayFor:(TDListCustomRow *)row;
- (BOOL)isLastObjectOnView:(TDListCustomRow *)row;  
- (void)shiftByScale:(float)scale forPinch:(BOOL)pinch withState:(UIGestureRecognizerState)state andCreating:(BOOL)creating forCurrentRow: (TDListCustomRow *) customNewRow;
- (void)addNewRow:(TDListCustomRow *)newRow AtIndex:(int)index;
- (void)removeNewRow:(TDListCustomRow *)newRow AtIndex:(int)index;
@end

@protocol TDCustomExtraPullDownDelegate<NSObject>
- (NSString *)getParentName;
//- (void)addParentView;
- (void)removeCurrentView;
@end

@protocol TDCustomExtraPullUpDelegate<NSObject>
- (NSString *)getChildName;
- (void)addChildView;
@end

@protocol TDCustomParentDelegate<NSObject>
- (UIView *)addView;
@end