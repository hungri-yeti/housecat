//
//  MIRAppDelegate.m
//  houseCat
//
//  Created by kenl on 12/10/4.
//  Copyright (c) 2012 kl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MIRAppDelegate.h"
#import "MIRRoomsViewController.h"
#import "Rooms.h"
// these are only used when generating the launch images, not necessary for release.
#include <sys/types.h>
#include <pwd.h>
#include <uuid/uuid.h>


@implementation MIRAppDelegate
{
   NSArray *roomsItems;
}


@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	//NSLog(@"houseCat dir: %@", NSHomeDirectory() );
	
   // Override point for customization after application launch.
   UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
   MIRRoomsViewController *controller = (MIRRoomsViewController *)navigationController.topViewController;
   controller.managedObjectContext = self.managedObjectContext;

	// Get a reference to the stardard user defaults
   NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSError* error;
	NSFileManager *fileManager;
   
   // Check if the app has run before by checking a key in user defaults
   if ([prefs boolForKey:@"hasRunBefore"] != YES)
   {

      // Set flag so we know not to run this next time
      [prefs setBool:YES forKey:@"hasRunBefore"];
      [prefs synchronize];
		
		// create subdirs in Documents:
		fileManager = [NSFileManager defaultManager]; 
		
		NSURL *pdfURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"pdf"];
		BOOL results = [fileManager createDirectoryAtURL:pdfURL 
									 withIntermediateDirectories:NO 
															attributes:nil 
																  error:&error
							 ];
		if( NO == results )
		{
			NSLog(@"ERROR: unable to create pdf directory, error: %@", [error localizedDescription]);
         // Notify the user
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                         message:[error localizedFailureReason]
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK",@"Alert 'OK' (Cancel) button.")
                                               otherButtonTitles:nil];
         [alert show];
		}
		
		error = nil;
		NSURL *imgURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"img"];
		results = [fileManager createDirectoryAtURL:imgURL 
									 withIntermediateDirectories:NO 
															attributes:nil 
																  error:&error
							 ];
		if( NO == results )
		{
			NSLog(@"ERROR: unable to create img directory, error: %@", [error localizedDescription]);
         // Notify the user
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                         message:[error localizedFailureReason]
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK",@"Alert 'OK' (Cancel) button.")
                                               otherButtonTitles:nil];
         [alert show];
		}


//#ifdef SCREENSHOT
//#warning Screenshot Mode enabled!
//#else
      // Add our default Room list in Core Data
      NSArray *defaultRooms = [NSArray arrayWithObjects:
										 NSLocalizedString(@"Kitchen",@"default kitch room name"),
										 NSLocalizedString(@"Dining Room",@"default dining room name"),
										 NSLocalizedString(@"Living Room",@"default living room name"),
										 NSLocalizedString(@"Garage",@"default garage room name"),
										 NSLocalizedString(@"Master Bedroom",@"default master bedroom room name"),
										 NSLocalizedString(@"Den/Office",@"default den/office room name"),
										 NSLocalizedString(@"Car",@"default car room name"),
										 nil];
      for(NSString *roomName in defaultRooms)
      {
         Rooms *room = (Rooms *)[NSEntityDescription insertNewObjectForEntityForName:@"Rooms" inManagedObjectContext:self.managedObjectContext];
         [room setName:roomName];
      }
//#endif

      
		// debug: list out all rooms to log
      //NSFetchRequest *request = [[NSFetchRequest alloc] init];
      //NSEntityDescription *entity = [NSEntityDescription entityForName:@"Rooms"
      //                                          inManagedObjectContext:[self managedObjectContext]];
      //request.entity = entity;
      //NSArray *listOfRooms = [[self managedObjectContext] executeFetchRequest:request error:nil];
      //List out contents of each project
      //if([listOfRooms count] == 0)
      //   NSLog(@"There are no Rooms in the data store yet");
      //else {
      //   NSLog(@"Rooms contents:");
      //   [listOfRooms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      //      NSLog(@"   room.name = %@", [obj name]);
      //   }];
      //}
      
      // Commit to core data
      error = nil;
      if (![self.managedObjectContext save:&error])
      {
         NSLog(@"ERROR: save default Rooms: error: %@", [error localizedDescription]);
         // Notify the user
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                         message:[error localizedFailureReason]
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK",@"Alert 'OK' (Cancel) button.")
                                               otherButtonTitles:nil];
         [alert show];
      }
   }
	else
	{
		// clean out the pdf directory:
		error = nil;
		
		// List the files in the sandbox Documents/pdf folder
		NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/pdf"]; 
		fileManager = [NSFileManager defaultManager];
		NSArray* files = [fileManager contentsOfDirectoryAtPath:path error:&error];
      if (error != nil) 
      {
         NSLog(@"ERROR: contentsOfDirectoryAtPath failed, error: %@", [error localizedDescription]);
         // Notify the user
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                         message:[error localizedFailureReason]
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK",@"Alert 'OK' (Cancel) button.")
                                               otherButtonTitles:nil];
         [alert show];
      }

		for( NSString* file in files )
		{
         error = nil;
			NSString* pdfPath = [NSString stringWithFormat:@"%@/%@", path, file];
			[fileManager removeItemAtPath:pdfPath error:&error];
			
			if( error != nil)
			{
				NSLog(@"ERROR: removeItemAtPath failed, error: %@", [error localizedDescription] );
            // Notify the user
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK",@"Alert 'OK' (Cancel) button.")
                                                  otherButtonTitles:nil];
            [alert show];
			}
		}
	}

// from cocanetics:
//#ifdef SCREENSHOT
//	NSString *defaultImageName = @"Default.png";
//	//CGSize imageSize = [[UIScreen mainScreen] applicationFrame].size; // this doesn't include the status bar, which apparently xcode isists on.
//   CGSize imageSize = self.window.bounds.size;
//   NSLog(@"imageSize.width: %f, .height: %f\n", imageSize.width, imageSize.height);
//	CGFloat imageScale = [[UIScreen mainScreen] scale];
//
//	if (imageScale>1)
//	{
//		if (imageSize.height<500)
//		{
//			defaultImageName = @"Default@2x.png";
//		}
//		else
//		{
//			defaultImageName = @"Default-568h@2x.png";
//		}
//	}
//
//	UIGraphicsBeginImageContextWithOptions(imageSize, YES, imageScale);
//
//	[self.window.rootViewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
//
//	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//	UIGraphicsEndImageContext();
//
//	// thanks Cédric Luthi!
//	NSString *logname = [NSString stringWithCString:getenv("LOGNAME") encoding:NSUTF8StringEncoding];
//	struct passwd *pw = getpwnam([logname UTF8String]);
//	NSString *homeDir = pw ? [NSString stringWithCString:pw->pw_dir encoding:NSUTF8StringEncoding] : [@"/Users" stringByAppendingPathComponent:logname];
//
//	homeDir = [homeDir stringByAppendingPathComponent:@"Downloads"];
//
//	NSString *path = [homeDir stringByAppendingPathComponent:defaultImageName];
//	NSData *imageData = UIImagePNGRepresentation(image);
//	[imageData writeToFile:path atomically:NO];
//
//	NSLog(@"Image saved at %@", path);
//#endif
  
   return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
   // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
   // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
   // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
   // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
   // Saves changes in the application's managed object context before the application terminates.
   [self saveContext];
}

- (void)saveContext
{
   NSError *error = nil;
   NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
   if (managedObjectContext != nil) {
      if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         NSLog(@"ERROR: [managedObjectContext save] failed: %@", [error localizedDescription]);
         // Notify the user
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                         message:[error localizedFailureReason]
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK",@"Alert 'OK' (Cancel) button.")
                                               otherButtonTitles:nil];
         [alert show];

         abort();
      }
   }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
   if (_managedObjectContext != nil) {
      return _managedObjectContext;
   }
   
   NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
   if (coordinator != nil) {
      _managedObjectContext = [[NSManagedObjectContext alloc] init];
      [_managedObjectContext setPersistentStoreCoordinator:coordinator];
   }
   return _managedObjectContext;
}


// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
   if (_managedObjectModel != nil) {
      return _managedObjectModel;
   }
   NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"houseCat" withExtension:@"momd"];
   _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
   return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
   if (_persistentStoreCoordinator != nil) {
      return _persistentStoreCoordinator;
   }
   
   NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"houseCat"];
   NSError *error = nil;
   _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

   NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                            [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
   if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
   {
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
       
       Typical reasons for an error here include:
       * The persistent store is not accessible;
       * The schema for the persistent store is incompatible with current managed object model.
       Check the error message to determine what the actual problem was.
       
       
       If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
       
       If you encounter schema incompatibility errors during development, you can reduce their frequency by:
       * Simply deleting the existing store:
       [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
       
       * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
       @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
       
       Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
       
       */
      NSLog(@"ERROR: [persistentStoreCoordinator addPersistentStoreWithType] failed: %@", [error localizedDescription]);
      // Notify the user
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                      message:[error localizedFailureReason]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK",@"Alert 'OK' (Cancel) button.")
                                            otherButtonTitles:nil];
      [alert show];

      abort();
   }
   return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
   return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
