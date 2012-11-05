//
//  MIRPhotosViewController.h
//  houseCat
//
//  Created by kenl on 12/11/1.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Items.h"
#import "Images.h"



@interface MIRPhotosViewController : UIViewController <NSFetchedResultsControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate>


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

// Used to pass the parent (Item) in:
@property( strong, nonatomic ) Items *item;


-(IBAction)done:(id)sender;
-(IBAction)addImage:(id)sender;

-(NSString*)uniqueImagePath;
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;


- (void) dumpView: (UIView *) aView atIndent: (int) indent
             into:(NSMutableString *) outstring;
- (NSString *) displayViews: (UIView *) aView;

@end
