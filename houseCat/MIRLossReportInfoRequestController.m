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
   [self dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction)save:(id)sender
{
	// this is where we'll call our delegate:
	[self callDelegate];
}


-(void)updateTextField:(id)sender
{
   NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
   [dateFormatter setDateStyle:NSDateFormatterShortStyle];
	
	UIDatePicker *picker = (UIDatePicker*)self.lossDate.inputView;
	self.lossDate.text = [dateFormatter stringFromDate:picker.date];
}


-(IBAction)userDoneEnteringText:(id)sender
{
   [sender resignFirstResponder];
}


#pragma mark - init

- (void)viewDidLoad
{
   [super viewDidLoad];
   // Do any additional setup after loading the view.

   // setup datepicker:
   UIDatePicker *datePicker = [[UIDatePicker alloc]init];
   datePicker.datePickerMode = UIDatePickerModeDate;
   [datePicker setDate:[NSDate date]];
   [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];       
   [self.lossDate setInputView:datePicker];

   // automatically fill in the date with current:
   NSDate* currentDate = [NSDate date];
   [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
   NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
   [dateFormatter setDateStyle:NSDateFormatterShortStyle];
   [dateFormatter setTimeStyle:NSDateFormatterNoStyle];

   self.lossDate.text = [dateFormatter stringFromDate:currentDate];
}


@end

