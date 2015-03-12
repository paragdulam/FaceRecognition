//
//  TFImagesView.m
//  TwinFinder
//
//  Created by Parag Dulam on 12/03/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import "TFImagesView.h"
#import "MAImageView.h"

@implementation TFImagesView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.imageView1 = [[MAImageView alloc] initWithFrame:CGRectZero];
        self.imageView1.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView1.userInteractionEnabled = YES;
        [self addSubview:self.imageView1];
        
        self.imageView2 = [[MAImageView alloc] initWithFrame:CGRectZero];
        self.imageView2.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView2.userInteractionEnabled = YES;
        [self addSubview:self.imageView2];

        self.imageView3 = [[MAImageView alloc] initWithFrame:CGRectZero];
        self.imageView3.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView3.userInteractionEnabled = YES;
        [self addSubview:self.imageView3];

        self.imageView4 = [[MAImageView alloc] initWithFrame:CGRectZero];
        self.imageView4.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView4.userInteractionEnabled = YES;
        [self addSubview:self.imageView4];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}


-(void) tapGesture:(UITapGestureRecognizer *) gestureRecognizer
{
    UIView* view = gestureRecognizer.view;
    CGPoint loc = [gestureRecognizer locationInView:view];
    MAImageView* subview = (MAImageView *)[view hitTest:loc withEvent:nil];
    if ([self.delegate respondsToSelector:@selector(imagesView:tappedView:)]) {
        [self.delegate imagesView:self tappedView:subview];
    }
}


-(void) layoutSubviews
{
    [super layoutSubviews];
    self.imageView1.frame = CGRectMake(0, 0, self.frame.size.width/2, self.frame.size.height/2);
    self.imageView2.frame = CGRectMake(self.frame.size.width/2, 0, self.frame.size.width/2, self.frame.size.height/2);
    self.imageView3.frame = CGRectMake(0, self.frame.size.height/2, self.frame.size.width/2, self.frame.size.height/2);
    self.imageView4.frame = CGRectMake(self.frame.size.width/2, self.frame.size.height/2, self.frame.size.width/2, self.frame.size.height/2);
}

@end
