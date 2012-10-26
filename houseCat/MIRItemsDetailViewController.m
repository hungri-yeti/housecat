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
   NSLog(@"saveButton, itemDesc: %@", self.itemDesc.text);

   NSManagedObjectContext *context = self.managedObjectContext;
   NSManagedObject *newItem;
   newItem = [NSEntityDescription
                 insertNewObjectForEntityForName:@"Items"
                 inManagedObjectContext:context];
   [newItem setValue:self.itemDesc.text forKey:@"name"];
   [self.parent addItemsObject:newItem];
   
   NSError *error;
   [context save:&error];
   
   [self.navigationController popViewControllerAnimated:YES];
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
   // TODO: if this is an Edit action, this is where I will set the existing values for the fields
   // e.g.:
   // NSLog(@"In viewDidLoad - the title is: %@ and the info is: %@",self.locTitle,self.locInfo);
   // detailTitle.text = locTitle;
   // detailMainText.text = locInfo;

   // This doesn't work here, it needs to be done in the previous view's viewDidLoad.
   // change the back button to read Cancel
   //UIBarButtonItem* btnCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:0 target:nil action:nil];
   //self.navigationItem.backBarButtonItem = btnCancel;
   
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
   activeField = textField;
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