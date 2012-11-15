//
//  MIRLossReportListViewController.h
//  houseCat
//
//  Created by kenl on 12/11/7.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MIRLossReportInfoRequestController.h"


@interface MIRLossReportListViewController : UITableViewController 
<MIRLossReportInfoRequestDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;


@end
