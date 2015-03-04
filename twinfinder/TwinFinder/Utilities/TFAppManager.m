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


#pragma mark - Helpers

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



#pragma mark - Cache Readers



+(UserInfo *) userForId:(NSString *) fbId
{
    NSFetchRequest *userRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserInfo"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookId == %@",fbId];
    [userRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *users = [self.appDelegate.managedObjectContext executeFetchRequest:userRequest error:&error];
    return [users count] ? [users firstObject] : nil;
}


+(FaceImage *) faceImageForId:(NSString *)parseId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FaceImage"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parse_id == %@ && confidence != 0",parseId];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *faceImages = [self.appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return [faceImages count] ? [faceImages firstObject] : nil;
}



+(NSArray *) faceImagesForUserid:(NSString *) uid
{
    NSFetchRequest *userRequest = [[NSFetchRequest alloc] initWithEntityName:@"FaceImage"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"createdBy.facebookId == %@",uid];
    [userRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    [userRequest setSortDescriptors:@[sortDescriptor]];
    NSError *error = nil;
    return [self.appDelegate.managedObjectContext executeFetchRequest:userRequest error:&error];;
}


+(NSArray *) lookalikesForUserid:(NSString *) uid
{
    NSFetchRequest *userRequest = [[NSFetchRequest alloc] initWithEntityName:@"FaceImage"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"createdBy.facebookId != %@",uid];
    [userRequest setPredicate:predicate];
    NSError *error = nil;
    return [self.appDelegate.managedObjectContext executeFetchRequest:userRequest error:&error];
}



+(FaceImage *) faceImageForUserId:(NSString *)uid andIndex:(int) index
{
    NSFetchRequest *faceImageRequest = [[NSFetchRequest alloc] initWithEntityName:@"FaceImage"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"createdBy.facebookId == %@ && index == %@",[TFAppManager currentUserId],[NSNumber numberWithInt:index]];
    [faceImageRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *faceImages = [self.appDelegate.managedObjectContext executeFetchRequest:faceImageRequest error:&error];
    return [faceImages count] ? [faceImages firstObject] : nil;
}


#pragma mark - Network Requests

+(void) getUserImagesWithId:(NSString *)fbId andCompletionBlock :(void(^)(id object,NSError *error))completionBlock
{
    [PFCloud callFunctionInBackground:@"getFaceImages" withParameters:@{@"uid":fbId} block:^(id object, NSError *error) {
        NSArray *images = (NSArray *)object;
        if ([images count]) {
            for (PFObject *faceImage in images) {
                int index = [[faceImage objectForKey:@"imageIndex"] intValue];
                FaceImage *fImage = [TFAppManager faceImageForUserId:fbId andIndex:index];
                if (!fImage) {
                    fImage = (FaceImage *)[NSEntityDescription insertNewObjectForEntityForName:@"FaceImage" inManagedObjectContext:[TFAppManager appDelegate].managedObjectContext];
                }
                fImage.index = [NSNumber numberWithInt:index];
                fImage.parse_id = faceImage.objectId;
                fImage.createdBy = [TFAppManager userForId:fbId];
                
                PFFile *imageFile = [faceImage objectForKey:@"imageFile"];
                fImage.image_url = imageFile.url;
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    fImage.image = data;
                    [[TFAppManager appDelegate].managedObjectContext save:nil];
                    completionBlock(fImage,error);
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
        
        UserInfo *userInfo = [TFAppManager userForId:facebookId];
        if (!userInfo) {
            userInfo = (UserInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"UserInfo"
                                                                 inManagedObjectContext:self.appDelegate.managedObjectContext];
        }
        [userInfo setFacebookId:facebookId];
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
            
            //upload to Parse
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
        userInfo = [TFAppManager userForId:facebookId];
        if (!userInfo) {
            [TFAppManager getUserInfoWithCompletionBlock:completionBlock];
        } else {
            completionBlock(userInfo,nil);
        }
    } else {
        [TFAppManager getUserInfoWithCompletionBlock:completionBlock];
    }
}


+(void) getFaceImagesForUserId:(NSString *) userId completionBlock:(void(^)(id object,NSError *error))completionBlock
{
    NSArray *faceImages = [TFAppManager faceImagesForUserid:userId];
    if ([faceImages count]) {
        completionBlock(faceImages,nil);
    }
    [TFAppManager getUserImagesWithId:userId andCompletionBlock:completionBlock];
}




+(void) getLookalikesForFaceImage:(FaceImage *) fImage withCompletionBlock:(void(^)(id object,NSError *error)) completionBlock
{
    [PFCloud callFunctionInBackground:@"getLookalikes" withParameters:@{@"faceImageId":fImage.parse_id} block:^(id object, NSError *error) {
        if (!error) {
            NSArray *lookalikes = [object objectForKey:@"lookalikes"];
            if ([lookalikes count]) {
                NSMutableArray *finalLookalikes = [[NSMutableArray alloc] init];
                for (NSDictionary *uidDict in lookalikes) {
                    NSString *uid = [[[uidDict objectForKey:@"uid"] componentsSeparatedByString:@"@"] firstObject];
                    PFQuery *query = [PFQuery queryWithClassName:@"FaceImage"];
                    [query whereKey:@"objectId" equalTo:uid];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        PFObject *pImage = [objects objectAtIndex:0];
                        PFUser *createdBy = [pImage objectForKey:@"createdBy"];
                        if (![createdBy.objectId isEqualToString:[PFUser currentUser].objectId]) {
                            
                            PFQuery *userQuery = [PFQuery queryWithClassName:@"UserInfo"];
                            [userQuery whereKey:@"User" equalTo:createdBy];
                            [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                PFObject *pUserInfo = [objects firstObject];
                                
                                NSString *createdByFbId = [pUserInfo objectForKey:@"facebookId"];
                                UserInfo *createdByObj = [TFAppManager userForId:createdByFbId];
                                if (!createdByObj) {
                                    createdByObj = (UserInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:[TFAppManager appDelegate].managedObjectContext];
                                }
                                
                                [createdByObj setFacebookId:createdByFbId];
                                [createdByObj setName:[pUserInfo objectForKey:@"name"]];
                                [createdByObj setFirstName:[pUserInfo objectForKey:@"firstName"]];
                                [createdByObj setLastName:[pUserInfo objectForKey:@"lastName"]];
                                [createdByObj setGender:[pUserInfo objectForKey:@"gender"]];
                                [[TFAppManager appDelegate].managedObjectContext save:nil];
                                
                                FaceImage *facImage = [TFAppManager faceImageForId:pImage.objectId];
                                if (!facImage) {
                                    facImage = (FaceImage *)[NSEntityDescription insertNewObjectForEntityForName:@"FaceImage" inManagedObjectContext:[TFAppManager appDelegate].managedObjectContext];
                                }
                                facImage.index = [pImage objectForKey:@"imageIndex"];
                                facImage.confidence = [uidDict objectForKey:@"confidence"];
                                PFFile *imgFile = [pImage objectForKey:@"imageFile"];
                                facImage.image_url = imgFile.url;
                                facImage.parse_id = pImage.objectId;
                                facImage.createdBy = createdByObj;
                                NSLog(@"parse_id saved%@",facImage.parse_id);
                                [[TFAppManager appDelegate].managedObjectContext save:nil];
                                
                                [imgFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                    facImage.image = data;
                                    [[TFAppManager appDelegate].managedObjectContext save:nil];
                                    NSLog(@"parse_id final saved %@",facImage.parse_id);
                                    [finalLookalikes addObject:facImage];
                                    
                                    if ([uidDict isEqualToDictionary:[lookalikes lastObject]]) {
                                        completionBlock(finalLookalikes,error);
                                    }
                                }];
                            }];
                        } else {
                            completionBlock(nil,nil);
                        }
                    }];
                }
            } else {
                completionBlock(nil,nil);
            }
        } else {
            completionBlock(nil,error);
        }
    }];
}

+(void) saveFaceImageData:(NSData *)imData
                  AtIndex:(int)index
              ForUserInfo:(UserInfo *)user
        withProgressBlock:(void(^)(NSString *progressString,int progress))progressBlock
      WithCompletionBlock:(void(^)(id object, int type ,NSError *error))completionBlock
{
    progressBlock(@"Uploading...",0);
    FaceImage *faceImage = [TFAppManager faceImageForUserId:user.facebookId andIndex:index];
    if (!faceImage) {
        faceImage = (FaceImage *)[NSEntityDescription insertNewObjectForEntityForName:@"FaceImage" inManagedObjectContext:[TFAppManager appDelegate].managedObjectContext];
    }
    faceImage.createdBy = user;
    faceImage.index = [NSNumber numberWithInt:index];
    faceImage.image = imData;
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
                    [TFAppManager getLookalikesForFaceImage:faceImage withCompletionBlock:^(id object, NSError *error) {
                        completionBlock(object,1,error);
                    }];
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


@end
