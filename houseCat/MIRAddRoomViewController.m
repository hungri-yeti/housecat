//
//  MIRAddRoomViewController.m
//  houseCat
//
//  Created by kenl on 12/10/18.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import "MIRAddRoomViewController.h"
#import "Rooms.h"

@interface MIRAddRoomViewController ()


@end

@implementation MIRAddRoomViewController



-(void) saveRoomName:(NSString*)roomName
{
   // Add our default Room list in Core Data
   Rooms *room = (Rooms *)[NSEntityDescription insertNewObjectForEntityForName:@"Rooms" inManagedObjectContext:self.managedObjectContext];
   [room setName:self.roomNameField.text];
   
   NSError *error = nil;
   if (self.managedObjectContext != nil) {
      if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
		NSLog(@"MIRAddRoomViewController: you have not entered a Room name %@", self.roomNameField.text);
   }
   else
   {
      //DebugLog(@"MIRAddRoomViewController: roomNameField: %@", self.roomNameField.text);
      [self saveRoomName:self.roomNameField.text];
  }
   
   [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)endEditing:(id)sender
{
   UITextField *roomName = (UITextField*)sender;
   [self saveRoomName:roomName.text];

   
   //DebugLog(@"endEditing: text: %@", roomName.text );
   [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
   
	[self.roomNameField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
