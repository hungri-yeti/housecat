//
//  MIRPhotoDetailViewController.m
//  houseCat
//
//  Created by kenl on 12/11/5.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import "MIRPhotoDetailViewController.h"

@interface MIRPhotoDetailViewController ()

@end

@implementation MIRPhotoDetailViewController



- (IBAction)deleteImage:(id)sender
{
	// DRY: some of this code is duplicated in MIRItemsViewController:commitEditingStyle
	NSError* error;
	NSFileManager *fileManager = [NSFileManager defaultManager];

	// delete the image files so we don't fill up the file system:
	if ([fileManager removeItemAtPath:[self.image thumbPath] error:&error])
	{
		NSLog(@"ERROR: unable to delete thumbPath %@: error: %@", [self.image thumbPath], [error localizedDescription]);
      // Notify the user
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                      message:[error localizedFailureReason]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK",@"Alert 'OK' (Cancel) button.")
                                            otherButtonTitles:nil];
      [alert show];
	}
	
	error = nil;
	if ([fileManager removeItemAtPath:[self.image imagePath] error:&error])
	{
		NSLog(@"ERROR: unable to delete imagePath %@: error: %@", [self.image imagePath], [error localizedDescription]);
      // Notify the user
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                      message:[error localizedFailureReason]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK",@"Alert 'OK' (Cancel) button.")
                                            otherButtonTitles:nil];
      [alert show];
	}
	
	// then delete the obj:
	error = nil;
	[self.managedObjectContext deleteObject:self.image];
   if (![self.managedObjectContext save:&error])
   {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog(@"ERROR: [self.managedObjectContext save:error] failed, error: %@", [error localizedDescription]);
      // Notify the user
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                      message:[error localizedFailureReason]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK",@"Alert 'OK' (Cancel) button.")
                                            otherButtonTitles:nil];
      [alert show];
   }
	
	// my work here is done:
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
	
	NSString *imgPath = [self.image imagePath];
	UIImage *image = [UIImage imageWithContentsOfFile:imgPath];
	[self.imageView setImage:image];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
