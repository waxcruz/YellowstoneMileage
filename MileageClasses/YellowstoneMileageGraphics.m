//
//  YellowstoneMileageGraphics.m
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/23/17.
//  Copyright © 2017 Bill Weatherwax. All rights reserved.
//

#import "YellowstoneMileageGraphics.h"

@implementation YellowstoneMileageGraphics
+(CGRect)makeRectFromCorners:(CGFloat) upperLeftX upperCornerY: (CGFloat) upperLeftY lowerRightCornerX: (CGFloat) lowerRightX lowerRightCornerY: (CGFloat) lowerRightY
{
    // Yellowstone SPOTR describes rectangles as two points: upper left corner and bottom right corner
    CGRect newRect = CGRectMake(upperLeftX, upperLeftY, lowerRightX - upperLeftX, lowerRightY - upperLeftY);
    return newRect;
}

+(NSString *)displayCGPoint:(CGPoint)point
{
    return [NSString stringWithFormat:@"(%f, %f)",point.x, point.y];
}

+(NSString *)displayCGFrame:(CGRect) frame
{
    return [NSString stringWithFormat:@"origin: %@ size: %@",
            [self displayCGPoint:frame.origin],
            [self displayCGSize:frame.size]];
}
+(NSString *)displayCGSize:(CGSize) size
{
    return [NSString stringWithFormat:@"width = %f, height = %f", size.width, size.height];
}


@end
