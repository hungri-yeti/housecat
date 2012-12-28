//
//  MIRitemsViewController.m
//  houseCat
//
//  Created by kenl on 12/10/4.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import "MIRItemsViewController.h"
// for segue:
#import "MIRItemsDetailViewController.h"
#import "Items.h"
#import "Images.h"


@interface MIRItemsViewController ()


@end

@implementation MIRItemsViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   [self.navigationController setToolbarHidden:YES];

	[self setTitle:[[self.parent valueForKey:@"name"] description]];
	

   // Uncomment the following line to preserve selection between presentations.
   // self.clearsSelectionOnViewWillAppear = NO;

   // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
   // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated
{
	[self.tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload
{
	self.fetchedResultsController = nil;
}



#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   MIRItemsDetailViewController *vc = [segue destinationViewController];
   if ([segue.identifier isEqualToString:@"itemEdit"])
   {
      // pass the existing Item obj to the child view:
		NSIndexPath *indexPath;
		if([sender isKindOfClass:[UITableViewCell class]])
		{
			indexPath = [self.tableView indexPathForSelectedRow];			
		}
		else if ([sender isKindOfClass:[NSIndexPath class]])
		{
			// The segue may be called from accessoryButtonTappedForRowWithIndexPath, in which case
			// sender will already be NSIndexPath.
			indexPath = sender;
		}
		
      Items *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
      vc.item = item;
   }
   else if ([segue.identifier isEqualToString:@"itemAdd"])
   {
      vc.item = nil;
   }
   
   // pass the moc to the child view:
   vc.managedObjectContext = self.managedObjectContext;

   // pass the Room obj to the child view:
   vc.parent = self.parent;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	[self performSegueWithIdentifier:@"itemEdit" sender:indexPath];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   // Return the number of sections.
   return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
   return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemsCell" forIndexPath:indexPath];
   [self configureCell:cell atIndexPath:indexPath];
   return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	Items* item = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = item.name;
	
	NSString* thumbPath = item.thumbPath;
	UIImage *thumbImage = [UIImage imageWithContentsOfFile:thumbPath];
	cell.imageView.image = thumbImage;
}



#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
   if (_fetchedResultsController != nil) {
      return _fetchedResultsController;
   }
   
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   fetchRequest.predicate = [NSPredicate predicateWithFormat:@"room == %@", self.parent];

   // Edit the entity name as appropriate.
   NSEntityDescription *entity = [NSEntityDescription entityForName:@"Items" inManagedObjectContext:self.managedObjectContext];
   [fetchRequest setEntity:entity];
   
   // Set the batch size to a suitable number.
   [fetchRequest setFetchBatchSize:20];
   
   // Edit the sort key as appropriate.
   NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                       initWithKey:@"name"
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
      ReleaseLog(@"ERROR: [self.fetchedResultsController performFetch:&error] failed: %@", [error localizedDescription]);
      abort();
	}
   
   return _fetchedResultsController;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
   [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
   switch(type) {
      case NSFetchedResultsChangeInsert:
         [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
         break;
         
      case NSFetchedResultsChangeDelete:
         [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
         break;
   }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
   UITableView *tableView = self.tableView;
   
   switch(type) {
      case NSFetchedResultsChangeInsert:
         [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
         break;
         
      case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
         break;
         
      case NSFetchedResultsChangeUpdate:
         [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
         break;
         
      case NSFetchedResultsChangeMove:
         [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
         [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
         break;
   }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
   [self.tableView endUpdates];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		// DRY: some of this code is repeated in MIRPhotoDetailVC:deleteImage
		Items* item = [self.fetchedResultsController objectAtIndexPath:indexPath];

		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		// get all of the Images for this Item:
		[fetchRequest setEntity:[NSEntityDescription entityForName:@"Images"
												 inManagedObjectContext:self.managedObjectContext]];
		fetchRequest.predicate = [NSPredicate predicateWithFormat:@"parentItem == %@", item];
		NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
		
		NSError* error;
		NSFileManager *fileManager = [NSFileManager defaultManager];
		for (Images *image in results)
		{
			// delete the image files so we don't fill up the file system:
			error = nil;
			if ( NO == [fileManager removeItemAtPath:[image thumbPath] error:&error])
			{
				ReleaseLog(@"ERROR: unable to delete file thumbPath=%@: error: %@", image.thumbPath, [error localizedDescription]);
			}
			
			error = nil;
			if ( NO == [fileManager removeItemAtPath:[image imagePath] error:&error])
			{
				ReleaseLog(@"ERROR: unable to delete file imagePath=%@: error: %@", image.imagePath, [error localizedDescription]);
			}
		}
		
      NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
      [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
      
		error = nil;
      if (![context save:&error])
		{
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         ReleaseLog(@"ERROR: [context save:&error] failed: %@", [error localizedDescription]);
         abort();
      }
   }
}




@end
