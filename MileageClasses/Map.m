//
//  Map.m
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/10/18.
//  Copyright © 2018 Bill Weatherwax. All rights reserved.
//

#import "Map.h"
@interface Map()
@property (nonatomic, strong, readwrite) UIImage *map;
@property (nonatomic, strong) UIImage *workingMap;
@end


@implementation Map
-(instancetype) initMap: (UIImage *) mapImage
{
    self = [super init];
    if (self) {
        _map = [UIImage imageWithData:UIImagePNGRepresentation(mapImage)];//mapImage;
        _workingMap = [UIImage imageWithData:UIImagePNGRepresentation(mapImage)];;
    }
    return self;
}
-(UIImage *)addRoutes: (NSMutableArray *) routes //route is a UIImage between 2 nodes on map
{
    for (UIImage *route in routes){
        self.workingMap = [self addRoute:route toMap:self.workingMap];
    }

    return self.workingMap;
}

-(UIImage *)resetMap
{
    self.workingMap = self.map;
    return self.workingMap;
}

-(NSString *)toString
{
    return [NSString stringWithFormat:@"%@%f%@%f%@%f",
            @"\nsize(",
            self.map.size.width,
            @", ",
            self.map.size.height,
            @") with scale ",
            self.map.scale];
}

#pragma mark - merge map
-(UIImage *)addRoute: (UIImage *) route toMap: (UIImage *) map
{
    CGSize mapSize = map.size;
    CGSize routeSize = route.size;
    // merge maps
    UIGraphicsBeginImageContextWithOptions(mapSize, false, 0.0);
    [map drawInRect:CGRectMake(0, 0, mapSize.width, mapSize.height)];
    [route drawInRect:CGRectMake(0, 0, routeSize.width, routeSize.height) blendMode:kCGBlendModeNormal alpha:1.0];
    UIImage *combinedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return combinedImage;
}


@end
