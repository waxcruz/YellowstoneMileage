//
//  Routes.h
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/23/17.
//  Copyright © 2017 Bill Weatherwax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Route : NSObject
#pragma properties
@property (nonatomic, strong, readonly) NSString *startNode;
@property (nonatomic, strong, readonly) NSString *endNode;
@property (nonatomic, strong, readonly) NSNumber *distance;
@property (nonatomic, strong, readonly) NSString *route;
@property (nonatomic, strong, readonly) NSArray *edges;

#pragma methods
// designate init
-(instancetype) initRouteStartName: (NSString *) startNode
                           endName: (NSString *) endNode
                   distance: (NSNumber *) distance
                             route: (NSString *)route;
-(NSString *)toString;



@end
