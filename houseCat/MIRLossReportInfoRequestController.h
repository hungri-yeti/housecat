//
//  MIRLossReportInfoRequestController.h
//  houseCat
//
//  Created by kenl on 12/11/12.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MIRLossReportInfoRequestDelegate
	-(void)readLossInfo:(NSArray*)results;
@end


@interface MIRLossReportInfoRequestController : UIViewController
@property (strong, nonatomic) id <MIRLossReportInfoRequestDelegate> delegate;


@property (strong, nonatomic) IBOutlet UITextField *policyNumber;
@property (strong, nonatomic) IBOutlet UITextField *lossDate;



-(IBAction)cancel:(id)sender;
-(IBAction)save:(id)sender;

@end
