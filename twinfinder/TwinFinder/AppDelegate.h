//
//  AppDelegate.h
//  TwinFinder
//
//  Created by Parag Dulam on 27/02/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#define CLICKED_FACE_PICTURE @"clickedProfilePicture.jpg"
#define CLICKED_PROFILE_PICTURE @"clickedProfilePicture.jpg"
#define MATCHES @"matches"

typedef enum {
    HOME = 0,
    PROFILE,
}TF_VIEW_TYPE;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSString *)clickedPicturePath;
- (NSString *)profilePicturePath;
-(NSString *)matchesPath;
-(void) flushDatabase;


@end

