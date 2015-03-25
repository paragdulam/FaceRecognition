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
        self.imageView1.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView1.userInteractionEnabled = YES;
        self.imageView1.layer.borderColor = [UIColor greenColor].CGColor;
        [self.imageView1 setClipsToBounds:YES];

        [self addSubview:self.imageView1];
        
        self.imageView2 = [[MAImageView alloc] initWithFrame:CGRectZero];
        self.imageView2.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView2.userInteractionEnabled = YES;
        [self addSubview:self.imageView2];
        self.imageView2.layer.borderColor = [UIColor greenColor].CGColor;
        [self.imageView2 setClipsToBounds:YES];

        self.imageView3 = [[MAImageView alloc] initWithFrame:CGRectZero];
        self.imageView3.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView3.userInteractionEnabled = YES;
        [self addSubview:self.imageView3];
        self.imageView3.layer.borderColor = [UIColor greenColor].CGColor;
        [self.imageView3 setClipsToBounds:YES];

        self.imageView4 = [[MAImageView alloc] initWithFrame:CGRectZero];
        self.imageView4.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView4.userInteractionEnabled = YES;
        [self addSubview:self.imageView4];
        self.imageView4.layer.borderColor = [UIColor greenColor].CGColor;
        [self.imageView4 setClipsToBounds:YES];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}


-(void) deselectAllButImageView:(MAImageView *) imageView
{
    self.imageView1.layer.borderWidth = 0;
    self.imageView2.layer.borderWidth = 0;
    self.imageView3.layer.borderWidth = 0;
    self.imageView4.layer.borderWidth = 0;
    
    imageView.layer.borderWidth = 2.f;
}

-(void) tapGesture:(UITapGestureRecognizer *) gestureRecognizer
{
    UIView* view = gestureRecognizer.view;
    CGPoint loc = [gestureRecognizer locationInView:view];
    MAImageView* subview = (MAImageView *)[view hitTest:loc withEvent:nil];
    if ([subview isKindOfClass:[MAImageView class]] && subview.image) {
        if ([self.delegate respondsToSelector:@selector(imagesView:tappedView:)]) {
            [self deselectAllButImageView:subview];
            [self.delegate imagesView:self tappedView:subview];
        }
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
