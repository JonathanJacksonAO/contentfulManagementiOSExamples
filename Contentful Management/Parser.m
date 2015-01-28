//
//  Parser.m
//  Contentful Management
//
//  Created by Jonathan Jackson on 12/12/2014.
//  Copyright (c) 2014 Jonathan Jackson. All rights reserved.
//

#import "Parser.h"

@implementation Parser

-(id) initParser {
    if (self == [super init]) {
        app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    }
    return self;
}

-(void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    if ([elementName isEqualToString:@"ArrayOfPerson"]) {
        app.listArray = [[NSMutableArray alloc] init];
    }
    else if([elementName isEqualToString:@"Person"]) {
        theList = [[List alloc] init];
        theList.Id = [[attributeDict objectForKey:@"id"] integerValue];
        
    }
}

-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (!currentElementValue) {
        currentElementValue = [[NSMutableString alloc] initWithString:string];
    }
    else
        [currentElementValue appendString:string];
    
}

-(void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"ArrayOfPerson"]) {
        return;
    }
    if ([elementName isEqualToString:@"Person"]) {
        [app.listArray addObject:theList];
        theList = nil;
    }
    else
        [theList setValue:[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:elementName];
    
    currentElementValue = nil;
}
@end
