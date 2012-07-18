//
//  TDViewController.m
//  ToDo
//
//  Created by Megha Wadhwa on 19/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//listArray contains all TODOList's Model objects
//doneArray contains all completed TODOList's Model Objects.
//CustomViewsArray contains all custom rows
//CheckedViewsArray contains all completed custom rows

//listArray and CustomViewsArray are in sync
//doneArray and CheckedViewsArray are in sync

//indexArrays are used coz to clear the completed items,we can have more than one element to clear
// that is why we pass an index array containing indexes of checked rows

#import "TDViewController.h"
#import "TDListViewController.h"

@interface TDViewController(privateMethods)
- (void)createUI;
- (void)shiftRowsFromIndex:(int)index;
- (void)shiftRowsBackFromIndex:(int)index withDeletionFlag:(BOOL)flag;
- (void)rearrangeColorsBasedOnPrioirity; 
- (void)animateRowsAfterDeletionAtIndex:(int)index FromArray:(NSMutableArray *) requiredArray withDeletionFlag: (BOOL)flag;
- (void)moveCheckedRowsUptoIndex:(int)index WithDeletionFlag:(BOOL) flag;
- (void)moveCheckedRowsDown;
@end

@implementation TDViewController
@synthesize backgroundScrollView;
@synthesize listArray,doneArray;
@synthesize customViewsArray,checkedViewsArray;
@synthesize parentName;
@synthesize goingDownByPullUp;
@synthesize childName;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}
- (void)animateWhenComingBack
{
    //if (self.goingBackFlag == YES) {
        [UIView animateWithDuration:2 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{  
            CGRect myFrame = self.view.frame;
            myFrame.origin.y = 0;
            self.view.frame = myFrame;
            NSLog(@"height :%f",myFrame.origin.y);
        } completion:nil];
    //}
    
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor blackColor];
    self.listArray = [[NSMutableArray alloc] init];
    self.doneArray = [[NSMutableArray alloc] init];
    self.checkedViewsArray = [[NSMutableArray alloc] init];
    self.customViewsArray = [[NSMutableArray alloc] init];
    //[self getDataFromServer];                            // TODO :Fix Server 
    [self createUI];
}

#pragma mark - Navigation 

- (void)TDCustomRowTapped:(TDListCustomRow *)sender
{
    [self perform];
}

- (void)perform {
    
}

#pragma mark - Deletion Delegates

- (BOOL)checkedRowsExist
{
    BOOL checkedRowFlag = FALSE;
    int totalObjects = [self.doneArray count];
    for (int i =0; i<totalObjects; i++) 
    {
        ToDoList *aListItem = [self.doneArray objectAtIndex:i];
        if (aListItem.doneStatus == TRUE) 
        {
            checkedRowFlag = TRUE;
            break;
        }
    }
    return checkedRowFlag;
}

- (void)TDCustomRowToBeDeleted:(BOOL)flag With:(TDListCustomRow *)senderRow bySwipe:(BOOL)Flag
{
    TDListCustomRow * currentView = (TDListCustomRow *)senderRow;
   //depending on checked or unchecked row ,checked or custom views array is selected
    NSMutableArray * requiredArray , *modelArray;
    if(currentView.doneStatus == TRUE) { 
        requiredArray = self.checkedViewsArray;
        modelArray = self.doneArray;
    }
    else { 
        requiredArray =self.customViewsArray ;
        modelArray = self.listArray;
    }
    
    int numberOfviews = [requiredArray count];
    NSMutableArray *swipedIndexArray = [[NSMutableArray alloc] init];
    int index;
    for (index = 0; index< numberOfviews; index++) 
    {
        TDListCustomRow * currentView = [requiredArray objectAtIndex:index];  
        if(senderRow.tag == currentView.tag){  
        [swipedIndexArray addObject:[NSNumber numberWithInt:index]];
            break;
        }
    }
    if ([swipedIndexArray count]>0) {
        // If current Row is checked And it is not suppossed to be deleted
        if (currentView.doneStatus && !flag)
        {
            [self rearrangeRowsAfterUnChekingAtIndex:[[swipedIndexArray lastObject]intValue]];
            [TDCommon setDoneStatus:currentView];

        }
        else {
            if (Flag) {
                [self rearrangeRowsAfterRemovingObjectAtIndex:swipedIndexArray withDeletionFlag:flag fromRequiredArray:requiredArray];
            }
            else {
                [self rearrangeRowsAfterPullUpAtIndex:swipedIndexArray];
            }
        }
        [self rearrangeListObjectsAfterRemovingObjectAtIndex:swipedIndexArray withDeletionFlag:flag fromModelArray:modelArray];
        [self rearrangeColorsBasedOnPrioirity];
        // TODO: remove from Server also.
    }
}

#pragma mark - Extra Pull Down Delegates
- (NSString *)getParentName{
    return self.parentName;
}

- (void)addParentView{
    
}
#pragma mark - Extra Pull Up Delegates

- (NSString *)getChildName
{
    return self.childName;
}

- (void)addChildView{}
#pragma mark - Pull Delegates
- (void)TDCustomViewPulledUp
{
    int numberOfRows = [self.doneArray count];
    NSMutableArray *checkedIndexArray = [[NSMutableArray alloc] init];
    for (int i = 0; i<numberOfRows; i++) 
    { 
        ToDoList *currentList = [self.doneArray objectAtIndex:i];
        if (currentList.doneStatus == TRUE)                             //******* TO REMOVE
        {
            [checkedIndexArray addObject:[NSNumber numberWithInt:i]];
            NSLog(@"index :%i",i);
        }
    }
    if ([checkedIndexArray count]>0) {
        [self rearrangeRowsAfterPullUpAtIndex:checkedIndexArray];
        // TODO: remove from Server also.
    }
}

- (void)TDCustomViewPulledDownWithNewRow:(TDListCustomRow *)newRow
{
    static int listId = 7;
    ToDoList *newList = [[ToDoList alloc] init];
    newList.listName = newRow.listTextField.text;
    if ([self.listArray count]!=0) {
        ToDoList *firstList = [self.listArray objectAtIndex:0];
        ToDoList *lastList = [self.listArray lastObject];
        newList.listId =(lastList.listId >firstList.listId ? lastList.listId :firstList.listId)+1;   
    }
    else
    {
        newList.listId = listId;
        listId ++;
    }
    // greater of first/last 
    newList.createdAtDate = [NSDate date];
    newList.updatedAtDate = [NSDate date];
    
    // TODO: WEB SERVICE TO ADD A LIST NEW :
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithObjects:newList, nil];
    [tempArray addObjectsFromArray:self.listArray];
    self.listArray = nil;
    self.listArray = tempArray;
    tempArray = nil;
    
    tempArray = [[NSMutableArray alloc] initWithObjects:newRow, nil];
    newRow.tag = newList.listId; 
    newRow.swipeDelegate = self;
    newRow.tapDelegate = self;
    [tempArray addObjectsFromArray:self.customViewsArray];
    self.customViewsArray = nil;
    self.customViewsArray = tempArray;
    tempArray = nil;
    
    [self rearrangeColorsBasedOnPrioirity];
}

#pragma mark - Pinch Delegates

- (TDListCustomRow *)RowAtPoint:(CGPoint)point
{
    //NSLog(@"custom array :%@",self.customViewsArray);
    for ( TDListCustomRow *row in self.customViewsArray)
        if ( CGRectContainsPoint(row.frame, point ) )
            return row;
    
    return nil;
}

- (int)getRowIndexFromCustomArrayFor:(TDListCustomRow *)row
{
    int index = nil;
    int count = [self.customViewsArray count];
    for (int i = 0; i < count; i++) {
        TDListCustomRow *currentRow = [self.customViewsArray objectAtIndex:i];
        if (currentRow.tag == row.tag) {
            index = i;
            break;
        }
    }
    return index;
}

- (BOOL)isLastObjectOnView:(TDListCustomRow *)row 
{
    BOOL lastObjectFlag = NO;
    // last custom row to be created and no checked row after that
    if (row == [self.customViewsArray lastObject] && [self.checkedViewsArray count] == 0) {
        lastObjectFlag = YES;
    }
    return lastObjectFlag;
}

- (void)shiftByScale:(float)scale forPinch:(BOOL)pinch withState:(UIGestureRecognizerState)state andCreating:(BOOL)creating forCurrentRow: (TDListCustomRow *) customNewRow 
{
    CGFloat y = 0;
    for ( TDListCustomRow *uncheckedRow in self.customViewsArray)
    {   
        CGRect frame = uncheckedRow.frame;
        if ( pinch && uncheckedRow == customNewRow && scale > 1 && state == UIGestureRecognizerStateChanged )
        {
            CGRect layerFrame = uncheckedRow.layer.frame;
            TDRowLayer *innerlayer = [uncheckedRow.layer.sublayers lastObject];
            CGRect innerlayerFrame = innerlayer.frame;
            if ( creating )
                scale = fmaxf(scale - 1, 0);
            
            CGFloat dy = ROW_HEIGHT * scale;
            if ( creating && scale < 1 )
            {
                frame.origin.y = y;
                layerFrame.origin.y =y;
                innerlayerFrame.origin.y = y;
            }
            else
            {
                frame.origin.y = y + 0.5 * (dy - ROW_HEIGHT);
                layerFrame.origin.y = y + 0.5 * (dy - ROW_HEIGHT);
                innerlayerFrame.origin.y = y + 0.5 * (dy - ROW_HEIGHT);
            } 
            uncheckedRow.frame = frame;
            uncheckedRow.layer.frame = layerFrame;
            innerlayer.frame = innerlayerFrame;
            y += dy;
        }
        else
        {
            frame.origin.y = y;
            uncheckedRow.frame = frame;
            y += frame.size.height;
        }        
    }

}

- (void)addNewRow:(TDListCustomRow *)newRow AtIndex:(int)index
{
    [self.customViewsArray insertObject:newRow atIndex:index];
    //[self rearrangeColorsBasedOnPrioirity];
}

- (void)removeNewRow:(TDListCustomRow *)newRow AtIndex:(int)index
{
    if (newRow == [self.customViewsArray objectAtIndex:index]) {
    [self.customViewsArray removeObjectAtIndex:index];
    }
}
#pragma mark - UI

- (void)shiftRowsFromIndex:(int)index
{
    // rearrange after the new row is added
    
}

- (void)shiftRowsBackFromIndex:(int)index withDeletionFlag:(BOOL)flag
{
    int lastObjectIndex = [self.customViewsArray count]-1;
    if (index < lastObjectIndex){ // Not the last object
        for (int i = lastObjectIndex; i > index; i--) { // transfer frames from last to current
            TDListCustomRow *Row = [self.customViewsArray objectAtIndex:i];
            TDListCustomRow *previousRow = [self.customViewsArray objectAtIndex:i-1];
            float delay;
            if (flag == TRUE) delay = DELETION_DELAY;  
            else delay =CHECKING_DELAY;
            [UIView animateWithDuration:ROWS_SHIFTING_DURATION delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                Row.frame = CGRectMake(0, previousRow.frame.origin.y, previousRow.frame.size.width, previousRow.frame.size.height);} completion:nil]; 
        }
    }
}

// Prioirity is based on Index,Higher Index Lesser Priority,Lesser Color
- (void)rearrangeColorsBasedOnPrioirity 
{
    int totalRows = [self.customViewsArray count];
    for (int i =0; i<totalRows; i++) 
    {
        ToDoList *aList = [self.listArray objectAtIndex:i];
        if(aList.doneStatus == FALSE)
        {
            TDListCustomRow *aRow = [self.customViewsArray objectAtIndex:i];
            aRow.backgroundColor = [TDCommon getColorByPriority:i+1];
            aRow.defaultRowColor = aRow.backgroundColor;
        }
    }
}

//rearrangeRows after pull up and deleting all checked Rows
-(void)rearrangeRowsAfterPullUpAtIndex:(NSMutableArray*)indexArray
{
    int lastObjectIndex = [TDCommon calculateLastIndexForArray:indexArray];
    for (int i =lastObjectIndex; i>=0; i--) 
    {
        TDListCustomRow *RowToBeMoved = [self.checkedViewsArray objectAtIndex:i];
        [UIView animateWithDuration:DELETING_ROW_ANIMATION_DURATION animations:^{
                RowToBeMoved.frame = CGRectMake(0, 480, ROW_WIDTH, ROW_HEIGHT);
            }];
        [RowToBeMoved performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:DELETING_ROW_ANIMATION_DURATION];
        [self.checkedViewsArray removeObjectAtIndex:i];
    }
    [self rearrangeListObjectsAfterPullUpWithIndex:indexArray];
}

- (void)rearrangeRowsAfterUnChekingAtIndex:(int)index
{
    NSLog(@"array checked %@ array custom %@",self.checkedViewsArray,self.customViewsArray);
     TDListCustomRow * lastCustomRow = [self.customViewsArray lastObject];
    
    TDListCustomRow *RowToBeMoved = [self.checkedViewsArray objectAtIndex:index];
    BOOL lastCheckedFlag = (RowToBeMoved == [self.checkedViewsArray lastObject]);
    [[RowToBeMoved superview] bringSubviewToFront:RowToBeMoved];
    
    [self.customViewsArray addObject:RowToBeMoved];
       
    if (!lastCheckedFlag) { //NO need to move the last checked row
        [self moveCheckedRowsUptoIndex:index WithDeletionFlag:YES];
        [self.checkedViewsArray removeObjectAtIndex:index];

        if (lastCustomRow) {
            [UIView animateWithDuration:ROWS_SHIFTING_DURATION animations:^{
                RowToBeMoved.frame = CGRectMake(0, lastCustomRow.frame.origin.y + ROW_HEIGHT, ROW_WIDTH, ROW_HEIGHT);
            }];
        }
        else {
            [UIView animateWithDuration:ROWS_SHIFTING_DURATION animations:^{
                RowToBeMoved.frame = CGRectMake(0, 0, ROW_WIDTH, ROW_HEIGHT);
            }];
        }
        //Re Arrange the checked Rows From and after that Index
        [self moveCheckedRowsDown];
    }
    else {
        [self.checkedViewsArray removeObjectAtIndex:index];
    }
    
}

 - (void)rearrangeRowsAfterRemovingObjectAtIndex:(NSMutableArray *)indexArray withDeletionFlag:(BOOL)flag fromRequiredArray:(NSMutableArray *)requiredArray
{
    NSLog(@"array here %@",requiredArray);
    int lastIndex = [indexArray count] -1;
    for (int i =lastIndex; i>=0; i--) 
    {
        int index = [[indexArray objectAtIndex:i] intValue];
        
        TDListCustomRow *RowToBeMoved = [requiredArray objectAtIndex:index];
        
        if (flag == TRUE)     // deleted row to be removed from view
        {
            [UIView animateWithDuration:DELETING_ROW_ANIMATION_DURATION animations:^{
                    RowToBeMoved.frame = CGRectMake(-ROW_WIDTH, RowToBeMoved.frame.origin.y, ROW_WIDTH, ROW_HEIGHT);
            }];
            [RowToBeMoved performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:DELETING_ROW_ANIMATION_DURATION];
        }   
        
        [self animateRowsAfterDeletionAtIndex:index FromArray:requiredArray withDeletionFlag:flag];
        
               if (flag == TRUE) {    // deleted row to be removed from custom views array
            [requiredArray removeObjectAtIndex:index];
        }
        else
        {
            [requiredArray removeObjectAtIndex:index];
            [UIView animateWithDuration:0.5 animations:^{
                TDListCustomRow *lastRow = [requiredArray lastObject];
                [self.backgroundScrollView bringSubviewToFront:RowToBeMoved];
                RowToBeMoved.frame =CGRectMake(0, lastRow.frame.origin.y + lastRow.frame.size.height, RowToBeMoved.frame.size.width, RowToBeMoved.frame.size.height);
                
            }];
            [TDCommon setDoneStatus:RowToBeMoved];
            if (RowToBeMoved.doneStatus)
            {
                [self.checkedViewsArray addObject:RowToBeMoved];
                RowToBeMoved.listTextField.textColor = [UIColor grayColor];
                RowToBeMoved.backgroundColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1];
            }
            else 
            {
                [self.customViewsArray addObject:RowToBeMoved];
                RowToBeMoved.listTextField.textColor = [UIColor grayColor];
            }
            }
    }

    NSLog(@"array now %@ chkd views array : %@",self.customViewsArray,self.checkedViewsArray);
}

- (void)animateRowsAfterDeletionAtIndex:(int)index FromArray:(NSMutableArray *) requiredArray withDeletionFlag:(BOOL)flag
{

    if (requiredArray != self.checkedViewsArray) {
        if (flag) {
        int lastCheckedObjectIndex = [self.checkedViewsArray count]-1;  //First Move ALL Checked Rows Up-Frm ChckdViewarray
        TDListCustomRow * lastCheckedRow = [self.checkedViewsArray lastObject];
        TDListCustomRow *lastCustomRow = [self.customViewsArray lastObject];
        [self moveCheckedRowsUptoIndex:lastCheckedObjectIndex WithDeletionFlag:flag];
        [UIView animateWithDuration:ROWS_SHIFTING_DURATION delay:DELETION_DELAY options:UIViewAnimationOptionCurveEaseInOut animations:^{
                lastCheckedRow.frame = CGRectMake(0, lastCustomRow.frame.origin.y, lastCustomRow.frame.size.width, lastCustomRow.frame.size.height);} completion:nil]; 
        }
        //Then Move Custom Unchecked Rows Up till the required Index
        [self shiftRowsBackFromIndex:index withDeletionFlag:flag];
     
    }    
    else [self moveCheckedRowsUptoIndex:index WithDeletionFlag:flag];
}

- (void)moveCheckedRowsUptoIndex:(int)index WithDeletionFlag:(BOOL) flag 
{
    for (int i = 0; i < index; i++)  // transfer frames from first to current
    {
        TDListCustomRow *Row = [self.checkedViewsArray objectAtIndex:i];
        TDListCustomRow *nextRow = [self.checkedViewsArray objectAtIndex:i+1];
        float delay;
        if (flag == TRUE) delay = DELETION_DELAY;  
        else delay =CHECKING_DELAY;
        [UIView animateWithDuration:ROWS_SHIFTING_DURATION delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
            Row.frame = CGRectMake(0, nextRow.frame.origin.y, nextRow.frame.size.width, nextRow.frame.size.height);} completion:nil]; 
    }
}
- (void) moveCheckedRowsDown
{
    TDListCustomRow *lastCustomRow = [self.customViewsArray lastObject];
    
    int lastCheckedObjectIndex = [self.checkedViewsArray count]-1;
    
    TDListCustomRow * lastCheckedRow = [self.checkedViewsArray lastObject];
    
    if (lastCustomRow) {
        [UIView animateWithDuration:ROWS_SHIFTING_DURATION animations:^{
            lastCheckedRow.frame = CGRectMake(0, lastCustomRow.frame.origin.y + ROW_HEIGHT, ROW_WIDTH, ROW_HEIGHT);
        }];
    }
    else {
        [UIView animateWithDuration:ROWS_SHIFTING_DURATION animations:^{
            lastCheckedRow.frame = CGRectMake(0, 0, ROW_WIDTH, ROW_HEIGHT);
        }];
    }

    //[self moveCheckedRowsUptoIndex:lastCheckedObjectIndex WithDeletionFlag:YES];
    
    for (int index = lastCheckedObjectIndex -1 ; index >= 0; index--) {
        TDListCustomRow *checkedRow = [self.checkedViewsArray objectAtIndex:index];
        
        [UIView animateWithDuration:ROWS_SHIFTING_DURATION delay:CHECKING_DELAY options:UIViewAnimationOptionCurveEaseInOut animations:^{
           checkedRow.frame = CGRectMake(0, checkedRow.frame.origin.y +ROW_HEIGHT, ROW_WIDTH, ROW_HEIGHT);} completion:nil]; 
    }
}
- (void)createUI
{
    /************** background scrollview *************/
    self.backgroundScrollView = [[TDScrollView alloc] initWithFrame:CGRectMake(0, 0, SCROLLVIEW_WIDTH, SCROLLVIEW_HEIGHT)];
    self.backgroundScrollView.pullDelegate = self;
    self.backgroundScrollView.pinchOutdelegate = self;
    self.backgroundScrollView.extraPullDownDelegate = self;
    self.backgroundScrollView.extraPullUpDelegate = self;
    [self.view addSubview:self.backgroundScrollView];
    [self populateCustomViewsArrayFromListArray];
}

- (void)toggleSubViews:(BOOL)hide
{
    if (hide) {
        for (TDListCustomRow *subview in self.view.subviews)
        {
            subview.hidden = YES;
        }
    }
    else {
        for (TDListCustomRow *subview in self.view.subviews)
        {
            subview.hidden = NO;
        }
    }
}

- (void)populateCustomViewsArrayFromListArray
{
    //static int y =1;
    for (int i =0; i<[self.listArray count]; i++)
    {
        ToDoList *toDoList = [self.listArray objectAtIndex:i];
        static int y =0;
        y= ROW_HEIGHT *i ;
        TDListCustomRow *row = [[TDListCustomRow alloc ] initWithFrame:CGRectMake(0, y,ROW_WIDTH , ROW_HEIGHT)];
        row.backgroundColor = [TDCommon getColorByPriority:i+1];
        row.listTextField.text = toDoList.listName;
        CGSize textSize = [[row.listTextField text] sizeWithFont:[row.listTextField font]];
        [row.listTextField setFrame:CGRectMake(row.listTextField.frame.origin.x, row.listTextField.frame.origin.y, textSize.width+5, textSize.height)];
        row.swipeDelegate = self;
        row.tapDelegate = self;
        row.tag =toDoList.listId;
        row.doneStatus = FALSE;
        NSLog(@" To Do List :%@,%i",toDoList.listName,y);
        [self.backgroundScrollView addSubview:row];
        [self.customViewsArray addObject:row];       
    }
    //    self.backgroundScrollView.customViewsArray =self.customViewsArray;
    //    self.backgroundScrollView.checkedViewsArray = self.checkedViewsArray;
    [self rearrangeColorsBasedOnPrioirity];
    NSLog(@"array now %@",self.customViewsArray);
}

- (float)getLastRowHeight
{
    float lastRowheight = 480;
    if ([self.checkedViewsArray lastObject]) {
        lastRowheight = [TDCommon getLastRowMaxYFromArray:self.checkedViewsArray];
    }
    else if([self.customViewsArray lastObject]){
        lastRowheight = [TDCommon getLastRowMaxYFromArray:self.customViewsArray];
    }
    return lastRowheight;
}
#pragma mark - Change Models

- (void)rearrangeListObjectsAfterPullUpWithIndex:(NSMutableArray*)indexArray
{
    NSLog(@"array before %@",self.doneArray);
    int lastObjectIndex = [TDCommon calculateLastIndexForArray:indexArray];
    for (int i =lastObjectIndex; i>=0; i--) 
    {
        // TODO: DELETE WEB SERVICE CALL
        [self.doneArray removeObjectAtIndex:i];
    }
    NSLog(@"array before %@",self.doneArray);
} 

- (void)rearrangeListObjectsAfterRemovingObjectAtIndex:(NSMutableArray*)indexArray withDeletionFlag:(BOOL)flag fromModelArray:(NSMutableArray *)modelArray
{
    NSLog(@"array before %@",modelArray);
    int lastObjectIndex = [TDCommon calculateLastIndexForArray:indexArray];
    for (int i =lastObjectIndex; i>=0; i--) 
    {
        int index = [[indexArray objectAtIndex:i] intValue];
        
        if (flag == TRUE) 
        {                                   // TODO: DELETE WEB SERVICE CALL
            [modelArray removeObjectAtIndex:index];
        } 
        else
        {
            ToDoList *listToBeMoved = [modelArray objectAtIndex:index];
            if (listToBeMoved.doneStatus == TRUE) {
                 listToBeMoved.doneStatus =FALSE;
            }
            else
            {
                listToBeMoved.doneStatus = TRUE;
            }
            [modelArray removeObjectAtIndex:index];
            if (listToBeMoved.doneStatus == TRUE) {
            [self.doneArray addObject:listToBeMoved];
            }
            else {
                [self.listArray addObject:listToBeMoved];
            }
            // TODO: update WEB SERVICE CALL
            // checked
            //TODO:delete after pull
        }
    }
    NSLog(@"array now %@ done array %@",self.listArray,self.doneArray);
}

# pragma mark - FETCH  DATA FROM SERVER
- (void)getDataFromServer
{
    NSDictionary * dict = [NSDictionary dictionaryWithContentsOfJSONURLString:IP];
    
    if (dict) 
    {
        NSArray* responseArray = [dict objectForKey:@"result"]; //2
        NSLog(@"response array: %@",responseArray);
        
        //****************** populating model with data
        for (int i =0; i<[responseArray count]; i++)
        {
            ToDoList *toDoList = [[ToDoList alloc] init];
            NSDictionary *paramDict = [responseArray objectAtIndex:i];
            [toDoList readFromDictionary:paramDict]; 
            toDoList.doneStatus = FALSE;   //TOREMOVE
            [self.listArray addObject:toDoList];
            NSLog(@" To Do List :%@",self.listArray);
        }
    }
    
    else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"To Do App" message:@"Server unavailable" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        [alert show];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [TDCommon setTheme:THEME_HEAT_MAP];
    //if (self.goingBackFlag == YES) {
      //  [self animateWhenComingBack];
    //}
//    CGRect myFrame = self.view.frame;
//    myFrame.origin.y = -480.0f;
//    self.view.frame = myFrame;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
