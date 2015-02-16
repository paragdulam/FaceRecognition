//
//  TFUserProfileView.m
//  ParseStarterProject
//
//  Created by Parag Dulam on 03/02/15.
//
//

#import "TFUserProfileView.h"
#import "UserInfo.h"

@interface TFUserProfileView()
{
    UIButton *profileButton;
    UILabel *nameLabel;
    UILabel *ageLabel;
    UIActivityIndicatorView *activityIndicator;
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
        profileButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self addSubview:profileButton];
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [profileButton addSubview:activityIndicator];
        [profileButton addTarget:self action:@selector(profileButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [nameLabel setFont:[UIFont boldSystemFontOfSize:18.f]];
        [nameLabel setTextColor:[UIColor whiteColor]];
        [self addSubview:nameLabel];
        
        ageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [ageLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
        [ageLabel setTextColor:[UIColor whiteColor]];
        [self addSubview:ageLabel];
    }
    return self;
}


-(void) layoutSubviews
{
    [super layoutSubviews];
    profileButton.frame = CGRectMake(5,
                                     5,
                                     self.frame.size.height - 10,
                                     self.frame.size.height - 10);
    profileButton.layer.cornerRadius = profileButton.frame.size.width/2;
    profileButton.clipsToBounds = YES;
    profileButton.layer.borderColor = [UIColor whiteColor].CGColor;
    profileButton.layer.borderWidth = 2.f;
    
    activityIndicator.center = CGPointMake(profileButton.frame.size.width/2,
                                           profileButton.frame.size.height/2);
    
    nameLabel.frame = CGRectMake(CGRectGetMaxX(profileButton.frame) + 5.f,
                                 profileButton.frame.origin.y,
                                 self.frame.size.width - 10 - profileButton.frame.size.width,
                                 profileButton.frame.size.height/2);
    
    ageLabel.frame = CGRectMake(nameLabel.frame.origin.x,
                                 CGRectGetMaxY(nameLabel.frame),
                                 nameLabel.frame.size.width,
                                 nameLabel.frame.size.height);

}



- (NSString *)age:(NSDate *)dateOfBirth {
    
    NSInteger years;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponentsNow = [calendar components:unitFlags fromDate:[NSDate date]];
    NSDateComponents *dateComponentsBirth = [calendar components:unitFlags fromDate:dateOfBirth];
    
    if (([dateComponentsNow month] < [dateComponentsBirth month]) ||
        (([dateComponentsNow month] == [dateComponentsBirth month]) && ([dateComponentsNow day] < [dateComponentsBirth day]))) {
        years = [dateComponentsNow year] - [dateComponentsBirth year] - 1;
    } else {
        years = [dateComponentsNow year] - [dateComponentsBirth year];
    }
    return [NSString stringWithFormat:@"%d",years];
}

-(void) profileButtonTapped:(UIButton *) btn
{
    if ([self.delegate respondsToSelector:@selector(profileButtonTappedInHeaderView:)]) {
        [self.delegate profileButtonTappedInHeaderView:self];
    }
}


-(void) setUserInfo:(id) userInfo
{
    UserInfo *user = (UserInfo *)userInfo;
    [nameLabel setText:user.name];
    [ageLabel setText:user.age];
    NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",user.facebookId];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [activityIndicator startAnimating];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [activityIndicator stopAnimating];
        [profileButton setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
    }];
}

@end
