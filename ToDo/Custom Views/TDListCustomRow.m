//
//  TDListCustomRow.m
//  TD
//
//  Created by Megha Wadhwa on 06/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#define HORIZ_SWIPE_DRAG_MIN  50
#define VERT_SWIPE_DRAG_MAX   1
#define HORIZ_SWIPE_DRAG_MAX 2 
#define VERT_SWIPE_DRAG_MIN 0.1
#import "TDListCustomRow.h"
#import "TDCommon.h"
#import <QuartzCore/QuartzCore.h>

@implementation TDListCustomRow
@synthesize listTextField;
@synthesize swipeDelegate; 
@synthesize initialCentre;
@synthesize rightSwipeDetected,leftSwipeDetected;
@synthesize strikedLabel;
@synthesize defaultRowColor;
@synthesize PullDetected,swipeDetected;
@synthesize startPoint;
@synthesize doneStatus;
@synthesize  doneOverlayView;
@synthesize tapDelegate;
@synthesize deleteImgView,checkImgView;
@synthesize topHalfLayer,bottomHalfLayer;
//@synthesize innerLayer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UITextField *listField = [[UITextField alloc] initWithFrame:CGRectMake(10,15,frame.size.width -25,frame.size.height-30)];
        listField.enablesReturnKeyAutomatically =YES;
        listField.backgroundColor = [UIColor clearColor];
        listField.textColor =[UIColor whiteColor];
        [listField setFont:[UIFont boldSystemFontOfSize:18]];
        listField.delegate = self;
        listField.returnKeyType = UIReturnKeyDone;
        self.listTextField = listField;
        [self addSubview:self.listTextField];
        self.backgroundColor=[TDCommon getColorByPriority:1];  // default color value;
        self.defaultRowColor = self.backgroundColor;
        self.doneStatus = FALSE;
        [self setUserInteractionEnabled:YES];
        [self  makeDeleteIcon];
        [self makeCheckedIcon];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(customRowTapped)];
        [self addGestureRecognizer:tapGesture];
        //tapGesture = nil;
        self.multipleTouchEnabled = NO;
        //[self divideIntoTwoLayers];
    }
    return self;
}

#pragma mark - gesture Recognizer

- (void)customRowTapped
{
    if ([self.tapDelegate respondsToSelector:@selector(TDCustomRowTapped:)]) 
    {
        [self.tapDelegate TDCustomRowTapped:self];
    }
}

#pragma mark - touch delegates

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{ 
    if([touches count] == 1){
    initialCentre = self.center;
    swipeDetected = NO;
    rightSwipeDetected = NO;
    leftSwipeDetected = NO;
    [[self superview] touchesBegan:touches withEvent:event];
    PullDetected = NO;
      self.defaultRowColor = self.backgroundColor;
    UITouch *touch = [touches anyObject];
     startPoint = [touch locationInView:self];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
    if([touches count] == 1){
        UITouch *touch = [touches anyObject];
        
        CGPoint currentTouchPosition = [touch locationInView:self];
        CGPoint prevTouchPosition = [touch previousLocationInView:self];
        
        // to check for scrollView's touch 
        if( (rightSwipeDetected == YES) || (leftSwipeDetected == YES) || (swipeDetected == YES)){
            PullDetected = NO;
        }
        else if(PullDetected == NO && swipeDetected == NO)
        {
            if (fabsf(startPoint.x - currentTouchPosition.x) <= HORIZ_SWIPE_DRAG_MAX && fabsf(startPoint.y - currentTouchPosition.y) >= VERT_SWIPE_DRAG_MIN)
            {
                 PullDetected = YES;
                swipeDetected = NO;
                [[self superview] touchesBegan:touches withEvent:event];
            }
            else
            {
                swipeDetected = YES;
                PullDetected = NO;
            }
        }
          if(swipeDetected == NO)
        {
            self.backgroundColor = self.defaultRowColor;
            self.listTextField.textColor = [UIColor whiteColor];
            [self.strikedLabel removeFromSuperview];
            self.strikedLabel = nil;
            [[self superview] touchesMoved:touches withEvent:event];
        }
        else
        {
            CGRect myFrame = self.frame;
            float deltaX = currentTouchPosition.x - prevTouchPosition.x;
            if (rightSwipeDetected || leftSwipeDetected) // give decelleration effect
            {
                deltaX = deltaX/DECELERATION_RATE;
            }
            myFrame.origin.x += deltaX;
            [self setFrame:myFrame];
            
            
            [self makeDeleteIcon];
            self.deleteImgView.frame =CGRectMake(self.frame.size.width +20,15, 24, 24);
            
            if (self.doneStatus == FALSE && prevTouchPosition.x < currentTouchPosition.x) {
            [self makeCheckedIcon];
            checkImgView.frame =CGRectMake(320 - self.frame.size.width - 30 ,15, 24, 24);  
            }
            else {
                [self.checkImgView removeFromSuperview];
                self.checkImgView =nil;
            }
            
            // To be a swipe, direction of touch must be horizontal and long enough.
            if (fabsf(initialCentre.x - self.center.x) >= HORIZ_SWIPE_DRAG_MIN && fabsf(initialCentre.y - self.center.y) <= VERT_SWIPE_DRAG_MAX)
            {
                // It appears to be a right swipe.
                        if (prevTouchPosition.x > currentTouchPosition.x && leftSwipeDetected == NO)
                {
                    self.alpha =0.5;
                    rightSwipeDetected =YES;
                    PullDetected = NO;
                }
         
          else  if (prevTouchPosition.x < currentTouchPosition.x && rightSwipeDetected == NO)
                {
                      if (self.doneStatus == TRUE) {
                          [self.checkImgView removeFromSuperview];
                          self.checkImgView =nil;
                          self.backgroundColor = self.defaultRowColor;
                          self.listTextField.textColor = [UIColor whiteColor];
                          [self.strikedLabel removeFromSuperview];
                          self.strikedLabel = nil;
                      }
                     else
                     {
                    self.listTextField.textColor = [UIColor grayColor];
                    self.backgroundColor = [UIColor colorWithRed:0.082 green:0.71 blue:0.11 alpha:1]; 
                    [self makeStrikedLabel];       //TODO: make it non editable after checked
                     [self addSubview:self.strikedLabel];
                    }
                    leftSwipeDetected = YES;
                    PullDetected = NO;
                }
            }
            else
            {
                NSLog(@" else :delta ,prev , current : %f %f,%f",initialCentre.x - self.center.x,initialCentre.x,self.center.x);
                if (rightSwipeDetected == YES)
                {
                    NSLog(@"right");
                    self.alpha =1;
                    rightSwipeDetected =NO;
                }
                if(leftSwipeDetected == YES)
                {
                    NSLog(@"here");
                    [self.checkImgView removeFromSuperview];
                    self.checkImgView =nil;
                    self.backgroundColor = self.defaultRowColor;
                    self.listTextField.textColor = [UIColor whiteColor];
                    [self.strikedLabel removeFromSuperview];    
                    leftSwipeDetected = NO;
                }
            }
        }
    }
} 

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (PullDetected == YES) {
        [[self superview] touchesEnded:touches withEvent:event];
        PullDetected = NO;
    }
    if (rightSwipeDetected == YES)
        {
        [self customRowRightSwipe:touches withEvent:event];
        }
    else if(leftSwipeDetected == YES)
        {
        [self customRowLeftSwipe:touches withEvent:event];  
        [self setFrame:CGRectMake(0, self.frame.origin.y, ROW_WIDTH, ROW_HEIGHT)];    
        }
    else{
        [self setFrame:CGRectMake(0, self.frame.origin.y, ROW_WIDTH, ROW_HEIGHT)];  
    }
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
{
    PullDetected = NO;
    rightSwipeDetected = NO;
    leftSwipeDetected = NO;
    [self setFrame:CGRectMake(0, self.frame.origin.y, ROW_WIDTH , ROW_HEIGHT)];
}

- (void)customRowRightSwipe:(NSSet *)touches withEvent:(UIEvent*)event
{
    self.alpha = 0.9;
    [self performSelector:@selector(deleteRow) withObject:nil afterDelay:0];
}

- (void)customRowLeftSwipe:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.alpha = 1;
    [self setFrame:CGRectMake(0, self.frame.origin.y, ROW_WIDTH, ROW_HEIGHT)];
    [self performSelector:@selector(checkRow) withObject:nil afterDelay:0.4];
}

# pragma mark - delegates

- (void)checkRow
{
    if ([swipeDelegate respondsToSelector:@selector(TDCustomRowToBeDeleted:With:bySwipe:)])
    {
    [swipeDelegate TDCustomRowToBeDeleted:FALSE With:self bySwipe:YES ];
    }
}
- (void)deleteRow
{
    if ([swipeDelegate respondsToSelector:@selector(TDCustomRowToBeDeleted:With:bySwipe:)])
    {
    [swipeDelegate TDCustomRowToBeDeleted:TRUE With:self bySwipe:YES];
    }
}

#pragma mark -UI
- (void)makeStrikedLabel
{ 
    //calculate the width of text in textfield
    CGSize textSize = [[listTextField text] sizeWithFont:[listTextField font]];
    CGFloat strikeWidth = textSize.width;
    
    if (self.strikedLabel !=nil) {
        [self.strikedLabel setFrame: CGRectMake(self.listTextField.frame.origin.x, self.listTextField.frame.origin.y, strikeWidth, self.listTextField.frame.size.height)];
        return;
    }
    //create the striked label with calculated text width
    self.strikedLabel = [[TDStrikedLabel alloc] initWithFrame:CGRectMake(self.listTextField.frame.origin.x, self.listTextField.frame.origin.y, strikeWidth, self.listTextField.frame.size.height)];
    self.strikedLabel.backgroundColor = [UIColor clearColor];
}

- (void)makeCheckedIcon
{
    if (self.checkImgView == nil) {
     self.checkImgView = [[UIImageView alloc] init];
    [self.checkImgView setImage:[UIImage imageNamed:@"check.png"]];
    self.checkImgView.tag = 101;
        [self addSubview:self.checkImgView];
    }
}

- (void)makeDeleteIcon
{
    if (self.deleteImgView == nil) {
    self.deleteImgView = [[UIImageView alloc] init];
    [self.deleteImgView setImage:[UIImage imageNamed:@"delete.png"]];
    self.deleteImgView.tag = 100;
    [self addSubview:self.deleteImgView];
    } 
}
#pragma mark - text field delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.listTextField resignFirstResponder];
    if ([self.listTextField.text isEqualToString:@""] && [swipeDelegate respondsToSelector:@selector(TDCustomRowToBeDeleted:WithId:bySwipe:)]) {
        [swipeDelegate TDCustomRowToBeDeleted:YES With:self bySwipe:YES];
    }
    else
    {
        TDScrollView * superView = (TDScrollView *)[self superview];
        if (superView.overlayView != nil) 
        {
            [superView overlayViewTapped];       
        }
        else if (self.doneOverlayView != nil) 
        {
            [self doneOverlayViewTapped];
            // TODO: update Web SErvice and update the list View array
        }
        else
        {
            TDScrollView * superView = (TDScrollView *)[self superview];
            [UIView animateWithDuration:0.3 animations:^{
                [superView setFrame:CGRectMake(0,0, SCROLLVIEW_WIDTH, SCROLLVIEW_HEIGHT)];
            }];
        }
    }
    CGSize textSize = [[self.listTextField text] sizeWithFont:[self.listTextField font]];
    [self.listTextField setFrame:CGRectMake(self.listTextField.frame.origin.x, self.listTextField.frame.origin.y, textSize.width+5, textSize.height)];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.listTextField.text isEqualToString:@""]) {
        self.listTextField.enablesReturnKeyAutomatically= YES;
    }

    TDScrollView * superView = (TDScrollView *)[self superview];
    [UIView animateWithDuration:0.3 animations:^{
        [superView setFrame:CGRectMake(0,0 - self.frame.origin.y, SCROLLVIEW_WIDTH, SCROLLVIEW_HEIGHT)];}];
    if (superView.overlayView == nil) {
    [self createDoneOverlayAtHeight:-superView.frame.origin.y + ROW_HEIGHT];
    [superView addSubview:self.doneOverlayView];
    }
}

- (void)createDoneOverlayAtHeight:(float)height
{
    if (self.doneOverlayView) {
        return;
    }
    self.doneOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, height, ROW_WIDTH, 480)];
    self.doneOverlayView.backgroundColor =[[UIColor blackColor] colorWithAlphaComponent:0.5];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doneOverlayViewTapped)]; 
    [self.doneOverlayView addGestureRecognizer:tapGestureRecognizer];
}

- (void)doneOverlayViewTapped
{
    [self.listTextField resignFirstResponder];
    [self.doneOverlayView removeFromSuperview];
    self.doneOverlayView = nil;
 
    TDScrollView * superView = (TDScrollView *)[self superview];
    [UIView animateWithDuration:0.3 animations:^{
        [superView setFrame:CGRectMake(0,0, SCROLLVIEW_WIDTH, SCROLLVIEW_HEIGHT)];
    }];
    CGSize textSize = [[self.listTextField text] sizeWithFont:[self.listTextField font]];
    [self.listTextField setFrame:CGRectMake(self.listTextField.frame.origin.x, self.listTextField.frame.origin.y, textSize.width+5, textSize.height)];
}

- (void)divideIntoTwoLayers
{   
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1/200.0;
    self.layer.sublayerTransform = transform;

    self.topHalfLayer = [CALayer layer];
    self.topHalfLayer.anchorPoint = CGPointMake(0.5, 1);
    self.topHalfLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    self.bottomHalfLayer = [CALayer layer];
    self.bottomHalfLayer.anchorPoint = CGPointMake(0.5, 0);
    self.bottomHalfLayer.backgroundColor = [UIColor clearColor].CGColor;

//    CGRect halfRect = CGRectMake(0, 0, ROW_WIDTH, 0.5 * ROW_HEIGHT);
//    self.topHalfLayer.bounds = halfRect;
//    self.bottomHalfLayer.bounds = halfRect;
//
//    CGPoint midpoint = CGPointMake(0.5 * ROW_WIDTH, 0.5 * ROW_HEIGHT);
//    self.topHalfLayer.position = midpoint;
//    self.bottomHalfLayer.position = midpoint;
//    
    [self.layer addSublayer:self.topHalfLayer];
    [self.layer addSublayer:self.bottomHalfLayer];

//    self.innerLayer = [TDRowLayer layer];
//    self.innerLayer.topHalfLayer.backgroundColor = self.defaultRowColor.CGColor;
//    self.innerLayer.bottomHalfLayer.backgroundColor = self.defaultRowColor.CGColor;
//    [self.layer addSublayer:self.innerLayer];
}

//- (void)layoutSublayers
- (void)test
{    
//    CGSize size = self.bounds.size; 
//    
//    NSLog(@" Lay out sub layers here !!!!!!!!!!!!!!!!!!!!!!");    
//    CGRect halfRect = CGRectMake(0, 0, size.width, 0.5 * ROW_HEIGHT);
//    self.topHalfLayer.bounds = halfRect;
//    self.bottomHalfLayer.bounds = halfRect;
//    
//    CGPoint midpoint = CGPointMake(0.5 * size.width, 0.5 * size.height);
//    self.topHalfLayer.position = midpoint;
//    self.bottomHalfLayer.position = midpoint;
//    
//    CGFloat y = 0.5 * self.bounds.size.height;
//    CGFloat l = 0.5 * ROW_HEIGHT;
//    CGFloat angle = acosf(y/l);
//    CGFloat zTranslationValue = l * sinf(angle);
//    CGFloat topAngle = angle;
//    CGFloat bottomAngle = angle;
//    
//    // For pinch
//    topAngle *= -1;
//    
//    CATransform3D transform = CATransform3DMakeTranslation(0, 0, -zTranslationValue);
//    self.topHalfLayer.transform = CATransform3DRotate(transform, topAngle , 1.0, 0.0, 0.0);
//    self.bottomHalfLayer.transform =CATransform3DRotate(transform, bottomAngle , 1.0, 0.0, 0.0);
//
    CGFloat fraction = (self.frame.size.height / ROW_HEIGHT);
    fraction = MAX(MIN(1, fraction), 0);
    
    CGFloat angle = (M_PI / 2) - asinf(fraction);
    CATransform3D transform = CATransform3DMakeRotation(angle, -1, 0, 0);
    [self.topHalfLayer setTransform:transform];
    [self.bottomHalfLayer setTransform:CATransform3DMakeRotation(angle, 1, 0, 0)];
    
//    self.textLabel.backgroundColor       = [self.tintColor colorWithBrightness:0.3 + 0.7*fraction];
//    self.detailTextLabel.backgroundColor = [self.tintColor colorWithBrightness:0.5 + 0.5*fraction];
//    
    CGSize contentViewSize = self.frame.size;
    CGFloat contentViewMidY = contentViewSize.height / 2;
    CGFloat labelHeight = ROW_HEIGHT / 2;
    
    // OPTI: Always accomodate 1 px to the top label to ensure two labels 
    // won't display one px gap in between sometimes for certain angles 
    self.topHalfLayer.frame = CGRectMake(0, contentViewMidY - (labelHeight * fraction),
                                      contentViewSize.width, labelHeight + 1);
    self.bottomHalfLayer.frame = CGRectMake(0, contentViewMidY - (labelHeight * (1 - fraction)),
                                            contentViewSize.width, labelHeight);

}

@end
