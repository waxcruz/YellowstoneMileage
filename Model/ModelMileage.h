//
//  ModelMileage.h
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/23/17.
//  Copyright © 2017 Bill Weatherwax. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OverlayRoads;
@class TouchNodes;
@class Routes;
@class Strings;
@interface ModelMileage : NSObject
#pragma  methods
-(void) startOfModel;
-(void) stopModel;
-(NSString *)getContentsOfStringName: (NSString *) name;
-(NSString *)getImageFileStringOfYellowstoneMap;
-(OverlayRoads *)getEdges;
-(TouchNodes *)getTouchNodes;
-(Routes *) getRoutes;
-(Strings *) getLiterals;
@end
