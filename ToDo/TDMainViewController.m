//
//  TDMainViewController.m
//  ToDo
//
//  Created by Megha Wadhwa on 19/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// Main View containing Themes settings and lists

#import "TDMainViewController.h"
#import "TDListViewController.h"

@interface TDMainViewController ()

@end

@implementation TDMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.parentName = nil;
    }
    return self;
}

- (void)createTemporaryModalData
{
    NSNumber *id1= [NSNumber numberWithInt:100];
    NSNumber *donestatus= [NSNumber numberWithInt:0];
    NSNumber *id2= [NSNumber numberWithInt:101];
    NSNumber *id3= [NSNumber numberWithInt:102];
    
    NSDictionary *dict1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"Lists",kListName,id1,kListId,donestatus,kDoneStatus,nil];
    NSDictionary *dict2 = [[NSDictionary alloc] initWithObjectsAndKeys:@"Themes",kListName,id2,kListId,donestatus,kDoneStatus,nil];
    NSDictionary *dict3 = [[NSDictionary alloc] initWithObjectsAndKeys:@"Settings",kListName,id3,kListId,donestatus,kDoneStatus,nil];
    NSArray *responseArray = [NSArray arrayWithObjects:dict1,dict2,dict3,nil];
    for (int i =0; i<3 ; i++) {
        ToDoList * aList = [[ToDoList alloc] init];
        [aList readFromDictionary:[responseArray objectAtIndex:i]];
        [self.listArray addObject:aList];
    }
}

//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    
//    NSLog(@"prepareForSegue: %@", segue.identifier);
//    
//    if ([segue.identifier isEqualToString:@"listSegue"]) {
////        [segue.destinationViewController setHappiness:100];
////        
////    } else if ([segue.identifier isEqualToString:@"Sad"]) {
////        [segue.destinationViewController setHappiness:0];
//    }
//}

- (void)TDCustomRowTapped:(TDListCustomRow *)sender
{
    if ([super respondsToSelector:@selector(TDCustomRowTapped:)]) {
        // TO CHECK :[super TDCustomRowTapped];
    }
    [self perform];
}

- (void) perform {
    
    TDMainViewController *src = (TDMainViewController *) self;
    TDListViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"ListViewController"];
    destination.parentName = @"Menu";
    destination.goingBackFlag = NO;
    [src.navigationController pushViewController:destination animated:YES];
}

- (void)addChildView
{
    TDMainViewController *src = (TDMainViewController *) self;
    TDListViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"ListViewController"];
    destination.parentName = @"Menu";
    destination.goingBackFlag = NO;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect myFrame = src.view.frame;
        myFrame.origin.y = -480;
        src.view.frame = myFrame;
    } completion:^(BOOL finished){if(finished)
    [UIView transitionWithView:src.navigationController.view duration:0.3
                       options:UIViewAnimationTransitionNone
                    animations:^{
                        
                        [src.navigationController pushViewController:destination animated:YES];
                    }
                    completion:NULL];
    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [TDCommon setTheme:THEME_MAIN_GRAY];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [TDCommon setTheme:THEME_MAIN_GRAY];
    self.childName = @"Lists";
    [self toggleSubViews:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
//    NSLog(@"frame is : %@", self.view.frame);
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
