//
//  MIRItemsDetailViewController.h
//  houseCat
//
//  Created by kenl on 12/10/23.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Items.h"
#import "Rooms.h"


@interface MIRItemsDetailViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
// Used to pass objects in:
@property( strong, nonatomic ) Rooms *parent;
@property( strong, nonatomic ) Items *item;


@property (strong, nonatomic) IBOutlet UITextField *itemName;
@property (strong, nonatomic) IBOutlet UITextField *itemPurchaseDate;
@property (strong, nonatomic) IBOutlet UITextField *itemCost;
@property (strong, nonatomic) IBOutlet UITextField *itemSerialNumber;
@property (strong, nonatomic) IBOutlet UITextView *itemNotes;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIButton *photoButton;


@end
