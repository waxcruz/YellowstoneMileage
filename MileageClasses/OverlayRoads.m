//
//  Edges.m
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 12/16/16.
//  Copyright © 2016 ccspotr. All rights reserved.
//

#import "OverlayRoads.h"
#import "GlobalConstantsAndTypesDefinitions.h"
#import "HelperDataFiles.h"
#import "OverlayRoad.h"


@interface OverlayRoads()
@property (nonatomic, strong) NSDictionary *edges;
@property (nonatomic, strong) HelperDataFiles *helperDataFiles;

@end
@implementation OverlayRoads

-(instancetype) init
{
    self = [super init];
    if (self) {
        _edges = [[NSDictionary alloc] initWithDictionary:[self loadPNGs]];
    }
    return self;
}

-(HelperDataFiles *) helperDataFiles
{
    if (!_helperDataFiles) {
        _helperDataFiles = [[HelperDataFiles alloc] init];
    }
    return _helperDataFiles;
}

-(NSDictionary *)loadPNGs
{
    NSMutableDictionary *edgeData = [[NSMutableDictionary alloc] init];
    // route_overlay_pngs.txt line layout:
    //   col 0 = from node name
    //   col 1 = to node name
    //   col 2 = PNG name
    //   col 3 = seasonal flag
    
    // read edge data
    NSString * pngData = [self.helperDataFiles textFileData: PNG_DATA_FILENAME ofType: @"txt"];
    // trim end of file (\r\n) from asset data
    pngData = [self.helperDataFiles trimEOF:pngData];
    // build png array
    OverlayRoad *edge;
    for (NSString *edgeLine in [pngData componentsSeparatedByString:@"\r\n"]){
        NSArray *parts = [edgeLine componentsSeparatedByString:@"\t"];
        edge = [[OverlayRoad alloc] initEdgeStartName:parts[0] endName:parts[1] edgePNG:[self.helperDataFiles filePath:parts[2] ofType:@".png"] seasonal:([parts[3] isEqualToString:@"seasonal"] ? true : false)];
        edgeData[edge.edgeDictionaryKey] = edge;
        [edgeData setObject:edge forKey:edge.edgeDictionaryKey];
    }
    return edgeData;
}
-(OverlayRoad *) edgeNode1: (NSString *) startNode node2:(NSString *) endNode
{
    NSString *key = @"";
    if ([startNode compare:endNode] == NSOrderedAscending) {
        key = [NSString stringWithFormat:@"%@%@%@",startNode,@"|",endNode];
    } else {
        key = [NSString stringWithFormat:@"%@%@%@",endNode,@"|",startNode];
    }
    return self.edges[key];
}

-(NSString *) toString
{
    return [NSString stringWithFormat:@"%@%lu%@",
            @"Edges contains ",
            (unsigned long)self.edges.count,
            @" edges"];
}

@end
