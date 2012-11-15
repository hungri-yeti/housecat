//
//  Items.h
//  houseCat
//
//  Created by kenl on 12/11/15.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Images, Rooms;

@interface Items : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * cost;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSDate * purchaseDate;
@property (nonatomic, retain) NSNumber * selected;
@property (nonatomic, retain) NSString * serialNumber;
@property (nonatomic, retain) NSString * thumbPath;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) Rooms *room;
@end

@interface Items (CoreDataGeneratedAccessors)

- (void)addImagesObject:(Images *)value;
- (void)removeImagesObject:(Images *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
