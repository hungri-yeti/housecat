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



#pragma mark - addressbook delegate

- (IBAction)getToAddressee:(id)sender
{
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	picker.peoplePickerDelegate = self;
	[self presentViewController:picker animated:YES completion:nil];
}


- (IBAction)getFromAddressee:(id)sender
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
	//NSString* name = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
	//self.firstName.text = name;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
