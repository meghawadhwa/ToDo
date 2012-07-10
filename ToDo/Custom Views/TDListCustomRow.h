//
//  TDListCustomRow.h
//  TD
//
//  Created by Megha Wadhwa on 06/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDListCustomRow.h"
#import "TDDelegates.h"
#import "TDStrikedLabel.h"
#import "TDConstants.h"
#import "TDScrollView.h"
#import "TDRowLayer.h"

@class TDScrollView;
@class TDStrikedLabel;
@class TDRowLayer;

@interface TDListCustomRow : UIView<UITextFieldDelegate>
@property(nonatomic,retain) UITextField *listTextField;
@property(assign) id<TDCustomRowSwipedDelegate> swipeDelegate;
@property(nonatomic) CGPoint initialCentre;
@property(nonatomic) CGPoint startPoint;
@property(nonatomic,assign) BOOL leftSwipeDetected;
@property(nonatomic,assign) BOOL rightSwipeDetected;
@property(nonatomic,assign) BOOL PullDetected;
@property(nonatomic,assign) BOOL swipeDetected;
@property(nonatomic,assign) BOOL doneStatus;
@property(nonatomic,retain) TDStrikedLabel *strikedLabel;
@property(nonatomic,retain)UIColor *defaultRowColor;
@property(nonatomic,retain)UIView *doneOverlayView;
@property(nonatomic,retain)UIImageView *checkImgView;
@property(nonatomic,retain)UIImageView *deleteImgView;
@property(assign) id<TDCustomRowTappedDelegate> tapDelegate;
//@property (nonatomic,retain) CALayer *topHalfLayer;
//@property (nonatomic,retain) CALayer *bottomHalfLayer;
@property (nonatomic,retain) TDRowLayer *innerLayer;

- (void)makeStrikedLabel;
- (void)makeCheckedIcon;
- (void)customRowRightSwipe:(NSSet *)touches withEvent:(UIEvent*)event;
- (void)customRowLeftSwipe:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)makeDeleteIcon;
- (void)createDoneOverlayAtHeight:(float)height;
- (void)doneOverlayViewTapped;
- (void)divideIntoTwoLayers;
//- (void)layoutSublayers;

@end
