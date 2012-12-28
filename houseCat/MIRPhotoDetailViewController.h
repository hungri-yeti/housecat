//
//  MIRPhotoDetailViewController.h
//  houseCat
//
//  Created by kenl on 12/11/5.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Images.h"

@interface MIRPhotoDetailViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
// Used to pass objects in:
@property( strong, nonatomic ) Images *image;

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
- (IBAction)deleteImage:(id)sender;

@end
