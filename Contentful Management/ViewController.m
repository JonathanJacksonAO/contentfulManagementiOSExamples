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
                                         if ([cType.name isEqualToString:@"Contact"]) {
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
                                             [NSThread sleepForTimeInterval:1.0];
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
- (IBAction)loadTheUsers:(id)sender {
    app = [[UIApplication sharedApplication] delegate];
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading Users...";
    [HUD showInView:self.view animated:YES];
    NSURL *uploadFile;
    
    for (List *li in app.listArray) {
        
        [NSThread sleepForTimeInterval:1.0];
        uploadFile = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.allenovery.com%@", li.Photo]];
        
        [self.space createEntryOfContentType:self.contentType withFields:@{@"forename": @{@"en-US": [[NSUUID UUID] UUIDString]},@"surname": @{@"en-US": [[NSUUID UUID] UUIDString]},@"title": @{@"en-US": [[NSUUID UUID] UUIDString]},@"telephone": @{@"en-US": [[NSUUID UUID] UUIDString]}, @"email": @{@"en-US": [[NSUUID UUID] UUIDString]}, @"notes": @{@"en-US": [[NSUUID UUID] UUIDString]}} success:^(CDAResponse *response, CMAEntry *entry) {
            [(CMAEntry*)entry setValue:@{ @"sys": @{ @"type": @"Link", @"linkType": @"Asset", @"id": @"2D6nhwZlAAeU4MS6WeGyWY" } }  forFieldWithName:@"image"];
            [(CMAEntry*)entry updateWithSuccess:^{
                NSLog(@"Successfully created contact %@ with image.", entry);
            } failure:^(CDAResponse *response, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            NSLog(@"%@", entry);
//            [entry publishWithSuccess:nil failure:nil];
            
        } failure:^(CDAResponse *response, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
    [HUD dismissAnimated:YES];

//    NSLog(@"%@ and then... %@ and then... %@", [[NSUUID UUID] UUIDString], [[NSUUID UUID] UUIDString], [[NSUUID UUID] UUIDString]);
}
- (IBAction)deleteAllContacts:(id)sender {
    [self.space fetchEntriesMatching:@{@"content_type": self.contentType.identifier, @"limit": @10000} success:^(CDAResponse *response, CDAArray *array) {
        for (CMAEntry *de in array.items) {
            [NSThread sleepForTimeInterval:0.5];
//            NSLog(@"Contact %@ publish property is: %i", de.identifier, de.isPublished);
            if (de.isPublished) {
                [de unpublishWithSuccess:^{
                    [de deleteWithSuccess:^{
                        NSLog(@"Successfully deleted Contact with Id: %@", de.identifier);
                    } failure:^(CDAResponse *response, NSError *error) {
                        NSLog(@"Error could not delete because: %@", error);
                    }];
                } failure:^(CDAResponse *response, NSError *error) {
                    NSLog(@"Error could not unpublish because: %@", error);
                }];
            }
            else
            {
                [de deleteWithSuccess:^{
                    NSLog(@"Successfully deleted Contact with Id: %@", de.identifier);
                } failure:^(CDAResponse *response, NSError *error) {
                    NSLog(@"Error could not delete because: %@", error);
                }];
            }
            
        }
    } failure:^(CDAResponse *response, NSError *error) {
        NSLog(@"Error fetching matching entries because: %@", error);
    }];
}
- (IBAction)publishAllContacts:(id)sender {
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Publishing Contacts...";
    [HUD showInView:self.view animated:YES];
    [self.space fetchEntriesMatching:@{@"content_type": self.contentType.identifier, @"limit": @10000} success:^(CDAResponse *response, CDAArray *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (CMAEntry *de in array.items) {
//                [NSThread sleepForTimeInterval:0.5];
                //            NSLog(@"Contact %@ publish property is: %i", de.identifier, de.isPublished);
                if (!de.isPublished) {
                    [de publishWithSuccess:^{
                        NSLog(@"Successfully published contact with Id: %@", de.identifier);
                    } failure:^(CDAResponse *response, NSError *error) {
                        NSLog(@"Failed to publish contact with Id: %@", de.identifier);
                    }];
                }
            }
            [HUD dismissAnimated:YES];
        });

    } failure:^(CDAResponse *response, NSError *error) {
        NSLog(@"Error fetching matching entries because: %@", error);
    }];
}
- (IBAction)addImageToAllContacts:(id)sender {
    [self.space fetchEntriesMatching:@{@"content_type": self.contentType.identifier, @"limit": @10000} success:^(CDAResponse *response, CDAArray *array) {
        [self.space fetchAssetWithIdentifier:@"2D6nhwZlAAeU4MS6WeGyWY" success:^(CDAResponse *response, CMAAsset *asset) {
            NSLog(@"%@", asset.title);
            for (CMAEntry *pe in array.items) {
                [NSThread sleepForTimeInterval:0.5];
                [self.space fetchEntryWithIdentifier:pe.identifier success:^(CDAResponse *response, CDAEntry *entry) {
                    [(CMAEntry*)entry setValue:@[ @{ @"sys": @{ @"type": @"Link", @"linkType": @"Asset", @"id": asset.identifier } } ] forFieldWithName:@"image"];
                    [(CMAEntry*)entry updateWithSuccess:^{
                    } failure:^(CDAResponse *response, NSError *error) {
                        NSLog(@"Error: %@", error);
                    }];
                } failure:^(CDAResponse *response, NSError *error) {
                    NSLog(@"Error: %@", error);
                }];
                
            }
        } failure:^(CDAResponse *response, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
- (IBAction)loadAContactWithAnImage:(id)sender {
    [self.space createEntryOfContentType:self.contentType withFields:@{@"forename": @{@"en-US": [[NSUUID UUID] UUIDString]},@"surname": @{@"en-US": [[NSUUID UUID] UUIDString]},@"title": @{@"en-US": [[NSUUID UUID] UUIDString]},@"telephone": @{@"en-US": [[NSUUID UUID] UUIDString]}, @"email": @{@"en-US": [[NSUUID UUID] UUIDString]}, @"notes": @{@"en-US": [[NSUUID UUID] UUIDString]}} success:^(CDAResponse *response, CMAEntry *entry) {
//        [(CMAEntry*)entry setValue:@[ @{ @"sys": @{ @"type": @"Link", @"linkType": @"Asset", @"id": @"2D6nhwZlAAeU4MS6WeGyWY" } } ] forFieldWithName:@"image"];
        [(CMAEntry*)entry setValue:@{ @"sys": @{ @"type": @"Link", @"linkType": @"Asset", @"id": @"2D6nhwZlAAeU4MS6WeGyWY" } }  forFieldWithName:@"image"];
        [(CMAEntry*)entry updateWithSuccess:^{
            NSLog(@"Successfully created contact %@ with image.", entry);
        } failure:^(CDAResponse *response, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        NSLog(@"%@", entry);
        //            [entry publishWithSuccess:nil failure:nil];
        
    } failure:^(CDAResponse *response, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
- (IBAction)loadContactsOntoContactsPage:(id)sender {
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Building Contacts Page...";
    [HUD showInView:self.view animated:YES];
//    [self.space fetchEntryWithIdentifier:@"5pRc2zsQ7KOcsEseeKmUAg" success:^(CDAResponse *response, CDAEntry *entry) {
    [self.space fetchEntryWithIdentifier:@"jeFQG7FT320eCcMSWwA2" success:^(CDAResponse *response, CDAEntry *entry) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.space fetchEntriesMatching:@{@"content_type": self.contentType.identifier, @"limit": @100, @"include": @(3)} success:^(CDAResponse *response, CDAArray *array) {
                NSMutableArray *uploadArray = [[NSMutableArray alloc] init];
                    for (CMAEntry *ce in array.items) {
                        HUD.textLabel.text = ce.identifier;
                        NSMutableDictionary *subdic  = [NSMutableDictionary dictionary];
                        [subdic setObject:@"Link" forKey:@"type"];
                        [subdic setObject:@"Entry" forKey:@"linkType"];
                        [subdic setObject:ce.identifier forKey:@"id"];
                        
                        
                        NSMutableDictionary *dic  = [NSMutableDictionary dictionary];
                        [dic setObject:subdic forKey:@"sys"];
                        
                        NSLog(@"%@", dic);
                        
                        [uploadArray addObject:dic];

                    }
                [(CMAEntry*)entry setValue:uploadArray forFieldWithName:@"entries"];

                [(CMAEntry*)entry updateWithSuccess:^{
                    NSLog(@"Successfully updated entries with: %@", uploadArray);
//                    [(CMAEntry*)entry publishWithSuccess:nil failure:nil];
                    [(CMAEntry*)entry publishWithSuccess:^{
                        NSLog(@"We did it dude!!!");
                    } failure:^(CDAResponse *response, NSError *error) {
                        NSLog(@"Error: %@", error);
                    }];
                } failure:^(CDAResponse *response, NSError *error) {
                    NSLog(@"Error: %@", error);
                }];

                    [HUD dismissAnimated:YES];
            } failure:^(CDAResponse *response, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
        });
    } failure:^(CDAResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD dismissAnimated:YES];
            NSLog(@"Error: %@", error);
        });
    }];
    }

@end
