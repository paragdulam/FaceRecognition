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

@interface TFBaseViewController : UIViewController
{
    UIImageView *backgroundImageView;
    UILabel *appNameLabel;
    UIView *homeViewBackground;
    TFBaseContentView *dataBackgroundView;
}

@end
