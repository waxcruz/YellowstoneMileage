//
//  TouchNodes.h
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/23/17.
//  Copyright © 2017 Bill Weatherwax. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RectF;

#pragma properties
@interface TouchNode : NSObject
@property (nonatomic, strong, readonly) NSString *nodeName;
@property (nonatomic, strong, readonly) RectF *touchNode;

#pragma methods
// designate init
-(instancetype) initNodeWithName: (NSString *) nodeName
                           withTouchArea: (RectF *) touchArea;


-(NSString *)toString;

@end
