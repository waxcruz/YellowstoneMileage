//
//  UIImageView+HighlightImage.h
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/23/17.
//  Copyright © 2017 Bill Weatherwax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (HighlightImage)
-(CAShapeLayer *)addHighlightToImageView: (UIImageView *) imageView atRect: (CGRect) area isOrientationPortrait:(BOOL) isPortrait;
-(void) removeHighlightFromImageView: (CAShapeLayer *) layer;
+(CGPoint)rotatePointAboutOrigin:(CGPoint) point angleInDegrees:(CGFloat) angle origin: (CGPoint) centerOfOrigin;

@end
