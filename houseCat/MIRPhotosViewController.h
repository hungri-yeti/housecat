//
//  MIRPhotosViewController.h
//  houseCat
//
//  Created by kenl on 12/11/1.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MIRPhotosViewController : UICollectionViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>


-(IBAction)done:(id)sender;
-(IBAction)addImage:(id)sender;


@end
