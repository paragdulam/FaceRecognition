//
//  FaceImage.h
//  ParseStarterProject
//
//  Created by Parag Dulam on 23/02/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FaceAttribute, UserInfo;

@interface FaceImage : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) UserInfo *createdBy;
@property (nonatomic, retain) FaceAttribute *eye_left;
@property (nonatomic, retain) FaceAttribute *eye_right;
@property (nonatomic, retain) FaceAttribute *mouth;
@property (nonatomic, retain) FaceAttribute *nose;

@end
