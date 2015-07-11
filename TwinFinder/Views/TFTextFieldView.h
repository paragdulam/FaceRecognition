//
//  TFTextFieldView.h
//  TwinFinder
//
//  Created by Parag Dulam on 09/03/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserInfo;
@class HTAutocompleteTextField;

@protocol TFTextFieldViewDelegate;

@interface TFTextFieldView : UIView
{
    UITextField *nameTextField;
    UITextField *ageTextField;
    UITextField *cityTextField;
    HTAutocompleteTextField *nationalTextField;
}

@property (nonatomic,weak) id<TFTextFieldViewDelegate>delegate;


-(void) fetchUserInfo;

@end


@protocol TFTextFieldViewDelegate<NSObject>

-(void) textFieldView:(TFTextFieldView *) view didUpdateUser:(UserInfo *) uInfo;

@end