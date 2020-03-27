//
//  Map.h
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/10/18.
//  Copyright © 2018 Bill Weatherwax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Map : NSObject

#pragma properties
@property (nonatomic, strong, readonly) UIImage *map;

#pragma methods
// designate init
-(instancetype) initMap: (UIImage *) mapImage;
-(UIImage *)addRoutes: (NSArray *) routes; //route is a UIImage between 2 nodes on map
-(UIImage *)resetMap;
-(NSString *)toString;
@end
