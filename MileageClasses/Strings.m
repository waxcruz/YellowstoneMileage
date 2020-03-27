//
//  Strings.m
//  YellowstoneMileage
//
//  Created by Bill Weatherwax on 6/24/17.
//  Copyright © 2017 Bill Weatherwax. All rights reserved.
//

#import "Strings.h"
@interface Strings()<NSXMLParserDelegate>
@property (nonatomic, strong) NSDictionary *literals;
@property (nonatomic, strong) NSXMLParser * parseStrings;
@property (nonatomic, strong) NSMutableDictionary *codeStrings;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;

@end

@implementation Strings
-(instancetype)init
{
    [self superclass];
    if (self) {
        [self parseXMLFile];
        _literals = [NSDictionary dictionaryWithDictionary:self.codeStrings];
    }
    return self;
}

-(void) parseXMLFile
{
    BOOL success; // not used
    NSURL * xmlURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"strings" ofType:@"xml"]];
    self.parseStrings = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
    [self.parseStrings setDelegate:self];
    [self.parseStrings setShouldResolveExternalEntities:YES];
    self.key = nil;
    self.value = nil;
    success = [self.parseStrings parse];
    
}


-(void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict
{
    if ([elementName isEqualToString:@"string"]) {
        self.key = [attributeDict valueForKey:@"name"];
    }
}
-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.key) {
        if (![string isEqualToString:@"\n"]) {
            if (self.value) {
                self.value = [self.value stringByAppendingString:string];
            } else {
                self.value = string;
            }
        }
    }
}

-(void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"string"]) {
        if (self.value) {
            [self.codeStrings setObject:self.value forKey:self.key ];
        }
        self.key = nil;
        self.value = nil;
    }
}

-(NSMutableDictionary *) codeStrings
{
    if (!_codeStrings) {
        _codeStrings = [[NSMutableDictionary alloc] init];
    }
    return _codeStrings;
}




-(NSString *)stringValueForName: (NSString *)name
{
    return [self.literals objectForKey:name];
}




@end
