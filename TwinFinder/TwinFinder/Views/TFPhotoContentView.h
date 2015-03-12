//
//  TFPhotoContentView.h
//  TwinFinder
//
//  Created by Parag Dulam on 08/03/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MAImageView;
@class DACircularProgressView;
@class TFTextFieldView;
@class TFImagesView;

@protocol TFPhotoContentViewDelegate;

@interface TFPhotoContentView : UIView

@property(nonatomic,weak) id<TFPhotoContentViewDelegate> delegate;
@property(nonatomic) MAImageView *imageView1;
@property(nonatomic) MAImageView *imageView2;
@property(nonatomic) DACircularProgressView *progressView;
@property(nonatomic) UILabel *progressLabel;
@property(nonatomic) UIButton *photoButton1;
@property(nonatomic) UIButton *photoButton2;
@property(nonatomic) TFTextFieldView *textFieldView;
@property(nonatomic) TFImagesView *imagesView;



@end



@protocol TFPhotoContentViewDelegate <NSObject>

-(void) photoContentView:(TFPhotoContentView *) view buttonTapped:(UIButton *) btn;

@end
