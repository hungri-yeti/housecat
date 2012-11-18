//
//  MIRLossReportListViewController.h
//  houseCat
//
//  Created by kenl on 12/11/7.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MIRLossReportInfoRequestController.h"


@interface MIRLossReportListViewController : UITableViewController 
<MIRLossReportInfoRequestDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
{
	@private
	UIViewController *infoRequestVC;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic)	NSString* pdfFilePath;


@end
