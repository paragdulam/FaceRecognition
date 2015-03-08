//
//  FaceImage.h
//  TwinFinder
//
//  Created by Parag Dulam on 08/03/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserInfo;

@interface FaceImage : NSManagedObject

@property (nonatomic, retain) NSString * image_url;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * parse_id;
@property (nonatomic, retain) NSString * temp_id;
@property (nonatomic, retain) UserInfo *createdBy;

@end
