//
//  MIRLossReportListViewController.m
//  houseCat
//
//  Created by kenl on 12/11/7.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import "MIRLossReportListViewController.h"
#import "Rooms.h"
#import "Items.h"
#import "MIRGeneratePDF.h"



@interface MIRLossReportListViewController (Private)
	- (void)drawPageNumber:(NSInteger)pageNum;

@end



@implementation MIRLossReportListViewController



#pragma mark - loss info delegate
-(void)readLossInfo:(NSArray*)results
{
	NSLog(@"loss date: %@, policy number: %@", [results objectAtIndex:0], [results objectAtIndex:1]);
	
	[self performSegueWithIdentifier:@"selectItemsToPreview" sender:self];
}



#pragma mark - table delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Items* item = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if( NO == [item.selected boolValue] )
	{
		[item setSelected:[NSNumber numberWithBool:YES]];
	} 
	else
	{
		cell.selected = NO;
		[item setSelected:[NSNumber numberWithBool:NO]];
	}

	NSManagedObjectContext *context = [self managedObjectContext]; 
   NSError *error;
   if (![context save:&error])
   {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog(@"MIRLossReportListViewController: didSelectRowAtIndexPath: unresolved error %@, %@", error, [error userInfo]);
   }
}



#pragma mark - Fetched results controller

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo name];
}


- (NSFetchedResultsController *)fetchedResultsController
{
   if (_fetchedResultsController != nil) {
      return _fetchedResultsController;
   }
   
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   // Edit the entity name as appropriate.
   NSEntityDescription *entity = [NSEntityDescription entityForName:@"Items" inManagedObjectContext:self.managedObjectContext];
   [fetchRequest setEntity:entity];
   
   // Set the batch size to a suitable number.
   [fetchRequest setFetchBatchSize:20];
   
   // Edit the sort key as appropriate.
   NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                       initWithKey:@"room.name"
                                       ascending:YES
                                       selector:@selector(localizedCaseInsensitiveCompare:)];
   NSArray *sortDescriptors = @[sortDescriptor];
   
   [fetchRequest setSortDescriptors:sortDescriptors];
   
   // Edit the section name key path and cache name if appropriate.
   // nil for section name key path means "no sections".
   NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] 
																				initWithFetchRequest:fetchRequest 
																				managedObjectContext:self.managedObjectContext 
																				sectionNameKeyPath:@"room.name" 
																				cacheName:nil];
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


//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//   if (editingStyle == UITableViewCellEditingStyleDelete) {
//      NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//      [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
//      
//      NSError *error = nil;
//      if (![context save:&error]) {
//         // Replace this implementation with code to handle the error appropriately.
//         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//         abort();
//      }
//   }
//}



#pragma mark - tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[[self fetchedResultsController] sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
   return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Does this really do anything? I didn't get the requested style until I changed it in the storyboard.
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"lossreport_cell" forIndexPath:indexPath];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"lossreport_cell"];
	}
   [self configureCell:cell atIndexPath:indexPath];
   return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	Items* item = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = item.name;
	NSString *numberStr = [NSNumberFormatter localizedStringFromNumber:item.cost
																			 numberStyle:NSNumberFormatterCurrencyStyle];
	cell.detailTextLabel.text = numberStr;
	
	NSString* thumbPath = item.thumbPath;
	UIImage *thumbImage = [UIImage imageWithContentsOfFile:thumbPath];
	cell.imageView.image = thumbImage;
	
	// set checkmark state:
	if( YES == [item.selected boolValue] )
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
}



#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   //DebugLog(@"segue.id: %@", segue.identifier );
	
   if ([segue.identifier isEqualToString:@"selectItemsToPreview"])
	{
		// generate the PDF:
		//NSString* pdfPath = [self generatePDF];

		// provide the file path to the preview controller:
		//NSLog(@"pdfPath: %@", pdfPath );
	}
	else if([segue.identifier isEqualToString:@"requestInfo"])
	{
		UIViewController *newController = segue.destinationViewController;
		MIRLossReportInfoRequestController *mlrVC = (MIRLossReportInfoRequestController *) newController;
		mlrVC.delegate = self;
	}
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
