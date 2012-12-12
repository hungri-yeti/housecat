//
//  MIRAppDelegate.h
//  houseCat
//
//  Created by kenl on 12/10/4.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MIRAppDelegate : UIResponder <UIApplicationDelegate>


@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
