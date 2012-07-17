//
//  TDScrollView.h
//  TD
//
//  Created by Megha Wadhwa on 06/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDDelegates.h"
#import "TDConstants.h"
#import "TDCommon.h"

@class TDListCustomRow;
@class TDListViewController;
@interface TDScrollView : UIView
@property(assign) CGPoint initialCentre;
@property(assign) float initialDistance;
@property(assign) BOOL pullUpDetected;
@property(assign)BOOL pullDownDetected;
@property(assign)BOOL startedpullingDownFlag; //This flag ensures rotation when pulled up again after pulldown first
@property(assign)BOOL checkedRowsExist; 
@property(nonatomic,retain)UIView *overlayView;
@property(nonatomic,assign) id<TDCustomViewPulledDelegate> pullDelegate;
@property(nonatomic,assign) id<TDCustomPinchOutDelegate> pinchOutdelegate;
@property(nonatomic,assign) id<TDCustomExtraPullDownDelegate> extraPullDownDelegate;
@property(nonatomic,retain) TDListCustomRow *customNewRow;
@property(nonatomic,retain)  TDListCustomRow *RowAdded;
@property(nonatomic,retain)  UIView *pullUpView;
@property(nonatomic,retain)  UIImageView *arrowImageView;
@property(nonatomic,retain)  UIImageView *boxImageView;
@property(nonatomic,retain) NSMutableArray *customViewsArray;
@property(nonatomic,retain) NSMutableArray *checkedViewsArray;
@property(nonatomic,retain) UIPinchGestureRecognizer *pinchRecognizer;
@property(nonatomic,assign) BOOL creatingNewRow;
@property(nonatomic,assign) BOOL extraPullDownDetected;
@property(nonatomic,assign) BOOL extraPullUpDetected;
@property(nonatomic,retain)  UIImageView *upArrowImageView;
@property(nonatomic,retain)  UIImageView *smileyImageView;
@property(nonatomic,retain)  UIView *switchUpView;
- (void)overlayViewTapped;
@end
