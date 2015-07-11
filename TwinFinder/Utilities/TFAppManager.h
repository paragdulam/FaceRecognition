//
//  TFAppManager.h
//  ParseStarterProject
//
//  Created by Parag Dulam on 23/02/15.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"

@class FaceImage;
@class UserInfo;

@interface TFAppManager : NSObject

+(AppDelegate *) appDelegate;
+(void) getFaceImagesForUserId:(NSString *) userId completionBlock:(void(^)(id object,NSError *error))completionBlock;
+(void) saveCurrentUserWithCompletionBlock:(void(^)(id object,NSError *error))completionBlock;
+(void) saveFaceImageData:(NSData *)imData
                  AtIndex:(int)index
                ForUserId:(NSString *)fbId
        withProgressBlock:(void(^)(NSString *progressString,int progress))progressBlock
      WithCompletionBlock:(void(^)(id object, int type ,NSError *error))completionBlock;
+(NSString *) currentUserId;
+(void) getUserFriendsWithCompletionBlock:(void(^)(id object,NSError *error))completionBlock;
+(void) matchImageWithOtherUsers:(FaceImage *) faceImage withCompletionBlock:(void(^)(id obj,NSError *error))completionBlock;
+(void) getLookalikesForFaceImage:(FaceImage *) fImage withCompletionBlock:(void(^)(id object,NSError *error)) completionBlock;
+(void) saveFaceImageData:(NSData *)imData ForUserId:(NSString *)userId withProgressBlock:(void (^)(NSString *, int))progressBlock WithCompletionBlock:(void (^)(id, int, NSError *))completionBlock;

+(UserInfo *) userWithId:(NSString *) uid;
+(FaceImage *) faceImageWithUserId:(NSString *)uid;
+(void) saveFaceImage:(PFObject *) faceImage completionBlock:(void(^)(id obj,NSError *error))completionBlock;
+(void) saveUserinfo:(PFObject *) userInfo;
+(FaceImage *)faceImageWithFaceImageId:(NSString *) pid;
+(void) logout;
+(void) addMessageWithText:(NSString *) text ToUser:(UserInfo *) toUser onDate:(NSDate *) date;
+(NSArray *) messagesForFromUser:(UserInfo *) fromUser ToUser:(UserInfo *) toUser;
+(NSInteger) messageCountForFromUser:(UserInfo *) fromUser ToUser:(UserInfo *) toUser;
+(void) loadMessagesFromUser:(UserInfo *) fromUser ToUser:(UserInfo *) toUser completionBlock:(void(^)(NSError *error))completionBlock;




@end
