//
//  TouchNodes.m
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/23/17.
//  Copyright © 2017 Bill Weatherwax. All rights reserved.
//

#import "TouchNodes.h"
#import "RectF.h"
#import "HelperDataFiles.h"
#import "TouchNode.h"
#import "GlobalConstantsAndTypesDefinitions.h"

@interface TouchNodes()
@property (nonatomic, strong) NSArray *actionNodes;
@property (nonatomic, strong) HelperDataFiles *helperDataFiles;
@end

@implementation TouchNodes
-(instancetype) init
{
    self = [super init];
    if (self) {
        _actionNodes = [[NSArray alloc] initWithArray:[self loadTouchNodes]];
    }
    return self;
}

-(NSArray *)loadTouchNodes
{
    
    // loads the touch sensitive nodes of file map_touch_areas.txt which is used to highlight the names of nodes on the Yellowstone Park map image
    // map_touch_areas.txt line layout:
    //   col 0 = node name
    //       1 -  = data for a text box containing a pullout     //              1 - 4 = coordinates of text box in the image (left, top, right, bottom)
   
    NSArray *columns;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    NSMutableArray *lines;
    NSMutableArray *stageArray = [[NSMutableArray alloc] init];
    
    
    // read map touch data
    NSString * mapTouchAreasData = [self.helperDataFiles  textFileData: MAP_TOUCH_AREA_FILENAME  ofType: @"txt"];
    // trim end of file (\r\n) from file data
    mapTouchAreasData = [self.helperDataFiles trimEOF:mapTouchAreasData];
    // build touchNodes array
    NSMutableArray *touchNodes = [[NSMutableArray alloc] init];
    [touchNodes removeAllObjects]; // setup for touchNodes
    lines = [NSMutableArray arrayWithArray:[mapTouchAreasData componentsSeparatedByString:@"\r\n"]];
    [stageArray removeAllObjects];
    for (NSString *line in lines) {
        columns = [line componentsSeparatedByString:@"\t"];
        TouchNode * node = [[TouchNode alloc] initNodeWithName:columns[0] withTouchArea:[[RectF alloc] initWithCGRectAtLeft:[[formatter numberFromString:columns[1]] floatValue]
                                                                                                                     atTop:[[formatter numberFromString:columns[2]] floatValue]
                                                                                                                   atRight:[[formatter numberFromString:columns[3]] floatValue]
                                                                                                                  atBottom:[[formatter numberFromString:columns[4]] floatValue]
                                                                                                                            ]];
        [touchNodes addObject:node];
    }
    return [[NSArray alloc] initWithArray:touchNodes];
}

-(NSArray *)allTouchNodes
{
    return self.actionNodes;
}

-(int)count
{
    return (int)self.actionNodes.count;
}



-(HelperDataFiles *) helperDataFiles
{
    if (!_helperDataFiles) {
        _helperDataFiles = [[HelperDataFiles alloc] init];
    }
    return _helperDataFiles;
}







@end
