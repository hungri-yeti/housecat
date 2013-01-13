//
//  MIRroomsViewController.h
//  houseCat
//
//  Created by kenl on 12/10/4.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MIRRoomsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
// iPad-specific:
//@property (strong, nonatomic) UIPopoverController* popoverController;

// move the table into a view so we can add an advertising panel:
@property (nonatomic,retain) IBOutlet UITableView *tableView;

-(IBAction)gotoUrl:(id)sender;




@end
