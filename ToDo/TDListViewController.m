//
//  TDListViewController.m
//  ToDo
//
//  Created by Megha Wadhwa on 19/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TDListViewController.h"
#import "TDItemViewController.h"
#import "TDMainViewController.h"

@interface TDListViewController ()

@end

@implementation TDListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)TDCustomRowTapped:(TDListCustomRow *)sender
{
    if ([super respondsToSelector:@selector(TDCustomRowTapped:)]) {
    // TO CHECK :[super TDCustomRowTapped];
    }
    [self performWithListName:sender.listTextField.text];
}

- (void)performWithListName:(NSString *)listName {
    
    TDListViewController *src = (TDListViewController *) self;
    TDItemViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemViewController"];
    src.childName = listName;
    destination.parentName = @"Lists";
    destination.childName = nil;
    destination.goingBackFlag = NO;
    //destination.parentDelegate = self;
    [UIView transitionWithView:src.navigationController.view duration:0.3
                       options:UIViewAnimationTransitionCurlUp
                    animations:^{
                        [src.navigationController pushViewController:destination animated:YES];
                    }
                    completion:NULL];
    
}
- (void)addChildView
{
    [self performWithListName:self.childName];
}
#pragma mark- Parent Delegate
//- (UIView *)addView
////{
////        float originY = [TDCommon getLastRowMaxYFromArray:self.customViewsArray];
////        UIView *tempView = [[UIView alloc] in]  self.view; 
////        CGRect frame = tempView.frame;
////        frame.origin.y = -200;
////        frame.size.height = originY;
////        tempView.frame = frame;
////        //tempView.backgroundScrollView.backgroundColor = [UIColor yellowColor];
////        tempView.backgroundColor= [UIColor redColor];
////        return tempView;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)removeCurrentView
{
    [UIView animateWithDuration:BACK_ANIMATION delay:BACK_ANIMATION_DELAY options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect myFrame = self.view.frame;
        myFrame.origin.y = 480;
        self.view.frame = myFrame; 
    } completion:^ (BOOL finished) {
            [self.navigationController popViewControllerAnimated:NO]; 
//            TDMainViewController * mainController =(TDMainViewController *)[self.navigationController topViewController];
//            CGRect myFrame = mainController.view.frame;
//            myFrame.origin.y = -480;
//            mainController.view.frame = myFrame;
//            mainController.goingBackFlag = YES;
    }];
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [TDCommon setTheme:THEME_BLUE];
    if (!self.childName && [self.customViewsArray count]!=0) {
        TDListCustomRow *firstRow = (TDListCustomRow *)[self.customViewsArray objectAtIndex:0];
        self.childName = firstRow.listTextField.text;
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    
}
@end
