//
//  DraggableView.m
//  HotOrNot
//
//  Created by Connor Barnett on 4/3/14.
//  Copyright (c) 2014 Cbo Games. All rights reserved.
//
#import "DraggableView.h"
#import "OverlayView.h"
#import "HoNManager.h"
#import "GAi.h"
#import "GAIDictionaryBuilder.h"

@interface DraggableView ()
/**
 *  Gesture recognizer for dragging
 */
@property(strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

/**
 *  Original point for the frame so that we can move it back if it is moved but a vote is not casted
 */
@property(nonatomic) CGPoint originalPoint;

/**
 *  The overlay that displays either the thumbs up or thumbs down as the view is being dragged
 */
@property(strong, nonatomic) OverlayView *overlayView;

/**
 *  Singleton used for networking calls to get the company image and cast the vote
 */
@property(strong, nonatomic) HoNManager *myHonManager;

/**
 *  Boolean saying whether the overlay view is being used in the tutorial or on the main votes page
 *  Info needed to determine whether the actual vote should be cast.
 */

@end

@implementation DraggableView
static BOOL isTutorial;
static NSString * const ImgsURLString = @"http://www.stanford.edu/~robdun11/cgi-bin/thermalrunaway/images/logos/";

-(HoNManager *)myHonManager
{
    if(!_myHonManager) _myHonManager = [HoNManager sharedHoNManager];
    return _myHonManager;
}

- (id)initWithFrame:(CGRect)frame company:(NSString *)company
{
    isTutorial = NO;
    self = [super initWithFrame:frame];
    
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:@"cardLoad"
                                            action:[NSString stringWithFormat:@"loading card For %@", self.company]
                                             label:[NSString stringWithFormat:@"loading card For %@", self.company]
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
    
    if (!self) return nil;
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    [self addGestureRecognizer:self.panGestureRecognizer];
    self.company = company;
    [self loadImageAndStyle];
    return self;
}

- (id)initNetworkFreeWithFrame:(CGRect)frame company:(NSString *)company{
    isTutorial = YES;
    self = [super initWithFrame:frame];

    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    [self addGestureRecognizer:self.panGestureRecognizer];
    self.company = company;
    UIImage *image = [UIImage imageNamed:company];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imageView];
    self.overlayView = [[OverlayView alloc] initWithFrame:self.bounds];
    self.overlayView.alpha = 0;
    [self addSubview:self.overlayView];
    return self;

}

/**
 *  Makes a networking call to get the image data for the company logo, then sets the view to have the company's logo
 */
- (void)loadImageAndStyle
{
    if(![[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@image",self.company]]){
        NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.png",ImgsURLString, self.company]];
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:imageData];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                [self addSubview:imageView];
                self.overlayView = [[OverlayView alloc] initWithFrame:self.bounds];
                self.overlayView.alpha = 0;
                [self addSubview:self.overlayView];
            });
            [[NSUserDefaults standardUserDefaults] setObject:imageData forKey:[NSString stringWithFormat:@"%@image",self.company]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        });
    }
    else{
        NSData *imageData = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%@image",self.company]];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:imageData];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self addSubview:imageView];
            self.overlayView = [[OverlayView alloc] initWithFrame:self.bounds];
            self.overlayView.alpha = 0;
            [self addSubview:self.overlayView];
        });
    }
    
    self.layer.cornerRadius = 8;
    self.layer.shadowOffset = CGSizeMake(7, 7);
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.5;
}

/**
 *  Determines whether the view has been swiped beyond two thresholds-
 *  1) The view can be swiped sufficiently far to the left, casting a down vote
 *  2) The view can be swiped sufficeintly far to the right, casting an up vote
 *
 *  If either of these events occur, a vote is recorded and a new company card (if available) replaces the old one
 *  If not, the view snaps back into place.  Either way, Google Analytics monitors the interaction.
 *
 *  @param gestureRecognizer
 */
- (void)dragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGFloat xDistance = [gestureRecognizer translationInView:self].x;
    
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
            self.center = CGPointMake(self.originalPoint.x + xDistance, self.originalPoint.y);
            [self updateOverlay:xDistance];
            break;
        };
        case UIGestureRecognizerStateEnded: {
            NSLog(@"%i", isTutorial);
            if (fabs(xDistance) > 100) {//case where vote has been issued
                NSString *voteType;
                if(xDistance > 0) {
                    voteType = @"up_vote";
                } else {
                    voteType = @"down_vote";
                }
                NSDictionary *voteDetails = @{@"company": self.company, @"voteType":voteType};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"votedOnCompany" object:voteDetails];
                if(!isTutorial){
                    [self.myHonManager castVote:voteType forCompany:self.company];
                    [self.myHonManager removeTopCompanyFromDeck];
                    if([self.myHonManager deckEmpty])
                        [self.myHonManager loadNextDeck];
                }
                [self removeFromSuperview];
                
            }
            else {
                if(xDistance > 0){
                    NSDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"returnedDrag"
                                                            action:[NSString stringWithFormat:@"dragRightNoVoteFor%@", self.company]
                                                             label:[NSString stringWithFormat:@"dragRightNoVoteFor%@", self.company]
                                                             value:nil] build];
                    [[GAI sharedInstance].defaultTracker send:event];
                    [[GAI sharedInstance] dispatch];
                }
                if(xDistance < 0){
                    NSDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"returnedDrag"
                                                            action:[NSString stringWithFormat:@"dragLeftNoVoteFor%@", self.company]
                                                             label:[NSString stringWithFormat:@"dragLeftNoVoteFor%@", self.company]
                                                             value:nil] build];
                    [[GAI sharedInstance].defaultTracker send:event];
                    [[GAI sharedInstance] dispatch];
                }
                [self resetViewPositionAndTransformations];
            }
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

/**
 *  Updates the overlay to have the approrpiate thumb (either up or down) based on the location of the card
 *
 *  @param distance how far the card has been dragged
 */
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

/**
 *  When the card is touched but a vote is not casted, we place the card back in the middle
 */
- (void)resetViewPositionAndTransformations
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.center = self.originalPoint;
                         self.transform = CGAffineTransformMakeRotation(0);
                         self.overlayView.alpha = 0;
                     }];
}

/**
 *  Deallocates the view
 */
- (void)dealloc
{
    [self removeGestureRecognizer:self.panGestureRecognizer];
}


@end