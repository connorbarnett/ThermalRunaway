#import "GraphView.h"
#import "DraggableGraphView.h"


@interface GraphView ()
@property(nonatomic, strong) DraggableGraphView *draggableView;
@end

@implementation GraphView

- (id)init
{
    self = [super init];
    if (!self) return nil;

    self.backgroundColor = [UIColor whiteColor];

    [self loadDraggableCustomView];

    return self;
}

- (id)initWithGraphType:(NSString *)graphType
{
    self = [super init];
    if (!self) return nil;
    self.backgroundColor = [UIColor whiteColor];
    self.draggableView = [[DraggableGraphView alloc] initWithFrame:CGRectMake(0, 60, 320, 320) andGraphType:graphType];
    [self addSubview:self.draggableView];
    return self;
}

- (id)initWithGraphType:(NSString *)graphType andData:(NSArray *)data
{
    self = [super init];
    if (!self) return nil;
    self.backgroundColor = [UIColor whiteColor];
    self.draggableView = [[DraggableGraphView alloc] initWithFrame:CGRectMake(0, 60, 320, 320) andGraphType:graphType andData:data];
    [self addSubview:self.draggableView];
    return self;
}

- (void)loadDraggableCustomView
{
    self.draggableView = [[DraggableGraphView alloc] initWithFrame:CGRectMake(60, 60, 330, 330) andGraphType:@"rankings"];

    [self addSubview:self.draggableView];
}

@end