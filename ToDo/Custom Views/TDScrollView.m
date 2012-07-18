//
//  TDScrollView.m
//  TD
//
//  Created by Megha Wadhwa on 06/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TDScrollView.h"
#import "TDListCustomRow.h"
#import <QuartzCore/QuartzCore.h>
#import "TDListCustomRow.h"
#import "TDRowLayer.h"

#define HORIZ_SWIPE_DRAG_MAX  4
#define EXTRA_PULL_DOWN_MIN  ROW_HEIGHT *2
#define VERT_PULL_DRAG_MIN   ROW_HEIGHT
#define VERT_PULL_UP_DRAG_MIN ROW_HEIGHT *2
#define EXTRA_PULL_UP_DRAG_MIN -ROW_HEIGHT *2
#define DEGREE_TO_RADIAN 0.0174532925
#define EMPTY_BOX [UIImage imageNamed:@"empty_box.png"]
#define FULL_BOX [UIImage imageNamed:@"full_box.png"]
#define BIG_ARROW_UP @"arrow-up.png"
#define BIG_ARROW_DOWN @"arrow-down.png"
#define SMILEY @"smilie.png"
#define EXTRA_PULL_UP_ORIGINY 485
#define EXTRA_PULL_DOWN_ORIGINY -50

@interface TDScrollView(privateMethods)
- (void)customViewPullUpDetected:(NSSet *)touches withEvent:(UIEvent*)event;
- (void)customViewPullDownDetected:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)removeCheckedItems;
- (void)makeNewRow;
- (void)addNewRow;
- (void)accomodateNewRowAndMakeItFirstResponder;
- (void)removeNewRow;
- (void)createPullUpView;
- (void)createArrowImageView;
- (void)addOverlayView;
- (void)createOverlay;
@end

@implementation TDScrollView
static float rotationAngle; // global variable
    @synthesize initialCentre;
@synthesize pullUpDetected,pullDownDetected;
@synthesize pullDelegate;
@synthesize customNewRow;
@synthesize RowAdded;
@synthesize startedpullingDownFlag;
@synthesize overlayView;
@synthesize pullUpView,arrowImageView,boxImageView;
@synthesize checkedRowsExist;
@synthesize initialDistance;
@synthesize checkedViewsArray,customViewsArray;
@synthesize pinchRecognizer;
@synthesize pinchOutdelegate;
@synthesize creatingNewRow;
@synthesize extraPullDownDetected;
@synthesize switchUpView,upArrowImageView,smileyImageView;
@synthesize extraPullDownDelegate,extraPullUpDetected,extraPullUpDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blackColor];
        [self setUserInteractionEnabled:YES];
        self.multipleTouchEnabled = YES;
//        self.pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandler:)];
//        [self addGestureRecognizer:self.pinchRecognizer];
//        creatingNewRow = NO;
        }
    return self;
}

- (TDListCustomRow *)RowAtPoint:(CGPoint)point
{
    NSLog(@"custom array :%@",self.customViewsArray);
    for ( TDListCustomRow *row in self.customViewsArray)
        if ( CGRectContainsPoint(row.frame, point ) )
            return row;
    
    return nil;
}

#pragma mark - pinch gesture recognizer
- (void)pinchHandler:(UIPinchGestureRecognizer*)pinch
{
    if ( pinch.state == UIGestureRecognizerStateChanged && pinch.numberOfTouches < 2 )
    {
        // Cancel the pinch if the user lifts a finger and we only have a single touch
        pinch.enabled = NO;
        pinch.enabled = YES;
        return;
    }
    [self handleGesture:pinch withPinch:YES andScale:pinch.scale];
}

- (void)handleGesture:(UIGestureRecognizer*)gesture withPinch:(BOOL)pinch andScale:(float)scale
{
    BOOL pinchEnded = NO;
    int midRowIndex = nil;
    switch ( gesture.state )
    {
        case UIGestureRecognizerStateBegan:
        {
            // Pinching
            CGPoint firstTouch = [gesture locationOfTouch:0 inView:self];
            CGPoint secondTouch = [gesture locationOfTouch:1 inView:self]; 
            CGPoint midPoint = CGPointMake(0.5 * ( firstTouch.x + secondTouch.x), 0.5 * ( firstTouch.y + secondTouch.y ) );
           // midPoint.y += self.contentOffset.y; // We may be further down the list
            midPoint.y += self.frame.origin.y;
            TDListCustomRow *customRow = [self.pinchOutdelegate RowAtPoint:midPoint];
            
            if ( customRow == nil )
                return;
            
            NSLog(@"PINCH Scale : %f row detected height: %f",scale,customRow.frame.origin.y);
            
            if (scale < 1) {
                // Inward Pinch To handle
                creatingNewRow = NO;
                break;
            }
            midRowIndex = [self.pinchOutdelegate getRowIndexFromCustomArrayFor:customRow];
            // If the mid point is in the top half of the current Row, we create a new Row Above otherwise below the current
            if ( midPoint.y < CGRectGetMidY(customRow.frame) )
            midRowIndex --;
            
//            int height = (midRowIndex +1) * ROW_HEIGHT; // New Row is added below the middle Row during a pinch out
            
            [self makeNewPinchedRowatHeight:CGRectGetMaxY(customRow.frame)]; // created a new row,added to sub view also
            NSLog(@" frame : %f",self.customNewRow.frame.size.height);
 //           [self.customNewRow.layer setDelegate:self];
            [self.pinchOutdelegate addNewRow:self.customNewRow AtIndex:midRowIndex+1];
            creatingNewRow = YES; 
            
             // handing Fold Up other than a pinch
//            if ([self.pinchOutdelegate isLastObjectOnView:customNewRow]) {
//               
//            }
            [self.customNewRow divideIntoTwoLayers];
            break;
        }
            case UIGestureRecognizerStateChanged:
        {
            if (!customNewRow) {
                return;
            }
            
//            TDRowLayer *innerLayer = [self.customNewRow.layer.sublayers objectAtIndex:1]; 
//            [innerLayer layoutSublayers];
//            [innerLayer setNeedsDisplay];
            CGFloat frameScale = scale;        
            if (pinch && creatingNewRow) {
                frameScale = fmaxf(frameScale - 1.0, 0);
                frameScale = fminf(frameScale, 1.0);
                
                frameScale = fmaxf(frameScale, 0);
                
                CGRect frame = self.customNewRow.frame;
                frame.size.height = ROW_HEIGHT * frameScale;
                self.customNewRow.frame = frame;
                
                CGRect layerframe = self.customNewRow.layer.frame;
                layerframe.size.height = ROW_HEIGHT * frameScale;
                self.customNewRow.layer.frame = layerframe;
                
//                CGRect innerlayerframe = innerLayer.frame;
//                innerlayerframe.size.height = ROW_HEIGHT * frameScale;
//                innerLayer.frame = layerframe;
                
                NSLog(@" frame : %f",self.customNewRow.frame.size.height);
                [self.customNewRow test];
                break;
            }
        }
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateFailed:
            case UIGestureRecognizerStateCancelled :
        {
            pinchEnded = YES;
            CGRect pinchEndedFrame = self.customNewRow.frame;
            float height = self.customNewRow.frame.size.height;
            pinchEndedFrame.size.height = 0;
            
            if (height / ROW_HEIGHT < 0.8) {
                self.customNewRow.frame = pinchEndedFrame;
                [self.pinchOutdelegate removeNewRow:self.customNewRow AtIndex:(midRowIndex+1)];
                [self.customNewRow removeFromSuperview];
                self.customNewRow = nil;
            }
            else {
                pinchEndedFrame.size.height = ROW_HEIGHT;
                self.customNewRow.frame = pinchEndedFrame;
                self.RowAdded = self.customNewRow;
                self.customNewRow = nil;
            }
            break;
        }
        default:NSLog(@"UnIdentified gesture ");
    }
    [CATransaction begin];

    [self.pinchOutdelegate shiftByScale:scale forPinch:pinch withState:gesture.state andCreating:creatingNewRow forCurrentRow:self.customNewRow];
    [CATransaction commit];    
    // To remove the object
}

- (void)makeNewPinchedRowatHeight:(float) height
{
    if (self.customNewRow !=nil) {
        self.customNewRow.listTextField.text =PINCH_OUT_TEXT;
        return;
    }  
    else if (self.customNewRow == nil) {
        self.customNewRow = [[TDListCustomRow alloc]initWithFrame:CGRectMake(0,height, ROW_WIDTH , 0)];
        self.customNewRow .listTextField.text =PINCH_OUT_TEXT;
        [self addSubview:self.customNewRow];
    }
}

#pragma mark - CALayer Delegates
//- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
//{
//    UIPinchGestureRecognizer *pinch = self.pinchRecognizer;
//    
//    // Set up an animation delegate when we are removing a layer so we can remove it from the
//    // view hierarchy when it is done
////    if ( [layer valueForKey:@"toRemove"] )
////    {
////        CABasicAnimation *animation = [CABasicAnimation animation]; 
////        if ( [event isEqualToString:@"bounds"] )
////            animation.delegate = self;
////        return animation;
////    }
//    
//    // Don't allow core animation to animate while dragging, otherwise it gets all
//    // wibbly-wobbly timey-wimey and interpolates through the wrong rotated plane.
//  
//    if ( pinch.state == UIGestureRecognizerStateChanged || pinch.state == UIGestureRecognizerStateBegan )
//        return (id)[NSNull null];
//    
//    return nil;
//}
#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    // Remove any sublayers marked for removal
//    NSMutableArray *layersToDelete = [NSMutableArray array];
//    for ( CALayer *layer in self.scrollView.layer.sublayers )
//        if ( [[layer valueForKey:@"toRemove"] boolValue] )
//            [layersToDelete addObject:layer];
//    
//    for ( CALayer *layer in layersToDelete )
//        [layer removeFromSuperlayer];
}

#pragma mark - touch delegates
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    //TOREMOVE
    if([touches count] == 2){
		NSArray *twoTouches = [touches allObjects];
		UITouch *firstTouch = [twoTouches objectAtIndex:0];
		UITouch *secondTouch = [twoTouches objectAtIndex:1];
        CGPoint firstPoint = [firstTouch locationInView: self];
        CGPoint secondPoint = [secondTouch locationInView:self];
        initialDistance = [TDCommon calculateDistanceBetweenTwoPoints:firstPoint:secondPoint];
	}
    
    else if ([touches count] == 1) {
        if (self.overlayView) {
            return;
        }
        initialCentre = self.center;
        pullDownDetected = FALSE;
        pullUpDetected = FALSE;
        startedpullingDownFlag = FALSE;
        extraPullDownDetected = NO;
        extraPullUpDetected = NO;
         rotationAngle = 85.0; 
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
    if([touches count] == 2)
	{
		NSArray *twoTouches = [touches allObjects];
		UITouch *firstTouch = [twoTouches objectAtIndex:0];
		UITouch *secondTouch = [twoTouches objectAtIndex:1];
       // NSArray *allRowsArray = [self subviews];

            CGPoint firstPoint = [firstTouch locationInView: self];
            CGPoint secondPoint = [secondTouch locationInView: self];
            float currentDistance = [TDCommon calculateDistanceBetweenTwoPoints:firstPoint:secondPoint];
            if(initialDistance == 0) initialDistance = currentDistance;
            else if (currentDistance - initialDistance >MINIMUM_PINCH_DISTANCE){
                int mean = firstPoint.y +secondPoint.y/2;
                NSLog(@"***************Outward Pinch, mean %i",mean);
        }
    }
    else if ([touches count] == 1)
    {

        if (self.overlayView) {
            return;
        }
        UITouch *touch = [touches anyObject];
        CGPoint currentTouchPosition = [touch locationInView:self];
        CGPoint prevTouchPosition = [touch previousLocationInView:self];
        
        float deltaY;
        CGRect myFrame = self.frame;
        deltaY = currentTouchPosition.y - prevTouchPosition.y;
        if (pullDownDetected || pullUpDetected || self.pullUpView.alpha <1) {
        deltaY = deltaY/DECELERATION_RATE;
        }
        myFrame.origin.y += deltaY;
        [self setFrame:myFrame];

        float scrolledDistanceY = self.center.y - initialCentre.y;
        //static float rotationAngle = 85.0f;
       
        [self extraPullDownDetectedByScrolledDistance:scrolledDistanceY];
        [self createViewForExtraPullDown];
        
        CGFloat originY = self.frame.origin.y;
        if (originY >0) {
            startedpullingDownFlag = YES;
        }
        else
        {
            startedpullingDownFlag = NO;
        }
        NSLog(@"scrolledY %f %i %i",deltaY,self.extraPullDownDetected,self.extraPullUpDetected);

        if (startedpullingDownFlag == YES) 
        {
            if (prevTouchPosition.y < currentTouchPosition.y && pullUpDetected == NO) // PULL DOWN
                {
                     [self makeNewRow];
                    if (rotationAngle >0) {
                        if (rotationAngle <3  || scrolledDistanceY >= VERT_PULL_DRAG_MIN) 
                        {
                            rotationAngle = 0;
                        }
                        else{
                        rotationAngle = (85.0 - scrolledDistanceY *1.52);
                        }
                    }
                    
                }
            else if(prevTouchPosition.y > currentTouchPosition.y && pullUpDetected == NO) // PULL UP
            {
                 if(scrolledDistanceY <= VERT_PULL_DRAG_MIN) //ROTATE back ONLY after REACHING THE MINIMUM DRAG POINT 
                 {rotationAngle = (85.0 - scrolledDistanceY *1.52);}
                
            }
        }
        else if(scrolledDistanceY <= VERT_PULL_UP_DRAG_MIN && startedpullingDownFlag == NO)
        { 
            [self createViewForPullUp];
            self.upArrowImageView.image = [UIImage imageNamed:BIG_ARROW_DOWN];
            extraPullUpDetected = YES;
        }
        else if(scrolledDistanceY > VERT_PULL_UP_DRAG_MIN && startedpullingDownFlag == NO)
        {
            [self createViewForPullUp];
            extraPullUpDetected = NO;
            self.upArrowImageView.image = [UIImage imageNamed:BIG_ARROW_UP];
        }
        [self animateArrowForPullUpbyScrolledDistance:deltaY];
        CALayer *layer = self.customNewRow.layer;
        layer.anchorPoint =CGPointMake(0.5, 1);
        CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
        rotationAndPerspectiveTransform.m34 = 1.0 /- 120;     //m34(matrix value at 3 by 4) is the value of zDistance that affects the sharpness of the transform and lesser the value ,more sharper transformation across z axis.
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, rotationAngle * M_PI / 180.0f,1.0f, 0.0f,0.0f);
        layer.transform = rotationAndPerspectiveTransform;
         
        // To be a pull, direction of touch must be vertical and long enough.
        if (fabsf(initialCentre.y - self.center.y) >= VERT_PULL_DRAG_MIN && fabsf(initialCentre.x - self.center.x) <= HORIZ_SWIPE_DRAG_MAX)
        { 
            if (fabsf(initialCentre.y - self.center.y) >= VERT_PULL_UP_DRAG_MIN && prevTouchPosition.y > currentTouchPosition.y && pullDownDetected == FALSE)
            {
                NSLog(@" PULL UP :delta ,prev , current : %f %f,%f",initialCentre.y - self.center.y,initialCentre.y,self.center.y);
                self.boxImageView.image = FULL_BOX;
                self.arrowImageView.hidden = YES;
                pullUpDetected = TRUE;
                startedpullingDownFlag = FALSE;
                NSLog(@"pullUpDetected %i",pullUpDetected);
            }
            else if(fabsf(initialCentre.y - self.center.y) < VERT_PULL_UP_DRAG_MIN)
            {
                if (pullUpDetected == TRUE) {
                    pullUpDetected = FALSE;
                    self.arrowImageView.hidden = NO;
                    self.boxImageView.image = EMPTY_BOX;
                }
            } 
            if (prevTouchPosition.y < currentTouchPosition.y && startedpullingDownFlag == TRUE )
            {
                NSLog(@" PULL DOWN :delta ,prev , current : %f %f,%f",initialCentre.y - self.center.y,initialCentre.y,self.center.y);
                pullDownDetected = TRUE;
                NSLog(@"pullDownDetected %i",pullDownDetected);
            }
            self.customNewRow.listTextField.text= RELEASE_AFTER_PULL_TEXT;
        } 
        else if(fabsf(initialCentre.y - self.center.y) < VERT_PULL_DRAG_MIN)
        {
            if (pullDownDetected == TRUE && (fabsf(initialCentre.y - self.center.y) < VERT_PULL_DRAG_MIN)) {
                pullDownDetected =FALSE;
            }
            self.customNewRow.listTextField.text= PULL_DOWN_TEXT;
        }
    }
} 

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    if (self.overlayView) {
        return;
    }
    if (self.switchUpView !=nil ) {
    [self removeExtraPullDownView];
    }
    
    if(extraPullDownDetected == YES){
        if ([self.extraPullDownDelegate getParentName]) {
        [self.extraPullDownDelegate removeCurrentView];
            return;
        }
    pullDownDetected = NO;
    }
    if (extraPullUpDetected == YES) {
        if ([self.extraPullUpDelegate getChildName]) {
            [self.extraPullUpDelegate addChildView];
        }
    }
    
    if (self.pullUpView) {
        [self.pullUpView removeFromSuperview];
        self.pullUpView = nil;
        [self.arrowImageView removeFromSuperview];
        self.arrowImageView = nil;
    }
    if (pullUpDetected == YES) {
        [self customViewPullUpDetected:touches withEvent:event];
        [self setFrame:CGRectMake(0, 0, SCROLLVIEW_WIDTH, SCROLLVIEW_HEIGHT)];
    }
    else if (pullDownDetected == YES){
        [self customViewPullDownDetected:touches withEvent:event];
         NSLog(@" angle : %f ",rotationAngle);
    }
    else{
    [self setFrame:CGRectMake(0, 0, SCROLLVIEW_WIDTH, SCROLLVIEW_HEIGHT)];
    }
}

# pragma mark - PULL UP METHODS
- (void)createViewForPullUp
{
// check If it is Items view controller,then create pull up view to remove checked items
if ([self.extraPullDownDelegate getParentName] == @"Lists")  [self createPullUpViewToComplete];
else [self createPullUpViewToMoveDown];
}

-(void)createPullUpViewToMoveDown
{
    if(self.extraPullUpDetected == YES)
    {
        [self createArrowImageViewWithImageName:BIG_ARROW_DOWN atHeight:EXTRA_PULL_UP_ORIGINY];
        [self createSwitchUpViewAtHeight:EXTRA_PULL_UP_ORIGINY];
    }
    else {
        if (self.upArrowImageView) self.upArrowImageView.hidden = YES;
        else if(self.smileyImageView) self.smileyImageView.hidden = YES;
        self.switchUpView.hidden = YES;
    }
}

- (void)createPullUpViewToComplete
{
    [self createPullUpView];
    if ([pullDelegate checkedRowsExist]) // checks If already checked rows exists
    {
        [self createArrowImageView];
    }
    else
    {
        self.pullUpView.alpha = 0.2;
        return;
    }
}
- (void)animateArrowForPullUpbyScrolledDistance:(float)deltaY
{
    if (self.arrowImageView) {
        CGRect arrowFrame = self.arrowImageView.frame;
        arrowFrame.origin.y -= deltaY/3.1;
        [self.arrowImageView setFrame:arrowFrame];
    }
}

- (void)createArrowImageView
{
    if (self.arrowImageView != nil) {
        return;
    }
    self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    self.arrowImageView.backgroundColor = [UIColor clearColor];
    [self.arrowImageView setFrame:CGRectMake(105, 480, 10, 13)];
    [self addSubview:self.arrowImageView];
}

- (void)createPullUpView
{
    if (self.pullUpView != nil) {
        return;
    }
    self.boxImageView = [[UIImageView alloc] initWithImage:EMPTY_BOX];
    self.boxImageView.backgroundColor = [UIColor clearColor];
    [self.boxImageView setFrame:CGRectMake(0, 13, 22, 10)];
                            
    UILabel *pullUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 100,30)];
    pullUpLabel.text = @"Pull to Clear";
    pullUpLabel.textAlignment = UITextAlignmentCenter;
    pullUpLabel.textColor = [UIColor whiteColor];
    pullUpLabel.backgroundColor = [UIColor clearColor];
    pullUpLabel.font = [UIFont boldSystemFontOfSize:16];
    
    self.pullUpView = [[UIView alloc] initWithFrame:CGRectMake(100, 510, 130, 30)];
    self.pullUpView.backgroundColor = [UIColor clearColor];
    [self.pullUpView addSubview:pullUpLabel];
    [self.pullUpView addSubview:self.boxImageView];
    [self addSubview:self.pullUpView];
}

- (NSString *)getSwitchLabelTextForPullUp
{
    NSString *switchLabelText = nil;
    NSString * child = [self.extraPullUpDelegate getChildName];
    if (child!= nil) {
        switchLabelText = child;
    }
    else {
        switchLabelText = @"Nothing beyond it!!";
    }
    return switchLabelText;
}

# pragma mark - EXTRA PULL DOWN METHODS
- (void)removeExtraPullDownView
{
    if (self.upArrowImageView) {
        [self.upArrowImageView removeFromSuperview];
        self.upArrowImageView =nil;
    }
    else if(self.smileyImageView){
        [self.smileyImageView removeFromSuperview];
        self.smileyImageView = nil;
    }
    [self.switchUpView removeFromSuperview];
    self.switchUpView = nil;
}

- (void) extraPullDownDetectedByScrolledDistance:(float)deltaY
{
    if (!self.customNewRow) {
        self.extraPullDownDetected = NO;
        return;
    }
    if ((deltaY >= EXTRA_PULL_DOWN_MIN) && ([self.customNewRow.listTextField.text isEqualToString:RELEASE_AFTER_PULL_TEXT])){
        self.extraPullDownDetected = YES;
        return;
    }
    self.extraPullDownDetected = NO;
}

- (void)createViewForExtraPullDown
{
    if (self.extraPullDownDetected == YES) {
        self.customNewRow.hidden = YES;
        [self createArrowImageViewWithImageName:BIG_ARROW_UP atHeight:EXTRA_PULL_DOWN_ORIGINY];
        [self createSwitchUpViewAtHeight:EXTRA_PULL_DOWN_ORIGINY];
        return;
    }
    else {
        if (self.upArrowImageView) self.upArrowImageView.hidden = YES;
        else if(self.smileyImageView) self.smileyImageView.hidden = YES;
        self.switchUpView.hidden = YES;
        self.customNewRow.hidden = NO;
    }
}

- (void)createArrowImageViewWithImageName:(NSString *)imageName atHeight:(float)originY
{
    if (self.upArrowImageView != nil) {
        self.upArrowImageView.hidden = NO;
        return;
    }
    else if (self.smileyImageView != nil) {
        self.smileyImageView.hidden = NO;
        return;
    }
    if (self.extraPullDownDetected) {
    if ([self.extraPullDownDelegate getParentName] !=nil) {
        [self createBigArrowImageViewWithImage:imageName atHeight:originY];
    }
    else {
        [self createSmileyImageViewWithImage:SMILEY atHeight:originY];    
    }
    }
    else if(self.extraPullUpDetected) {
        if (![[self.extraPullDownDelegate getParentName] isEqualToString:@"Lists"]) {
            [self createBigArrowImageViewWithImage:BIG_ARROW_DOWN atHeight:originY];
        }
        else {
            [self createSmileyImageViewWithImage:SMILEY atHeight:originY];    
        }
    }
}

- (void)createBigArrowImageViewWithImage:(NSString *)imageName atHeight:(float)originY
{
    self.upArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    self.upArrowImageView.backgroundColor = [UIColor clearColor];
    [self.upArrowImageView setFrame:CGRectMake(80, originY, 18, 24)];
    [self addSubview:self.upArrowImageView];   
}

- (void)createSmileyImageViewWithImage:(NSString *)imageName atHeight:(float)originY
{
    self.smileyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    self.smileyImageView.backgroundColor = [UIColor clearColor];
    [self.smileyImageView setFrame:CGRectMake(70, originY -5, 33, 37)];
    [self addSubview:self.smileyImageView];
}
- (void)createSwitchUpViewAtHeight:(float)originY
{
    if (self.switchUpView != nil) {
        self.switchUpView.hidden = NO;
        return;
    }
    
    UILabel *switchUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200,30)];
    if(self.extraPullDownDetected) switchUpLabel.text = [self getSwitchLabelTextForPullDown];
    else if (self.extraPullUpDetected) switchUpLabel.text = [self getSwitchLabelTextForPullUp];
    switchUpLabel.textAlignment = UITextAlignmentLeft;
    switchUpLabel.textColor = [UIColor whiteColor];
    switchUpLabel.backgroundColor = [UIColor clearColor];
    switchUpLabel.font = [UIFont boldSystemFontOfSize:18];

    self.switchUpView = [[UIView alloc] initWithFrame:CGRectMake(115, originY, 200, 30)];
    self.switchUpView.backgroundColor = [UIColor clearColor];
    [self.switchUpView addSubview:switchUpLabel];
    [self addSubview:self.switchUpView];
}

- (NSString *)getSwitchLabelTextForPullDown
{
    NSString *switchLabelText = nil;
    NSString * parent = [self.extraPullDownDelegate getParentName];
    if (parent!= nil) {
        switchLabelText = [NSString stringWithFormat:@"Switch to %@",parent];
    }
    else {
        switchLabelText = @"Nothing beyond it!!";
    }
    return switchLabelText;
}
#pragma mark - PULL DOWN METHODS
- (void)makeNewRow
{
    if (self.customNewRow) {
        self.customNewRow.listTextField.text =PULL_DOWN_TEXT;
        return;
    }  
    TDListCustomRow * newRow;
    if (self.customNewRow == nil) {
        newRow = [[TDListCustomRow alloc]initWithFrame:CGRectMake(0,-ROW_HEIGHT + 27.5, ROW_WIDTH , ROW_HEIGHT)];
        self.customNewRow = newRow;
        self.customNewRow .listTextField.text =PULL_DOWN_TEXT;
        [self addSubview:self.customNewRow];
    }
}

- (void)accomodateNewRowAndMakeItFirstResponder
{   self.customNewRow.listTextField.text = NO_TEXT;
    [self.customNewRow.listTextField becomeFirstResponder];
    [self setFrame:CGRectMake(0,ROW_HEIGHT, SCROLLVIEW_WIDTH, SCROLLVIEW_HEIGHT)];
}

- (void)createOverlay
{
    if (self.overlayView) {
        return;
    }
    self.overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ROW_WIDTH, 480)];
    self.overlayView.backgroundColor =[[UIColor blackColor] colorWithAlphaComponent:0.5];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayViewTapped)]; 
    [self.overlayView addGestureRecognizer:tapGestureRecognizer];
}

- (void)addOverlayView
{
    [self addSubview:self.overlayView];
}

- (void)overlayViewTapped
{
    if (self.overlayView == nil) {
        return;
    }
    [self.customNewRow.listTextField resignFirstResponder];
    [self.overlayView removeFromSuperview];
    self.overlayView = nil;
    if ([self.customNewRow.listTextField.text isEqualToString:NO_TEXT]) {
        [self removeNewRow];
    }
    else
    {
        for ( TDListCustomRow * row in [self subviews])
        {
            [row setFrame:CGRectMake(0, row.frame.origin.y +ROW_HEIGHT , ROW_WIDTH, ROW_HEIGHT)]; 
            NSLog(@" Y : %f angle : %f",row.frame.origin.y,rotationAngle);
        }
        [self setFrame:CGRectMake(0, 0, SCROLLVIEW_WIDTH , SCROLLVIEW_HEIGHT)];
             [self addNewRow];
    }
}

- (void)removeNewRow
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
        [self.customNewRow setFrame:CGRectMake(-ROW_WIDTH, self.customNewRow.frame.origin.y, ROW_WIDTH, ROW_HEIGHT)];
    } completion:^(BOOL finished){
        [self.customNewRow removeFromSuperview];
        self.customNewRow = nil;  [self setFrame:CGRectMake(0, 0, 320, 480)];} ];
    }

- (void)addNewRow
{
    self.RowAdded = self.customNewRow;
    self.customNewRow = nil;
    CGSize textSize = [[self.RowAdded.listTextField text] sizeWithFont:[self.RowAdded.listTextField font]];
    [self.RowAdded.listTextField setFrame:CGRectMake(self.RowAdded.listTextField.frame.origin.x, self.RowAdded.listTextField.frame.origin.y, textSize.width +1, textSize.height)];
    if ([pullDelegate respondsToSelector:@selector(TDCustomViewPulledDownWithNewRow:)]) {
    [pullDelegate TDCustomViewPulledDownWithNewRow:self.RowAdded];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
{
    pullUpDetected = NO;
    pullDownDetected = NO;
 }

#pragma mark -  PUll UP
- (void)customViewPullUpDetected:(NSSet *)touches withEvent:(UIEvent*)event
{
    [self performSelector:@selector(removeCheckedItems) withObject:nil afterDelay:0.4];
}

- (void)removeCheckedItems
{
    if ([pullDelegate respondsToSelector:@selector(TDCustomViewPulledUp)])
    {
    [pullDelegate TDCustomViewPulledUp];
    }
}
#pragma mark -  PUll Down

- (void)customViewPullDownDetected:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self createOverlay];
    [self accomodateNewRowAndMakeItFirstResponder];
    
    [self addOverlayView];
}

- (void)dealloc
{
    [self.pinchRecognizer removeTarget:nil action:nil];    
    [self.pinchRecognizer.view removeGestureRecognizer:self.pinchRecognizer];
}
@end
