//
//  TFImagesView.h
//  TwinFinder
//
//  Created by Parag Dulam on 12/03/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MAImageView;

@protocol TFImagesViewDelegate;

@interface TFImagesView : UIView

@property(nonatomic) MAImageView *imageView1;
@property(nonatomic) MAImageView *imageView2;
@property(nonatomic) MAImageView *imageView3;
@property(nonatomic) MAImageView *imageView4;
@property(nonatomic,weak) id<TFImagesViewDelegate> delegate;



@end


@protocol TFImagesViewDelegate<NSObject>

-(void) imagesView:(TFImagesView *) view tappedView:(MAImageView *) imgView;
-(void) imagesView:(TFImagesView *) view longPressedView:(MAImageView *) imgView;


@end