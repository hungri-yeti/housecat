//
//  Items.h
//  houseCat
//
//  Created by kenl on 12/10/22.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Rooms;

@interface Items : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber *cost;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *notes;
@property (nonatomic, retain) NSDate *purchaseDate;
@property (nonatomic, retain) NSString *serialNumber;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) Rooms *room;
@end

@interface Items (CoreDataGeneratedAccessors)

- (void)addImagesObject:(NSManagedObject *)value;
- (void)removeImagesObject:(NSManagedObject *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
