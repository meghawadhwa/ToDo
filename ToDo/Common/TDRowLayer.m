//
//  TDRowLayer.m
//  ToDo
//
//  Created by Megha Wadhwa on 05/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TDRowLayer.h"

@implementation TDRowLayer
@synthesize topHalfLayer;
@synthesize bottomHalfLayer;
@synthesize topHalfTextLayer,bottomHalfTextLayer;

- (id)init
{
    self = [super init];
    if (self) {
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1/200.0;
        self.sublayerTransform = transform;
        
        self.topHalfLayer = [CALayer layer];
        self.topHalfLayer.anchorPoint = CGPointMake(0.5, 1);
        self.topHalfLayer.backgroundColor = [UIColor clearColor].CGColor;
        
        self.bottomHalfLayer = [CALayer layer];
        self.bottomHalfLayer.anchorPoint = CGPointMake(0.5, 0);
        self.bottomHalfLayer.backgroundColor = [UIColor clearColor].CGColor;
    
        [self addSublayer:self.topHalfLayer];
        [self addSublayer:self.bottomHalfLayer];
        CGFloat y = 18.0;
        CGFloat textHeight = 30.0;
        self.topHalfTextLayer = [CATextLayer layer];
        self.topHalfTextLayer.string = nil;
        self.topHalfTextLayer.fontSize = 20;
        self.topHalfTextLayer.font = CGFontCreateWithFontName(CFSTR("HelveticaNeue-Bold"));
        self.topHalfTextLayer.contentsScale = [[UIScreen mainScreen] scale];
        self.topHalfTextLayer.frame = CGRectMake(20,y,300,textHeight);
        [self.topHalfLayer addSublayer:self.topHalfTextLayer];
        
        self.bottomHalfTextLayer = [CATextLayer layer];
        self.bottomHalfTextLayer.string = nil;
        self.bottomHalfTextLayer.fontSize = self.topHalfTextLayer.fontSize;
        self.topHalfTextLayer.font = self.topHalfTextLayer.font;
        self.bottomHalfTextLayer.contentsScale = self.topHalfTextLayer.contentsScale;
        self.bottomHalfTextLayer.frame = CGRectMake(20,0,300,textHeight);
        self.bottomHalfTextLayer.contentsRect = CGRectMake(0,(textHeight - y)/textHeight,1,1);
        self.bottomHalfTextLayer.rasterizationScale = self.bottomHalfTextLayer.contentsScale;
        [self.bottomHalfLayer addSublayer:self.bottomHalfTextLayer];


    }
    return self;
}

- (void) setDelegate:(id)delegate
{
    super.delegate = delegate;
    self.topHalfLayer = delegate;
    self.bottomHalfLayer = delegate;
}
- (void)layoutSublayers
{    
    [super layoutSublayers];
    CGSize size = self.bounds.size; 
    
    NSLog(@" Lay out sub layers here !!!!!!!!!!!!!!!!!!!!!!");    
    CGRect halfRect = CGRectMake(0, 0, size.width, 0.5 * ROW_HEIGHT);
    self.topHalfLayer.bounds = halfRect;
    self.bottomHalfLayer.bounds = halfRect;
    
    CGPoint midpoint = CGPointMake(0.5 * size.width, 0.5 * size.height);
    self.topHalfLayer.position = midpoint;
    self.bottomHalfLayer.position = midpoint;

    CGFloat y = 0.5 * self.bounds.size.height;
    CGFloat l = 0.5 * ROW_HEIGHT;
    CGFloat angle = acosf(y/l);
    CGFloat zTranslationValue = l * sinf(angle);
    CGFloat topAngle = angle;
    CGFloat bottomAngle = angle;
    
    // For pinch
    topAngle *= -1;
    
    CATransform3D transform = CATransform3DMakeTranslation(0, 0, -zTranslationValue);
    self.topHalfLayer.transform = CATransform3DRotate(transform, topAngle , 1.0, 0.0, 0.0);
    self.bottomHalfLayer.transform =CATransform3DRotate(transform, bottomAngle , 1.0, 0.0, 0.0);
}

@end
