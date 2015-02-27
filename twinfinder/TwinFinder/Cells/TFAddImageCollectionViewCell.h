//
//  TFAddImageCollectionViewCell.h
//  ParseStarterProject
//
//  Created by Parag Dulam on 04/02/15.
//
//

#import <ParseUI/ParseUI.h>
#import <UIKit/UIKit.h>

@interface TFAddImageCollectionViewCell : UICollectionViewCell


@property(nonatomic,strong) UIButton *addButton;
@property(nonatomic,strong) UIImageView *imageView;

-(void) setHideFooterView:(BOOL) hidden;

@end
