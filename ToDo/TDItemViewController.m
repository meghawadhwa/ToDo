//
//  TDItemViewController.m
//  ToDo
//
//  Created by Megha Wadhwa on 17/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TDItemViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "TDListViewController.h"

@implementation TDItemViewController
@synthesize parentDelegate;

- (void)addParentView{
//    if([self.parentDelegate respondsToSelector:@selector(addView)])
//    {   
//        UIView *parentView = [self.parentDelegate addView];
//        [self.backgroundScrollView addSubview:parentView];
//    }
}

- (void)createTemporaryModalData
{
    NSNumber *id1= [NSNumber numberWithInt:100];
    NSNumber *donestatus= [NSNumber numberWithInt:0];
    NSNumber *id2= [NSNumber numberWithInt:101];
    NSNumber *id3= [NSNumber numberWithInt:102];

    NSDictionary *dict1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"Swipe Checked",kListName,id1,kListId,donestatus,kDoneStatus,nil];
    NSDictionary *dict2 = [[NSDictionary alloc] initWithObjectsAndKeys:@"Extra Pull Down",kListName,id2,kListId,donestatus,kDoneStatus,nil];
    NSDictionary *dict3 = [[NSDictionary alloc] initWithObjectsAndKeys:@"Extra Pull Up",kListName,id3,kListId,donestatus,kDoneStatus,nil];

    NSArray *responseArray = [NSArray arrayWithObjects:dict1,dict2,dict3,nil];
    for (int i =0; i<3 ; i++) {
        ToDoList * aList = [[ToDoList alloc] init];
        [aList readFromDictionary:[responseArray objectAtIndex:i]];
        [self.listArray addObject:aList];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [TDCommon setTheme:THEME_HEAT_MAP];
    if ([self.listArray count] == 0) {
        [self createTemporaryModalData];
        [self populateCustomViewsArrayFromListArray];
    }
}

- (void)removeCurrentView
{
    [UIView animateWithDuration:BACK_ANIMATION delay:BACK_ANIMATION_DELAY options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect myFrame = self.view.frame;
        myFrame.origin.y = 480;
        self.view.frame = myFrame; 
    } completion:^ (BOOL finished) {
        if (finished) {
            [self.navigationController popViewControllerAnimated:NO]; 
//            TDListViewController * listController =(TDListViewController *)[self.navigationController topViewController];
////            CGRect myFrame = listController.view.frame;
//            myFrame.origin.y = -480;
//            listController.view.frame = myFrame;
//              listController.goingBackFlag = YES;
        }
    }];

}
- (void)viewDidAppear:(BOOL)animated
{ 
    if (self.goingDownByPullUp) {
    [UIView animateWithDuration:0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{  
        CGRect myFrame = self.view.frame;
        myFrame.origin.y = 480;
        self.view.frame = myFrame;
    } completion:^(BOOL fin){
        [UIView animateWithDuration:0.6 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self toggleSubViews:NO];
            CGRect myFrame = self.view.frame;
            myFrame.origin.y = 0.0;
            self.view.frame = myFrame;
        } 
                         completion: nil];
    }];
}
else {
    float originY = [self getLastRowHeight];
    [UIView animateWithDuration:0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{  
        CGRect myFrame = self.view.frame;
        myFrame.origin.y = -originY;
        self.view.frame = myFrame;
    } completion:^(BOOL fin){
        [UIView animateWithDuration:0.6 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self toggleSubViews:NO];
            CGRect myFrame = self.view.frame;
            myFrame.origin.y = 0.0;
            self.view.frame = myFrame;
        } 
                         completion: nil];
    }];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [TDCommon setTheme:THEME_HEAT_MAP];
    [self toggleSubViews:YES];
}
@end
