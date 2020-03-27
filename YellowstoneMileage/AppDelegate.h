//
//  AppDelegate.h
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 5/16/16.
//  Copyright © 2016 Bill Weatherwax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModelMileage.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) ModelMileage *model;



@end

