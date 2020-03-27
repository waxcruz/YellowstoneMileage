//
//  Mileage.m
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 5/19/16.
//  Copyright © 2016 Bill Weatherwax. All rights reserved.
//

#import "MileageViewController.h"
#import "Map.h"
#import "ModelMileage.h"
#import "AppDelegate.h"
#import "OverlayRoad.h"
#import "OverlayRoads.h"
#import "TouchNode.h"
#import "TouchNodes.h"
#import "RectF.h"
#import "UIImageView+GeometryConversion.h"
#import "Route.h"
#import "Routes.h"
#import "OverlayRoad.h"


enum routeDescriptors {FromLabel=0, FromValue, ToLabel, ToValue, ToInstructions, RouteLabel, SeasonalLabel, NewLine, MilesValue, ViaLabel, ViaValue};
enum textAttributes {Body=0,Italic, Bold};
enum textColor {Black, Gray};

@interface MileageViewController () <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) Map *map;
@property (nonatomic, strong) ModelMileage *model;
@property (nonatomic, strong) OverlayRoads *overlays;
@property (nonatomic, strong) TouchNodes *nodeSenseTouch;
@property (nonatomic, strong) Routes *routing;
@property (nonatomic, strong) NSArray *tapNodes;
@property (nonatomic, strong) NSDictionary *routes; // each object is a class of route. Key is start node|end node
@property (nonatomic, strong) NSMutableArray *originDestinationChoices;
@property (nonatomic, strong) NSMutableArray *viaChoices; // object is string name
@property (nonatomic, strong) NSMutableArray *routeSegments; // object is string where contents are a pair of nodes (n1|n2)
@property (nonatomic, getter=isAddingWaypoints) BOOL addingWaypoints;
@property (nonatomic,getter=isZoomedIn) bool zoomIn;
// view outlets
// @property (weak, nonatomic) IBOutlet UIImageView *processingMap;
@property (weak, nonatomic) IBOutlet UILabel *routeMiles;
@property (weak, nonatomic) IBOutlet UIScrollView *mapScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *mapUIImageView;
@property (weak, nonatomic) IBOutlet UITextView *routeDescription;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *busyMapBuilding;


@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *reverseButton;
@property (weak, nonatomic) IBOutlet UIButton *viaButton;

// attributed text controls
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *attributes;
@property (nonatomic, strong) NSArray *fields;
@property (nonatomic, getter=isSeasonal) BOOL seasonalRoute;

// gesture recognizers
@property (nonatomic, strong) UIPinchGestureRecognizer *pinch;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeft;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRight;

// via placeholder info
@property (nonatomic, strong) NSMutableArray *viaWaypoints;
@property (nonatomic) int viaSumDistance;
@property (nonatomic, strong)NSMutableString *viaRouteDescription;
// optimize map building
@property (nonatomic, strong) NSMutableSet *displayedOverlays; // prevent duplication of map of overlays
@property (nonatomic, strong) NSMutableArray *routeOverlayQueue; // each object is a route
@end


@implementation MileageViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
    self.zoomIn = NO;
    self.mapScrollView.delegate = self;
    [self.mapScrollView setMinimumZoomScale:1.0f];
    [self.mapScrollView setMaximumZoomScale:3.75f];
    [self setupForGestures];
    self.addingWaypoints = false;
    self.viaWaypoints = [[NSMutableArray alloc] init];
    self.viaSumDistance = 0;
    self.viaRouteDescription = [[NSMutableString alloc] init];
    self.model = [(AppDelegate *)[[UIApplication sharedApplication] delegate] model];
    NSString *parkMapFileName = [self.model getImageFileStringOfYellowstoneMap];
    UIImage *parkMapImage = [[UIImage alloc] initWithContentsOfFile: parkMapFileName];
    self.map = [[Map alloc] initMap:parkMapImage];
    self.mapUIImageView.image = parkMapImage;
    self.resetButton.hidden = true;
    self.reverseButton.hidden = true;
    self.viaButton.hidden = true;
    [self.mapUIImageView sizeToFit];
    self.displayedOverlays = [[NSMutableSet alloc] init];
    self.routeOverlayQueue = [[NSMutableArray alloc] init];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupRouteInfoFormatting];
    [self refreshView];
}
-(void) refreshView
{
    Route *route = nil;
    switch (self.originDestinationChoices.count) {
        case 0:
            [self showCleanMap];
            [self showHowToInstructions];
            self.reverseButton.hidden = true;
            self.resetButton.hidden = true;
            self.viaButton.hidden = true;
            break;
        case 1:
            [self showCleanMap];
            [self showHowtoInstructionsWithOrigin];
            self.resetButton.hidden = false;
            self.reverseButton.hidden = true;
            self.viaButton.hidden = true;
            break;
        case 2:
            if (self.isAddingWaypoints) {
                [self clearViaWorkingValues];
                [self.routeOverlayQueue removeAllObjects];
                NSString *startNode = [[NSString alloc] initWithString: self.originDestinationChoices[0]];
                [self.viaWaypoints addObject:startNode];
                if (self.viaChoices.count == 0) {
                    // edge case where via waypoint requested and then road hazards button touched. No via waypoints exist
                    route = [self buildRouteFromStart:self.originDestinationChoices[0] toEnd:self.originDestinationChoices[1]];
                    [self showCleanMap];
                    [self.routeOverlayQueue removeAllObjects];
                    [self.routeOverlayQueue addObject:route];
                    [self overlayMap:self.routeOverlayQueue];
                    [self showRoute:route withViaPrompt:true];
                } else {
                    NSString *endNode = @"";
                    [self showCleanMap];
                    for (int i = 0; i < self.viaChoices.count; i++){
                        if (i == 0) {
                            endNode = self.viaChoices[0];
                        } else {
                            startNode = endNode;
                            endNode = self.viaChoices[i];
                        }
                        [self.viaWaypoints addObject:endNode];
                        route = [self buildRouteFromStart:startNode toEnd:endNode];
                        [self.routeOverlayQueue addObject:route];
                        self.viaSumDistance += [route.distance intValue];
                        // [self overlayMap:route];
                        // cobble segments into one route description
                        NSMutableArray *tokens = [[NSMutableArray alloc] initWithArray:[route.route componentsSeparatedByString:@" --> "]];
                        [tokens removeLastObject];
                        for (NSString *token in tokens){
                            [self.viaRouteDescription appendString:token];
                            [self.viaRouteDescription appendString:@" --> "];
                        }
                    }
                    startNode = [self.viaChoices lastObject];
                    endNode = self.originDestinationChoices[1];
                    [self.viaWaypoints addObject:endNode];
                    route = [self buildRouteFromStart:startNode toEnd:endNode];
                    [self.routeOverlayQueue addObject:route];
                    self.viaSumDistance += [route.distance intValue];
                    [self overlayMap:self.routeOverlayQueue];
                    [self.viaRouteDescription appendString:route.route];
                    [self showViaRouteByWaypoints:self.viaWaypoints description:self.viaRouteDescription totalMiles:self.viaSumDistance withPrompt:false];
                    self.addingWaypoints = false;
                }
            } else {
                route = [self buildRouteFromStart:self.originDestinationChoices[0] toEnd:self.originDestinationChoices[1]];
                [self showCleanMap];
                [self.routeOverlayQueue removeAllObjects];
                [self.routeOverlayQueue addObject:route];
                [self overlayMap:self.routeOverlayQueue];
                [self showRoute:route withViaPrompt:false];
                self.reverseButton.hidden = false;
                self.resetButton.hidden = false;
                self.viaButton.hidden = false;
            }
            break;
        default:
            break;
    }
}


#pragma mark - construct view components
-(Route *) buildRouteFromStart: (NSString *) startNode toEnd: (NSString *) endNode
{
    if ([startNode isEqualToString:endNode]) {
        return [[Route alloc]
                     initRouteStartName:self.originDestinationChoices[0]
                     endName:self.originDestinationChoices[1]
                     distance:[[NSNumber alloc] initWithInt:0]
                     route:self.originDestinationChoices[0]
                     ];
    } else {
        NSString *key = [[NSString alloc] initWithFormat:@"%@%@%@",startNode, @"|", endNode];
        return self.routes[key];
    }
}

-(void) overlayMap:(NSMutableArray *) routesForOffBackgroundThread
{
    // find overlay (all overlay names are in alphabetical order)
    self.seasonalRoute = false; // assume roads are open
    NSMutableArray *routeOverlays = [[NSMutableArray alloc] init];
    for (Route *route in routesForOffBackgroundThread){
        for (NSString *overlayEdge in route.edges) {
            NSArray *wayPoints = [overlayEdge componentsSeparatedByString:@"|"];
            if (!self.isSeasonal) {
                self.seasonalRoute =  [self isRoadSeasonallyOpen:wayPoints];
            }
            if ([self.displayedOverlays containsObject:overlayEdge]){
                // skip processing
            } else {
                [routeOverlays addObject:[self makeOverlayImage:wayPoints]];
                [self.displayedOverlays addObject:overlayEdge];
            }
        }
    }
    if (routeOverlays.count > 0) {
        self.busyMapBuilding.hidden = false;
        [self.busyMapBuilding setUserInteractionEnabled:false];
        [self.busyMapBuilding startAnimating];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            // Perform async operation
            // Call your method/function here
            // Example:
            UIImage *overlaidMap = [self.map addRoutes:routeOverlays];
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.busyMapBuilding.hidden = true;
                [self.busyMapBuilding setUserInteractionEnabled:true];
                [self.busyMapBuilding stopAnimating];
                self.mapUIImageView.image = overlaidMap;
                [self.mapUIImageView sizeToFit];
                [self.mapScrollView sizeToFit];
            });
        });
    }
}

-(UIImage *) makeOverlayImage: (NSArray *) wayPoints
{
    OverlayRoad *overlayFileName = (wayPoints[0] < wayPoints[1]) ?
    [self.overlays edgeNode1:wayPoints[0] node2:wayPoints[1]] : [self.overlays edgeNode1:wayPoints[1] node2:wayPoints[0]];
    UIImage *overlay = [[UIImage alloc] initWithContentsOfFile: overlayFileName.edgeFileNameOfPNG];
    return overlay;
}
-(BOOL) isRoadSeasonallyOpen: (NSArray *) wayPoints
{
    OverlayRoad *road = (wayPoints[0] < wayPoints[1]) ?
    [self.overlays edgeNode1:wayPoints[0] node2:wayPoints[1]] : [self.overlays edgeNode1:wayPoints[1] node2:wayPoints[0]];
    return road.isEdgeSeasonalStartName;
}


-(void) showHowToInstructions
{
     // display information
    NSMutableAttributedString *info = [[NSMutableAttributedString alloc] init];
    [info appendAttributedString:self.fields[FromLabel]];
    [info appendAttributedString:self.fields[FromValue]];
    [info appendAttributedString:self.fields[NewLine]];
    [info appendAttributedString:self.fields[ToLabel]];
    [info appendAttributedString:self.fields[ToValue]];
    [info appendAttributedString:self.fields[NewLine]];
    self.routeDescription.attributedText = info;
    self.routeMiles.hidden = true;
}
-(void) showHowtoInstructionsWithOrigin
{
    // display information
    NSMutableAttributedString *info = [[NSMutableAttributedString alloc] init];
    [info appendAttributedString:self.fields[FromLabel]];
    [info appendAttributedString: [[NSAttributedString alloc] initWithString:self.originDestinationChoices[0] attributes:self.attributes[Body]]];
    [info appendAttributedString:self.fields[NewLine]];
    [info appendAttributedString:self.fields[ToLabel]];
    [info appendAttributedString:self.fields[ToInstructions]];
    [info appendAttributedString:self.fields[NewLine]];
    self.routeDescription.attributedText = info;
    self.routeMiles.hidden = true;

}
-(void) showRoute: (Route *) route withViaPrompt: (BOOL) prompt
{
    // display information

    NSMutableAttributedString *info = [[NSMutableAttributedString alloc] init];
    [info appendAttributedString:self.fields[FromLabel]];
    [info appendAttributedString: [[NSAttributedString alloc] initWithString:self.originDestinationChoices[0] attributes:self.attributes[Body]]];
    [info appendAttributedString:self.fields[NewLine]];
    if (prompt) {
        [info appendAttributedString:self.fields[ViaLabel]];
        [info appendAttributedString:self.fields[ViaValue]];
        [info appendAttributedString:self.fields[NewLine]];
    }
    [info appendAttributedString:self.fields[ToLabel]];
    [info appendAttributedString: [[NSAttributedString alloc] initWithString:self.originDestinationChoices[1] attributes:self.attributes[Body]]];
    [info appendAttributedString:self.fields[NewLine]];
    [info appendAttributedString:self.fields[RouteLabel]];
    if (self.isSeasonal) {
        [info appendAttributedString:self.fields[SeasonalLabel]];
    }
    [info appendAttributedString: [[NSAttributedString alloc] initWithString:route.route attributes:self.attributes[Body]]];
    self.routeDescription.attributedText = info;
    self.routeMiles.hidden = false;
    info = [[NSMutableAttributedString alloc] init];
    [info appendAttributedString:[[NSAttributedString alloc] initWithString:[route.distance stringValue] attributes:self.attributes[Bold]]];
    [info appendAttributedString:self.fields[MilesValue]];
    self.routeMiles.attributedText = info;
}

-(void) showViaRouteByWaypoints: (NSMutableArray *) waypoints description: (NSString *) routeDescription totalMiles:(int) miles withPrompt: (BOOL) prompt
{
    // display information with via waypoints
    
    NSMutableAttributedString *info = [[NSMutableAttributedString alloc] init];
    [info appendAttributedString:self.fields[FromLabel]];
    [info appendAttributedString: [[NSAttributedString alloc] initWithString:[waypoints firstObject] attributes:self.attributes[Body]]];
    [info appendAttributedString:self.fields[NewLine]];
    for (int i = 1; i < waypoints.count - 1; i++) {
        [info appendAttributedString:self.fields[ViaLabel]];
        [info appendAttributedString:[[NSAttributedString alloc] initWithString:waypoints[i] attributes:self.attributes[Body]]];
        [info appendAttributedString:self.fields[NewLine]];
    }
    if (prompt) {
        // add a via prompt
        [info appendAttributedString:self.fields[ViaLabel]];
        [info appendAttributedString:self.fields[ViaValue]];
        [info appendAttributedString:self.fields[NewLine]];
    }
    [info appendAttributedString:self.fields[ToLabel]];
    [info appendAttributedString: [[NSAttributedString alloc] initWithString:[waypoints lastObject] attributes:self.attributes[Body]]];
    [info appendAttributedString:self.fields[NewLine]];
    [info appendAttributedString:self.fields[RouteLabel]];
    if (self.isSeasonal) {
        [info appendAttributedString:self.fields[SeasonalLabel]];
    }
    [info appendAttributedString: [[NSAttributedString alloc] initWithString:routeDescription attributes:self.attributes[Body]]];
    self.routeDescription.attributedText = info;
    self.routeMiles.hidden = false;
    info = [[NSMutableAttributedString alloc] init];
    [info appendAttributedString:[[NSAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"%d",miles] attributes:self.attributes[Bold]]];
    [info appendAttributedString:self.fields[MilesValue]];
    self.routeMiles.attributedText = info;
}
#pragma mark - Setup attributed text controls
-(void)setupRouteInfoFormatting
{
    NSMutableArray *elements = [[NSMutableArray alloc] init];
    [elements addObject:[UIColor blackColor]];
    [elements addObject:[UIColor grayColor]];
    self.colors = [[NSArray alloc] initWithArray:elements];
    [elements removeAllObjects];
    // setup attributes for text
    
    NSDictionary *attrsForItalicText = @{
                                         NSForegroundColorAttributeName : self.colors[Gray],
                                         NSFontAttributeName : [UIFont italicSystemFontOfSize:16.0]
                                         
                                         };
    NSDictionary *attrsForBoldText = @{
                                       NSForegroundColorAttributeName : self.colors[Black],
                                       NSFontAttributeName : [UIFont boldSystemFontOfSize:16.0]
                                       
                                       };
    
    NSDictionary *attrsForText = @{
                                   NSForegroundColorAttributeName : self.colors[Black],
                                   NSFontAttributeName :  [UIFont systemFontOfSize:16.0]
                                   };
    [elements addObject:attrsForText];
    [elements addObject:attrsForItalicText];
    [elements addObject:attrsForBoldText];
    self.attributes = [[NSArray alloc] initWithArray:elements];
    [elements removeAllObjects];
    // build text
    [elements addObject:[[NSAttributedString alloc] initWithString:@"From: " attributes:self.attributes[Bold]]];
    [elements addObject:[[NSAttributedString alloc] initWithString:@"Touch Origination Square" attributes:self.attributes[Body]]];
    [elements addObject:[[NSAttributedString alloc] initWithString:@"To: " attributes:self.attributes[Bold]]];
    [elements addObject:[[NSAttributedString alloc] initWithString:@"Touch Destination Square" attributes:self.attributes[Italic]]];
    [elements addObject:[[NSAttributedString alloc] initWithString:@"Touch Destination Square" attributes:self.attributes[Body]]];
    [elements addObject:[[NSAttributedString alloc] initWithString:@"Route: " attributes:self.attributes[Bold]]];
     [elements addObject:[[NSAttributedString alloc] initWithString:@"(seasonal) " attributes:self.attributes[Bold]]];
    [elements addObject:[[NSAttributedString alloc] initWithString:@"\n" attributes:self.attributes[Body]]];
    [elements addObject:[[NSAttributedString alloc] initWithString:@" miles" attributes:self.attributes[Bold]]];
    [elements addObject:[[NSAttributedString alloc] initWithString:@"Via: " attributes:self.attributes[Bold]]];
    [elements addObject:[[NSAttributedString alloc] initWithString:@" Touch Waypoint Square" attributes:self.attributes[Body]]];
    self.fields = [[NSArray alloc] initWithArray:elements];
    [elements removeAllObjects];
}


#pragma mark -Delegates
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.mapUIImageView;
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
    [self.mapUIImageView addGestureRecognizer:self.doubleTap];
    [self.mapScrollView addGestureRecognizer:self.doubleTap];

    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.singleTap requireGestureRecognizerToFail : self.doubleTap];
    [self.singleTap setDelaysTouchesBegan : YES];
    [self.singleTap setNumberOfTapsRequired : 1];
    self.singleTap.cancelsTouchesInView = NO;
    [self.mapUIImageView addGestureRecognizer:self.singleTap];
    [self.mapScrollView addGestureRecognizer:self.singleTap];
    
    self.pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    self.pinch.delegate = self;
    [self.mapUIImageView addGestureRecognizer:self.pinch];
    [self.mapScrollView addGestureRecognizer:self.pinch];
    
    
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.pan setMaximumNumberOfTouches:1];
    self.pan.delegate = self;
    [self.mapUIImageView addGestureRecognizer:self.pan];
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
    CGPoint point = [gesture locationInView:self.mapUIImageView];
    CGPoint pointInImage = [self.mapUIImageView convertPointFromView:point];
    float x = pointInImage.x;
    float y = pointInImage.y;
    float scaledX = x / self.mapUIImageView.image.size.width;
    float scaledY = y / self.mapUIImageView.image.size.height;
    CGPoint touched = CGPointMake(scaledX, scaledY);
    for (int node = 0; node < [self.nodeSenseTouch count]; node++) {
        if ([((TouchNode *)self.tapNodes[node]).touchNode isTouchedAtPoint:touched]) {
            if (self.isAddingWaypoints) {
                if(![self.originDestinationChoices[1] isEqualToString:((TouchNode *)self.tapNodes[node]).nodeName]) {
                    [self.viaChoices addObject:((TouchNode *)self.tapNodes[node]).nodeName];
                }
                if (self.viaChoices.count == 5) {
                    self.viaButton.hidden = true;
                }
                [self refreshView];
                break;
            } else {
                [self pushChoice:((TouchNode *)self.tapNodes[node]).nodeName];
                [self refreshView];
                break;
            }
        }
    }
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
        //        self.mapUIImageView.frame = scrollView.frame;
        self.zoomIn = NO;
    } else {
        // NSLog(@"set scrollView to maximumZoomScale");
        CGPoint point = [gesture locationInView:scrollView];
        //        // NSLog(@"point %@",[YellowstoneSPOTRGraphics displayCGPoint:point]);
        scrollView.contentOffset = CGPointMake(point.x - scrollView.bounds.size.width/2, point.y - scrollView.bounds.size.height/2);
        //        self.mapUIImageView#import "UIImageView+GeometryConversion.h".frame = scrollView.frame;
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

#pragma mark - helper methods
-(void) pushChoice:(NSString *) choice
{
    switch (self.originDestinationChoices.count) {
        case 0:
            [self.originDestinationChoices addObject:choice];
            break;
        case 1:
            [self.originDestinationChoices addObject:choice];
            break;
        default:
            [self clearChoices];
            [self.originDestinationChoices addObject:choice];
            break;
    }
}

-(void) clearChoices
{
    [self.originDestinationChoices removeAllObjects];
    [self.viaChoices removeAllObjects];
}

-(void) showCleanMap
{
    self.mapUIImageView.image = [self.map resetMap];
    [self.displayedOverlays removeAllObjects];
    [self.mapUIImageView sizeToFit];
    [self.mapScrollView sizeToFit];
}
-(NSString *) formatRoute:(Route *) route
{
    return [NSString stringWithFormat:@"From: %@\nTo: %@\nRoute%@: %@",
            route.startNode,
            route.endNode,
            @"(seasonal)",
            route.route];
}

-(NSString *) formateReverseRoute:(Route *) route
{
    return [NSString stringWithFormat:@"From: %@\nTo: %@\nRoute%@: %@",
            route.startNode,
            route.endNode,
            @"(seasonal)",
            route.route];
}

-(void) clearViaWorkingValues
{
    [self.viaWaypoints removeAllObjects];
    self.viaSumDistance = 0;
    [self.viaRouteDescription setString:@""];
}

#pragma mark - actions
- (IBAction)resetRoutes:(id)sender {
    [self.originDestinationChoices removeAllObjects];
    [self.viaChoices removeAllObjects];
    self.addingWaypoints = false;
    self.resetButton.hidden = true;
    self.reverseButton.hidden = true;
    self.viaButton.hidden = true;
    [self clearViaWorkingValues];
    [self showCleanMap];
    [self  refreshView];
}

- (IBAction)reverseRoute:(id)sender {
    NSString *temp = @"";
    temp = self.originDestinationChoices[0];
    self.originDestinationChoices[0] = self.originDestinationChoices[1];
    self.originDestinationChoices[1] = temp;
    NSMutableArray *reverseViaWaypoints = [[NSMutableArray alloc] init];
    for (NSString *waypoint in [self.viaChoices reverseObjectEnumerator]) {
        [reverseViaWaypoints addObject:waypoint];
    }
    self.viaChoices = [[NSMutableArray alloc] initWithArray:reverseViaWaypoints];
    if (self.viaChoices.count > 0) {
        self.addingWaypoints = true;
    }
    [self refreshView];
}

- (IBAction)viaWaypoint:(id)sender {
    self.addingWaypoints = true;
    if (self.viaChoices.count > 0) {
        if (self.viaChoices.count == 5) {
            self.viaButton.hidden = true;
        }
        [self showViaRouteByWaypoints:self.viaWaypoints description:self.viaRouteDescription totalMiles:self.viaSumDistance withPrompt:true];
    } else {
        [self clearViaWorkingValues];
        // add a via choice to display
        Route * route = [self buildRouteFromStart:self.originDestinationChoices[0] toEnd:self.originDestinationChoices[1]];
        [self showRoute:route withViaPrompt:true];
    }
}


#pragma  mark - lazy instantiation
-(OverlayRoads *)overlays
{
    if (!_overlays) {
        _overlays = [self.model getEdges];
    }
    return _overlays;
}

-(TouchNodes *) nodeSenseTouch
{
    if (!_nodeSenseTouch) {
        _nodeSenseTouch = [self.model getTouchNodes];
    }
    return _nodeSenseTouch;
}

-(NSArray *) tapNodes
{
    if (!_tapNodes) {
        _tapNodes = [self.nodeSenseTouch allTouchNodes];
    }
    return _tapNodes;
}

-(Routes *) routing
{
    if (!_routing) {
        _routing = [self.model getRoutes];
    }
    return _routing;
}
-(NSDictionary *) routes
{
    if (!_routes) {
        _routes = [self.routing allRoutes];
    }
    return _routes;
}

-(NSMutableArray *) originDestinationChoices
{
    if (!_originDestinationChoices) {
        _originDestinationChoices = [[NSMutableArray alloc] init];
    }
    return _originDestinationChoices;
}

-(NSMutableArray *) viaChoices
{
    if (!_viaChoices) {
        _viaChoices = [[NSMutableArray alloc] init];
    }
    return _viaChoices;
}
@end
