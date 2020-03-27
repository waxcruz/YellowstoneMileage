//
//  RectF.h
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/23/17.
//  Copyright © 2017 Bill Weatherwax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RectF : NSObject
@property (nonatomic,readonly) CGFloat rectTop;
@property (nonatomic,readonly) CGFloat rectLeft;
@property (nonatomic,readonly) CGFloat rectBottom;
@property (nonatomic,readonly) CGFloat rectRight;






// designate init
-(instancetype) initWithCGRectAtLeft: (CGFloat) left
                               atTop: (CGFloat) top
                             atRight:(CGFloat) right
                            atBottom: (CGFloat) bottom

;

-(CGRect)toCGRect;
-(BOOL)isTouchedAtPoint:(CGPoint) touchPoint;
-(BOOL)isTouchedAtPoint: (CGPoint) touchPoint withRotationAngle:(CGFloat)degrees;

@end
