//
//  TFEmptyCollectionViewCell.m
//  ParseStarterProject
//
//  Created by Parag Dulam on 08/02/15.
//
//

#import "TFEmptyCollectionViewCell.h"

@interface TFEmptyCollectionViewCell()
{
    UILabel *textLabel;
}

@end

@implementation TFEmptyCollectionViewCell

-(id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        textLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        [textLabel setFont:[UIFont boldSystemFontOfSize:14.f]];
        [textLabel setTextColor:[UIColor whiteColor]];
        [textLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [textLabel setNumberOfLines:0];
        [textLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:textLabel];
    }
    return self;
}

-(void) setText:(NSString *)text
{
    [textLabel setText:text];
}

@end
