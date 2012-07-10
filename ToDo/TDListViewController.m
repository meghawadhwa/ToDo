//
//  TDListViewController.m
//  ToDo
//
//  Created by Megha Wadhwa on 19/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TDListViewController.h"

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

- (void)TDCustomRowTapped
{
    if ([super respondsToSelector:@selector(TDCustomRowTapped)]) {
    // TO CHECK :[super TDCustomRowTapped];
    }
    [self perform];
}

- (void) perform {
    
    UIViewController *src = (UIViewController *) self;
    TDViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemViewController"];
    
    [UIView transitionWithView:src.navigationController.view duration:0.3
                       options:UIViewAnimationTransitionCurlUp
                    animations:^{
                        [src.navigationController pushViewController:destination animated:YES];
                    }
                    completion:NULL];
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [TDCommon setTheme:THEME_BLUE];
}

@end
