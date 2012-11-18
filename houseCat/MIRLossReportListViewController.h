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


@interface MIRLossReportListViewController : UITableViewController 
<	MIRLossReportInfoRequestDelegate, 
	UITableViewDelegate, 
	UITableViewDataSource, 
	NSFetchedResultsControllerDelegate, 
	UIActionSheetDelegate, 
	MFMailComposeViewControllerDelegate, 
	QLPreviewControllerDelegate
>
{
	@private
	UIViewController *infoRequestVC;
}

-(NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller;
- (id <QLPreviewItem>) previewController: (QLPreviewController *) controller previewItemAtIndex: (NSInteger) index;


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic)	NSString* pdfFilePath;
@property (strong, nonatomic) NSMutableArray* pdfs;


@end
