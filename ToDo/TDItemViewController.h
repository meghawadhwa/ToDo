//
//  TDItemViewController.h
//  ToDo
//
//  Created by Megha Wadhwa on 17/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TDViewController.h"

@interface TDItemViewController : TDViewController
@property(nonatomic,assign) id<TDCustomParentDelegate> parentDelegate;

@end
