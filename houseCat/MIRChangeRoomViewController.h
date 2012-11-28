//
//  MIRChangeRoomViewController.h
//  houseCat
//
//  Created by kenl on 12/11/27.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Rooms.h"

@interface MIRChangeRoomViewController : UIViewController <UITextFieldDelegate>
@property(strong,nonatomic)IBOutlet UITextField *roomNameField;

-(IBAction)cancel:(id)sender;
-(IBAction)save:(id)sender;
-(IBAction)endEditing:(id)sender;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
-(void) saveRoomName:(NSString*)roomName;

// Used to pass the parent (Room) in:
@property( strong, nonatomic ) Rooms *room;


@end
