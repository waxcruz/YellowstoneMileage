//
//  Routes.m
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/23/17.
//  Copyright © 2017 Bill Weatherwax. All rights reserved.
//

#import "Routes.h"
#import "Route.h"
#import "HelperDataFiles.h"
#import "GlobalConstantsAndTypesDefinitions.h"

@interface Routes()
@property (nonatomic, strong) NSDictionary *routes; // all route objects
@property (nonatomic, strong) HelperDataFiles *helperDataFiles;


@end
@implementation Routes
-(instancetype) init
{
    self = [super init];
    if (self) {
        _routes = [[NSDictionary alloc] initWithDictionary:[self loadRoutes]];
    }
    return self;
}

-(NSDictionary *)loadRoutes
{
    
    // loads the routes of file iosRoutes.txt which is used routes on the Yellowstone Park map image
    // iosRoutes.txt line layout:
    //   col 0 = start node name
    //       1 = end node name
    //       2 = distance
    //       3 = routes path
    
    NSArray *columns;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    NSMutableArray *lines;
    // read route data
    NSString * routeData = [self.helperDataFiles  textFileData: IOS_ROUTES_FILENAME  ofType: @"txt"];
    // trim end of file (\r\n) from file data
    routeData = [self.helperDataFiles trimEOF:routeData];
    // build route array
    NSMutableDictionary *routePaths = [[NSMutableDictionary alloc] init];
    NSString *key = @"";
    [routePaths removeAllObjects]; // setup for route paths
    lines = [NSMutableArray arrayWithArray:[routeData componentsSeparatedByString:@"\n"]];

    for (NSString *line in lines) {
        if ([line isEqualToString:@""]) {
            continue;
        }
        columns = [line componentsSeparatedByString:@","];
        Route * route = [[Route alloc] initRouteStartName:columns[0] endName:columns[1] distance:[NSNumber numberWithInt:[[formatter numberFromString:columns[2]] intValue]] route:columns[3]];
        key = [[NSString alloc] initWithFormat:@"%@%@%@",route.startNode, @"|", route.endNode ];
        routePaths[key] = route;
    }
    return [[NSDictionary alloc] initWithDictionary:routePaths];
}

-(NSDictionary *)allRoutes
{
    return self.routes;
}





-(HelperDataFiles *) helperDataFiles
{
    if (!_helperDataFiles) {
        _helperDataFiles = [[HelperDataFiles alloc] init];
    }
    return _helperDataFiles;
}








@end
