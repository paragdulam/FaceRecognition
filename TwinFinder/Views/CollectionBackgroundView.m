//
//  CollectionBackgroundView.m
//  TwinFinder
//
//  Created by Parag Dulam on 27/02/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import "CollectionBackgroundView.h"


@interface CollectionBackgroundView ()

@property (nonatomic) CAGradientLayer *backgroundLayer;

@end

@implementation CollectionBackgroundView

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
        self.backgroundLayer = [CAGradientLayer layer];
        self.backgroundLayer.frame = self.bounds;
        self.backgroundLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
        [self.layer insertSublayer:self.backgroundLayer atIndex:0];
    }
    return self;
}


-(void) setColors:(NSArray *)colors
{
    self.backgroundLayer.colors = colors;
}


@end
