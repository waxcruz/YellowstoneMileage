//
//  HelperDataFiles.h
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/23/17.
//  Copyright © 2017 Bill Weatherwax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HelperDataFiles : NSObject
-(NSString *)trimEOF:(NSString *) myString;
- (NSString *)textFileData:(NSString *)myFileName ofType:(NSString *)myFileType;
- (NSString *)filePath:(NSString *)myFileName ofType:(NSString *)myFileType;
@end
