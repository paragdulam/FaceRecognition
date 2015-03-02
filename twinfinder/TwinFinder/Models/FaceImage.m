//
//  FaceImage.m
//  ParseStarterProject
//
//  Created by Parag Dulam on 25/02/15.
//
//

#import "FaceImage.h"
#import "UserInfo.h"


@implementation FaceImage

@dynamic image;
@dynamic image_url;
@dynamic index;
@dynamic parse_id;
@dynamic createdBy;


-(BOOL) isEqual:(id)object
{
    FaceImage *image = (FaceImage *)object;
    return [self.parse_id isEqualToString:image.parse_id];
}

@end


//Dayanand Aadam
//1506, Daaji Peth,
//Solapur