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
	
	NSString *placeHolderText;

	CGSize kbSize;
	BOOL kbVisible;
}
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

@end



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
	NSString *thumbPath = [self.item thumbPath];
	UIImage *thumbImage = nil;
	
	if( nil != thumbPath )
	{
		thumbImage = [UIImage imageWithContentsOfFile:thumbPath];
		if( nil == thumbImage )
		{
			// thumbPath is set but there is no corresponding img file. Shouldn't this be an error?
			[self.photoButton setTitle:NSLocalizedString(@"Click to set photo", @"Click to set photo") forState:(UIControlStateNormal && UIControlStateHighlighted)];			
		}
	}
	else
	{
		[self.photoButton setTitle:NSLocalizedString(@"Click to set photo", @"Click to set photo") forState:(UIControlStateNormal && UIControlStateHighlighted)];
	}
	[self.photoButton setImage:thumbImage forState:(UIControlStateNormal && UIControlStateHighlighted)];
}


- (void)viewDidLoad
{
   [super viewDidLoad];
   // Do any additional setup after loading the view.
   [self.navigationController setToolbarHidden:YES];
	placeHolderText = NSLocalizedString(@"(enter notes here)", @"Item notes placeholder");
   
   // setup date picker:
   UIDatePicker *datePicker = [[UIDatePicker alloc]init];
   datePicker.datePickerMode = UIDatePickerModeDate;
	NSDate* currentDate = [NSDate date];
	
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
			NSLog(@"ERROR: viewDidLoad:[self.managedObjectContext] failed: %@", [error localizedDescription]);
         // Notify the user
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                         message:[error localizedFailureReason]
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK",@"Alert 'OK' (Cancel) button.")
                                               otherButtonTitles:nil];
         [alert show];
		}
      // this is a new item so date isn't set yet:
      [datePicker setDate:currentDate];
      
      // DRY: there's some duplication here and in the following else clause but
		// I don't think there's anything I can do about it due to the pre- and post-
		// requisites being different
		// -
      [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateStyle:kDateFormatStyle];
      [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		// -
      self.item.purchaseDate = currentDate;
      self.itemPurchaseDate.text = [dateFormatter stringFromDate:currentDate];
      purchaseDate = currentDate;
		
		self.itemNotes.text = placeHolderText;
      self.itemNotes.textColor = [UIColor lightGrayColor];
   }
   else
   {
		self.itemName.text = self.item.name;
      
		// date may or may not have been set:
		if( nil == self.item.purchaseDate )
		{
			[datePicker setDate:currentDate];
			purchaseDate = currentDate;
		}
		else
		{
			[datePicker setDate:self.item.purchaseDate];
			purchaseDate = self.item.purchaseDate;
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

   [self.itemPurchaseDate setInputView:datePicker];   
   [self registerForKeyboardNotifications];
	
	// This seems like the 'right' thing to do but it looks odd when implemented:
	//[self.itemName becomeFirstResponder];
	
	// setup keyboard:
	NSArray *fields = @[ self.itemName,
                        self.itemPurchaseDate,
                        self.itemCost,
								self.itemSerialNumber, 
                        self.itemNotes];
	
	[self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
	[self.keyboardControls setDelegate:self];
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


- (void)viewWillDisappear:(BOOL)animated
{
	// If the user is currently editing a text field/vew and taps the Items nav button,
	// the parent's viewWillAppear (which is where I refresh the table) is called before textFieldDidEndEditing.
	// This means that the edits are saved after the parent table is refreshed, resulting in an
	// incorrect view.
	// Force endEditing here which makes sure that textFieldDidEndEditing is called prior to table refresh.
	[self.view endEditing:YES];
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
	NSComparisonResult ncr = [textView.text localizedCompare:placeHolderText];
   if( NSOrderedSame == ncr )
   {
      textView.text = nil;
		textView.textColor = [UIColor blackColor];
   }
	return YES;
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
   
   NSError *error;
   if (![self.managedObjectContext save:&error])
   {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog(@"ERROR: textViewDidEndEditing: [self.managedObjectContext save] failed: %@", [error localizedDescription]);
      // Notify the user
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                      message:[error localizedFailureReason]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK",@"Alert 'OK' (Cancel) button.")
                                            otherButtonTitles:nil];
      [alert show];
   }
	activeField = nil;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
   activeField = textField;
   [self.keyboardControls setActiveField:textField];
   [self scrollToField];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   [textField resignFirstResponder];
   return NO;
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	NSLocale* currentUserLocale = [NSLocale currentLocale];
	
   if( self.itemCost == textField)
   {
		// If the user just typed the number in, e.g. 12.34 or 42, prepend the currency symbol:
		NSString *currencySymbol = [currentUserLocale objectForKey:NSLocaleCurrencySymbol];
		
		NSRange strRange = [textField.text rangeOfString:currencySymbol];
		if (strRange.location == NSNotFound)
		{
			NSString *numberStr = [NSNumberFormatter localizedStringFromNumber:[NSDecimalNumber numberWithFloat:[textField.text floatValue]]
																					 numberStyle:NSNumberFormatterCurrencyStyle];
			textField.text = numberStr;
		}
		else
		{
			// contains a currency symbol, but we don't know if it's in the form $xx.nn or just $xx.
			// If it's $xx, we want to change it to $xx.00:
			NSString *decimalSeparator = [currentUserLocale objectForKey:NSLocaleDecimalSeparator];			
			NSRange resultsRange = [textField.text rangeOfString:decimalSeparator
																		options:NSCaseInsensitiveSearch];
			if(resultsRange.location == NSNotFound)
			{
				// number is in form $XX, change it to $XX.00:
				NSNumberFormatter *costFmt = [[NSNumberFormatter alloc] init];
				[costFmt setNumberStyle:NSNumberFormatterCurrencyStyle];
				
				NSNumber* floatNum = [costFmt numberFromString:textField.text];
				NSNumber *costNum=[NSNumber numberWithFloat:[floatNum floatValue]];
				NSString* costStr = [costFmt stringFromNumber:costNum];
				
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
      NSLog(@"ERROR: textFieldDidEndEditing:[self.managedObjectContext save] failed: %@", [error localizedDescription]);
      // Notify the user
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                      message:[error localizedFailureReason]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK",@"Alert 'OK' (Cancel) button.")
                                            otherButtonTitles:nil];
      [alert show];
   }
	activeField = nil;
}



#pragma mark - View scrolling
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
   NSDictionary* info = [aNotification userInfo];
   kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;	
   kbVisible = TRUE;
   [self scrollToField];
	
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
   UIEdgeInsets contentInsets = UIEdgeInsetsZero;
   self.scrollView.contentInset = contentInsets;
   self.scrollView.scrollIndicatorInsets = contentInsets;
	
   kbVisible = FALSE;
   
   // scroll to the top of the view:
   CGPoint scrollPoint = CGPointMake(0.0, 0.0);
   [self.scrollView setContentOffset:scrollPoint animated:YES];

}



#pragma mark -
#pragma mark Text View Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	activeField = textView;
	[self.keyboardControls setActiveField:textView];
	[self scrollToField];
}



#pragma mark -
#pragma mark Keyboard Controls Delegate

- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
//	UIView *view = keyboardControls.activeField.superview.superview;
//	[self.tableView scrollRectToVisible:view.frame animated:YES];
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
	[keyboardControls.activeField resignFirstResponder];
}


#pragma mark - scrolling
-(void)scrollToField
{
	if(!kbVisible)
		return;
	
	float kToolBarHeight = 44;
   
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



@end
