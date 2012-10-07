//
//  MIRitemsViewController.h
//  houseCat
//
//  Created by kenl on 12/10/4.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MIRItemsViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong ) NSArray *items;

@end
