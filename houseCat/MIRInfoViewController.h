//
//  MIRInfoViewController.h
//  houseCat
//
//  Created by kenl on 12/11/26.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MIRInfoViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic) IBOutlet UIWebView *webView;

-(IBAction)done:(id)sender;

@end
