//
//  TFUserProfileView.h
//  ParseStarterProject
//
//  Created by Parag Dulam on 03/02/15.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>



@protocol TFUserProfileViewDelegate;

@interface TFUserProfileView : UICollectionReusableView


@property (nonatomic,weak) id<TFUserProfileViewDelegate> delegate;
-(void) setUserInfo:(id) userInfo;
-(void) setAgeText:(NSString *) text;
@end


@protocol TFUserProfileViewDelegate<NSObject>

-(void) profileButtonTappedInHeaderView:(TFUserProfileView *) view;

@end


