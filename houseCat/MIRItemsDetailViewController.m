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
   NSDate *purchaseDate;
}

@end

@implementation MIRItemsDetailViewController


// This is used in a couple of different places, edit here to change globally (file scope)
NSDateFormatterStyle kDateFormatStyle = NSDateFormatterShortStyle;



#pragma mark - picker field updates

-(void)updatePurchaseDateField:(id)sender
{
   NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
   [dateFormatter setDateStyle:kDateFormatStyle];
   
   // update the textfield:
   UIDatePicker *picker = (UIDatePicker*)self.itemPurchaseDate.inputView;
   self.itemPurchaseDate.text = [dateFormatter stringFromDate:picker.date];
   // set this here, it won't be set in saveButton:
   // this won't work for a new Item becuase we wont have an item obj yet.
   //[self.item setValue:picker.date forKey:@"purchaseDate"];
   purchaseDate = picker.date;
}


-(void)setupPurchaseDateField:(id)sender
{
   NSLog(@"setupPurchaseDateField");
   
   //   Get the size of the keyboard.
   //   Adjust the bottom content inset of your scroll view by the keyboard height.
   //   Scroll the target text field into view.
   
   UIBarButtonItem* btnDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:0 target:nil action:@selector(doneButtonPressed:)];
   self.navigationItem.rightBarButtonItem = btnDone;
}



#pragma mark - buttons
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
   
   // this is actually set in updatePurchaseDateField
   //[self.item setValue:self.itemPurchaseDate forKey:@"purchaseDate"];
   [self.item setValue:purchaseDate forKey:@"purchaseDate"];

   // this works only if they use the currency symbol at the begining of the number,
   // so we need to check for it and, if necessary, add it in textFieldShouldEndEditing
   NSNumberFormatter *costFmt = [[NSNumberFormatter alloc] init];
   [costFmt setNumberStyle:NSNumberFormatterCurrencyStyle];
   NSNumber *costNum=[NSNumber numberWithFloat:[[costFmt numberFromString:self.itemCost.text] floatValue]];
   [self.item setValue:costNum forKey:@"cost"];
   
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
   [self.itemPurchaseDate resignFirstResponder];
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
   [self.navigationController setToolbarHidden:YES];
   
   // setup date picker:
   UIDatePicker *datePicker = [[UIDatePicker alloc]init];
   datePicker.datePickerMode = UIDatePickerModeDate;
   
   if( NULL == self.item.purchaseDate )
   {
      // new item:
      [datePicker setDate:[NSDate date]];
   }
   else
   {
      [datePicker setDate:self.item.purchaseDate];
   }
   [datePicker addTarget:self action:@selector(updatePurchaseDateField:) forControlEvents:UIControlEventValueChanged];
   [self.itemPurchaseDate addTarget:self action:@selector(setupPurchaseDateField:) forControlEvents:UIControlEventEditingDidBegin];
   
   [self.itemPurchaseDate setInputView:datePicker];

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
      
      [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateStyle:kDateFormatStyle];
      [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
      self.itemPurchaseDate.text = [dateFormatter stringFromDate:self.item.purchaseDate];
      
      NSString *numberStr = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:[self.item.cost floatValue]]
                                                             numberStyle:NSNumberFormatterCurrencyStyle];
      self.itemCost.text = numberStr;
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
   NSLog(@"textFieldShouldEndEditing, textField: %@", textField.text );
   
   if( self.itemCost == textField)
   {
      // There may or may not be a currency symbol included in the string.
      // If not, add it:
      if( [textField.text floatValue] != 0.0 )  // TODO: is there any better way to determine if the string starts with any arbitrary currency symbol?
      {
         NSString *numberStr = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:[textField.text floatValue]]
                                                                numberStyle:NSNumberFormatterCurrencyStyle];
         self.itemCost.text = numberStr;
      }
   }
   
   // activate the Save button:
   self.navigationItem.rightBarButtonItem.enabled = YES;
   
   [textField resignFirstResponder];
   return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
   NSLog(@"textFieldDidBeginEditing");
   
   activeField = textField;
}


-(void)textFieldDidEndEditing:(UITextField *)textField
{
   NSLog(@"textFieldDidEndEditing");
   
   activeField = nil;

   // change the Done button to Save:
   UIBarButtonItem* btnSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:0 target:self action:@selector(saveButton:)];
   self.navigationItem.rightBarButtonItem = btnSave;
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
   NSLog(@"keyboardWasShown");
   
   float kToolBarHeight = 44;
   
   NSDictionary* info = [aNotification userInfo];
   CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
   
   //NSLog(@"kbSize.height: %f", kbSize.height);
   
   
   UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
   self.scrollView.contentInset = contentInsets;
   self.scrollView.scrollIndicatorInsets = contentInsets;
   
   // If active text field is hidden by keyboard, scroll it so it's visible
   // Your application might not need or want this behavior.
   CGRect aRect = self.view.frame;
   
   //NSLog(@"aRect.size.height: %f", aRect.size.height );
   
   aRect.size.height -= kbSize.height;
   CGPoint origin = activeField.frame.origin;
   
   //NSLog(@"origin.y: %f, activeField.frame.size.height: %f", origin.y, activeField.frame.size.height );
   
   origin.y += activeField.frame.size.height;
   if (!CGRectContainsPoint(aRect, origin) )
   {
      //NSLog(@"!CGRectContainsPoint");
      
      CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-(aRect.size.height) + kToolBarHeight);
      [self.scrollView setContentOffset:scrollPoint animated:YES];
   }
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
   NSLog(@"keyboardWillBeHidden");
   
   UIEdgeInsets contentInsets = UIEdgeInsetsZero;
   self.scrollView.contentInset = contentInsets;
   self.scrollView.scrollIndicatorInsets = contentInsets;
}



@end
