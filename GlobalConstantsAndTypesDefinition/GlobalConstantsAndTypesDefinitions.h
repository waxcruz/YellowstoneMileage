//
//  GlobalConstantsAndTypesDefinitions.h
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/23/17.
//  Copyright © 2017 Bill Weatherwax. All rights reserved.
//

#ifndef GlobalConstantsAndTypesDefinitions_h
#define GlobalConstantsAndTypesDefinitions_h

// single location for enumerations

typedef NS_ENUM(NSInteger, ScreenOrientations) {
    PORTRAIT_ORIENTATION=0,
    LANDSCAPE_ORIENTATION
};
#define screenOrientationTypeStrings(enum) [@[@"portrait",@"landscape"] objectAtIndex:enum]

#pragma literals

// My naming conventions
// I use "target" for properties associated with targets on Interface Builder screens
//
// Mileage File Names
#define MAP_TOUCH_AREA_FILENAME @"map_touch_areas"
#define IOS_ROUTES_FILENAME @"iosRoutes"
#define PNG_DATA_FILENAME @"route_overlay_pngs"

// Constant values
#define vSwipeLeft -1
#define vSwipeRight 1
#define vMinZoomScale 1.0f
#define vMaxZoomScale 3.75f
#define vSearchPrompt @"A place to go or see"












#endif /* GlobalConstantsAndTypesDefinitions_h */
