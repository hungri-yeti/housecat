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
	// TODO: double-check that this still works; I think it null-ed out the date when I was fiddling with
	//	something else, but I'm not sure.
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
   
	newItem = NO;	// otherwise this new Item will be deleted in viewWillDisappear
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


- (void)viewWillAppear:(BOOL)animated
{
	// take care of the button's thumbnail image here instead of viewDidLoad
	// as we might be returning from a newly selected photo via MIRPhotosViewController
	NSString *imgPath = [self.item thumbPath];
	UIImage *image = nil;
	
	//NSLog(@"viewWillAppear: imgPath: %@", imgPath );
	
	if( nil != imgPath )
	{
		// TODO: what happens here if the img file doesn't exist?
		// This could happen if the db is stored on iCloud, they delete the app or lose their phone and then reload the app.
		// They'll still have all the entries, but thumbPath & imgPath will point to nonexistant files (I don't think I'll
		// be able to store the actual images in iCloud due to file size issues)
		// Should I set path = nil, do I inform the user, do I display a specific "Image not found" label?
		// wait a minute, won't the images be restored when they do a restore from iTunes? Since I'm not planning
		// on a desktop client, maybe I don't really need iCloud backup?
		image = [UIImage imageWithContentsOfFile:imgPath];
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
      //NSLog(@"viewDidLoad: self.item != nil");
		
		newItem = NO;
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


// since we can't tap in to the nav bar's back button we will see if we need to do
// the equivalent of a Cancel (and delete new item) operation here
- (void)viewWillDisappear:(BOOL)animated
{
	//NSLog(@"viewWillDisappear");
	
	// If this is a new Item and they click on the back button, assume that they do not
	// want to save the edits:
	if( YES == newItem )
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
         // FIXME: stopped showing cents after text input, just the dollars. Cents appear correctly after refresh
			// This problem occurs when you just type in the dollar amount, e.g. 42
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
