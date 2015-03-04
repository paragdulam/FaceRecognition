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
              ForUserInfo:(UserInfo *)user
        withProgressBlock:(void(^)(NSString *progressString,int progress))progressBlock
      WithCompletionBlock:(void(^)(id object, int type ,NSError *error))completionBlock;
+(NSString *) currentUserId;
+(void) getUserFriendsWithCompletionBlock:(void(^)(id object,NSError *error))completionBlock;
+(void) getLookalikesForFaceImage:(FaceImage *) fImage withCompletionBlock:(void(^)(id object,NSError *error)) completionBlock;


+(NSArray *) faceImagesForUserid:(NSString *) uid;
+(NSArray *) lookalikesForUserid:(NSString *) uid;



@end
