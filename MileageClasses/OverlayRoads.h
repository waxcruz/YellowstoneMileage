//
//  NamesOfPNGs.h
//  YellowstoneSPOTR
//
//  Created by Bill Weatherwax on 12/16/16.
//  Copyright © 2016 ccspotr. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OverlayRoad;
@interface OverlayRoads : NSObject
-(OverlayRoad *) edgeNode1: (NSString *) startNode node2:(NSString *) endNode ;
-(NSString *) toString;
@end
