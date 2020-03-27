//
//  YellowstoneMileageGraphics.h
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/23/17.
//  Copyright © 2017 Bill Weatherwax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface YellowstoneMileageGraphics : NSObject
+(CGRect)makeRectFromCorners:(CGFloat) upperLeftX upperCornerY: (CGFloat) upperLeftY lowerRightCornerX: (CGFloat) lowerRightX lowerRightCornerY: (CGFloat) lowerRightY;
+(NSString *)displayCGPoint:(CGPoint) point;
+(NSString *)displayCGFrame:(CGRect) frame;
+(NSString *)displayCGSize:(CGSize) size;

@end
