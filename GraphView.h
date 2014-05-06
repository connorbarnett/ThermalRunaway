//
//


#import <Foundation/Foundation.h>

@class DraggableGraphView;


@interface GraphView : UIView
- (id)initWithGraphType:(NSString *)graphType;
- (id)initWithGraphType:(NSString *)graphType andData:(NSArray *)data;

@end