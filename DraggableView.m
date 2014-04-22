//
//  DraggableView.m
//  HotOrNot
//
//  Created by Connor Barnett on 4/3/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//
#import "DraggableView.h"
#import "OverlayView.h"
#import "VotedCompanies.h"

@interface DraggableView ()
@property(strong, nonatomic) VotedCompanies *votedComapnies;
@property(strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property(nonatomic) CGPoint originalPoint;
@property(strong, nonatomic) OverlayView *overlayView;

@end

@implementation DraggableView

-(VotedCompanies *)votedComapnies
{
    if(!_votedComapnies) _votedComapnies = [[VotedCompanies alloc] init];
    return _votedComapnies;
}

- (id)initWithFrame:(CGRect)frame company:(NSString *)company andUrl:(NSString *) companyUrl
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    [self addGestureRecognizer:self.panGestureRecognizer];
    self.company = company;
    [self loadImageAndStyle:companyUrl];
    self.overlayView = [[OverlayView alloc] initWithFrame:self.bounds];
    self.overlayView.alpha = 0;
    [self addSubview:self.overlayView];
    return self;
}

- (void)loadImageAndStyle:(NSString *) companyUrl
{
    NSURL *imageURL = [NSURL URLWithString:companyUrl];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:imageData];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self addSubview:imageView];
        });
    });

    self.layer.cornerRadius = 8;
    self.layer.shadowOffset = CGSizeMake(7, 7);
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.5;
}

- (void)dragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGFloat xDistance = [gestureRecognizer translationInView:self].x;
    CGFloat yDistance = [gestureRecognizer translationInView:self].y;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = self.center;
            break;
        };
        case UIGestureRecognizerStateChanged:{
            CGFloat rotationStrength = MIN(xDistance / 320, 1);
            CGFloat rotationAngel = (CGFloat) (2*M_PI/16 * rotationStrength);
            CGFloat scaleStrength = 1 - fabsf(rotationStrength) / 4;
            CGFloat scale = MAX(scaleStrength, 0.93);
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            self.transform = scaleTransform;
            self.center = CGPointMake(self.originalPoint.x + xDistance, self.originalPoint.y + yDistance);
            
            [self updateOverlay:xDistance];
            
            break;
        };
        case UIGestureRecognizerStateEnded: {
            if (fabs(xDistance) > 100) {//case where vote has been issued
                NSString *voteType;
                NSLog(@"adding a vote");
                if(xDistance > 0) {
                    voteType = @"up_vote";
                } else {
                    voteType = @"down_vote";
                }
//                NSURL *URL = [NSURL URLWithString:@"http://ec2-54-224-194-212.compute-1.amazonaws.com:3000/vote"];
//                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
//                // Set request type
//                request.HTTPMethod = @"POST";
//                
                NSDictionary *dictionary =  @{ @"name" : self.company, @"vote_type" : voteType, @"vote_location" : @"Foo123" };
//
//                // Set params to be sent to the server
////                NSString *params = [NSString stringWithFormat:@"name=%@&vote_type=%@&vote_location=foo", self.company, voteType];
//                // Encoding type
                NSError *error = nil;
//                NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
//                // Add values and contenttype to the http header
//                [request addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
//                [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//                [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
//                [request setHTTPBody:data];
//                
//                // Send the request
//                [NSURLConnection connectionWithRequest:request delegate:self];
//                

                NSData *jsonInputData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
                NSString *jsonInputString = [[NSString alloc] initWithData:jsonInputData encoding:NSUTF8StringEncoding];
//
                
                
                NSURL *url = [NSURL URLWithString:@"http://ec2-54-224-194-212.compute-1.amazonaws.com:3000/vote.json"];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                [request setHTTPMethod:@"POST"];
                [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [request setValue:@"application/json" forHTTPHeaderField:@"accept"];
                [request setHTTPBody:[jsonInputString dataUsingEncoding:NSUTF8StringEncoding]];
                NSURLResponse *response;
                NSError *err;
                NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
                
            }
            else {
                [self resetViewPositionAndTransformations];
            }
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

- (void)updateOverlay:(CGFloat)distance
{
    if (distance > 0) {
        self.overlayView.mode = OverlayViewModeRight;
    } else if (distance <= 0) {
        self.overlayView.mode = OverlayViewModeLeft;
    }
    CGFloat overlayStrength = MIN(fabsf(distance) / 100, 0.4);
    self.overlayView.alpha = overlayStrength;
}

- (void)resetViewPositionAndTransformations
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.center = self.originalPoint;
                         self.transform = CGAffineTransformMakeRotation(0);
                         self.overlayView.alpha = 0;
                     }];
}

- (void)dealloc
{
    [self removeGestureRecognizer:self.panGestureRecognizer];
}


@end