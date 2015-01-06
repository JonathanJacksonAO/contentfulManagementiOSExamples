//
//  ViewController.m
//  Contentful Management
//
//  Created by Jonathan Jackson on 20/11/2014.
//  Copyright (c) 2014 Jonathan Jackson. All rights reserved.
//

#import "ViewController.h"
#import "LoginViewController.h"
#import "ContentfulManagementAPI/ContentfulManagementAPI.h"
#import <JGProgressHUD.h>
#import <IAmUpload/BBUUploadsImUploader.h>
#import "Constants.h"

@interface ViewController () <UIWebViewDelegate>

@property (nonatomic) UIWebView* webView;
@property (nonatomic) CMAClient* client;
@property (nonatomic) CMAContentType* contentType;
@property (nonatomic) CMASpace* space;

@end

@implementation ViewController
@synthesize app;
@synthesize theList;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Initializing Environment...";
    [HUD showInView:self.view animated:YES];
    
    CDAConfiguration* configuration = [CDAConfiguration defaultConfiguration];
    configuration.rateLimiting = YES;

    self.client = [[CMAClient alloc] initWithAccessToken:@"a9fb295556d11a399d9e45ca8c9673e463561c982ce3865835a03489f4ae5b92" configuration:configuration];
    
    [self.client fetchSpaceWithIdentifier:@"4wump9bnhsww"
                             success:^(CDAResponse *response, CMASpace *space) {
//                                 NSLog(@"%@", space);
                                 self.space = space;
                                 [space fetchContentTypesWithSuccess:^(CDAResponse *response, CDAArray *array) {
                                     NSLog(@"%@",array);
                                     for (CMAContentType *cType in array.items) {
                                         if ([cType.name isEqualToString:@"Location"]) {
                                             NSLog(@"%@=%@",cType.name, cType.identifier);
                                             self.contentType = cType;
                                             [HUD dismissAnimated:YES];
                                         }
                                     }
                                 } failure:^(CDAResponse *response, NSError *error) {
                                     [HUD dismissAnimated:YES];
                                 }];
                                 
                             } failure:^(CDAResponse *response, NSError *error) {
                                 NSLog(@"Error: %@", error);
                             }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)loadOffices:(id)sender {
    app = [[UIApplication sharedApplication] delegate];
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading Offices...";
    [HUD showInView:self.view animated:YES];
    NSString *fullAddress;
    NSURL *uploadFile;
    
    for (List *li in app.listArray) {
        if (li.Address1 && ![li.Address1 isEqual:[NSNull null]]) {
            fullAddress = li.Address1;
        };
        if (li.Address2 && ![li.Address2 isEqual:[NSNull null]]) {
            fullAddress = [NSString stringWithFormat:@"%@, %@", fullAddress, li.Address2];
        };
        if (li.Address3 && ![li.Address3 isEqual:[NSNull null]]) {
            fullAddress = [NSString stringWithFormat:@"%@, %@", fullAddress, li.Address3];
        };
        if (li.Address4 && ![li.Address4 isEqual:[NSNull null]]) {
            fullAddress = [NSString stringWithFormat:@"%@, %@", fullAddress, li.Address4];
        };
        if (li.Address5 && ![li.Address5 isEqual:[NSNull null]]) {
            fullAddress = [NSString stringWithFormat:@"%@, %@", fullAddress, li.Address5];
        };
        if (li.Address6 && ![li.Address6 isEqual:[NSNull null]]) {
            fullAddress = [NSString stringWithFormat:@"%@, %@", fullAddress, li.Address6];
        };
        
        uploadFile = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.allenovery.com%@", li.Photo]];
        
        [self.space createEntryOfContentType:self.contentType withFields:@{@"name": @{@"en-US": li.LocationName},@"telephone": @{@"en-US": li.TelephoneNumber},@"address": @{@"en-US": fullAddress},@"email": @{@"en-US": li.ContactEmailAddress}} success:^(CDAResponse *response, CMAEntry *entry) {
            NSLog(@"%@", entry);
            
            [self.space createAssetWithTitle:@{ @"en-US": [NSString stringWithFormat:@"%@-Office-Image", li.LocationName] }
                                 description:@{ @"en-US": [NSString stringWithFormat:@"Image for the %@ Office", li.LocationName] }
                                fileToUpload:@{ @"en-US": uploadFile.absoluteString }
                                     success:^(CDAResponse *response, CMAAsset *asset) {
                                         [asset processWithSuccess:^{
                                             [self.space fetchEntryWithIdentifier:entry.identifier success:^(CDAResponse *response, CDAEntry *entry) {
                                                 [(CMAEntry*)entry setValue:@[ @{ @"sys": @{ @"type": @"Link", @"linkType": @"Asset", @"id": asset.identifier } } ] forFieldWithName:@"image"];
                                                 [(CMAEntry*)entry updateWithSuccess:^{
                                                 } failure:^(CDAResponse *response, NSError *error) {
                                                 }];
                                             } failure:^(CDAResponse *response, NSError *error) {
                                             }];
                                         } failure:^(CDAResponse *response, NSError *error) {
                                             NSLog(@"Error: %@", error);
                                         }];
                                         
                                     } failure:^(CDAResponse *response, NSError *error) {
                                         NSLog(@"Error: %@", error);
                                     }];
        } failure:^(CDAResponse *response, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
    [HUD dismissAnimated:YES];
}


- (IBAction)loadAsset:(id)sender {
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading Office...";
    [HUD showInView:self.view animated:YES];
    [self.space createAssetWithTitle:@{ @"en-US": @"London Office Image" }
                    description:@{ @"en-US": @"Image for the London Office" }
                   fileToUpload:@{ @"en-US": @"http://www.allenovery.com/PublishingImages/Office_OfficeImage_London.jpg" }
                        success:^(CDAResponse *response, CMAAsset *asset) {
                            [asset processWithSuccess:^{
                                    [NSThread sleepForTimeInterval:1.0];
                                    [asset publishWithSuccess:^{
                                        NSLog(@"Success: %@", asset);
                                        [HUD dismissAnimated:YES];
                                    } failure:^(CDAResponse *response, NSError *error) {
                                        NSLog(@"Error: %@", error);
                                        [HUD dismissAnimated:YES];
                                    }];
                                    
                            } failure:^(CDAResponse *response, NSError *error) {
                                NSLog(@"%@", error);
                            }];

                            
                        } failure:^(CDAResponse *response, NSError *error) {
                            NSLog(@"Error: %@", error);
                        }];
}

@end
