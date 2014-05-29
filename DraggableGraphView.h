//
//
//


#import <Foundation/Foundation.h>



@interface DraggableGraphView : UIView

/**
 *  Creates a graph view to display voting data that can be dragged
 *
 *  @param frame     size and location of the desired graph
 *  @param graphType can be either a vote graph (displays vote count) or rankings graph (displays the company's rankings)
 *  @param data      an array of points to be plotted
 *
 *  @return draggableGraphView
 */
- (id)initWithFrame:(CGRect)frame andGraphType:(NSString *)graphType andData:(NSArray *)data;
@end