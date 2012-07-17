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

- (void)removeCurrentView
{
    [UIView animateWithDuration:BACK_ANIMATION delay:BACK_ANIMATION_DELAY options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect myFrame = self.view.frame;
        myFrame.origin.y = 480;
        self.view.frame = myFrame; 
    } completion:^ (BOOL finished) {
        if (finished) {
            [self.navigationController popViewControllerAnimated:NO]; 
            TDListViewController * listController =(TDListViewController *)[self.navigationController topViewController];
            CGRect myFrame = listController.view.frame;
            myFrame.origin.y = -480;
            listController.view.frame = myFrame;
            listController.goingBackFlag = YES;
        }
    }];

}
@end
