#import "DraggableGraphView.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@interface DraggableGraphView ()

/**
 *  Gesture Recognizer to make the view draggable
 */
@property(nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

/**
 *  The starting point for the graph used for animation purposes
 */
@property(nonatomic) CGPoint originalPoint;

/**
 *  An array of either votes or rankings to be graphed
 */
@property(strong, nonatomic) NSArray *data;

/**
 *  Either vote or ranking
 */
@property(strong, nonatomic) NSString *graphType;

@end

@implementation DraggableGraphView

- (id)initWithFrame:(CGRect)frame andGraphType:(NSString *)graphType andData:(NSArray *)data
{
    self = [super initWithFrame:frame];
    CGPoint original = CGPointMake(160, 300);
    CGFloat startingX = -400;
    if ([graphType isEqualToString:@"votes"]) {
        startingX = -(startingX);
    }
    self.frame = CGRectMake(startingX, 160, self.frame.size.width, self.frame.size.height);
    if (!self) return nil;
    self.data = [[NSArray alloc] initWithArray:data];
    self.graphType = [[NSString alloc] initWithString:graphType];
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    [self addGestureRecognizer:self.panGestureRecognizer];
    [self setBackgroundColor:[UIColor lightGrayColor]];
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.center = original;
                         self.transform = CGAffineTransformMakeRotation(0);
                     }
     ];
    return self;
}

/**
 *  Responds to dragging.  If the view is dragged beyond a certain point, it is swapped out and replaced by another view
 *
 *  @param gestureRecognizer
 */
- (void)dragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGFloat xDistance = [gestureRecognizer translationInView:self].x;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = self.center;
            break;
        };
        case UIGestureRecognizerStateChanged:{
            if ([self.graphType isEqualToString:@"votes"]) {
                if(xDistance < 0) xDistance = 0;
            }
            if ([self.graphType isEqualToString:@"rankings"]) {
                if(xDistance > 0) xDistance = 0;
            }
            self.center = CGPointMake(self.originalPoint.x + xDistance, self.originalPoint.y);
            break;
        };
        case UIGestureRecognizerStateEnded: {
            if((([self.graphType isEqualToString:@"votes"]) && (xDistance) > 80) || ([self.graphType isEqualToString:@"rankings"] && (xDistance <-80))) {
                NSDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"returnedDrag"
                                                                              action:[NSString stringWithFormat:@"removedGraphType%@", self.graphType]
                                                                               label:[NSString stringWithFormat:@"removedGraphType%@", self.graphType]
                                                                               value:nil] build];
                [[GAI sharedInstance].defaultTracker send:event];
                [[GAI sharedInstance] dispatch];
                [self slowlyRemoveView:xDistance];
            } else {
                NSDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"returnedDrag"
                                                                              action:[NSString stringWithFormat:@"swipedNoRemoveGraphType%@", self.graphType]
                                                                               label:[NSString stringWithFormat:@"swipedNoRemoveGraphType%@", self.graphType]
                                                                               value:nil] build];
                [[GAI sharedInstance].defaultTracker send:event];
                [[GAI sharedInstance] dispatch];
                [self resetViewPositionAndTransformations];
                break;
            }
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

/**
 *  Animation.  Moves the view back to it's original point
 */
- (void)resetViewPositionAndTransformations
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.center = self.originalPoint;
                         self.transform = CGAffineTransformMakeRotation(0);
                     }];
}

/**
 *  Animation.  Slowly removes the view when it reaches the appropriate threshold
 *
 *  @param xDistance the distance the view has been moved
 */
- (void)slowlyRemoveView:(CGFloat) xDistance {
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.center = CGPointMake(xDistance*4, self.originalPoint.y);
                         self.transform = CGAffineTransformMakeRotation(0);
                     }
                    completion:^(BOOL finished) {
                        [self removeFromSuperview];
                        if([self.graphType isEqualToString:@"votes"]) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"graphSwipe" object:@1];
                        } else {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"graphSwipe" object:@0];
                        }
                    }
     ];
}

/**
 *  Deallocates the view
 */
- (void)dealloc
{
    [self removeGestureRecognizer:self.panGestureRecognizer];
}

/**
 *  Draws the actual graph
 *
 *  @param rect
 */
- (void)drawRect:(CGRect)rect
{
    if([self.graphType isEqualToString:@"votes"]) {
        [self plotVoteGraph];
    } else {
        [self drawScaleForRankGraph];
        [self plotRankGraph];
    }
}

/**
 *  Draws horizontal lines to display a scale on the rank graph
 */
- (void)drawScaleForRankGraph
{
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    double heightScaleFactor = height/4;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    for(int i = 0; i < 5; i++) {
        int currentHeight = (i+1)*heightScaleFactor;
        CGContextMoveToPoint(context, 0, currentHeight);
        CGContextAddLineToPoint(context, width, currentHeight);
    }
    CGContextStrokePath(context);
}

/**
 *  Plots the rank graph
 */
-(void)plotRankGraph
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextSetLineWidth(context, 4.0);
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    double widthScaleFactor = width/(self.data.count-1);
    double heightScaleFactor = height/20;
    for(int i = 0; i < self.data.count-1; i++) {
        NSNumber *rank = [self.data objectAtIndex:i];
        NSNumber *nextRank = [self.data objectAtIndex:i+1];
        CGContextMoveToPoint(context, i*widthScaleFactor, [rank integerValue]*heightScaleFactor);
        if(i == (self.data.count-2)) {
            [self addLabelInPosition:CGRectMake((i+1)*widthScaleFactor-10, [nextRank integerValue]*heightScaleFactor-20, 20, 20) andRank:nextRank];
        }
        [self addLabelInPosition:CGRectMake(i*widthScaleFactor-10, [rank integerValue]*heightScaleFactor-20, 20, 20) andRank:rank];
        CGContextAddLineToPoint(context, (i+1)*widthScaleFactor, [nextRank integerValue]*heightScaleFactor);
        CGContextStrokePath(context);
    }
}

/**
 *  Plots the vote graph
 */
-(void)plotVoteGraph
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
    CGContextSetLineWidth(context, 4.0);
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    double widthScaleFactor = width/(self.data.count-1);
    long mean = [self findMean];
    double heightScaleFactor = height/[self findDifference]/2;
    for(int i = 0; i < self.data.count-1; i++) {
        NSNumber *count = [self.data objectAtIndex:i];
        NSNumber *nextCount = [self.data objectAtIndex:i+1];
        CGContextMoveToPoint(context, i*widthScaleFactor, height/2 - heightScaleFactor*([count integerValue]-mean));
        if(i == (self.data.count-2)) {
            [self addLabelInPosition:CGRectMake((i+1)*widthScaleFactor-10, height/2 - heightScaleFactor*([nextCount integerValue]-mean)-20, 20, 20) andRank:nextCount];
        }
        [self addLabelInPosition:CGRectMake(i*widthScaleFactor-10, height/2 - heightScaleFactor*([count integerValue]-mean)-20, 20, 20) andRank:count];
        CGContextAddLineToPoint(context, (i+1)*widthScaleFactor, height/2 - heightScaleFactor*([nextCount integerValue]-mean));
        CGContextStrokePath(context);
    }
}

/**
 *  Self explanatory utility method used to scale the graph
 *
 *  @return min data point as a long
 */
-(long)findMin
{
    long min = [(NSNumber *)[self.data firstObject] integerValue];
    for(int i = 0; i < self.data.count; i++) {
        if([(NSNumber *)[self.data objectAtIndex:i] integerValue] < min) min = [(NSNumber *)[self.data objectAtIndex:i] integerValue];
    }
    return min;
}

/**
 *  Self explanatory utility method used to scale the graph
 *
 *  @return max data point as a long
 */
-(long)findMax
{
    long max = [(NSNumber *)[self.data firstObject] integerValue];
    for(int i = 0; i < self.data.count; i++) {
        if([(NSNumber *)[self.data objectAtIndex:i] integerValue] > max) max = [(NSNumber *)[self.data objectAtIndex:i] integerValue];
    }
    return max;
}

/**
 *  Self explanatory utility method used to scale the graph
 *
 *  @return difference between min and max data point as a long
 */
-(long)findDifference
{
    return [self findMax] - [self findMin];
}

/**
 *  Utility method used to scale the graph by finding whether the absolute vale of min or the max is greater
 *
 *  @return "most extreme" data point as a long
 */
-(long) findMostExtremeCount
{
    long max = [self findMax];
    long min = [self findMin];
    return (fabs(min) > fabs(max)) ? fabs(min) : fabs(max);
}

/**
 *  Self explanatory utility method used to scale the graph
 *
 *  @return median as a float
 */
-(float)findMean
{
    float sum = 0;
    for(NSNumber *n in self.data)
    {
        sum += [n integerValue];
    }
    return sum/self.data.count;
}

/**
 *  Draws the labels for the graph that indicate the numerical value at each point
 *
 *  @param rect the graphing view's drawing space
 *  @param rank the rank (or vote) to be written in the label
 */
-(void)addLabelInPosition:(CGRect)rect andRank:(NSNumber*)rank
{
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.text = [NSString stringWithFormat:@"%ld", (long)[rank integerValue]];
    label.font = [UIFont fontWithName:@"DIN Alternate" size:17];
    label.textColor = [UIColor darkTextColor];
    [self addSubview:label];
}

@end