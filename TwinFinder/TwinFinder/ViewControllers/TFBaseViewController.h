//
//  TFBaseViewController.h
//  TwinFinder
//
//  Created by Parag Dulam on 08/03/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFBaseContentView;
@class TFPhotoContentView;

typedef enum TF_VIEW_STATE {
    NORMAL,
    LOADING,
    LOADING_DONE
}TF_VIEW_STATE;


@interface TFBaseViewController : UIViewController
{
    UIImageView *backgroundImageView;
    UILabel *appNameLabel;
    UIView *homeViewBackground;
    TFBaseContentView *dataBackgroundView;
}

@property TF_VIEW_STATE viewState;

@end
