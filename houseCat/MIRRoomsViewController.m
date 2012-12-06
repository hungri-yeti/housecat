//
//  MIRroomsViewController.m
//  houseCat
//
//  Created by kenl on 12/10/4.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import "MIRRoomsViewController.h"
// for segues:
#import "MIRitemsViewController.h"
#import "MIRAddRoomViewController.h"
#import "Rooms.h"
#import "MIRLossReportListViewController.h"
#import "MIRChangeRoomViewController.h"


@interface MIRRoomsViewController ()

@end

@implementation MIRRoomsViewController


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
//   [self.navigationController setToolbarHidden:NO];

   // Uncomment the following line to preserve selection between presentations.
   // self.clearsSelectionOnViewWillAppear = NO;

   // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
   [self.navigationController setToolbarHidden:NO];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   //DebugLog(@"segue.id: %@", segue.identifier );
	
	Rooms *room;
	
   if ([segue.identifier isEqualToString:@"roomsToItems"])
   {
		// This actually hides the toolbar in the child view
		// that will appear soon:
      [self.navigationController setToolbarHidden:YES];
      
      // pass the moc to the child view:
		MIRItemsViewController *vc = [segue destinationViewController];
      vc.managedObjectContext = self.managedObjectContext;
      
      // pass the Room obj to the child view:
      NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
      room = [self.fetchedResultsController objectAtIndexPath:indexPath];
      vc.parent = room;
   }
   else if ([segue.identifier isEqualToString:@"addRoomName"])
   {
      // pass the moc to the child view: 
		MIRAddRoomViewController *vc = [segue destinationViewController];
      vc.managedObjectContext = self.managedObjectContext;
   }
	else if( [segue.identifier isEqualToString:@"lossReport"])
	{
      // pass the moc to the child view:
		MIRLossReportListViewController *vc = [segue destinationViewController];
      vc.managedObjectContext = self.managedObjectContext;
	}
	else if( [segue.identifier isEqualToString:@"changeRoomName"])
	{
      // pass the Room obj to the child view:
      NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
      room = [self.fetchedResultsController objectAtIndexPath:indexPath];
		MIRChangeRoomViewController *vc = [segue destinationViewController];
      vc.room = room;
      vc.managedObjectContext = self.managedObjectContext;
	}
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
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"roomsCell" forIndexPath:indexPath];
   [self configureCell:cell atIndexPath:indexPath];
   return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
   NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
   cell.textLabel.text = [[object valueForKey:@"name"] description];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//   NSUInteger row = [indexPath row];
//   NSLog(@"didSelectRowAtIndexPath: row: %u", row );
   
//	UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad"
//																bundle:nil];
//	UITableViewController *detailController = [sb instantiateViewControllerWithIdentifier:@"TableSettingDetails"];
//	
//	self.popoverController = [[UIPopoverController alloc] initWithContentViewController:detailController];
//	
//	self.popoverController.popoverContentSize = CGSizeMake(256, 128);
//	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//	[self.popoverController presentPopoverFromRect:cell.bounds inView:cell.contentView
//								 permittedArrowDirections:UIPopoverArrowDirectionAny
//													  animated:YES];
	// Deselect the row.
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
   // Do something here
	
	[self performSegueWithIdentifier:@"roomsToItems" sender:self];
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
   if (_fetchedResultsController != nil) {
      return _fetchedResultsController;
   }
   
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   // Edit the entity name as appropriate.
	// FIXME: moc is nil in line below:
   NSEntityDescription *entity = [NSEntityDescription entityForName:@"Rooms" inManagedObjectContext:self.managedObjectContext];
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
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (editingStyle == UITableViewCellEditingStyleDelete) {
      NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
      [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
      
      NSError *error = nil;
      if (![context save:&error]) {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
         abort();
      }
   }
}


@end



