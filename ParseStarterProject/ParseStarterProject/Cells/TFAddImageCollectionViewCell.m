//
//  TFAddImageCollectionViewCell.m
//  ParseStarterProject
//
//  Created by Parag Dulam on 04/02/15.
//
//

#import "TFAddImageCollectionViewCell.h"

@implementation TFAddImageCollectionViewCell

-(id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.imageView.contentMode = UIViewContentModeScaleToFill;
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}

@end
