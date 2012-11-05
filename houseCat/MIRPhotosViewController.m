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

@end

@implementation MIRPhotosViewController



#pragma mark - utilities

- (NSString*)uniqueImagePath
{
   NSMutableString *imageName = [[NSMutableString alloc] initWithCapacity:0];
   CFUUIDRef theUUID = CFUUIDCreate(kCFAllocatorDefault);
   if (theUUID)
   {
      [imageName appendString:CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, theUUID))];
      CFRelease(theUUID);
   }
   [imageName appendString:@".png"];
   
   NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
   NSString *documentsPath = [paths objectAtIndex:0];
   NSString *filePath = [documentsPath stringByAppendingPathComponent:imageName];
   NSLog(@"filePath: %@", filePath);
   
   return filePath;
}


- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
   UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
   [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
   UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
   UIGraphicsEndImageContext();
   return newImage;
}



#pragma mark - Actions
- (IBAction)addImage:(UIBarButtonItem *)sender
{
   BOOL cameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
   if( ! cameraAvailable )
   {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Camera"
                                                      message:@"The camera is not available"
                                                     delegate:self cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil, nil];
      [alert show];
   }
   else
   {
      UIImagePickerController *imagePickController=[[UIImagePickerController alloc]init];
      imagePickController.sourceType=UIImagePickerControllerSourceTypeCamera;
      imagePickController.delegate=self;
      imagePickController.allowsEditing=NO;
      imagePickController.showsCameraControls=YES;
      //This method inherit from UIView,show imagePicker with animation
      [self presentViewController:imagePickController animated:YES completion:nil];      
   }
}


-(IBAction)done:(id)sender
{
   [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - image picker

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   [picker dismissViewControllerAnimated:YES completion:nil];
   
   UIImage* image = nil;
   image = [info objectForKey:UIImagePickerControllerOriginalImage];
   
   NSString *imagePath = [self uniqueImagePath];
   NSString *thumbPath = [self uniqueImagePath];
   
   // save the main image:
   NSData *pngBigData = UIImagePNGRepresentation(image);
   [pngBigData writeToFile:imagePath atomically:YES];
   
   // generate & save the thumb:
   CGSize newSize = CGSizeMake(100, 100);
   UIImage* thumbImage = [self imageWithImage:image scaledToSize:newSize];
   NSData *pngThumbData = UIImagePNGRepresentation(thumbImage);
   [pngThumbData writeToFile:thumbPath atomically:YES];
   
   // insert the paths into the db:
   Images *imageObj = (Images *)[NSEntityDescription
                                insertNewObjectForEntityForName:@"Images"
                                inManagedObjectContext:self.managedObjectContext];
   
   [imageObj setValue:imagePath forKey:@"imagePath"];
   [imageObj setValue:thumbPath forKey:@"thumbPath"] ;
   
   [self.item addImagesObject:imageObj];
   NSError *error;
   if (![self.managedObjectContext save:&error])
   {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog(@"MIRPhotosViewController: unresolved error %@, %@", error, [error userInfo]);
   }
}


#pragma mark - datasource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *identifier = @"uicollection_cell";
   UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
   
//   NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
//   [cell setImage:[UIImage imageWithData:[object valueForKey:@"photoImageData"]]];
   
   return cell;
}



#pragma mark - delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
   return 4;
}


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
   return 4;
}


//- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//}



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
   
   NSLog(@"item: %@", [[self.item valueForKey:@"name"] description]);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
