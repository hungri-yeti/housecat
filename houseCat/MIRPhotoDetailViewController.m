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
   NSError *error;
	[self.managedObjectContext deleteObject:self.image];
   if (![self.managedObjectContext save:&error])
   {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog(@"MIRPhotoDetailViewController: unresolved error %@, %@", error, [error userInfo]);
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
	
	//NSLog(@"%@", [self displayViews:self.view] );
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
	
	NSLog(@"didReceiveMemoryWarning");
}



#pragma mark - utilites

// Recursively travel down the view tree, increasing the 
// indentation level for children
- (void) dumpView: (UIView *) aView atIndent: (int) indent
				 into:(NSMutableString *) outstring
{
	for (int i = 0; i < indent; i++) [outstring appendString:@"--"];
	[outstring appendFormat:@"[%2d] %@\n", indent, [[aView class] description]];
	for (UIView *view in [aView subviews])
		[self dumpView:view atIndent:indent + 1 into:outstring];
}

// Start the tree recursion at level 0 with the root view 
- (NSString *) displayViews: (UIView *) aView
{
	NSMutableString *outstring = [[NSMutableString alloc] init]; [self dumpView:aView atIndent:0 into:outstring];
	return outstring;
}



@end
