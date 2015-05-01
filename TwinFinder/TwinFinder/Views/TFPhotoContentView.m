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
#import "TFTextFieldView.h"
#import "TFImagesView.h"


@interface TFPhotoContentView ()
{
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
        self.imageView1.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView1.clipsToBounds = YES;
        self.imageView1.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainImageViewTapped:)];
        [self.imageView1 addGestureRecognizer:tapGestureRecognizer];
        [self addSubview:self.imageView1];
        
        self.imageView2 = [[MAImageView alloc] initWithFrame:CGRectZero];
        self.imageView2.backgroundColor = [UIColor clearColor];
        self.imageView2.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView2.clipsToBounds = YES;
        [self addSubview:self.imageView2];
        
        
        self.textFieldView = [[TFTextFieldView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.textFieldView];
        
        self.imagesView = [[TFImagesView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.imagesView];
        
        self.photoButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.photoButton1 setBackgroundColor:[UIColor whiteColor]];
        [self.photoButton1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.photoButton1.tag = 1;
        [self.photoButton1 addTarget:self action:@selector(photoButton1Tapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.photoButton1 setTitle:NSLocalizedString(@"Add Photo", @"Add Photo")
                       forState:UIControlStateNormal];
        [self.photoButton1.titleLabel setFont:[UIFont boldSystemFontOfSize:10.f]];
        [self addSubview:self.photoButton1];
        
        self.photoButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.photoButton2 setBackgroundColor:[UIColor whiteColor]];
        [self.photoButton2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.photoButton2.tag = 2;
        [self.photoButton2 addTarget:self action:@selector(photoButton2Tapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.photoButton2 setTitle:NSLocalizedString(@"Start Search", @"Start Search")
                      forState:UIControlStateNormal];
        [self.photoButton2.titleLabel setFont:[UIFont boldSystemFontOfSize:10.f]];
        [self addSubview:self.photoButton2];
        
        self.progressView = [[DACircularProgressView alloc] initWithFrame:CGRectZero];
        self.progressView.trackTintColor = [UIColor blackColor];
        self.progressView.progressTintColor = [UIColor greenColor];
        self.progressView.thicknessRatio = 0.1;
        [self addSubview:self.progressView];
        
        self.progressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.progressLabel setFont:[UIFont boldSystemFontOfSize:14.f]];
        [self addSubview:self.progressLabel];
    }
    return self;
}




-(void) layoutSubviews
{
    [super layoutSubviews];
    float width = (self.frame.size.width - 15)/2;
    self.imageView1.frame = CGRectMake(5, 5, width, width);
    self.imageView2.frame = CGRectMake(CGRectGetMaxX(self.imageView1.frame) + 5, 5, width, width);
    self.imagesView.frame = self.imageView2.frame;
    self.textFieldView.frame = CGRectMake(self.imageView2.frame.origin.x, 5, self.imageView2.frame.size.width, 145);
    
    self.photoButton1.frame = CGRectMake(0, 0, 100, 24);
    self.photoButton1.layer.cornerRadius = 12.f;
    self.photoButton1.clipsToBounds = YES;
    self.photoButton1.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.photoButton1.layer.borderWidth = 2.f;
    self.photoButton1.center = CGPointMake(self.imageView1.center.x, self.imageView1.center.y + ((self.imageView1.frame.size.height/2) + 20.f));
    
    self.photoButton2.frame = CGRectMake(0, 0, 100, 24);
    self.photoButton2.layer.cornerRadius = 12.f;
    self.photoButton2.clipsToBounds = YES;
    self.photoButton2.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.photoButton2.layer.borderWidth = 2.f;
    self.photoButton2.center = CGPointMake(self.imageView2.center.x, self.imageView2.center.y + ((self.imageView2.frame.size.height/2) + 20.f));
    
    CGFloat progressWidth = self.frame.size.height - 30 - self.imageView1.frame.size.height - self.photoButton2.frame.size.height;
    self.progressView.frame = CGRectMake(self.center.x - self.progressView.frame.size.width/2, CGRectGetMaxY(self.photoButton2.frame) + 10, progressWidth, progressWidth);
    [self.progressLabel sizeToFit];
    self.progressLabel.center = self.progressView.center;
}


-(void)mainImageViewTapped:(UITapGestureRecognizer *) gesture
{
    if ([self.delegate respondsToSelector:@selector(photoContentViewWasTapped:)]) {
        [self.delegate photoContentViewWasTapped:self];
    }
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
