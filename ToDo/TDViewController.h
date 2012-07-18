//
//  TDViewController.h
//  ToDo
//
//  Created by Megha Wadhwa on 19/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToDoList.h"
#import "TDDelegates.h"
#import "TDScrollView.h"
#import "TDConstants.h"
#import "TDCategory.h"
#import "ToDoList.h"
#import "TDScrollView.h"
#import "TDListCustomRow.h"
#import "TDCommon.h"
#import "TDRowLayer.h"

@class TDScrollView;
@class ToDoList;
@class TDListViewController;

@interface TDViewController : UIViewController<TDCustomRowSwipedDelegate,UITextFieldDelegate,TDCustomViewPulledDelegate,TDCustomRowTappedDelegate,TDCustomPinchOutDelegate,TDCustomExtraPullDownDelegate,TDCustomExtraPullUpDelegate>
@property(nonatomic,retain)TDScrollView *backgroundScrollView;
@property(nonatomic,retain) NSMutableArray *listArray;
@property(nonatomic,retain) NSMutableArray *doneArray;
@property(nonatomic,retain) NSMutableArray *customViewsArray;
@property(nonatomic,retain) NSMutableArray *checkedViewsArray;
@property(nonatomic,retain) NSString *parentName;
@property(nonatomic,retain) NSString *childName;
@property(nonatomic,assign) BOOL goingBackFlag;

- (void)getDataFromServer;
- (void)rearrangeRowsAfterRemovingObjectAtIndex:(NSMutableArray*)indexArray withDeletionFlag:(BOOL)flag fromRequiredArray:(NSMutableArray*) requiredArray;
- (void)rearrangeListObjectsAfterRemovingObjectAtIndex:(NSMutableArray*)indexArray withDeletionFlag:(BOOL)flag fromModelArray:(NSMutableArray *)modelArray;
-(void)rearrangeRowsAfterPullUpAtIndex:(NSMutableArray*)indexArray;
- (void)rearrangeListObjectsAfterPullUpWithIndex:(NSMutableArray*)indexArray;
- (void)populateCustomViewsArrayFromListArray;
- (void)animateWhenComingBack;
- (void)toggleSubViews:(BOOL)hide;
- (float)getLastRowHeight;

@end

