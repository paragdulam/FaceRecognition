//
//  FaceImage.h
//  ParseStarterProject
//
//  Created by Parag Dulam on 25/02/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserInfo;

@interface FaceImage : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * image_url;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSNumber * confidence;
@property (nonatomic, retain) NSString * parse_id;
@property (nonatomic, retain) UserInfo *createdBy;

@end
