//
//  TFPhotoContentView.h
//  TwinFinder
//
//  Created by Parag Dulam on 08/03/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TFPhotoContentViewDelegate;

@interface TFPhotoContentView : UIView

@property(nonatomic,weak) id<TFPhotoContentViewDelegate> delegate;

@end



@protocol TFPhotoContentViewDelegate <NSObject>

-(void) photoContentView:(TFPhotoContentView *) view buttonTapped:(UIButton *) btn;

@end
