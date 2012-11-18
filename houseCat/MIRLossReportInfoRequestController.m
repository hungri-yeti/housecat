//
//  MIRLossReportInfoRequestController.m
//  houseCat
//
//  Created by kenl on 12/11/12.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import "MIRLossReportInfoRequestController.h"

@interface MIRLossReportInfoRequestController ()

@end

@implementation MIRLossReportInfoRequestController


// TODO: need to implement keyboard actions, date picker

-(void)callDelegate
{
	// delegate is responsible for not freaking out if policyNumber and/or lossDate are empty:
	NSArray* results = [NSArray arrayWithObjects:self.policyNumber.text, self.lossDate.text, nil];
	[self.delegate readLossInfo:results];
}


#pragma mark - Actions
-(IBAction)cancel:(id)sender
{
	[self callDelegate];
   //[self dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction)save:(id)sender
{
	// this is where we'll call our delegate:
	[self callDelegate];
	
	// the delegate will handle this:
   //[self dismissViewControllerAnimated:YES completion:nil];
}





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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
