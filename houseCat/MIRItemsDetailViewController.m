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

NSString *const PlaceHolderText = @"(enter notes here)";

@implementation MIRItemsDetailViewController
// TODO: need to implement serial number scanner
// this will be a button next to the serial number field that will take a picture
// using the camera and then OCR the serial.


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
   purchaseDate = picker.date;
}


-(void)setupKeyboardDoneButton:(id)sender
{
   UIBarButtonItem* btnDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
																					style:0 
																				  target:nil 
																				  action:@selector(doneButtonPressed:)];
   self.navigationItem.rightBarButtonItem = btnDone;
}



#pragma mark - buttons

- (IBAction)doneButtonPressed:(id)sender
{
	[self.itemName resignFirstResponder];
   [self.itemPurchaseDate resignFirstResponder];
	[self.itemCost resignFirstResponder];
	[self.itemSerialNumber resignFirstResponder];
   [self.itemNotes resignFirstResponder];
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


- (void)viewWillAppear:(BOOL)animated
{
	// take care of the button's thumbnail image here instead of viewDidLoad
	// as we might be returning from a newly selected photo via MIRPhotosViewController
	NSString *imgPath = [self.item thumbPath];
	UIImage *image = nil;
	
	if( nil != imgPath )
	{
		image = [UIImage imageWithContentsOfFile:imgPath];
		if( nil == image )
		{
			[self.photoButton setTitle:@"Click to set photo" forState:(UIControlStateNormal && UIControlStateHighlighted)];			
		}
	}
	else
	{
		image = nil;
		[self.photoButton setTitle:@"Click to set photo" forState:(UIControlStateNormal && UIControlStateHighlighted)];
	}
	[self.photoButton setImage:image forState:(UIControlStateNormal && UIControlStateHighlighted)];
}


- (void)viewDidLoad
{
   [super viewDidLoad];
   // Do any additional setup after loading the view.
   [self.navigationController setToolbarHidden:YES];
   
   // setup date picker:
   UIDatePicker *datePicker = [[UIDatePicker alloc]init];
   datePicker.datePickerMode = UIDatePickerModeDate;
	
   if( self.item == nil )
   {
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
		
		self.itemNotes.text = PlaceHolderText;
      self.itemNotes.textColor = [UIColor lightGrayColor];
   }
   else
   {
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

	[self.itemName addTarget:self action:@selector(setupKeyboardDoneButton:) forControlEvents:UIControlEventEditingDidBegin];
   [self.itemPurchaseDate addTarget:self action:@selector(setupKeyboardDoneButton:) forControlEvents:UIControlEventEditingDidBegin];
   [self.itemCost addTarget:self action:@selector(setupKeyboardDoneButton:) forControlEvents:UIControlEventEditingDidBegin];
   [self.itemSerialNumber addTarget:self action:@selector(setupKeyboardDoneButton:) forControlEvents:UIControlEventEditingDidBegin];
   
   [self.itemPurchaseDate setInputView:datePicker];
   
   [self registerForKeyboardNotifications];
	
	// This seems like the 'right' thing to do but it looks odd when implemented:
	//[self.itemName becomeFirstResponder];
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


- (void)viewDidUnload
{
	[super viewDidUnload];

	[[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma mark - Edit actions

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
	// remove placeholder text:
	NSComparisonResult ncr = [textView.text localizedCompare:PlaceHolderText];
   if( NSOrderedSame == ncr )
   {
      textView.text = nil;
		textView.textColor = [UIColor blackColor];
   }
	return YES;
}


- (void)textViewDidBeginEditing:(UITextView *)textView
{
   UIBarButtonItem* btnDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
																					style:0 
																				  target:nil 
																				  action:@selector(doneButtonPressed:)];
   self.navigationItem.rightBarButtonItem = btnDone;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
   [textView resignFirstResponder];
   return YES;
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
	if( self.itemNotes == textView )
	{
		[self.item setValue:self.itemNotes.text forKey:@"notes"];
	}
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
   activeField = textField;
	
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   [textField resignFirstResponder];
   return NO;
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
   if( self.itemCost == textField)
   {
		// If the user just typed the number in, e.g. 12.34 or 42, prepend the currency symbol:
		BOOL hasCurrencyPrefix = [textField.text hasPrefix:@"$"];
		if( !hasCurrencyPrefix )
		{
			NSString *numberStr = [NSNumberFormatter localizedStringFromNumber:[NSDecimalNumber numberWithFloat:[textField.text floatValue]]
																					 numberStyle:NSNumberFormatterCurrencyStyle];
			self.itemCost.text = numberStr;
			textField.text = numberStr;
		}
		else
		{
			// begins with a currency symbol, but we don't know if it's in the form $xx.nn or just $xx.
			// If it's $xx, we want to change it to $xx.00:
			NSRange rangeToSearch = [textField.text rangeOfString:textField.text];
			// TODO: rangeOfString needs to be localized (decimal separator)
			NSRange resultsRange = [textField.text rangeOfString:@"."
																		options:NSCaseInsensitiveSearch
																		  range:rangeToSearch];
			if(resultsRange.location == NSNotFound)
			{
				// number is in form $XX, change it to $XX.00:
				NSNumberFormatter *costFmt = [[NSNumberFormatter alloc] init];
				[costFmt setNumberStyle:NSNumberFormatterCurrencyStyle];
				NSNumber *costNum=[NSNumber numberWithFloat:[[costFmt numberFromString:textField.text] floatValue]];
				
				// TODO: stringWithFormat needs to be localized (currency char):
				NSString* costStr = [NSString stringWithFormat:@"%@%@.00", @"$", costNum];
				textField.text = costStr;
			}
		}
	}
	
   [textField resignFirstResponder];
   return YES;
}


-(void)textFieldDidEndEditing:(UITextField *)textField
{
	if( self.itemName == textField )
	{
		[self.item setValue:self.itemName.text forKey:@"name"];
	}
	else if( self.itemPurchaseDate == textField )
	{
		[self.item setValue:purchaseDate forKey:@"purchaseDate"];
	}
	else if( self.itemCost == textField )
	{
		// this works only if they use the currency symbol at the begining of the number,
		// so we need to check for it and, if necessary, add it in textFieldShouldEndEditing
		NSNumberFormatter *costFmt = [[NSNumberFormatter alloc] init];
		[costFmt setNumberStyle:NSNumberFormatterCurrencyStyle];
		NSNumber *costNum=[NSNumber numberWithFloat:[[costFmt numberFromString:self.itemCost.text] floatValue]];
		[self.item setValue:costNum forKey:@"cost"];
	}
	else if( self.itemSerialNumber == textField )
	{
		[self.item setValue:self.itemSerialNumber.text forKey:@"serialNumber"];
	}

   NSError *error;
   if (![self.managedObjectContext save:&error])
   {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog(@"MIRItemsDetailViewController:saveButton: unresolved error %@, %@", error, [error userInfo]);
   }
	activeField = nil;
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
	
	// remove the Done button:
   self.navigationItem.rightBarButtonItem = nil;	
}



@end
