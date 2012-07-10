//
//  TDRowLayer.h
//  ToDo
//
//  Created by Megha Wadhwa on 05/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TDConstants.h"

@interface TDRowLayer : CALayer

@property (nonatomic,retain) CALayer *topHalfLayer;
@property (nonatomic,retain) CALayer *bottomHalfLayer;
@property (nonatomic,retain) CATextLayer *topHalfTextLayer;
@property (nonatomic,retain) CATextLayer *bottomHalfTextLayer;
@end
