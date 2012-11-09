//
//  Images.h
//  houseCat
//
//  Created by kenl on 12/11/8.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Items;

@interface Images : NSManagedObject

@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSString * thumbPath;
@property (nonatomic, retain) Items *parentItem;

@end
