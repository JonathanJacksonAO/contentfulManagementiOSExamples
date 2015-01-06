//
//  ViewController.h
//  Contentful Management
//
//  Created by Jonathan Jackson on 20/11/2014.
//  Copyright (c) 2014 Jonathan Jackson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "List.h"

@interface ViewController : UIViewController
@property (nonatomic, retain) AppDelegate *app;
@property (nonatomic, retain) List  *theList;
@end