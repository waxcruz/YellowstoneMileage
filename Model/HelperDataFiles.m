//
//  HelperDataFiles.m
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/23/17.
//  Copyright © 2017 Bill Weatherwax. All rights reserved.
//

#import "HelperDataFiles.h"

@implementation HelperDataFiles
-(NSString *)trimEOF:(NSString *) myString
{
    NSString *eof = [myString substringFromIndex:[myString length] - 2];
    if ([eof isEqualToString:@"\r\n"] || [eof isEqualToString:@"\n\r"]) {
        return [myString substringWithRange:NSMakeRange(0, myString.length - 2)];
    } else {
        return myString;
    }
    
}


- (NSString *)textFileData:(NSString *)myFileName ofType:(NSString *)myFileType{
    NSString* path = [[NSBundle mainBundle] pathForResource:myFileName
                                                     ofType:myFileType];
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    return content;
}

- (NSString *)filePath:(NSString *)myFileName ofType:(NSString *)myFileType{
    NSString* path = [[NSBundle mainBundle] pathForResource:myFileName
                                                     ofType:myFileType];
    return path;
}



@end
