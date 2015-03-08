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
        self.imageView1 = [[MAImageView alloc] initWithFrame:CGRectZero];
        self.imageView1.backgroundColor = [UIColor clearColor];
        self.imageView1.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView1];
        
        self.imageView2 = [[MAImageView alloc] initWithFrame:CGRectZero];
        self.imageView2.backgroundColor = [UIColor clearColor];
        self.imageView2.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView2];
        
        photoButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [photoButton1 setBackgroundColor:[UIColor whiteColor]];
        [photoButton1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        photoButton1.tag = 1;
        [photoButton1 addTarget:self action:@selector(photoButton1Tapped:) forControlEvents:UIControlEventTouchUpInside];
        [photoButton1 setTitle:NSLocalizedString(@"Add Photo", @"Add Photo")
                       forState:UIControlStateNormal];
        [photoButton1.titleLabel setFont:[UIFont boldSystemFontOfSize:10.f]];
        [self addSubview:photoButton1];
        
        photoButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [photoButton2 setBackgroundColor:[UIColor whiteColor]];
        [photoButton2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        photoButton2.tag = 2;
        [photoButton2 addTarget:self action:@selector(photoButton2Tapped:) forControlEvents:UIControlEventTouchUpInside];
        [photoButton2 setTitle:NSLocalizedString(@"Start Search", @"Start Search")
                      forState:UIControlStateNormal];
        [photoButton2.titleLabel setFont:[UIFont boldSystemFontOfSize:10.f]];
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
    self.imageView1.frame = CGRectMake(5, 5, width, width);
    self.imageView2.frame = CGRectMake(CGRectGetMaxX(self.imageView1.frame) + 5, 5, width, width);
    
    photoButton1.frame = CGRectMake(0, 0, 100, 24);
    photoButton1.layer.cornerRadius = 12.f;
    photoButton1.clipsToBounds = YES;
    photoButton1.layer.borderColor = [UIColor lightGrayColor].CGColor;
    photoButton1.layer.borderWidth = 2.f;
    photoButton1.center = CGPointMake(self.imageView1.center.x, self.imageView1.center.y + ((self.imageView1.frame.size.height/2) + 20.f));
    
    photoButton2.frame = CGRectMake(0, 0, 100, 24);
    photoButton2.layer.cornerRadius = 12.f;
    photoButton2.clipsToBounds = YES;
    photoButton2.layer.borderColor = [UIColor lightGrayColor].CGColor;
    photoButton2.layer.borderWidth = 2.f;
    photoButton2.center = CGPointMake(self.imageView2.center.x, self.imageView2.center.y + ((self.imageView2.frame.size.height/2) + 20.f));
    
    CGFloat progressWidth = self.frame.size.height - 30 - self.imageView1.frame.size.height - photoButton2.frame.size.height;
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
