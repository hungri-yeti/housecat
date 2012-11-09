//
//  MIRCell.h
//  houseCat
//
//  Created by kenl on 12/11/5.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Images.h"


@interface MIRCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property( strong, nonatomic ) Items *parentItem;
@property( strong, nonatomic ) Images *image;

@end
