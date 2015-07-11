//
//  TFFriendsHeaderView.m
//  ParseStarterProject
//
//  Created by Parag Dulam on 03/02/15.
//
//

#import "TFFriendsHeaderView.h"

@implementation TFFriendsHeaderView

-(id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:18.f]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [self addSubview:titleLabel];
    }
    return self;
}

-(void) layoutSubviews {
    [super layoutSubviews];
    titleLabel.frame = CGRectMake(5, 5, self.frame.size.width - 10, self.frame.size.height - 10);
}

-(void) setHeaderText:(NSString *) text
{
    [titleLabel setText:text];
}

@end
