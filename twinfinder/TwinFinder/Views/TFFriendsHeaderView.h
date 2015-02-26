//
//  TFFriendsHeaderView.h
//  ParseStarterProject
//
//  Created by Parag Dulam on 03/02/15.
//
//

#import <UIKit/UIKit.h>

@interface TFFriendsHeaderView : UICollectionReusableView
{
    UILabel *titleLabel;
}

-(void) setHeaderText:(NSString *) text;

@end
