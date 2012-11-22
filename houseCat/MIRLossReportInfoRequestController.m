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


-(void)callDelegate
{
	// delegate is responsible for not freaking out if policyNumber and/or lossDate are empty:
	NSArray* results = [NSArray arrayWithObjects:self.policyNumber.text, self.lossDate.text, nil];
	[self.delegate readLossInfo:results];
}


#pragma mark - Actions
-(IBAction)cancel:(id)sender
{
	// FIXME: the actionsheet still appears when tapping on Cancel
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


-(void)updateTextField:(id)sender
{
	
   NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
   [dateFormatter setDateStyle:NSDateFormatterShortStyle];
	
	UIDatePicker *picker = (UIDatePicker*)self.lossDate.inputView;
	//	self.lossDate.text = [NSString stringWithFormat:@"%@",picker.date];
	self.lossDate.text = [dateFormatter stringFromDate:picker.date];
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

	
	UIDatePicker *datePicker = [[UIDatePicker alloc]init];
	datePicker.datePickerMode = UIDatePickerModeDate;
	[datePicker setDate:[NSDate date]];
	[datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];       
	[self.lossDate setInputView:datePicker];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

