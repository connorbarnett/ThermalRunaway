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
int max;
int min;
int difference;


- (id)initWithFrame:(CGRect)frame andVotesArray:(NSArray *)votesArray
{
    self = [super initWithFrame:frame];
    if (self) {
        self.votes = [[NSArray alloc] initWithArray:votesArray];
        [self setBackgroundColor:[UIColor lightGrayColor]];
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
    [self findMin];
    [self findMax];
    difference = max - min;
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

-(void) findMax
{
    NSNumber *tempMax = (NSNumber *)[self.votes firstObject];
    for (int i = 0; i < self.votes.count; i++) {
        if((NSNumber *)[self.votes objectAtIndex:i] > tempMax) tempMax = (NSNumber *)[self.votes objectAtIndex:i];
    }
    max = [tempMax integerValue];
    
}

-(void) findMin
{
    NSNumber *tempMin = (NSNumber *)[self.votes firstObject];
    for (int i = 0; i < self.votes.count; i++) {
        if((NSNumber *)[self.votes objectAtIndex:i] < tempMin) tempMin = (NSNumber *)[self.votes objectAtIndex:i];
    }
    min = [tempMin integerValue];
}


-(void)plotGraph
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 4.0);
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    double widthScaleFactor = width/(self.votes.count-1);
    double heightScaleFactor = height/difference;
    for(int i = 0; i < self.votes.count-1; i++) {
        NSNumber *rank = [self.votes objectAtIndex:i];
        NSNumber *nextRank = [self.votes objectAtIndex:i+1];
        CGContextMoveToPoint(context, i*widthScaleFactor, [rank integerValue]*heightScaleFactor); //start at this point
        CGContextAddLineToPoint(context, (i+1)*widthScaleFactor, [nextRank integerValue]*heightScaleFactor); //draw to this point
        CGContextStrokePath(context);
    }
}



@end
