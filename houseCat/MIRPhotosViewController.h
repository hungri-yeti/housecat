//
//  MIRPhotosViewController.h
//  houseCat
//
//  Created by kenl on 12/11/1.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Items.h"


@interface MIRPhotosViewController : UIViewController <NSFetchedResultsControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

// Used to pass the parent (Item) in:
@property( strong, nonatomic ) Items *parent;


-(IBAction)done:(id)sender;
-(IBAction)addImage:(id)sender;


@end
