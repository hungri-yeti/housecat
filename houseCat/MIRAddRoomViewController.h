//
//  MIRAddRoomViewController.h
//  houseCat
//
//  Created by kenl on 12/10/18.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MIRAddRoomViewController : UIViewController <UITextFieldDelegate>
@property(strong,nonatomic)IBOutlet UITextField *roomNameField;

-(IBAction)cancel:(id)sender;
-(IBAction)save:(id)sender;
-(IBAction)endEditing:(id)sender;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
-(void) saveRoomName:(NSString*)roomName;

@end
