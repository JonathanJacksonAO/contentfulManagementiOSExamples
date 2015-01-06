//
//  Parser.h
//  Contentful Management
//
//  Created by Jonathan Jackson on 12/12/2014.
//  Copyright (c) 2014 Jonathan Jackson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "List.h"

@interface Parser : NSObject <NSXMLParserDelegate> {
    AppDelegate *app;
    List *theList;
    NSMutableString *currentElementValue;
}

-(id)initParser;

@end
