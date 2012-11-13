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
@property (nonatomic, weak) id <MIRLossReportInfoRequestDelegate> delegate;


@property (weak, nonatomic) IBOutlet UITextField *policyNumber;
@property (weak, nonatomic) IBOutlet UITextField *lossDate;



-(IBAction)cancel:(id)sender;
-(IBAction)save:(id)sender;

@end
