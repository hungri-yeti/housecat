//
//  MIRItemsDetailViewController.h
//  houseCat
//
//  Created by kenl on 12/10/23.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Items.h"
#import "Rooms.h"


@interface MIRItemsDetailViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
// Used to pass the parent (Room) in:
@property( strong, nonatomic ) Rooms *parent;


@property (weak, nonatomic) IBOutlet UITextField *itemDesc;
@property (weak, nonatomic) IBOutlet UITextField *itemPurchased;
@property (weak, nonatomic) IBOutlet UITextField *itemCost;
@property (weak, nonatomic) IBOutlet UITextField *itemSerial;
@property (weak, nonatomic) IBOutlet UITextView *itemNotes;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)saveButton:(id)sender;


@end
