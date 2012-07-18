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
    [src.navigationController pushViewController:destination animated:YES];   
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

- (void)createTemporaryModalData
{
    NSNumber *id1= [NSNumber numberWithInt:100];
    NSNumber *donestatus= [NSNumber numberWithInt:0];
    
    NSDictionary *dict1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"PersonalList",kListName,id1,kListId,donestatus,kDoneStatus,nil];
    NSArray *responseArray = [NSArray arrayWithObjects:dict1,nil];
    for (int i =0; i<1 ; i++) {
        ToDoList * aList = [[ToDoList alloc] init];
        [aList readFromDictionary:[responseArray objectAtIndex:i]];
        [self.listArray addObject:aList];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [TDCommon setTheme:THEME_BLUE];
    if ([self.listArray count] == 0) {
        [self createTemporaryModalData];
        [self populateCustomViewsArrayFromListArray];
    }
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
    [self toggleSubViews:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
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
@end
