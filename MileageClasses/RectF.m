//
//  RectF.m
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/23/17.
//  Copyright © 2017 Bill Weatherwax. All rights reserved.
//

#import "RectF.h"
#import "UIImageView+HighlightImage.h"
@interface RectF()
@property (nonatomic,readwrite) CGFloat rectLeft;   // x top left corner
@property (nonatomic,readwrite) CGFloat rectTop;    // y top left corner
@property (nonatomic,readwrite) CGFloat rectRight;  // x right bottom corner
@property (nonatomic,readwrite) CGFloat rectBottom; // y right bottom corner
@end

@implementation RectF


- (instancetype) init
{
    return nil;
}

-(instancetype) initWithCGRectAtLeft: (CGFloat) left
                               atTop: (CGFloat) top
                             atRight:(CGFloat) right
                            atBottom: (CGFloat) bottom

{
    self = [super init];
    if (self) {
        _rectTop = top;
        _rectLeft = left;
        _rectBottom = bottom;
        _rectRight = right;
    }
    return self;
}

-(CGRect)toCGRect
{
    return CGRectMake(self.rectLeft, self.rectTop,  // x, y
                      self.rectRight - self.rectLeft,              // width
                      self.rectBottom - self.rectTop);             // height
}

-(BOOL)isTouchedAtPoint:(CGPoint) touchPoint
{
    if ((touchPoint.x >= self.rectLeft)
        && (touchPoint.x <= self.rectRight)
        && (touchPoint.y >= self.rectTop)
        && (touchPoint.y <= self.rectBottom)) {
        return TRUE;
    } else {
        return FALSE;
    }
}

-(BOOL)isTouchedAtPoint: (CGPoint) touchPoint withRotationAngle:(CGFloat)angle
{
    //    CGFloat width = self.rectRight - self.rectLeft;
    //    CGFloat height = self.rectBottom - self.rectTop;
    //    CGPoint centerOfBox = CGPointMake(self.rectLeft + .5 * width, self.rectTop + .5 *height);
    //    CGPoint topLeftRotated = [UIImageView rotatePointAboutOrigin:CGPointMake(self.rectLeft, self.rectTop)angleInDegrees:angle origin:centerOfBox];
    //    CGPoint topRightRotated = [UIImageView rotatePointAboutOrigin:CGPointMake(self.rectLeft + width, self.rectTop) angleInDegrees:angle origin:centerOfBox];
    //    CGPoint bottomRightRotated = [UIImageView rotatePointAboutOrigin:CGPointMake(self.rectRight, self.rectBottom) angleInDegrees:angle origin:centerOfBox];
    //    CGPoint bottomLeftRotated = [UIImageView rotatePointAboutOrigin:CGPointMake(self.rectLeft, self.rectTop + height) angleInDegrees:angle origin:centerOfBox];
    //    if (touchPoint.x < MAX(topLeftRotated.x, bottomLeftRotated.x)) {
    //        return NO;
    //    }
    //    if (touchPoint.x > MAX(topRightRotated.x, bottomRightRotated.x)) {
    //        return NO;
    //    }
    //    if (touchPoint.y < MAX(topLeftRotated.y, topRightRotated.y)) {
    //        return NO;
    //    }
    //    if (touchPoint.y > MAX(bottomLeftRotated.y, bottomRightRotated.y)) {
    //        return NO;
    //    }
    //
    //
    //    CGPoint touchPointRotated = [UIImageView rotatePointAboutOrigin:touchPoint angleInDegrees:angle origin:centerOfBox];
    //    if (   (touchPointRotated.x >= topLeftRotated.x)
    //        && (touchPointRotated.x <= topRightRotated.x)
    //        && (touchPointRotated.y >= bottomLeftRotated.y)
    //        && (touchPointRotated.y <= bottomRightRotated.y)) {
    //        return YES;
    //    }
    CGPoint centerOfBox = CGPointMake(self.rectLeft + .5 * (self.rectRight - self.rectLeft), self.rectTop + .5 *(self.rectBottom - self.rectTop));
    CGPoint touchPointRotated = [UIImageView rotatePointAboutOrigin:touchPoint angleInDegrees:angle origin:centerOfBox];
    if ((touchPointRotated.x >= self.rectLeft)
        && (touchPointRotated.x <= self.rectRight)
        && (touchPointRotated.y >= self.rectTop)
        && (touchPointRotated.y <= self.rectBottom)) {
        return YES;
    }
    return NO;
}
@end
