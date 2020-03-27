//
//  RoadClosureViewController.m
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/12/18.
//  Copyright © 2018 Bill Weatherwax. All rights reserved.
//

#import "RoadClosureViewController.h"
#import "AppDelegate.h"
#import "ModelMileage.h"
#import "UIImageView+GeometryConversion.h"
#import "Strings.h"

@interface RoadClosureViewController () <UIGestureRecognizerDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) ModelMileage *model;
@property (nonatomic,getter=isZoomedIn) bool zoomIn;
@property (nonatomic, strong) Strings *literals;
@property (strong, nonatomic) IBOutlet UIView *masterView;
@property (weak, nonatomic) IBOutlet UITextView *instructions;
@property (weak, nonatomic) IBOutlet UIScrollView *mapScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;
@property (nonatomic, strong)     NSDictionary *attrsForText;
// gesture recognizers
@property (nonatomic, strong) UIPinchGestureRecognizer *pinch;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeft;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRight;
@end

@implementation RoadClosureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.zoomIn = NO;
    self.mapScrollView.delegate = self;
    [self.mapScrollView setMinimumZoomScale:1.0f];
    [self.mapScrollView setMaximumZoomScale:3.75f];
    [self setupForGestures];
    self.model = [(AppDelegate *)[[UIApplication sharedApplication] delegate] model];
    self.literals = [self.model getLiterals];
    [self refreshView: self.masterView.frame.size];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.attrsForText = @{
                          NSForegroundColorAttributeName : [UIColor blackColor],
                          NSFontAttributeName : [UIFont systemFontOfSize:11.0]
                          };
    [self refreshView: self.masterView.frame.size];
}

-(void) refreshView: (CGSize) size
{
    
    if (self.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPhone){
         if (size.width > size.height) {
            self.instructions.attributedText = [[NSAttributedString alloc]
                                                initWithString:[self.literals stringValueForName:@"intro_paragraph_right"]
                                                attributes:self.attrsForText];
         } else {
            self.instructions.attributedText = [[NSAttributedString alloc]
                                                initWithString:[self.literals stringValueForName:@"intro_paragraph_top"] attributes:self.attrsForText];
            ;
        }
    } else {
        self.instructions.attributedText = [[NSAttributedString alloc]
                                            initWithString:[self.literals stringValueForName:@"intro_paragraph_top"] attributes:self.attrsForText];
        ;
    }
 }
-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self refreshView:size];
}
#pragma mark -Delegates
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.mapImageView;
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.instructions scrollRangeToVisible:NSMakeRange(0, 0)];
}
#pragma mark - gestures
-(void) setupForGestures
{
    //    self.swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeHandler)];
    //    self.swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    //    [self.mapScrollView addGestureRecognizer:self.swipeLeft];
    //
    //    self.swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeHandler)];
    //    self.swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    //    [self.mapScrollView addGestureRecognizer:self.swipeRight];
    //
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTap:)];
    [self.doubleTap setDelaysTouchesBegan : YES];
    [self.doubleTap setNumberOfTapsRequired : 2];
    self.doubleTap.cancelsTouchesInView = NO;
    [self.mapImageView addGestureRecognizer:self.doubleTap];
    [self.mapScrollView addGestureRecognizer:self.doubleTap];
    
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.singleTap requireGestureRecognizerToFail : self.doubleTap];
    [self.singleTap setDelaysTouchesBegan : YES];
    [self.singleTap setNumberOfTapsRequired : 1];
    self.singleTap.cancelsTouchesInView = NO;
    [self.mapImageView addGestureRecognizer:self.singleTap];
    [self.mapScrollView addGestureRecognizer:self.singleTap];
    
    self.pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    self.pinch.delegate = self;
    [self.mapImageView addGestureRecognizer:self.pinch];
    [self.mapScrollView addGestureRecognizer:self.pinch];
    
    
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.pan setMaximumNumberOfTouches:1];
    self.pan.delegate = self;
    [self.mapImageView addGestureRecognizer:self.pan];
    [self.mapScrollView addGestureRecognizer:self.pan];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
    
}



- (void)tap:(UITapGestureRecognizer *)gesture
{
    // NSLog(@"tap");
    // [self traceViews:@"before check of touch points"];
//    CGPoint point = [gesture locationInView:self.mapImageView];
//    CGPoint pointInImage = [self.mapImageView convertPointFromView:point];
//    float x = pointInImage.x;
//    float y = pointInImage.y;
//    float scaledX = x / self.mapImageView.image.size.width;
//    float scaledY = y / self.mapImageView.image.size.height;
    // [self traceViews:@"tap after check of touch points"];
}

-(void)pinch:(UIPinchGestureRecognizer *)gesture
{
    
    if ([(UIScrollView *)[gesture view] zoomScale] > [(UIScrollView *)[gesture view] minimumZoomScale]) {
        self.zoomIn = YES;
    } else {
        self.zoomIn = NO;
    }
    
}
-(void)pan:(UIPanGestureRecognizer *)gesture
{
    if ([(UIScrollView *)[gesture view] zoomScale] > [(UIScrollView *)[gesture view] minimumZoomScale]) {
        self.zoomIn = YES;
    } else {
        self.zoomIn = NO;
    }
}

-(void)tapTap:(UITapGestureRecognizer *)gesture
{
    // [self traceViews:@"tapTap begin"];
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    if ([gesture.view isKindOfClass:[UIScrollView class]] ) {
        scrollView = (UIScrollView *) gesture.view;
    }
    // NSLog(@"zoom scale in self.scrollView: %f",scrollView.zoomScale);
    if (self.isZoomedIn) {
        // NSLog(@"set scrollView to minimumZoomScale");
        scrollView.contentOffset = CGPointZero;
        [scrollView setZoomScale:scrollView.minimumZoomScale];
        //        self.mapImageView.frame = scrollView.frame;
        self.zoomIn = NO;
    } else {
        // NSLog(@"set scrollView to maximumZoomScale");
        CGPoint point = [gesture locationInView:scrollView];
        //        // NSLog(@"point %@",[YellowstoneSPOTRGraphics displayCGPoint:point]);
        scrollView.contentOffset = CGPointMake(point.x - scrollView.bounds.size.width/2, point.y - scrollView.bounds.size.height/2);
        //        self.mapImageView#import "UIImageView+GeometryConversion.h".frame = scrollView.frame;
        [scrollView setZoomScale:scrollView.maximumZoomScale];
        self.zoomIn = YES;
    }
    // [self traceViews:@"tapTap end"];
}

-(void)longPress:(UILongPressGestureRecognizer *) gesture
{
    
}

-(void)rightSwipeHandler
{
    //    if (self.mapSegments.selectedSegmentIndex == 0) {
    //        [self.mapSegments setSelectedSegmentIndex:self.mapSegments.numberOfSegments-1];
    //    } else {
    //        [self.mapSegments setSelectedSegmentIndex:self.mapSegments.selectedSegmentIndex-1];
    //    }
    //    [self swipeChangesMap];
}

-(void)leftSwipeHandler
{
    //    if (self.mapSegments.selectedSegmentIndex == self.mapSegments.numberOfSegments-1) {
    //        [self.mapSegments setSelectedSegmentIndex:0];
    //    } else {
    //        [self.mapSegments setSelectedSegmentIndex:self.mapSegments.selectedSegmentIndex + 1];
    //    }
    //    [self swipeChangesMap];
}

-(void)swipeChangesMap
{
    //    self.viewingMapNumber = [NSNumber numberWithInt:(int)self.mapSegments.selectedSegmentIndex + 1];  // use external number of map (starts at 1 not 0)
    //    [self newMapSelected:self.viewingMapNumber
    //                  inArea:self.viewingMapsInArea
    //             atPulloutID:[self selectPulloutID]];
}

- (IBAction)close:(id)sender {
    [self exitRoadClosures];
}

-(void) exitRoadClosures
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
