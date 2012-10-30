//
//  MIRItemsDetailViewController.m
//  houseCat
//
//  Created by kenl on 12/10/23.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import "MIRItemsDetailViewController.h"

@interface MIRItemsDetailViewController ()
{
   // used when scrolling above kb:
   UIView *activeField;
}

@end

@implementation MIRItemsDetailViewController



- (IBAction)saveButton:(id)sender
{
   NSLog(@"saveButton, itemName.text: %@", self.itemName.text);

   NSManagedObjectContext *context = self.managedObjectContext;
   
   // this will be the case for a new item being added:
   if( nil == self.item )
   {
      NSLog(@"saveButton: self.item == nil");
      
      Items *item = (Items *)[NSEntityDescription
                              insertNewObjectForEntityForName:@"Items"
                              inManagedObjectContext:self.managedObjectContext];
      self.item = item;
      [self.parent addItemsObject:item];
   }
   
   // set attributes from view:
   [self.item setValue:self.itemName.text forKey:@"name"];
   [self.item setValue:self.itemSerialNumber.text forKey:@"serialNumber"];
   [self.item setValue:self.itemNotes.text forKey:@"notes"];


   NSError *error;
   [context save:&error];
   
   [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)doneButtonPressed:(id)sender
{
   NSLog(@"doneButtonPressed");
   
   [self.itemNotes resignFirstResponder];
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

   // This doesn't work here, it needs to be done in the previous view's viewDidLoad?
   // It looks like this needs to be done _before_ pushViewController: is called
   // (which will be done in the parent view controller)
   // change the back button to read Cancel
   //UIBarButtonItem* btnCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:0 target:nil action:nil];
   //self.navigationItem.backBarButtonItem = btnCancel;
   if( self.item == nil )
   {
      // TODO: is anything necessary here, or change the comparison operator?
   }
   else
   {
      self.itemName.text = self.item.name;
      self.itemSerialNumber.text = self.item.serialNumber;
      self.itemNotes.text = self.item.notes;
   }
   
   [self registerForKeyboardNotifications];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// This is required for scrolling the view when kb appears:
- (void)registerForKeyboardNotifications
{
   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(keyboardWasShown:)
                                                name:UIKeyboardDidShowNotification object:nil];
   
   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(keyboardWillBeHidden:)
                                                name:UIKeyboardWillHideNotification object:nil];
}



#pragma mark - Edit actions

- (void)textViewDidBeginEditing:(UITextView *)textView
{
   NSLog(@"textViewDidBeginEditing");
   
   // TODO: this comparison will cause a problem when localized:
   // will probably need to use localizedCompare:.
   // remove the placeholder text:
   if( [textView.text isEqualToString:@"(enter notes here)"] )
   {
      textView.text = nil;
   }
   // change the Save button to Done:
   UIBarButtonItem* btnDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:0 target:nil action:@selector(doneButtonPressed:)];
   self.navigationItem.rightBarButtonItem = btnDone;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
   NSLog(@"textViewShouldEndEditing");
   
   [textView resignFirstResponder];
   return YES;
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
   NSLog(@"textViewDidEndEditing");
   
   // change the Done button to Save:
   UIBarButtonItem* btnSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:0 target:self action:@selector(saveButton:)];
   self.navigationItem.rightBarButtonItem = btnSave;
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
   NSLog(@"textFieldShouldEndEditing, textField: %@", textField.text);
   
   // activate the Save button:
   self.navigationItem.rightBarButtonItem.enabled = YES;
   
   [textField resignFirstResponder];
   return YES;
}


-(void)textFieldDidEndEditing:(UITextField *)textField
{
   activeField = nil;
   NSLog(@"textFieldDidEndEditing");
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   NSLog(@"textFieldShouldReturn");
   
   [textField resignFirstResponder];
   return NO;
}



#pragma mark - View scrolling
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
   float kToolBarHeight = 44;
   NSDictionary* info = [aNotification userInfo];
   CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
   
   UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
   self.scrollView.contentInset = contentInsets;
   self.scrollView.scrollIndicatorInsets = contentInsets;
   
   // If active text field is hidden by keyboard, scroll it so it's visible
   // Your application might not need or want this behavior.
   CGRect aRect = self.view.frame;
   aRect.size.height -= kbSize.height;
   CGPoint origin = activeField.frame.origin;
   origin.y += activeField.frame.size.height;
   if (!CGRectContainsPoint(aRect, origin) )
   {
      CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-(aRect.size.height) + kToolBarHeight);
      [self.scrollView setContentOffset:scrollPoint animated:YES];
   }
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
   UIEdgeInsets contentInsets = UIEdgeInsetsZero;
   self.scrollView.contentInset = contentInsets;
   self.scrollView.scrollIndicatorInsets = contentInsets;
}



@end
