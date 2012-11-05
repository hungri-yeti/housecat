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
#import "MIRCell.h"


NSString *kCellID = @"uicollection_cell";                          // UICollectionViewCell storyboard id


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
   UIImagePickerController *imagePickController=[[UIImagePickerController alloc]init];
   
   BOOL cameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
   if( ! cameraAvailable )
   {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Camera"
                                                      message:@"The camera is not available, using Photo Library"
                                                     delegate:self cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil, nil];
      [alert show];
      
      // basically for developing in the simulator:
      imagePickController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
   }
   else
   {
      imagePickController.sourceType=UIImagePickerControllerSourceTypeCamera;
      imagePickController.showsCameraControls=YES;
   }
   imagePickController.delegate=self;
   imagePickController.allowsEditing=NO;

   //This method inherit from UIView,show imagePicker with animation
   [self presentViewController:imagePickController animated:YES completion:nil];      

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
   
   // TODO: refactor this out?
   // save the main image:
   NSData *pngBigData = UIImagePNGRepresentation(image);
   [pngBigData writeToFile:imagePath atomically:YES];
   
   // generate & save the thumb:
   // TODO: this should query the cell size on the subview and set the size from that:
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
   
   // TODO: what happens here if the parent Item is a new item that hasn't been saved yet?
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
   MIRCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
	NSString *thumbPath = [[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row] thumbPath];
	UIImage *thumbImage = [UIImage imageWithContentsOfFile:thumbPath];
	
	[cell.image setImage:thumbImage];
	
//   NSLog(@"thumbPath: %@, thumbImage: %@", thumbPath, thumbImage );
//	NSLog(@"   cell.image.image: %@", cell.image.image );
	
   return cell;
}


- (NSFetchedResultsController *)fetchedResultsController
{
   if (_fetchedResultsController != nil) {
      return _fetchedResultsController;
   }
   
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   fetchRequest.predicate = [NSPredicate predicateWithFormat:@"item == %@", self.item];
   
   // Edit the entity name as appropriate.
   NSEntityDescription *entity = [NSEntityDescription entityForName:@"Images" inManagedObjectContext:self.managedObjectContext];
   [fetchRequest setEntity:entity];
   
   // Set the batch size to a suitable number.
   [fetchRequest setFetchBatchSize:20];
   
   // Edit the sort key as appropriate.
   NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                       initWithKey:@"thumbPath"
                                       ascending:YES
                                       selector:@selector(localizedCaseInsensitiveCompare:)];
   NSArray *sortDescriptors = @[sortDescriptor];
   
   [fetchRequest setSortDescriptors:sortDescriptors];
   
   // Edit the section name key path and cache name if appropriate.
   // nil for section name key path means "no sections".
   NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
   aFetchedResultsController.delegate = self;
   self.fetchedResultsController = aFetchedResultsController;
   
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
	}
   
   return _fetchedResultsController;
}




#pragma mark - delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
   return 1;
}


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
   id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
   
   NSLog(@"# of items: %i, frc: %@", [sectionInfo numberOfObjects], self.fetchedResultsController );
   
   return [sectionInfo numberOfObjects];
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
   
   NSLog(@"item: %@", [[self.item valueForKey:@"name"] description]);
   
//   NSLog(@"%@", [self displayViews:self.view]);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
