//
//  MIRLossReportListViewController.h
//  houseCat
//
//  Created by kenl on 12/11/7.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MIRLossReportInfoRequestController.h"


#define kBorderInset            20.0
#define kBorderWidth            1.0
#define kMarginInset            10.0


@interface MIRLossReportListViewController : UITableViewController 
<MIRLossReportInfoRequestDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>
{
	CGSize pageSize;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;


@end
