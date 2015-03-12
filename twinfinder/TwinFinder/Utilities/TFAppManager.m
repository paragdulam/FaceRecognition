//
//  TFAppManager.m
//  ParseStarterProject
//
//  Created by Parag Dulam on 23/02/15.
//
//

#import "TFAppManager.h"
#import "UserInfo.h"
#import "FaceImage.h"
#import "UserInfo.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

#define TF_CURRENT_USER_ID @"TF_CURRENT_USER_ID"



@implementation TFAppManager


+(AppDelegate *) appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


+(NSString *) currentUserId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:TF_CURRENT_USER_ID];
}



+ (NSString *)age:(NSDate *)dateOfBirth {
    NSInteger years;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponentsNow = [calendar components:unitFlags fromDate:[NSDate date]];
    NSDateComponents *dateComponentsBirth = [calendar components:unitFlags fromDate:dateOfBirth];
    
    if (([dateComponentsNow month] < [dateComponentsBirth month]) ||
        (([dateComponentsNow month] == [dateComponentsBirth month]) && ([dateComponentsNow day] < [dateComponentsBirth day]))) {
        years = [dateComponentsNow year] - [dateComponentsBirth year] - 1;
    } else {
        years = [dateComponentsNow year] - [dateComponentsBirth year];
    }
    return [NSString stringWithFormat:@"%d",years];
}


+(void) getUserFromCacheForId:(NSString *) fbId completionBlock:(void(^)(id object,NSError *error))completionBlock
{
    NSFetchRequest *userRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserInfo"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parse_id == %@",fbId];
    [userRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *users = [self.appDelegate.managedObjectContext executeFetchRequest:userRequest error:nil];
    completionBlock([users firstObject],error);
}


+(void) getUserImagesWithId:(NSString *)fbId andCompletionBlock :(void(^)(id object,NSError *error))completionBlock
{
    [PFCloud callFunctionInBackground:@"getFaceImages" withParameters:@{@"uid":fbId} block:^(id object, NSError *error) {
        NSArray *images = (NSArray *)object;
        if ([images count]) {
            for (PFObject *faceImage in images) {
                int index = [[faceImage objectForKey:@"imageIndex"] intValue];
                [TFAppManager getFaceImageForUserId:fbId andIndex:index withCompletionBlock:^(id object, NSError *error) {
                    FaceImage *fImage = (FaceImage *)object;
                    if (!fImage) {
                        fImage = (FaceImage *)[NSEntityDescription insertNewObjectForEntityForName:@"FaceImage" inManagedObjectContext:[TFAppManager appDelegate].managedObjectContext];
                    }
                    fImage.index = [NSNumber numberWithInt:index];
                    fImage.parse_id = faceImage.objectId;
                    
                    PFFile *imageFile = [faceImage objectForKey:@"imageFile"];
                    fImage.image_url = imageFile.url;
                    completionBlock(fImage,error);

                    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        [[TFAppManager appDelegate].managedObjectContext save:nil];
                    }];
                }];
            }
        } else {
            completionBlock(nil,nil);
        }
    }];
}



+(void) getUserFriendsWithCompletionBlock:(void(^)(id object,NSError *error))completionBlock
{
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        completionBlock(result,error);
    }];
}


+(void) getUserInfoWithCompletionBlock:(void(^)(id object,NSError *error))completionBlock
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSString *facebookId = [result objectForKey:@"id"];
        
        [[NSUserDefaults standardUserDefaults] setObject:facebookId forKey:TF_CURRENT_USER_ID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UserInfo *userInfo = nil;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserInfo"];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"facebookId == %@",facebookId]];
        NSArray *userInfos = [[TFAppManager appDelegate].managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
        if ([userInfos count]) {
            userInfo = [userInfos firstObject];
        } else {
            userInfo = (UserInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"UserInfo"
                                                                 inManagedObjectContext:self.appDelegate.managedObjectContext];
        }
        NSString *birthday = [result objectForKey:@"birthday"];
        if (birthday) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
            NSDate *date = [dateFormatter dateFromString:birthday];
            [userInfo setAge:[TFAppManager age:date]];
        }
        [userInfo setName:[result objectForKey:@"name"]];
        [userInfo setFirstName:[result objectForKey:@"first_name"]];
        [userInfo setLastName:[result objectForKey:@"last_name"]];
        [userInfo setGender:[result objectForKey:@"gender"]];
        if (!error) {
            [[TFAppManager appDelegate].managedObjectContext save:nil];
            
            PFQuery *uInfoQuery = [PFQuery queryWithClassName:@"UserInfo"];
            [uInfoQuery whereKey:@"facebookId" equalTo:facebookId];
            [uInfoQuery whereKey:@"User" equalTo:[PFUser currentUser]];
            [uInfoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                PFObject *uInfo = nil;
                if ([objects count]) {
                    uInfo = [objects firstObject];
                } else {
                    uInfo = [PFObject objectWithClassName:@"UserInfo"];
                }
                [uInfo setObject:userInfo.name forKey:@"name"];
                [uInfo setObject:userInfo.firstName forKey:@"firstName"];
                [uInfo setObject:userInfo.lastName forKey:@"lastName"];
                if (birthday) {
                    [uInfo setObject:userInfo.age forKey:@"age"];
                }
                [uInfo setObject:userInfo.gender forKey:@"gender"];
                [uInfo setObject:[PFUser currentUser] forKey:@"User"];
                [uInfo setObject:facebookId forKey:@"facebookId"];
                [uInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                }];
            }];
        }
        completionBlock(userInfo,error);
    }];

}


+(void) saveCurrentUserWithCompletionBlock:(void(^)(id object,NSError *error))completionBlock
{
    NSString *facebookId = [TFAppManager currentUserId];
    __block UserInfo *userInfo = nil;
    if (facebookId) {
        [TFAppManager getUserFromCacheForId:facebookId completionBlock:^(id object, NSError *error) {
            userInfo = (UserInfo *)object;
            if (!userInfo) {
                [TFAppManager getUserInfoWithCompletionBlock:completionBlock];
            } else {
                completionBlock(userInfo,error);
            }
        }];
    } else {
        [TFAppManager getUserInfoWithCompletionBlock:completionBlock];
    }
}



+(void) getFaceImagesForUserId:(NSString *) userId completionBlock:(void(^)(id object,NSError *error))completionBlock
{
    NSFetchRequest *faceImageRequest = [[NSFetchRequest alloc] initWithEntityName:@"FaceImage"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"createdBy.parse_id == %@",userId];
    [faceImageRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *faceImages = [self.appDelegate.managedObjectContext executeFetchRequest:faceImageRequest error:&error];
    if ([faceImages count]) {
        completionBlock(faceImages,error);
        [TFAppManager getUserImagesWithId:userId andCompletionBlock:completionBlock];
    } else {
        [TFAppManager getUserImagesWithId:userId andCompletionBlock:completionBlock];
    }
}



+(void) getFaceImageForUserId:(NSString *)uid andIndex:(int) index withCompletionBlock:(void(^)(id object,NSError *error))completionBlock
{
    NSFetchRequest *faceImageRequest = [[NSFetchRequest alloc] initWithEntityName:@"FaceImage"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"createdBy.parse_id == %@ && index == %@",uid,[NSNumber numberWithInt:index]];
    [faceImageRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *faceImages = [self.appDelegate.managedObjectContext executeFetchRequest:faceImageRequest error:&error];
    completionBlock([faceImages firstObject],error);
}






+(void) matchImageFile:(PFFile *) imageFile
           InNameSpace:(NSString *) namespace
   withCompletionBlock:(void(^)(id object,int type,NSError *error))completionBlock
{
    [PFCloud callFunctionInBackground:@"matchWithAllUsers" withParameters:@{@"namespace":namespace,@"urls":imageFile.url} block:^(id object, NSError *error) {
        if (!error) {
            NSDictionary *response = (NSDictionary *)object;
            NSArray *photos = [response objectForKey:@"photos"];
            NSDictionary *photo = [photos firstObject];
            NSArray *tags = [photo objectForKey:@"tags"];
            NSDictionary *tag = [tags firstObject];
            NSArray *uids = [tag objectForKey:@"uids"];
            if ([uids count]) {
                NSLog(@"uids %@",uids);
                for (NSDictionary *uid in uids) {
                    if ([[uid objectForKey:@"confidence"] intValue] > 70) {
                        //found similar face
                        NSString *uidString = [uid objectForKey:@"uid"];
                        NSString *faceImageId = [[uidString componentsSeparatedByString:@"@"] firstObject];
                        PFQuery *imageQuery = [PFQuery queryWithClassName:@"FaceImage"];
                        [imageQuery whereKey:@"objectId" equalTo:faceImageId];
                        [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            if ([objects count]) {
                                PFObject *faceImage = [objects firstObject];
                                
                                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FaceImage"];
                                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parse_id == %@",faceImage.objectId];
                                [fetchRequest setPredicate:predicate];
                                NSArray *fImages = [[TFAppManager appDelegate].managedObjectContext executeFetchRequest:fetchRequest error:nil];
                                FaceImage *fImage = nil;
                                if ([fImages count]) {
                                    fImage = [fImages firstObject];
                                } else {
                                    fImage = (FaceImage *)[NSEntityDescription insertNewObjectForEntityForName:@"FaceImage" inManagedObjectContext:[TFAppManager appDelegate].managedObjectContext];
                                }
                                PFFile *imageFile = [faceImage objectForKey:@"imageFile"];
                                PFUser *createdBy = [faceImage objectForKey:@"createdBy"];
                                if (![createdBy.objectId isEqualToString:[PFUser currentUser].objectId]) {
                                    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                        [[TFAppManager appDelegate].managedObjectContext save:nil];
                                        completionBlock(fImage,1,error);
                                    }];
                                } else {
                                    completionBlock(nil,1,error);
                                }
                            } else {
                                completionBlock(nil,1,error);
                            }
                        }];
                    } else {
                        completionBlock(nil,1,nil);
                    }
                }
            } else {
                completionBlock(nil,1,nil);
            }
        } else {
            completionBlock(nil,1,nil);
        }
    }];
}




+(void) imageFile:(PFFile *) imageFile
 savedToFaceImage:(FaceImage *) faceImage
          AtIndex:(int) index
withProgressBlock:(void(^)(NSString *progressString,int progress))progressBlock
WithCompletionHandler:(void(^)(id object,int type,NSError *error))completionBlock
{
    faceImage.image_url = imageFile.url;
    [[TFAppManager appDelegate].managedObjectContext save:nil];
    
    
    
    PFQuery *imageQuery = [PFQuery queryWithClassName:@"FaceImage"];
    [imageQuery whereKey:@"createdBy" equalTo:[PFUser currentUser]];
    [imageQuery whereKey:@"imageIndex" equalTo:[NSNumber numberWithInt:index]];
    [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *parseImage = nil;
        if ([objects count]) {
            parseImage = [objects firstObject];
        } else {
            parseImage = [PFObject objectWithClassName:@"FaceImage"];
        }
        [parseImage setObject:imageFile forKey:@"imageFile"];
        [parseImage setObject:[NSNumber numberWithInt:index] forKey:@"imageIndex"];
        [parseImage setObject:[PFUser currentUser] forKey:@"createdBy"];
        [parseImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                {
                    faceImage.parse_id = parseImage.objectId;
                    [[TFAppManager appDelegate].managedObjectContext save:nil];
                    
                    progressBlock(@"Detecting Face...",0);
                    [PFCloud callFunctionInBackground:@"detectFace"
                                       withParameters:@{@"faceImageId":parseImage.objectId}
                                                block:^(id object, NSError *error) {
                                                    if (!error) {
                                                        NSDictionary *faceFeatures = (NSDictionary *)object;
                                                        NSArray *photos = [faceFeatures objectForKey:@"photos"];
                                                        NSDictionary *photo = [photos firstObject];
                                                        NSArray *tags = [photo objectForKey:@"tags"];
                                                        NSDictionary *tag = [tags firstObject];
                                                        NSString *tid = tag[@"tid"];
                                                        [PFCloud callFunctionInBackground:@"getAppNamespace"
                                                                           withParameters:@{}
                                                                                    block:^(id object, NSError *error) {
                                                                                        if (!error) {
                                                                                            NSDictionary *response = (NSDictionary *)object;
                                                                                            NSArray *namespaces = [response objectForKey:@"namespaces"] ;
                                                                                            NSString *namespace = [[namespaces firstObject] objectForKey:@"name"];
                                                                                            NSString *uid = [NSString stringWithFormat:@"%@@%@",parseImage.objectId,namespace];
                                                                                            [PFCloud callFunctionInBackground:@"saveTag" withParameters:@{@"tid":tid,@"uid":uid} block:^(id object, NSError *error) {
                                                                                                progressBlock(@"Training the Image...",0);
                                                                                                [TFAppManager matchImageFile:imageFile
                                                                                                                 InNameSpace:namespace
                                                                                                         withCompletionBlock:completionBlock];
                                                                                            }];
                                                                                        } else {
                                                                                            completionBlock(nil,0,error);
                                                                                        }
                                                                                    }];
                                                    } else {
                                                        completionBlock(nil,1,error);
                                                    }
                                                }];
                }
            } else {
                completionBlock(nil,1,error);
            }
        }];
    }];
}


+(NSDictionary *) uidDictFromId:(NSString *) pId inLookalikes:(NSArray *) lookalikes
{
    for (NSDictionary *uidDict in lookalikes) {
        NSString *uid = [[[uidDict objectForKey:@"uid"] componentsSeparatedByString:@"@"] firstObject];
        if ([uid isEqualToString:pId]) {
            return uidDict;
        }
    }
    return nil;
}


+(void) getLookalikesForFaceImage:(FaceImage *) fImage withCompletionBlock:(void(^)(id object,NSError *error)) completionBlock
{
    [PFCloud callFunctionInBackground:@"getLookalikes" withParameters:@{@"faceImageId":fImage.parse_id} block:^(id object, NSError *error) {
        NSArray *lookalikes = [object objectForKey:@"lookalikes"];
        if ([lookalikes count]) {
            for (int i = 0; i < [lookalikes count]; i++) {
                NSDictionary *uidDict = [lookalikes objectAtIndex:i];
                NSString *uid = [[[uidDict objectForKey:@"uid"] componentsSeparatedByString:@"@"] firstObject];
                PFQuery *query = [PFQuery queryWithClassName:@"FaceImage"];
                [query whereKey:@"objectId" equalTo:uid];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    PFObject *pImage = [objects objectAtIndex:0];
                    PFUser *createdBy = [pImage objectForKey:@"createdBy"];
                    if (![createdBy.objectId isEqualToString:[PFUser currentUser].objectId]) {
                        [TFAppManager saveFaceImage:pImage completionBlock:^(id obj, NSError *error) {
                            FaceImage *facImage = (FaceImage *)obj;
                            NSDictionary *uDict = [TFAppManager uidDictFromId:facImage.parse_id inLookalikes:lookalikes];
                            facImage.confidence = [uDict objectForKey:@"confidence"];
                            [[TFAppManager appDelegate].managedObjectContext save:nil];
                            completionBlock(facImage,error);
                        }];
                    } else {
                        completionBlock(nil,nil);
                    }
                }];
            }
        } else {
            completionBlock(nil,nil);
        }
    }];
}



+(UserInfo *) userWithId:(NSString *) uid
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserInfo"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parse_id == %@",uid]];
    NSArray *userInfos = [[TFAppManager appDelegate].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return [userInfos firstObject];
}


+(FaceImage *)faceImageWithFaceImageId:(NSString *) pid
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FaceImage"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parse_id == %@",pid]];
    NSArray *faceImages = [[TFAppManager appDelegate].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return [faceImages firstObject];
}


+(FaceImage *) faceImageWithUserId:(NSString *)uid
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FaceImage"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"createdBy.parse_id == %@",uid]];
    NSArray *faceImages = [[TFAppManager appDelegate].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return [faceImages firstObject];
}

+(void) saveFaceImage:(PFObject *) faceImage completionBlock:(void(^)(id obj,NSError *error))completionBlock
{
    PFUser *user = [faceImage objectForKey:@"createdBy"];
    UserInfo *uInfo = [TFAppManager userWithId:user.objectId];
    if (!uInfo) {
        uInfo = (UserInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:[TFAppManager appDelegate].managedObjectContext];
    }
    
    PFQuery *userInfoQuery = [PFQuery queryWithClassName:@"UserInfo"];
    [userInfoQuery whereKey:@"User" equalTo:user];
    [userInfoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *userInfo = [objects firstObject];
        NSString *name = [userInfo objectForKey:@"name"];
        uInfo.name = name;
        uInfo.age = [userInfo objectForKey:@"age"];
        uInfo.city = [userInfo objectForKey:@"city"];
        uInfo.location = [userInfo objectForKey:@"location"];
        uInfo.national = [userInfo objectForKey:@"national"];
        uInfo.parse_id = user.objectId;
        
        FaceImage *fImage = [TFAppManager faceImageWithUserId:user.objectId];
        if (!fImage) {
            fImage = (FaceImage *)[NSEntityDescription insertNewObjectForEntityForName:@"FaceImage" inManagedObjectContext:[TFAppManager appDelegate].managedObjectContext];
        }
        
        fImage.index = [faceImage objectForKey:@"imageIndex"];
        fImage.parse_id = faceImage.objectId;
        PFFile *imageFile = [faceImage objectForKey:@"imageFile"];
        fImage.image_url = imageFile.url;
        fImage.createdBy = uInfo;
        [[TFAppManager appDelegate].managedObjectContext save:nil];
        completionBlock(fImage,error);
    }];
}




+(void) saveUserinfo:(PFObject *) userInfo
{
    PFUser *user = [userInfo objectForKey:@"User"];
    UserInfo *uInfo = [TFAppManager userWithId:user.objectId];
    if (!uInfo) {
        uInfo = (UserInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:[TFAppManager appDelegate].managedObjectContext];
    }
    
    uInfo.name = [userInfo objectForKey:@"name"];
    uInfo.age = [userInfo objectForKey:@"age"];
    uInfo.city = [userInfo objectForKey:@"city"];
    uInfo.location = [userInfo objectForKey:@"location"];
    uInfo.national = [userInfo objectForKey:@"national"];
    uInfo.parse_id = user.objectId;
    [[TFAppManager appDelegate].managedObjectContext save:nil];
}


+(void) saveFaceImageData:(NSData *)imData
                  AtIndex:(int)index
                ForUserId:(NSString *)fbId
        withProgressBlock:(void(^)(NSString *progressString,int progress))progressBlock
      WithCompletionBlock:(void(^)(id object, int type ,NSError *error))completionBlock
{
    progressBlock(@"Uploading...",0);
    FaceImage *faceImage = [TFAppManager faceImageWithUserId:fbId];
    if (!faceImage) {
        faceImage = (FaceImage *)[NSEntityDescription insertNewObjectForEntityForName:@"FaceImage" inManagedObjectContext:[TFAppManager appDelegate].managedObjectContext];
    }
    faceImage.index = [NSNumber numberWithInt:index];
    faceImage.createdBy = [TFAppManager userWithId:fbId];
    NSError *saveError = nil;
    [[TFAppManager appDelegate].managedObjectContext save:&saveError];
    completionBlock(faceImage,0,saveError);
    
    PFFile *imageFile = [PFFile fileWithData:imData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            faceImage.image_url = imageFile.url;
            [[TFAppManager appDelegate].managedObjectContext save:nil];
            
            PFQuery *imageQuery = [PFQuery queryWithClassName:@"FaceImage"];
            [imageQuery whereKey:@"createdBy" equalTo:[PFUser currentUser]];
            [imageQuery whereKey:@"imageIndex" equalTo:[NSNumber numberWithInt:index]];
            [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                PFObject *parseImage = nil;
                if ([objects count]) {
                    parseImage = [objects firstObject];
                } else {
                    parseImage = [PFObject objectWithClassName:@"FaceImage"];
                }
                [parseImage setObject:imageFile forKey:@"imageFile"];
                [parseImage setObject:[NSNumber numberWithInt:index] forKey:@"imageIndex"];
                [parseImage setObject:[PFUser currentUser] forKey:@"createdBy"];
                [parseImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    faceImage.parse_id = parseImage.objectId;
                    [[TFAppManager appDelegate].managedObjectContext save:nil];
                    completionBlock(faceImage,1,nil);
                }];
            }];
        } else {
            NSError *uploadError = nil;
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"There was a problem uploading your face image. Please retry!" forKey:NSLocalizedDescriptionKey];
            uploadError = [NSError errorWithDomain:@"Upload Image Error" code:200 userInfo:details];
            completionBlock(nil,1,uploadError);
        }
    }
       progressBlock:^(int percentDone) {
           NSMutableString *text = [[NSMutableString alloc] init];
           [text appendString:@"Uploading"];
           if (percentDone) {
               [text appendFormat:@"(%d%%)",percentDone];
           }
           [text appendString:@"..."];
           progressBlock(text,percentDone);
       }];
}



+(void) matchImageWithOtherUsers:(FaceImage *) faceImage withCompletionBlock:(void(^)(id obj,NSError *error))completionBlock
{
    [PFCloud callFunctionInBackground:@"getAppNamespace" withParameters:@{} block:^(id object, NSError *error) {
        NSDictionary *response = (NSDictionary *)object;
        NSArray *namespaces = [response objectForKey:@"namespaces"] ;
        NSString *namespace = [[namespaces firstObject] objectForKey:@"name"];
        [PFCloud callFunctionInBackground:@"matchWithAllUsers" withParameters:@{@"namespace":namespace,@"urls":faceImage.image_url} block:^(id object, NSError *error) {
            NSDictionary *response = (NSDictionary *)object;
            NSArray *photos = [response objectForKey:@"photos"];
            NSDictionary *photo = [photos firstObject];
            NSArray *tags = [photo objectForKey:@"tags"];
            NSDictionary *tag = [tags firstObject];
            NSArray *uids = [tag objectForKey:@"uids"];
            for (NSDictionary *uid in uids) {
                if ([[uid objectForKey:@"confidence"] intValue] > 70) {
                    //found similar face
                    NSString *uidString = [uid objectForKey:@"uid"];
                    NSString *faceImageId = [[uidString componentsSeparatedByString:@"@"] firstObject];
                    PFQuery *imageQuery = [PFQuery queryWithClassName:@"FaceImage"];
                    [imageQuery whereKey:@"objectId" equalTo:faceImageId];
                    [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if ([objects count]) {
                            PFObject *parseFaceImage = [objects objectAtIndex:0];
                            
                            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FaceImage"];
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parse_id == %@",parseFaceImage.objectId];
                            [fetchRequest setPredicate:predicate];
                            NSArray *fImages = [[TFAppManager appDelegate].managedObjectContext executeFetchRequest:fetchRequest error:nil];
                            FaceImage *fImage = nil;
                            if ([fImages count]) {
                                fImage = [fImages firstObject];
                            } else {
                                fImage = (FaceImage *)[NSEntityDescription insertNewObjectForEntityForName:@"FaceImage"
                                                                                    inManagedObjectContext:[TFAppManager appDelegate].managedObjectContext];
                            }
                            PFFile *imageFile = [parseFaceImage objectForKey:@"imageFile"];
                            PFUser *createdBy = [parseFaceImage objectForKey:@"createdBy"];
                            if (![createdBy.objectId isEqualToString:[PFUser currentUser].objectId]) {
                                if (imageFile.isDataAvailable) {
                                    completionBlock(fImage,error);
                                } else {
                                    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                        [[TFAppManager appDelegate].managedObjectContext save:nil];
                                        completionBlock(fImage,error);
                                    }];
                                }
                            }
                        } else {
                            completionBlock(nil,nil);
                        }
                    }];
                }
            }
        }];
    }];
}



@end
