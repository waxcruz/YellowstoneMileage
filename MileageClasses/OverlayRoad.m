//
//  Edge.m
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/12/18.
//  Copyright © 2018 Bill Weatherwax. All rights reserved.
//

#import "OverlayRoad.h"
@interface OverlayRoad()
@property(nonatomic, strong) NSString *startNode;
@property(nonatomic, strong) NSString *endNode;
@property(nonatomic, strong) NSString *fileNameOfPNG;
@property(nonatomic, strong) NSNumber *seasonalRoute;
@property(nonatomic, strong) NSString *edgeKey;
@end



@implementation OverlayRoad
-(instancetype) initEdgeStartName: (NSString *) startNode
                          endName: (NSString *) endNode
                          edgePNG: (NSString *) png
                         seasonal: (BOOL) seasonalRoute
{
    [self superclass];
    _startNode = startNode;
    _endNode = endNode;
    _fileNameOfPNG = png;
    _seasonalRoute = [NSNumber numberWithBool:seasonalRoute];
    _edgeKey = [self createEdgeKeyfromNodes:startNode toNode:endNode];  // data input should always be in ascending order. node1 < node2
    return self;
}

-(NSString *)createEdgeKeyfromNodes:(NSString *) node1 toNode: (NSString *) node2
{
    if ([node1 compare:node2] == NSOrderedAscending) {
        return [[NSString alloc] initWithFormat:@"%@|%@", node1, node2];
    } else {
        return [[NSString alloc] initWithFormat:@"%@|%@", node2, node1];
    }

    
}
-(NSString *)edgeFileNameOfPNG
{
    return self.fileNameOfPNG;
}

-(NSString *) edgeDictionaryKey
{
    return self.edgeKey;
}
-(BOOL)isEdgeSeasonalStartName
{
    return [_seasonalRoute boolValue];
}
-(NSString *)toString
{
 return [NSString stringWithFormat:@"%@%@%@%@%@%@@%%@%@",
     @"Edge: ",
     self.startNode,
     @" --- ",
     self.endNode,
     @" shows overlay file: ",
     self.fileNameOfPNG,
     self.seasonalRoute ? @"which is seasonal" : @"which is always open"
     ];
}
@end
