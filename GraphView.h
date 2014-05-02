//
// Created by guti on 1/17/14.
//
// No bugs for you!
//


#import <Foundation/Foundation.h>

@class DraggableGraphView;


@interface GraphView : UIView
- (id)initWithGraphType:(NSString *)graphType;
- (id)initWithGraphType:(NSString *)graphType andData:(NSArray *)data;

@end