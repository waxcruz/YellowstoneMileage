//
//  Edge.h
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/12/18.
//  Copyright © 2018 Bill Weatherwax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OverlayRoad : NSObject
#pragma methods
// designate init
-(instancetype) initEdgeStartName: (NSString *) startNode
                           endName: (NSString *) endNode
                          edgePNG: (NSString *) png
                             seasonal: (BOOL) seasonalRoute;
-(NSString *)edgeFileNameOfPNG;
-(BOOL)isEdgeSeasonalStartName;
-(NSString *) edgeDictionaryKey;
-(NSString *)toString;
@end
