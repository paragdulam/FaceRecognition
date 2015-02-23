//
//  FaceAttribute.h
//  ParseStarterProject
//
//  Created by Parag Dulam on 23/02/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FaceAttribute : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) NSNumber * confidence;

@end
