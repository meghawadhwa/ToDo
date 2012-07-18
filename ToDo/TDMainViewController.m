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
    [UIView transitionWithView:src.navigationController.view duration:0.3
                       options:UIViewAnimationTransitionCurlUp
                    animations:^{
                        [src.navigationController pushViewController:destination animated:YES];
                    }
                    completion:NULL];
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)toggleSubViews:(BOOL)hide
{
    if (hide) {
        for (UIView *subview in self.view.subviews)
        {
            subview.hidden = YES;
        }
    }
    else {
        for (UIView *subview in self.view.subviews)
        {
            subview.hidden = NO;
        }
    }
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
    [UIView animateWithDuration:0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{  
        CGRect myFrame = self.view.frame;
        myFrame.origin.y = -480.0f;
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
