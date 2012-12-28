//
//  MIRChangeRoomViewController.m
//  houseCat
//
//  Created by kenl on 12/11/27.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import "MIRChangeRoomViewController.h"

@interface MIRChangeRoomViewController ()

@end



@implementation MIRChangeRoomViewController


-(void) saveRoomName:(NSString*)roomName
{
	[self.room setName:self.roomNameField.text];
   
   NSError *error = nil;
   if (self.managedObjectContext != nil) {
      if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         ReleaseLog(@"ERROR: [self.managedObjectContext] failed: %@", [error localizedDescription]);
         abort();
      }
   }
}


#pragma mark - Actions
-(IBAction)cancel:(id)sender
{
   [self dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction)save:(id)sender
{
   if([self.roomNameField.text length]<=0)
   {
		// TODO: should disable the save button until some text is entered (also need to disable if all the text is deleted)
      //DebugLog(@"MIRChangeRoomViewController: you have not entered a Room name %@",self.roomNameField.text);
   }
   else
   {
      [self saveRoomName:self.roomNameField.text];
	}
   
   [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)endEditing:(id)sender
{
   UITextField *roomName = (UITextField*)sender;
   [self saveRoomName:roomName.text];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	self.roomNameField.text = [self.room name];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
