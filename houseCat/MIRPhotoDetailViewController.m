//
//  MIRPhotoDetailViewController.m
//  houseCat
//
//  Created by kenl on 12/11/5.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import "MIRPhotoDetailViewController.h"

@interface MIRPhotoDetailViewController ()

@end

@implementation MIRPhotoDetailViewController

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
	
	
	NSString *imgPath = [self.image imagePath];
	UIImage *image = [UIImage imageWithContentsOfFile:imgPath];
	[self.imageView setImage:image];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
