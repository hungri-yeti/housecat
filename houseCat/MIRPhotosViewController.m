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
#import "MIRPhotoDetailViewController.h"

#define kBorderInset 20.0
// TODO: currently 8.5x11, this will need to be a variable that can be localized (e.g. A4).
#define kPageWidth 612
#define kPageHeight 792


NSString *kCellID = @"uicollection_cell";      


@interface MIRPhotosViewController ()

@end

@implementation MIRPhotosViewController



#pragma mark - utilities

-(void)updateParentThumbPath
{
	// Update Item.thumbPath 
	//   Get the first photo (according to sortOrder)
	//   If an Image found
	//		Set parentItem.thumbPath to results[0].thumbPath
	//   else set parentItem.thumbPath = nil
	NSManagedObjectContext *context = [self managedObjectContext]; 
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
   request.predicate = [NSPredicate predicateWithFormat:@"parentItem == %@ AND sortOrder = %d", self.item, 0];
   
   NSEntityDescription *entity = [NSEntityDescription entityForName:@"Images" 
															inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
   NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                       initWithKey:@"sortOrder"
                                       ascending:YES];
   NSArray *sortDescriptors = @[sortDescriptor];
   [request setSortDescriptors:sortDescriptors];
	NSArray *results = [context executeFetchRequest:request error:nil];

	if ([results count]) 
	{
		Images* thumbImage = [results objectAtIndex:0];
		[self.item setThumbPath:[thumbImage thumbPath]];
	}
	else
	{
		[self.item setThumbPath:@""];
	}

   NSError *error;
   if (![context save:&error])
   {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      ReleaseLog(@"ERROR: [context save:&error] failed, error: %@", [error localizedDescription]);
   }
}


- (void)updateSortOrder
{
	// Set sortOrder for all the photos. Assume that either a new image (sortOrder = 255) was
	// added or an image was deleted from the view (hole in sort order).
	// Obtain all remaining images based on sortOrder, reset sortOrder starting at 0.
	NSManagedObjectContext *context = [self managedObjectContext]; 
	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
   request.predicate = [NSPredicate predicateWithFormat:@"parentItem == %@", self.item];
   
   NSEntityDescription *entity = [NSEntityDescription entityForName:@"Images" 
															inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
   // Edit the sort key as appropriate.
   NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                       initWithKey:@"sortOrder"
                                       ascending:YES];
   NSArray *sortDescriptors = @[sortDescriptor];
   [request setSortDescriptors:sortDescriptors];
	
	NSArray *results = [context executeFetchRequest:request error:nil];
	UInt16 sortOrder = 0;
	for (NSManagedObject *object in results)
	{
		[object setValue:[NSNumber numberWithUnsignedInt:sortOrder] forKey:@"sortOrder"];
		sortOrder++;
	}
	
   NSError *error;
   if (![context save:&error])
   {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      ReleaseLog(@"ERROR: [context save:&error] failed, error: %@", [error localizedDescription]);
   }
}


- (NSString*)uniqueImagePath
{
   NSMutableString *imageName = [[NSMutableString alloc] initWithCapacity:0];
	// all images (thumbs & full-size) will be stored in this dir:
	[imageName appendString:@"img/" ];
	
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

- (void) addImage:(id) sender
{
	// Weird bug(?) when I navigate down into the photo library the collection view starts at the top
	// of the screen, not below the navbar. After I pull the collection down and let it
	// pop back up, it snaps to the proper location. This shouldn't be a big deal since it's
	// only the photo library which is used in the simulator, the device uses the camera.
   UIImagePickerController *imagePickController=[[UIImagePickerController alloc]init];

   BOOL cameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
   if( !cameraAvailable )
   {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Camera", @"Camera")
                                                      message:NSLocalizedString(@"The camera is not available, using Photo Library", @"Camera unavailable message")
                                                     delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
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



#pragma mark - image picker

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   //[picker dismissViewControllerAnimated:YES completion:nil];
   
   UIImage* image = nil;
   image = [info objectForKey:UIImagePickerControllerOriginalImage];
   
   NSString *imagePath = [self uniqueImagePath];
   NSString *thumbPath = [self uniqueImagePath];
   
	// imageWithImage also rotates the image to the proper orientation. If we don't do this
	// for the main image, it will be offset 90 degrees ccw compared to the thumb. The only
	// drawback is the amount of time required, so we'll display an activity indicator.
	// replace right bar button 'refresh' with spinner.
	// I tested this on an actual device and didn't see the spinner but the process
	// didn't take very long either. This may not be necessary.
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	spinner.center = CGPointMake(160, 240);
	spinner.hidesWhenStopped = YES;
	[self.view addSubview:spinner];   
	[spinner startAnimating];	
	
	// this code is just copy & paste. the spinner doesn't show up but the imgpicker
	// returns immediately. The interesting thing is that the thumb shows up
	// immediately, it can take some time for the actual img to show up.

	// how we stop refresh from freezing the main UI thread
	dispatch_queue_t resizeBigImage = dispatch_queue_create("resize", NULL);
	dispatch_async(resizeBigImage, ^{
		// do our long running process here:
		// new image size should be the same as what will be rendered in MIRGeneratePDF.
		CGSize newSize = CGSizeMake( (kPageWidth/2)-(3*kBorderInset), (kPageHeight/2)-(2*kBorderInset) );   
		UIImage* mainImage = [self imageWithImage:image scaledToSize:newSize];	
		NSData *pngBigData = UIImagePNGRepresentation(mainImage);
		[pngBigData writeToFile:imagePath atomically:YES];
		// do any UI stuff on the main UI thread
		dispatch_async(dispatch_get_main_queue(), ^{
			[spinner stopAnimating];
		});
	});
   
   // generate & save the thumb. Base the thumb's size on the frame
	// of the UIImageView that it will be inserted into.
	// if this is the first Image for the Item, the tagged view won't exist
	// so we'll use some defaults.
	CGSize thumbSize;
	if( NULL == [self.view viewWithTag:100] )
	{
		thumbSize = CGSizeMake(100.0f, 100.0f);
	}
	else
	{
		thumbSize = [self.view viewWithTag:100].frame.size;		
	}	
	
   UIImage* thumbImage = [self imageWithImage:image scaledToSize:thumbSize];
   NSData *pngThumbData = UIImagePNGRepresentation(thumbImage);
   [pngThumbData writeToFile:thumbPath atomically:YES];
   
   // insert the paths into the db:
   Images *imageObj = (Images *)[NSEntityDescription
                                insertNewObjectForEntityForName:@"Images"
                                inManagedObjectContext:self.managedObjectContext];
	
   [imageObj setValue:imagePath forKey:@"imagePath"];
   [imageObj setValue:thumbPath forKey:@"thumbPath"];
	// I assume that there will never be more than 254 images, so the new image
	// is always inserted at the end.
	[imageObj setValue:[NSNumber numberWithInt:255] forKey:@"sortOrder"];
   
   [self.item addImagesObject:imageObj];
   NSError *error;
   if (![self.managedObjectContext save:&error])
   {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      ReleaseLog(@"ERROR: [self.managedObjectContext save:&error] failed, error: %@", [error localizedDescription]);
   }
   [picker dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MIRPhotoDetailViewController *vc = [segue destinationViewController];

	// pass the existing Image obj to the child view:
	NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] lastObject];
	Images *image = [self.fetchedResultsController objectAtIndexPath:indexPath];
	vc.image = image;
   
   // pass the moc to the child view:
   vc.managedObjectContext = self.managedObjectContext;
}


- (void)viewWillDisappear:(BOOL)animated
{
	[self updateSortOrder];
	[self updateParentThumbPath];
}



#pragma mark - datasource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
   MIRCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
	NSString *thumbPath = [[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row] thumbPath];
	UIImage *thumbImage = [UIImage imageWithContentsOfFile:thumbPath];
	Items* parentItem = [[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row] parentItem];
	cell.parentItem = parentItem;
	Images* imageObj = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
	cell.image = imageObj;
	
	[cell.imageView setImage:thumbImage];
	
   return cell;
}


- (NSFetchedResultsController *)fetchedResultsController
{
   if (_fetchedResultsController != nil) {
      return _fetchedResultsController;
   }
	
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   fetchRequest.predicate = [NSPredicate predicateWithFormat:@"parentItem == %@", self.item];
   
   NSEntityDescription *entity = [NSEntityDescription entityForName:@"Images" inManagedObjectContext:self.managedObjectContext];
   [fetchRequest setEntity:entity];
   
   // Set the batch size to a suitable number.
   [fetchRequest setFetchBatchSize:20];
   
   // Edit the sort key as appropriate.
   NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                       initWithKey:@"sortOrder"
                                       ascending:YES];
   NSArray *sortDescriptors = @[sortDescriptor];
   [fetchRequest setSortDescriptors:sortDescriptors];
   
   // Edit the section name key path and cache name if appropriate.
   // nil for section name key path means "no sections".
   NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] 
																				initWithFetchRequest:fetchRequest 
																				managedObjectContext:self.managedObjectContext 
																				sectionNameKeyPath:nil 
																				cacheName:nil];
   aFetchedResultsController.delegate = self;
   self.fetchedResultsController = aFetchedResultsController;
	
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      ReleaseLog(@"ERROR: [self.fetchedResultsController performFetch:&error] failed, error: %@", [error localizedDescription]);
      abort();
	}
   
   return _fetchedResultsController;
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
	UICollectionView *collectionView = self.collectionView;
   
   switch(type) {
      case NSFetchedResultsChangeInsert:
         [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
         break;
         
      case NSFetchedResultsChangeDelete:
         [collectionView deleteItemsAtIndexPaths:@[indexPath]];
         break;
	}
}



#pragma mark - delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
   return 1;
}


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
   id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
   return [sectionInfo numberOfObjects];
}



#pragma mark - init

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	UIBarButtonItem* btnCamera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(addImage:)];
   self.navigationItem.rightBarButtonItem = btnCamera;
	self.title = NSLocalizedString(@"Photos", @"Photos");
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
