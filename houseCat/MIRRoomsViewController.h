//
//  MIRroomsViewController.h
//  houseCat
//
//  Created by kenl on 12/10/4.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MIRRoomsViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
