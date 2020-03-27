//
//  ModelMileage.m
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/23/17.
//  Copyright © 2017 Bill Weatherwax. All rights reserved.
//

#import "ModelMileage.h"
#import "Routes.h"
#import "Route.h"
#import "TouchNodes.h"
#import "TouchNode.h"
#import "Strings.h"
#import "HelperDataFiles.h"
#import "OverlayRoads.h"


@interface ModelMileage()
@property (nonatomic, strong) HelperDataFiles *helperDataFiles;
@property (nonatomic, strong) Routes * routes; // route objects
@property (nonatomic, strong) TouchNodes * touches; // all touch objects
@property (nonatomic, strong) Strings *literals;
@property (nonatomic, strong) OverlayRoads *pngs;


@end



@implementation ModelMileage

-(instancetype) init
{
    self = [super init];
    if (self) {
        _routes = [[Routes alloc] init];
        _touches = [[TouchNodes alloc] init];
        _pngs = [[OverlayRoads alloc] init];
        _literals = [[Strings alloc] init];
    }
    return self;
}
-(void) startOfModel
{
    // NSLog(@"Model loaded");
}
-(void) stopModel
{
    // NSLog(@"Model unloaded");
}

-(NSString *)getContentsOfStringName: (NSString *) name;
{
    return [self.literals stringValueForName:name];
}

-(OverlayRoads *)getEdges
{
    return self.pngs;
}

-(TouchNodes *) getTouchNodes
{
    return self.touches;
}

-(Routes *) getRoutes
{
    return self.routes;
}
-(NSString *)getImageFileStringOfYellowstoneMap
{
    // yellowstone park map file name
    return [self.helperDataFiles filePath:@"yellowstone_np_map" ofType:@".png"];
}

-(Strings *) getLiterals
{
    return self.literals;
}

-(HelperDataFiles *) helperDataFiles
{
    if (!_helperDataFiles) {
        _helperDataFiles = [[HelperDataFiles alloc] init];
    }
    return _helperDataFiles;
}

@end
