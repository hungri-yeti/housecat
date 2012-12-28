//
//  MIRInfoViewController.m
//  houseCat
//
//  Created by kenl on 12/11/26.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import "MIRInfoViewController.h"

@interface MIRInfoViewController ()

@end

@implementation MIRInfoViewController



-(IBAction)done:(id)sender
{
   [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - handle links

// The info & help files may contain some links to external sites. We don't want those to stay in the app's UIWebView,
// instead they should be opened by the default browser:
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
	if (UIWebViewNavigationTypeLinkClicked == navigationType)
	{
		[[UIApplication sharedApplication] openURL:[request URL]];
		
		DebugLog(@"url: %@", [[request URL] absoluteString]);
	}
	return YES; 
}



#pragma mark - init

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.webView.delegate = self;
	
	// FIXME: this needs to be localized, separate copy of info.html in the app bundle?
	NSURL *url = [[NSBundle mainBundle] URLForResource:@"info" withExtension:@"html"];
	NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
	[self.webView loadRequest:requestURL];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
