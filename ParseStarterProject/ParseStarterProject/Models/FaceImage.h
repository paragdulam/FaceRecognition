//
//  FaceImage.h
//  ParseStarterProject
//
//  Created by Parag Dulam on 16/02/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserInfo;

@interface FaceImage : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) UserInfo *image_user;

@end
