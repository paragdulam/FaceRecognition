//
//  TFPhotoContentView.m
//  TwinFinder
//
//  Created by Parag Dulam on 08/03/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import "TFPhotoContentView.h"
#import "MAImageView.h"
#import "DACircularProgressView.h"


@interface TFPhotoContentView ()
{
    MAImageView *imageView1;
    MAImageView *imageView2;
    UIButton *photoButton1;
    UIButton *photoButton2;
    DACircularProgressView *progressView;
}

@end

@implementation TFPhotoContentView

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
        imageView1 = [[MAImageView alloc] initWithFrame:CGRectZero];
        imageView1.backgroundColor = [UIColor cyanColor];
        [self addSubview:imageView1];
        
        imageView2 = [[MAImageView alloc] initWithFrame:CGRectZero];
        imageView2.backgroundColor = [UIColor magentaColor];
        [self addSubview:imageView2];
        
        photoButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:photoButton1];
        
        photoButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:photoButton2];
        
        progressView = [[DACircularProgressView alloc] initWithFrame:CGRectZero];
        progressView.trackTintColor = [UIColor blackColor];
        progressView.thicknessRatio = 0.1;
        [self addSubview:progressView];
    }
    return self;
}




-(void) layoutSubviews
{
    [super layoutSubviews];
    float width = (self.frame.size.width - 15)/2;
    imageView1.frame = CGRectMake(5, 5, width, width);
    imageView2.frame = CGRectMake(CGRectGetMaxX(imageView1.frame) + 5, 5, width, width);
    
    photoButton1.frame = CGRectMake(0, 0, 100, 24);
    photoButton1.layer.cornerRadius = 12.f;
    photoButton1.clipsToBounds = YES;
    photoButton1.layer.borderColor = [UIColor lightGrayColor].CGColor;
    photoButton1.layer.borderWidth = 2.f;
    photoButton1.center = CGPointMake(imageView1.center.x, imageView1.center.y + ((imageView1.frame.size.height/2) + 20.f));
    
    photoButton2.frame = CGRectMake(0, 0, 100, 24);
    photoButton2.layer.cornerRadius = 12.f;
    photoButton2.clipsToBounds = YES;
    photoButton2.layer.borderColor = [UIColor lightGrayColor].CGColor;
    photoButton2.layer.borderWidth = 2.f;
    photoButton2.center = CGPointMake(imageView2.center.x, imageView2.center.y + ((imageView2.frame.size.height/2) + 20.f));
    
    CGFloat progressWidth = self.frame.size.height - 30 - imageView1.frame.size.height - photoButton2.frame.size.height;
    progressView.frame = CGRectMake(self.center.x - progressView.frame.size.width/2, CGRectGetMaxY(photoButton2.frame) + 10, progressWidth, progressWidth);
}



-(void) photoButton1Tapped:(UIButton *) btn
{
    if ([self.delegate respondsToSelector:@selector(photoContentView:buttonTapped:)]) {
        [self.delegate photoContentView:self buttonTapped:btn];
    }
}


-(void) photoButton2Tapped:(UIButton *) btn
{
    if ([self.delegate respondsToSelector:@selector(photoContentView:buttonTapped:)]) {
        [self.delegate photoContentView:self buttonTapped:btn];
    }
}

@end
