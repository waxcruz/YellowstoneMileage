//
//  Routes.m
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/23/17.
//  Copyright © 2017 Bill Weatherwax. All rights reserved.
//

#import "Route.h"

@interface Route()
@property (nonatomic, strong, readwrite) NSString * startNode;
@property (nonatomic, strong, readwrite) NSString * endNode;
@property (nonatomic, strong, readwrite) NSNumber *distance;
@property (nonatomic, strong, readwrite) NSString *route;
@property (nonatomic, strong, readwrite) NSArray *edges;

@end
@implementation Route
-(instancetype) initRouteStartName: (NSString *) startNode
                           endName: (NSString *) endNode
                          distance: (NSNumber *) distance
                             route: (NSString *) route
{
    self = [super init];
    if (self) {
        _startNode = startNode;
        _endNode = endNode;
        _distance = distance;
        _route = route;
        _edges = [self buildEdges];
    }
    return self;
}

-(NSArray *) buildEdges  // parse route into edges
{
    NSMutableArray *edge = [[NSMutableArray alloc] init];
    NSArray *waypoints = [self.route componentsSeparatedByString:@" --> "];
    for (int i = 0; i < waypoints.count - 1; i ++){
        // pair waypoints into an edge
        [edge addObject:[NSString stringWithFormat:@"%@|%@",waypoints[i], waypoints[i+1]]];
    }
    return edge;
    
}

-(NSString *)toString
{
    return [NSString stringWithFormat:@"%@-%@ %d %@",
            self.startNode,
            self.endNode,
            [self.distance intValue],
            self.route];
}


@end
