//
//  MAImageView.h
//  MobilyAssignment
//
//  Created by Parag Dulam on 28/02/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAImageView : UIImageView

@property(nonatomic) NSString *idString;
-(void) setImageURL:(NSURL *) url forFileId:(NSString *) idString;

@end
