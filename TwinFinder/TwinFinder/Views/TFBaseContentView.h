//
//  TFBaseContentView.h
//  TwinFinder
//
//  Created by Parag Dulam on 08/03/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TFBaseContentViewDelegate;

@interface TFBaseContentView : UIView

@property (nonatomic,weak) id<TFBaseContentViewDelegate>delegate;

-(void) setUserInfo:(id) userInfo;

@end

@protocol TFBaseContentViewDelegate <NSObject>

-(void) baseContentView:(TFBaseContentView *) view buttonTapped:(UIButton *) btn;

@end
