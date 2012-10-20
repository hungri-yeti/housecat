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

@interface MIRRoomsViewController ()
{
   NSArray *roomsItems;
   NSMutableArray *rooms;
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;

@end

@implementation MIRRoomsViewController
@synthesize managedObjectContext;


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
   
   // TODO: implement CoreData model
   // placeholder array until coredata model implemented
   roomsItems = [NSArray arrayWithObjects:
                 [NSArray arrayWithObjects: @"living room",@"item1",@"item2",@"item3",@"item4",nil],
                 [NSArray arrayWithObjects: @"family room",@"item5",@"item6",@"item7",@"item8",@"item9",nil],
                 [NSArray arrayWithObjects: @"master bedroom",@"item10",@"item11",nil],
                 [NSArray arrayWithObjects: @"bedroom #2",@"item15",@"item16",@"item17",nil],
                 [NSArray arrayWithObjects: @"kitchen",@"item20",@"item21",@"item22",@"item23",nil],
                 [NSArray arrayWithObjects: @"office",@"item25",@"item26",@"item27",@"item28",@"item29",nil],
                 [NSArray arrayWithObjects: @"basement",@"item30",@"item31",@"item32",@"item33",@"item34",nil],
                 [NSArray arrayWithObjects: @"garage",@"item35",@"item36",@"item37",@"item38",@"item39",@"item40",@"item41",@"item42",@"item43",@"item44",@"item45",@"item46",@"item47",@"item48",@"item49",nil],
                 [NSArray arrayWithObjects: @"car",@"item50",@"item51",nil],
                 nil];
   
   // load the room names into an array:
   NSMutableArray *table = [[NSMutableArray alloc] init];
   rooms = table;
   for (int i = 0; i < [roomsItems count]; i++)
   {
      [rooms addObject:roomsItems[i][0]];
      // NSLog(@"roomsItems[i][0]: %@", roomsItems[i][0]);
   }


   // Uncomment the following line to preserve selection between presentations.
   // self.clearsSelectionOnViewWillAppear = NO;

   // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
   // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   NSLog(@"prepareForSegue: segue: id: %@, moc: %@", segue.identifier, self.managedObjectContext );

   if ([segue.identifier isEqualToString:@"roomsToItems"])
   {
      NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
      NSUInteger row = [indexPath row];
      NSLog(@"   row: %u", row );
      
      // extract all of the selected room's items into an array that
      // will be passed to the Items view controller:
      NSMutableArray *roomItems = [[NSMutableArray alloc] init];
      NSRange theRange;
      
      theRange.location = 1;
      theRange.length = [roomsItems[row] count]-1;
      [roomItems addObjectsFromArray:[roomsItems[row] subarrayWithRange:theRange]];

      // pass the moc to the child view:
      UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
      MIRItemsViewController *vc = (MIRItemsViewController *)[[navController viewControllers] lastObject];
      vc.managedObjectContext = self.managedObjectContext;
   }
   else if ([segue.identifier isEqualToString:@"addRoomName"])
   {
      // pass the moc to the child view:
      UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
      MIRAddRoomViewController *vc = (MIRAddRoomViewController *)[[navController viewControllers] lastObject];
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
   // Return the number of rows in the section.
   return [rooms count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *simpleTableIdentifier = @"roomsCell";
   
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
   
   if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
   }
   
   cell.textLabel.text = [rooms objectAtIndex:indexPath.row];
   return cell;
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
   
   // Navigation logic may go here. Create and push another view controller.
   /*
   ￼ *detailViewController = [[￼ alloc] initWithNibName:@"￼" bundle:nil];
   // ...
   // Pass the selected object to the new view controller.
   [self.navigationController pushViewController:detailViewController animated:YES];
   */
}


-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
   // Do something here
}

@end




