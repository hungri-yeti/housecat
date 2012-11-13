//
//  MIRLossComposeMsgViewController.m
//  houseCat
//
//  Created by kenl on 12/11/10.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import "MIRLossComposeMsgViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface MIRLossComposeMsgViewController () <ABPeoplePickerNavigationControllerDelegate>

@end

@implementation MIRLossComposeMsgViewController

NSMutableArray* addressArray;


#pragma mark - addressbook delegate

- (IBAction)getToAddressee:(id)sender
{
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	picker.peoplePickerDelegate = self;
	
	[self presentViewController:picker animated:YES completion:nil];
}


- (void)peoplePickerNavigationControllerDidCancel: (ABPeoplePickerNavigationController *)peoplePicker
{
	[self dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
//	NSString* email = nil;
//	ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonEmailProperty);
//	NSLog(@"count: %li", ABMultiValueGetCount(multi) );
//	
//	if( ABMultiValueGetCount(multi) > 0 )
//	{
//		email = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(multi, 0);
//
//		[addressArray addObject:email];
//		NSLog(@"email: %@", email );
//		
//		
//		// there may be other addressees in the array, pretty-print to the text field:
//		self.toAddressee.text = NULL;
//		NSMutableString* emailAddress = [[NSMutableString alloc] init];
//		
//		for(NSString *address in addressArray)
//		{
//			NSLog(@"   address: %@", address );
//			
//			[emailAddress appendString:address];
//			[emailAddress appendString:@", "];
//		}
//		NSLog(@"emailAddress: %@", emailAddress);
//		
//		// the last entry will always have an extraneous trailing comma-space, trim it off:
//		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@", \\z" 
//																									  options:NSRegularExpressionCaseInsensitive 
//																										 error:nil];
//		NSString *addressesFormatted = [regex stringByReplacingMatchesInString:emailAddress 
//																							options:0 
//																							  range:NSMakeRange(0, [emailAddress length])
//																					 withTemplate:@""];
//		self.toAddressee.text = addressesFormatted; 
//	}
//	else
//	{
//		// Apparently we can not push an alert when the peoplepicker is on top:
//		//UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No email"
//		//																message:@"That contact does not have an email address."
//		//															  delegate:self cancelButtonTitle:@"OK"
//		//												  otherButtonTitles:nil, nil];
//      //[alert show];
//		
//		// for now, do nothing
//	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
	return NO;
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
		shouldContinueAfterSelectingPerson:(ABRecordRef)person 
										  property:(ABPropertyID)property 
										identifier:(ABMultiValueIdentifier)identifier
{
	return NO;
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
	addressArray = [[NSMutableArray alloc] init];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
