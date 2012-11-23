//
//  MIRAddRoomViewController.h
//  houseCat
//
//  Created by kenl on 12/10/18.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <UIKit/UIKit.h>

// TODO: remove the parent navigation controller, the segue should go straight to this view
@interface MIRAddRoomViewController : UIViewController <UITextFieldDelegate>
@property(strong,nonatomic)IBOutlet UITextField *roomNameField;

-(IBAction)cancel:(id)sender;
-(IBAction)save:(id)sender;
-(IBAction)endEditing:(id)sender;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
-(void) saveRoomName:(NSString*)roomName;

@end
