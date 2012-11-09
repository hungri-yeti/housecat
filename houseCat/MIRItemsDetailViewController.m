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
bool newItem;



#pragma mark - picker field updates

-(void)updatePurchaseDateField:(id)sender
{
   NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
   [dateFormatter setDateStyle:kDateFormatStyle];
   
   // update the textfield:
   UIDatePicker *picker = (UIDatePicker*)self.itemPurchaseDate.inputView;
   self.itemPurchaseDate.text = [dateFormatter stringFromDate:picker.date];
   purchaseDate = picker.date;
}


-(void)setupPurchaseDateField:(id)sender
{
   UIBarButtonItem* btnDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:0 target:nil action:@selector(doneButtonPressed:)];
   self.navigationItem.rightBarButtonItem = btnDone;
}



#pragma mark - buttons
- (void)cancelButton:(id)sender
{
	NSLog(@"cancelButton:");
	
	if( newItem )
	{ 
		NSLog(@"   newItem");
		
		[self.parent removeItemsObject:self.item];
		[self.managedObjectContext deleteObject:self.item];
		NSError *error;
		if (![self.managedObjectContext save:&error])
		{
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			NSLog(@"MIRItemsDetailViewController:cancelButton: unresolved error %@, %@", error, [error userInfo]);
		}
	}
   [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)saveButton:(id)sender
{
   //NSLog(@"saveButton, itemName.text: %@", self.itemName.text);

   // set attributes from view:
   [self.item setValue:self.itemName.text forKey:@"name"];
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
   if (![self.managedObjectContext save:&error])
   {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog(@"MIRItemsDetailViewController:saveButton: unresolved error %@, %@", error, [error userInfo]);
   }
   
   [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)doneButtonPressed:(id)sender
{
   [self.itemNotes resignFirstResponder];
   [self.itemPurchaseDate resignFirstResponder];
}



#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   // pass the moc & parent obj to the child view:
   MIRItemsDetailViewController *vc = [segue destinationViewController];
   vc.managedObjectContext = self.managedObjectContext;
   vc.item = self.item;
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

   self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                             target:self 
                                                                           action:@selector(cancelButton:)];

   if( self.item == nil )
   {
      //NSLog(@"viewDidLoad: self.item == nil");
		
		newItem = YES;
		
		// create new empty Item and store it:
      Items *item = (Items *)[NSEntityDescription
                              insertNewObjectForEntityForName:@"Items"
                              inManagedObjectContext:self.managedObjectContext];
      self.item = item;
		[self.parent addItemsObject:self.item];
		NSError *error;
		if (![self.managedObjectContext save:&error])
		{
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			NSLog(@"MIRItemsDetailViewController:viewDidLoad: unresolved error %@, %@", error, [error userInfo]);
		}
      // this is a new item so date isn't set yet:
      [datePicker setDate:[NSDate date]];
      
      // DRY: there's some duplication here and in the following else clause but
		// I don't think there's anything I can do about it due to the pre- and post-
		// requisites being different
		// -
      [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateStyle:kDateFormatStyle];
      [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		// -
      self.itemPurchaseDate.text = [dateFormatter stringFromDate:[NSDate date]];
      purchaseDate = [NSDate date];
   }
   else
   {
		newItem = NO;
		
      //NSLog(@"viewDidLoad: self.item != nil");
		// TODO: need to figure out which Image will be used for the thumbnail
		// (if sort order is implemented it should the first img)
      self.itemName.text = self.item.name;
      
		// date may or may not have been set:
		if( nil == self.item.purchaseDate )
		{
			[datePicker setDate:[NSDate date]];			
		}
		else
		{
			[datePicker setDate:self.item.purchaseDate];
		}
		
		// -
      [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateStyle:kDateFormatStyle];
      [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		// -
		
      self.itemPurchaseDate.text = [dateFormatter stringFromDate:self.item.purchaseDate];
      
      NSString *numberStr = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:[self.item.cost floatValue]]
                                                             numberStyle:NSNumberFormatterCurrencyStyle];
      self.itemCost.text = numberStr;
      self.itemSerialNumber.text = self.item.serialNumber;
      self.itemNotes.text = self.item.notes;
   }

   [datePicker addTarget:self action:@selector(updatePurchaseDateField:) forControlEvents:UIControlEventValueChanged];
   [self.itemPurchaseDate addTarget:self action:@selector(setupPurchaseDateField:) forControlEvents:UIControlEventEditingDidBegin];
   
   [self.itemPurchaseDate setInputView:datePicker];

   
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
   //NSLog(@"textViewDidBeginEditing");
   
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
   //NSLog(@"textViewShouldEndEditing");
   
   [textView resignFirstResponder];
   return YES;
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
   //NSLog(@"textViewDidEndEditing");
   
   // change the Done button to Save:
   UIBarButtonItem* btnSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:0 target:self action:@selector(saveButton:)];
   self.navigationItem.rightBarButtonItem = btnSave;
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
   //NSLog(@"textFieldShouldEndEditing, textField: %@", textField.text );
   
   if( self.itemCost == textField)
   {
      // There may or may not be a currency symbol included in the string.
      // If not, add it:
      if( [textField.text floatValue] != 0.0 )
      {	// TODO: use NSScanner for localized scan instead of the above comparison
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
   //NSLog(@"textFieldDidBeginEditing");
   
   activeField = textField;
}


-(void)textFieldDidEndEditing:(UITextField *)textField
{
   //NSLog(@"textFieldDidEndEditing");
   
   activeField = nil;

   // change the Done button to Save:
   UIBarButtonItem* btnSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:0 target:self action:@selector(saveButton:)];
   self.navigationItem.rightBarButtonItem = btnSave;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   //NSLog(@"textFieldShouldReturn");
   
   [textField resignFirstResponder];
   return NO;
}



#pragma mark - View scrolling
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
   //NSLog(@"keyboardWasShown");
   
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
   //NSLog(@"keyboardWillBeHidden");
   
   UIEdgeInsets contentInsets = UIEdgeInsetsZero;
   self.scrollView.contentInset = contentInsets;
   self.scrollView.scrollIndicatorInsets = contentInsets;
}



@end
