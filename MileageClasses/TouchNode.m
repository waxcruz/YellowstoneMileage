//
//  TouchNodes.m
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/23/17.
//  Copyright © 2017 Bill Weatherwax. All rights reserved.
//

#import "TouchNode.h"

@interface TouchNode()
@property (nonatomic, strong, readwrite) NSString *nodeName;
@property (nonatomic, strong, readwrite) RectF *touchNode;

@end

@implementation TouchNode
-(instancetype) initNodeWithName: (NSString *) nodeName
                   withTouchArea: (RectF *) touchArea
{
    self = [super init];
    if (self) {
        _nodeName = nodeName;
        _touchNode = touchArea;
    }
    return self;
}

-(instancetype) init
{
    return nil;
}


-(NSString *)toString
{
    return self.nodeName;
}


@end
