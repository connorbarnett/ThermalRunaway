//
//  CompanyGraph.m
//  Thermal
//
//  Created by Connor Barnett on 4/27/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//

#import "CompanyGraph.h"

@implementation CompanyGraph

#define MAX_RANKING 100

- (id)initWithFrame:(CGRect)frame andVotesArray:(NSArray *)votesArray
{
    self = [super initWithFrame:frame];
    if (self) {
        self.votes = [[NSArray alloc] initWithArray:votesArray];
        [self setBackgroundColor:[UIColor grayColor]];
        // Initialization code
    }
    return self;
}



- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self drawScale];
    [self plotGraph];
}

- (void)drawScale
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

-(void)plotGraph
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextSetLineWidth(context, 4.0);
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    double widthScaleFactor = width/(self.votes.count-1);
    double heightScaleFactor = height/MAX_RANKING;
    for(int i = 0; i < self.votes.count-1; i++) {
        NSNumber *rank = [self.votes objectAtIndex:i];
        NSNumber *nextRank = [self.votes objectAtIndex:i+1];
        CGContextMoveToPoint(context, i*widthScaleFactor, [rank integerValue]*heightScaleFactor); //start at this point
        CGContextAddLineToPoint(context, (i+1)*widthScaleFactor, [nextRank integerValue]*heightScaleFactor); //draw to this point
        CGContextStrokePath(context);
    }
}



@end