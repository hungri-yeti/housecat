//
//  MIRPDFPreviewViewController.m
//  houseCat
//
//  Created by kenl on 12/11/12.
//  Copyright (c) 2012 kl. All rights reserved.
//
// ----------------------------------------------------------------------------------------------------------------
# pragma mark -
# pragma mark I decided to go straight to an activity view instead of previewing the PDF, so this will go away.
# pragma mark -
// ----------------------------------------------------------------------------------------------------------------

#import "MIRPDFPreviewViewController.h"

@interface MIRPDFPreviewViewController ()

@end

@implementation MIRPDFPreviewViewController


#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	NSString *filePath = [[NSBundle mainBundle]
								 pathForResource:@"filenameWithoutExtension" 
								 ofType:@"svg"];
	NSData *svgData = [NSData dataWithContentsOfFile:filePath];
	NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
	NSURL *baseURL = [[NSURL alloc] initFileURLWithPath:resourcePath isDirectory:YES];
	
	[self.webView 	loadData:svgData 
						MIMEType:@"image/svg+xml"	
			 textEncodingName:@"UTF-8" 
						 baseURL:baseURL];	
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
