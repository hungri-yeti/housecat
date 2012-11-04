//
//  Images.h
//  houseCat
//
//  Created by kenl on 12/11/3.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Items;

@interface Images : NSManagedObject

@property (nonatomic, retain) NSData * thumb;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * sort;
@property (nonatomic, retain) Items *item;

@end
