//
//  LoginViewController.m
//  Contentful Management
//
//  Created by Jonathan Jackson on 08/12/2014.
//  Copyright (c) 2014 Jonathan Jackson. All rights reserved.
//

#import <SSKeychain/SSKeychain.h>
#import "LoginViewController.h"
#import "ContentfulManagementAPI/CMAClient.h"
#import "Constants.h"

static NSString* const kContentfulService = @"kContentfulServiceKey";

@interface LoginViewController () <UIWebViewDelegate>

@property (nonatomic) UIWebView* webView;

@end

@implementation LoginViewController
@synthesize OAuthTokenValue = _OAuthTokenValue;

//+(NSString*)oauthToken {
//    return [SSKeychain passwordForService:kContentfulService account:kContentfulService];
//}

-(NSString*)oauthTokenFromURLString:(NSString*)urlString {
    NSArray* components = [urlString componentsSeparatedByString:@"#"];
    
    if (components.count == 2 && [components[1] hasPrefix:@"access_token"]) {
        components = [components[1] componentsSeparatedByString:@"&"];
        if (components.count < 1) {
            return nil;
        }
        
        components = [components[0] componentsSeparatedByString:@"="];
        if (components.count != 2) {
            return nil;
        }
        
        return components[1];
    }
    
    return nil;
}

-(NSURL*)oauthURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://be.contentful.com/oauth/authorize?response_type=token&client_id=%@&redirect_uri=https://www.contentful.com&scope=content_management_manage", ContentfulAppClientId]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Login", nil);
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[self oauthURL]]];
    [self.view addSubview:self.webView];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.webView.scrollView setContentOffset:CGPointMake(140.0, 10.0) animated:YES];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString* urlString = request.URL.absoluteString;
    
    if ([urlString hasPrefix:@"https://www.contentful.com"]) {
        NSString* token = [self oauthTokenFromURLString:urlString];
        
        if (!token) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Login failed.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            
            return NO;
        }
        
        //[SSKeychain setPassword:token forService:kContentfulService account:kContentfulService];
        //[self dismissViewControllerAnimated:YES completion:nil];
        _OAuthTokenValue = token;
        [self.webView removeFromSuperview];
        return YES;
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
