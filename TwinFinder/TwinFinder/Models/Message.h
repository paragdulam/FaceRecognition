//
//  Message.h
//  TwinFinder
//
//  Created by Parag Dulam on 27/03/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserInfo;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * parse_id;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) UserInfo *fromUser;
@property (nonatomic, retain) UserInfo *toUser;

@end
