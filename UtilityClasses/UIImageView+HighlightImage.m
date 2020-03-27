//
//  UIImageView+HighlightImage.m
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/23/17.
//  Copyright © 2017 Bill Weatherwax. All rights reserved.
//

#import "UIImageView+HighlightImage.h"
#import "YellowstoneMileageGraphics.h"
#import <AVFoundation/AVFoundation.h>


@implementation UIImageView (HighlightImage)
-(CAShapeLayer *)addHighlightToImageView: (UIImageView *) imageView atRect: (CGRect) area isOrientationPortrait:(BOOL) isPortrait
{
    
    //    NSLog(@">>>> addHighlightToImageViewPNG  <<<<<");
    //    NSLog(@"\t\timageView.frame: %@ area: %@, orientation %d", [YellowstoneSPOTRGraphics displayCGFrame:imageView.frame], [YellowstoneSPOTRGraphics displayCGFrame:area],isPortrait);
    //    NSLog(@"\t\timageView.frame: %@ area: %@, orientation %d", [YellowstoneSPOTRGraphics displayCGFrame:imageView.bounds], [YellowstoneSPOTRGraphics displayCGFrame:area],isPortrait);
    CGFloat aspectScaleFactor = 1.0f;
    // NSLog(@"\t\tarea: %@",[YellowstoneSPOTRGraphics displayCGFrame:area]);
    CGRect appleSize = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(imageView.image.size.width, imageView.image.size.height), imageView.bounds);
    CGSize scaleSize = appleSize.size;
    // NSLog(@"\t\tscaleSize: %@", [YellowstoneSPOTRGraphics displayCGSize:scaleSize]);
    //    NSLog(@"\t\tappleSize: %@", [YellowstoneSPOTRGraphics displayCGSize:appleSize.size]);
    UIScrollView * parentOfImageView = (UIScrollView *)[imageView superview];
    if (parentOfImageView.zoomScale > 1.0f) {
        scaleSize = CGSizeMake(scaleSize.width/parentOfImageView.zoomScale, scaleSize.height/parentOfImageView.zoomScale);
        aspectScaleFactor = parentOfImageView.zoomScale;
        // NSLog(@"\t\tscaleSize after zoom adjustment: %@", [YellowstoneSPOTRGraphics displayCGSize:scaleSize]);
        // NSLog(@"\t\taspectScaleFactor: %f",aspectScaleFactor);
    }
    // NSLog(@"\t\tscaleSize: %@", [YellowstoneSPOTRGraphics displayCGSize:scaleSize]);
    CGFloat aspectRatioWidth = scaleSize.width;
    CGFloat aspectRatioHeight = scaleSize.height;
    CGFloat aspectRatio = scaleSize.width/scaleSize.height;
    // NSLog(@"\t\taspectRatioWidth: %f, aspectRatioHeight: %f, aspectRatio: %f", aspectRatioWidth, aspectRatioHeight, aspectRatio);
    BOOL isContentOrientationLandscape = YES;
    // PNG can be oriented differently than the device
    if (aspectRatio < 1.0) {
        isContentOrientationLandscape = NO;
    }
    // NSLog(@"\t\tisContentOrientationLandscape? %@",isContentOrientationLandscape ? @"YES":@"NO");
    // Detect existence of borders created by Aspect Fill content
    BOOL isThereAVerticalBorder;
    BOOL isThereAHorizontalBorder;
    if (((imageView.frame.size.height/aspectScaleFactor) - scaleSize.height) == 0.0f) {
        isThereAVerticalBorder = NO;
    } else {
        isThereAVerticalBorder = YES;
    }
    if (((imageView.frame.size.width/aspectScaleFactor) - scaleSize.width) == 0.0f) {
        isThereAHorizontalBorder = NO;
    } else {
        isThereAHorizontalBorder = YES;
    }
    // NSLog(@"\t\tisThereHorizontalBorder? %@ and isThereAVerticalBorder? %@",isThereAHorizontalBorder ? @"YES" : @"NO", isThereAVerticalBorder ? @"YES" : @"NO");
    
    CGFloat aspectAdjustment;
    // area represented as values from 0 to 1 as fractions of image space
    // convert from image space fractions to points in image
    area.origin.x *= (aspectRatioWidth);
    area.origin.y *= (aspectRatioHeight);
    area.size.width *= (aspectRatioWidth);
    area.size.height *= (aspectRatioHeight);
    // NSLog(@"\t\trecalculated area with aspect ratio adjustment: %@", [YellowstoneSPOTRGraphics displayCGFrame:area]);
    // Set content mode before calling this method.
    if (isThereAVerticalBorder) {
        aspectAdjustment = ((imageView.frame.size.height/aspectScaleFactor) - scaleSize.height)/2.0f;
        area.origin.y += ((aspectAdjustment+1.0f)); // * (aspectRatioWidth/aspectRatioHeight);
        // NSLog(@"\t\tVertical aspect adjustment: %f",aspectAdjustment);
    }
    if (isThereAHorizontalBorder) {
        // NSLog(@"++++++++++image width: %f and scaled width: %f", imageView.frame.size.width, scaleSize.width);
        aspectAdjustment = (imageView.frame.size.width/aspectScaleFactor - scaleSize.width)/2.00f;
        area.origin.x += aspectAdjustment+1.0f; // * (aspectRatioWidth/aspectRatioHeight);
        // NSLog(@"\t\tHorizontal aspect adjustment: %f",aspectAdjustment);
    }
    // NSLog(@"\t\trecalculated area with aspect adjustment: %@", [YellowstoneSPOTRGraphics displayCGFrame:area]);
    // adjustment is calculated by removing space surroung the imageView: self.mapView.bounds.size.height - self.navigationController.navigationBar.frame.size.height + (self.mapView.frame.origin.y/2.0f)
    //reposition y coordinate in aspect fit image space
    CAShapeLayer *highlightLayer = [CAShapeLayer layer];
    highlightLayer.opacity = 0.2f;
    // Give the layer the same bounds as your image view
    [highlightLayer setBounds:CGRectMake(0.0f, 0.0f, [imageView frame].size.width,
                                         [imageView frame].size.height)];
    // NSLog(@"\t\thighlightLayer bounds: %@", [YellowstoneSPOTRGraphics displayCGFrame:highlightLayer.bounds]);
    // Position the highlight anywhere you like, but this will center it
    // In the parent layer, which will be your image view's root layer
    [highlightLayer setPosition:CGPointMake(imageView.frame.size.width/2.0f, imageView.frame.size.height/2.0f)];
    // NSLog(@"\t\thighlightLayer position: %@",[YellowstoneSPOTRGraphics displayCGPoint:highlightLayer.position]);
    // Create a rectangle
    // NSLog(@"\t\thighlight area: %@", [YellowstoneSPOTRGraphics displayCGFrame:area]);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:
                          area];
    
    // Set the path on the layer
    [highlightLayer setPath:[path CGPath]];
    // Set the stroke color
    [highlightLayer setStrokeColor:[[UIColor blackColor] CGColor]];
    // Set the stroke line width
    [highlightLayer setLineWidth:1.0f];
    // set fill
    [highlightLayer setFillColor:[[UIColor greenColor] CGColor]];
    
    // Add the sublayer to the image view's layer tree
    //    [[imageView layer] addSublayer:highlightLayer];
    // NSLog(@"\t\thightlightLayer: %@", highlightLayer);
    
    return highlightLayer;
}
+(CGPoint)rotatePointAboutOrigin:(CGPoint) point angleInDegrees:(CGFloat) angle origin: (CGPoint) centerOfOrigin
{
    CGPoint adjustedPoint = CGPointMake(point.x - centerOfOrigin.x, point.y - centerOfOrigin.y);
    float s = sinf(angle*(M_PI/180.f));
    float c = cosf(angle*(M_PI/180.f));
    CGPoint rotatedPoint = CGPointMake(c * adjustedPoint.x - s * adjustedPoint.y, s * adjustedPoint.x + c * adjustedPoint.y);
    return CGPointMake(centerOfOrigin.x + rotatedPoint.x, centerOfOrigin.y + rotatedPoint.y);
}


-(void) removeHighlightFromImageView: (CAShapeLayer *) highlightLayer
{
    [highlightLayer removeFromSuperlayer];
}


@end
