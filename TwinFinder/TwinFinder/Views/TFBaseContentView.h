//
//  TFBaseContentView.h
//  TwinFinder
//
//  Created by Parag Dulam on 08/03/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFPhotoContentView;

@protocol TFBaseContentViewDelegate;

@interface TFBaseContentView : UIView

@property (nonatomic,weak) id<TFBaseContentViewDelegate>delegate;
@property (nonatomic) TFPhotoContentView *contentView;

@property (nonatomic) UIButton *profilePicButton;
@property (nonatomic) UILabel *descLabel;
@property (nonatomic) UILabel *locationLabel;
@property (nonatomic) UIButton *bottomButton1;
@property (nonatomic) CAGradientLayer *gradientLayer1;
@property (nonatomic) UIButton *bottomButton2;
@property (nonatomic) CAGradientLayer *gradientLayer2;
@property (nonatomic) UIActivityIndicatorView *activityIndicator;


-(void) setUserInfo:(id) userInfo;

@end

@protocol TFBaseContentViewDelegate <NSObject>

-(void) baseContentView:(TFBaseContentView *) view buttonTapped:(UIButton *) btn;

@end
