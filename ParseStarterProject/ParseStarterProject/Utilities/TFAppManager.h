//
//  TFAppManager.h
//  ParseStarterProject
//
//  Created by Parag Dulam on 23/02/15.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "ParseStarterProjectAppDelegate.h"

@interface TFAppManager : NSObject

+(ParseStarterProjectAppDelegate *) appDelegate;
+(void) getFaceImagesForUserId:(NSString *) userId completionBlock:(void(^)(id object,NSError *error))completionBlock;
+(void) saveCurrentUserWithCompletionBlock:(void(^)(id object,NSError *error))completionBlock;
+(void) saveFaceImageData:(NSData *)imData AtIndex:(int)index ForUserId:(NSString *)fbId WithCompletionBlock:(void(^)(id object,NSError *error))completionBlock;
+(NSString *) currentUserId;

@end
