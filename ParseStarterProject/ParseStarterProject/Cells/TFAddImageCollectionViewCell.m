//
//  TFAddImageCollectionViewCell.m
//  ParseStarterProject
//
//  Created by Parag Dulam on 04/02/15.
//
//

#import "TFAddImageCollectionViewCell.h"
@interface TFAddImageCollectionViewCell()
{
    UIView *overlayView;
    UIButton *addButton;
}

@end

@implementation TFAddImageCollectionViewCell

-(id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        overlayView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:overlayView];
        [overlayView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.3f]];
        
        addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [self.contentView addSubview:addButton];
        
        self.layer.shadowColor = [UIColor whiteColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(1, 1);
    }
    return self;
}


-(void) layoutSubviews
{
    [super layoutSubviews];
    if (!self.imageView.image) {
        addButton.center = self.contentView.center;
    } else {
        [UIView animateWithDuration:.3f
                         animations:^{
                             addButton.frame = CGRectMake(0, 0, addButton.frame.size.width, addButton.frame.size.height);
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    self.imageView.frame = self.contentView.bounds;
}


@end
