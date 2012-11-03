//
//  MIRPhotosViewController.m
//  houseCat
//
//  Created by kenl on 12/11/1.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MIRPhotosViewController.h"

@interface MIRPhotosViewController ()
// TODO: Change background color in storyboard back to 'default'


@end

@implementation MIRPhotosViewController

#pragma mark - Actions
- (IBAction)addImage:(UIBarButtonItem *)sender
{
   NSLog(@"addImage...");
   
   
//   UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//   picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//   NSString *requiredMediaType = (NSString *)kUTTypeImage;
//   picker.mediaTypes = [[NSArray alloc] initWithObjects:requiredMediaType, nil];
//   picker.allowsEditing = YES;
//   picker.delegate = self;
//   [self.navigationController presentViewController:picker animated:YES completion:nil];
   
   
   // figure out our media types
   if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
   {
      NSLog(@"   UIImagePickerControllerSourceTypeCamera");
      
      NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
      if ([mediaTypes containsObject:(NSString *)kUTTypeImage])
      {
         NSLog(@"      creating camera...");
         
         // create our image picker
         UIImagePickerController *picker = [[UIImagePickerController alloc] init];
         picker.delegate = self;
         picker.sourceType = UIImagePickerControllerSourceTypeCamera;
         picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
         picker.allowsEditing = YES;
         
         [self presentViewController:picker animated:YES completion:nil];
      }
   }
   else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
   {
      NSLog(@"   UIImagePickerControllerSourceTypePhotoLibrary");
      
      NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
      if ([mediaTypes containsObject:(NSString *)kUTTypeImage])
      {
         NSLog(@"      creating image picker...");
         
         // create our image picker
         UIImagePickerController *picker = [[UIImagePickerController alloc] init];
         picker.delegate = self;
         picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
         picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
         picker.allowsEditing = YES;
         
         [self presentViewController:picker animated:YES completion:nil];
      }
   }
}


-(IBAction)done:(id)sender
{
   [self dismissViewControllerAnimated:YES completion:nil];
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
