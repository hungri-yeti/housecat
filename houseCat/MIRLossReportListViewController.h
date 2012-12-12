//
//  MIRLossReportListViewController.h
//  houseCat
//
//  Created by kenl on 12/11/7.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <QuickLook/QuickLook.h>
#import "MIRLossReportInfoRequestController.h"


// TODO: refactor some of these delegates out, 
// maybe have one class for each output action (email, print, dropbox)?
@interface MIRLossReportListViewController : UITableViewController 
<	MIRLossReportInfoRequestDelegate, 
	UITableViewDelegate, 
	UITableViewDataSource, 
	NSFetchedResultsControllerDelegate, 
	UIActionSheetDelegate, 
	MFMailComposeViewControllerDelegate
>


-(void)showActionSheet;
-(void)actionSendEmail;
-(void)actionPrintPDF;
//-(void)actionDropBox;


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic)	NSString* pdfFilePath;
@property (strong, nonatomic) NSMutableArray* pdfs;
@property (strong, nonatomic) NSString* resultsString;


@end
