//
// Created by guti on 1/17/14.
//
// No bugs for you!
//


#import <Foundation/Foundation.h>



@interface DraggableGraphView : UIView
- (id)initWithFrame:(CGRect)frame andGraphType:(NSString *)graphType;
- (id)initWithFrame:(CGRect)frame andGraphType:(NSString *)graphType andData:(NSArray *)data;
@end