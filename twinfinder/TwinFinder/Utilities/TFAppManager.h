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

@interface TFAppManager : NSObject

+(AppDelegate *) appDelegate;
+(void) getFaceImagesForUserId:(NSString *) userId completionBlock:(void(^)(id object,NSError *error))completionBlock;
+(void) saveCurrentUserWithCompletionBlock:(void(^)(id object,NSError *error))completionBlock;
+(void) saveFaceImageData:(NSData *)imData AtIndex:(int)index ForUserId:(NSString *)fbId withProgressBlock:(void(^)(NSString *))progressBlock WithCompletionBlock:(void(^)(id object, int type ,NSError *error))completionBlock;
+(NSString *) currentUserId;
+(void) getUserFriendsWithCompletionBlock:(void(^)(id object,NSError *error))completionBlock;
+(void) matchImageWithOtherUsers:(FaceImage *) faceImage withCompletionBlock:(void(^)(id obj,NSError *error))completionBlock;

@end
