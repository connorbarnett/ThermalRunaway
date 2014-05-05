#import "DraggableGraphView.h"

@interface DraggableGraphView ()
@property(nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property(nonatomic) CGPoint originalPoint;
@property(strong, nonatomic) NSArray *data;
@property(strong, nonatomic) NSString *graphType;
@end

@implementation DraggableGraphView

- (id)initWithFrame:(CGRect)frame andGraphType:(NSString *)graphType
{
    self = [super initWithFrame:frame];
    CGPoint original = CGPointMake(160, 320);
    CGFloat startingX = -400;
    if ([graphType isEqualToString:@"votes"]) {
        startingX = -(startingX);
    }
    self.frame = CGRectMake(startingX, 160, self.frame.size.width, self.frame.size.height);
    if (!self) return nil;
    self.graphType = [[NSString alloc] initWithString:graphType];
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    [self addGestureRecognizer:self.panGestureRecognizer];
    [self setBackgroundColor:[UIColor lightGrayColor]];
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.center = original;
                         self.transform = CGAffineTransformMakeRotation(0);
                     }
     ];
    return self;
}

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

-(NSArray *)data
{
    if(!_data) _data = [[NSArray alloc] initWithObjects:@50, @60, @40, @70, @10, @20, @5, nil];
    return _data;
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
                [self slowlyRemoveView:xDistance];
            } else {
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
    [super drawRect:rect];
    if([self.graphType isEqualToString:@"votes"]) {
        [self drawScaleForVoteGraph];
        [self plotVoteGraph];
    } else {
        [self drawScaleForRankGraph];
        [self plotGraphRankGraph];
    }
}


- (void)drawScaleForRankGraph
{
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    double heightScaleFactor = height/10;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    for(int i = 0; i < 10; i++) {
        int currentHeight = (i+1)*heightScaleFactor;
        CGContextMoveToPoint(context, 0, currentHeight); //start at this point
        CGContextAddLineToPoint(context, width, currentHeight); //draw to this point
    }
    CGContextStrokePath(context);
    
}

-(void)plotGraphRankGraph
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextSetLineWidth(context, 4.0);
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    double widthScaleFactor = width/(self.data.count-1);
    double heightScaleFactor = height/100;
    for(int i = 0; i < self.data.count-1; i++) {
        NSNumber *rank = [self.data objectAtIndex:i];
        NSNumber *nextRank = [self.data objectAtIndex:i+1];
        CGContextMoveToPoint(context, i*widthScaleFactor, [rank integerValue]*heightScaleFactor); //start at this point
        CGContextAddLineToPoint(context, (i+1)*widthScaleFactor, [nextRank integerValue]*heightScaleFactor); //draw to this point
        CGContextStrokePath(context);
    }
}

- (void)drawScaleForVoteGraph
{
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    double heightScaleFactor = height/10;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    for(int i = 0; i < 10; i++) {
        int currentHeight = (i+1)*heightScaleFactor;
        CGContextMoveToPoint(context, 0, currentHeight); //start at this point
        CGContextAddLineToPoint(context, width, currentHeight); //draw to this point
    }
    CGContextStrokePath(context);
    
}

-(void)plotVoteGraph
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
    CGContextSetLineWidth(context, 4.0);
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    double widthScaleFactor = width/(self.data.count-1);
    double heightScaleFactor = height/100;
    for(int i = 0; i < self.data.count-1; i++) {
        NSNumber *rank = [self.data objectAtIndex:i];
        NSNumber *nextRank = [self.data objectAtIndex:i+1];
        CGContextMoveToPoint(context, i*widthScaleFactor, [rank integerValue]*heightScaleFactor); //start at this point
        CGContextAddLineToPoint(context, (i+1)*widthScaleFactor, [nextRank integerValue]*heightScaleFactor); //draw to this point
        CGContextStrokePath(context);
    }
}




@end