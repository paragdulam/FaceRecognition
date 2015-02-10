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
    UIView *backgroundView;
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
        
        
        backgroundView = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.bounds.origin.x, self.contentView.bounds.size.height * (4.f/5.f), self.contentView.bounds.size.width, self.contentView.bounds.size.height * (1.f/5.f))];
        backgroundView.backgroundColor = [UIColor whiteColor];
        backgroundView.alpha = 0.9;
        [self.contentView addSubview:backgroundView];
        
        addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [backgroundView addSubview:addButton];
        addButton.center = CGPointMake(backgroundView.frame.size.width/2, backgroundView.frame.size.height/2);
        
        self.layer.shadowColor = [UIColor whiteColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(1, 1);
    }
    return self;
}


-(void) layoutSubviews
{
    [super layoutSubviews];
}


@end
