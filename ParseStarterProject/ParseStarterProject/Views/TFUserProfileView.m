//
//  TFUserProfileView.m
//  ParseStarterProject
//
//  Created by Parag Dulam on 03/02/15.
//
//

#import "TFUserProfileView.h"

@interface TFUserProfileView()
{
    UIImageView *backgroundImageView;
}


@end


@implementation TFUserProfileView

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
        backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:backgroundImageView];
    }
    return self;
}


-(void) setUser:(NSDictionary *) user
{
    NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",user[@"id"]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [backgroundImageView setImage:[UIImage imageWithData:data]];
    }];
}

@end
