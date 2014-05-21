#import "DraggableGraphView.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@interface DraggableGraphView ()
@property(nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property(nonatomic) CGPoint originalPoint;
@property(strong, nonatomic) NSArray *data;
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


- (void)resetViewPositionAndTransformations
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.center = self.originalPoint;
                         self.transform = CGAffineTransformMakeRotation(0);
                     }];
}

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

- (void)dealloc
{
    [self removeGestureRecognizer:self.panGestureRecognizer];
}

- (void)drawRect:(CGRect)rect
{
    if([self.graphType isEqualToString:@"votes"]) {
        [self plotVoteGraph];
    } else {
        [self drawScaleForRankGraph];
        [self plotRankGraph];
    }
}


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


-(void)plotVoteGraph
{

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
    CGContextSetLineWidth(context, 4.0);
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    double widthScaleFactor = width/(self.data.count-1);
    double heightScaleFactor = height/([self findMostExtremeCount]*2);
    for(int i = 0; i < self.data.count-1; i++) {
        NSNumber *count = [self.data objectAtIndex:i];
        NSNumber *nextCount = [self.data objectAtIndex:i+1];
        CGContextMoveToPoint(context, i*widthScaleFactor, height/2 - [count integerValue]*heightScaleFactor);
        if(i == (self.data.count-2)) {
            [self addLabelInPosition:CGRectMake((i+1)*widthScaleFactor-10, height/2 - [nextCount integerValue]*heightScaleFactor-20, 20, 20) andRank:nextCount];
        }
        [self addLabelInPosition:CGRectMake(i*widthScaleFactor-10, height/2 - [count integerValue]*heightScaleFactor-20, 20, 20) andRank:count];
        CGContextAddLineToPoint(context, (i+1)*widthScaleFactor, height/2 - [nextCount integerValue]*heightScaleFactor);
        CGContextStrokePath(context);
    }
}

-(long)findMin
{
    long min = [(NSNumber *)[self.data firstObject] integerValue];
    for(int i = 0; i < self.data.count; i++) {
        if([(NSNumber *)[self.data objectAtIndex:i] integerValue] < min) min = [(NSNumber *)[self.data objectAtIndex:i] integerValue];
    }
    return min;
}

-(long)findMax
{
    long max = [(NSNumber *)[self.data firstObject] integerValue];
    for(int i = 0; i < self.data.count; i++) {
        if([(NSNumber *)[self.data objectAtIndex:i] integerValue] > max) max = [(NSNumber *)[self.data objectAtIndex:i] integerValue];
    }
    return max;
}

-(long)findDifference
{
    return [self findMax] - [self findMin];
}

-(long) findMostExtremeCount
{
    long max = [self findMax];
    long min = [self findMin];
    return (fabs(min) > fabs(max)) ? fabs(min) : fabs(max);
}

-(void)addLabelInPosition:(CGRect)rect andRank:(NSNumber*)rank
{
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.text = [NSString stringWithFormat:@"%ld", (long)[rank integerValue]];
    label.font = [UIFont fontWithName:@"DIN Alternate" size:17];
    label.textColor = [UIColor darkTextColor];
    [self addSubview:label];
}

@end