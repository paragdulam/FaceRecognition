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
        backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:backgroundImageView];
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [backgroundImageView addSubview:activityIndicator];
        
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
    backgroundImageView.frame = CGRectMake(5,5, self.frame.size.height - 10, self.frame.size.height - 10);
    backgroundImageView.layer.cornerRadius = backgroundImageView.frame.size.width/2;
    backgroundImageView.clipsToBounds = YES;
    backgroundImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    backgroundImageView.layer.borderWidth = 2.f;
    
    activityIndicator.center = CGPointMake(backgroundImageView.frame.size.width/2,
                                           backgroundImageView.frame.size.height/2);
    
    nameLabel.frame = CGRectMake(CGRectGetMaxX(backgroundImageView.frame) + 5.f,
                                 backgroundImageView.frame.origin.y,
                                 self.frame.size.width - 10 - backgroundImageView.frame.size.width,
                                 backgroundImageView.frame.size.height/2);
    
    ageLabel.frame = CGRectMake(nameLabel.frame.origin.x,
                                 CGRectGetMaxY(nameLabel.frame),
                                 nameLabel.frame.size.width,
                                 nameLabel.frame.size.height);

}



- (NSString *)age:(NSDate *)dateOfBirth {
    
    NSInteger years;
    NSInteger months;
    NSInteger days;
    
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
    
    NSLog(@"years:%d", years);
    
    if ([dateComponentsNow year] == [dateComponentsBirth year]) {
        months = [dateComponentsNow month] - [dateComponentsBirth month];
    } else if ([dateComponentsNow year] > [dateComponentsBirth year] && [dateComponentsNow month] > [dateComponentsBirth month]) {
        months = [dateComponentsNow month] - [dateComponentsBirth month];
    } else if ([dateComponentsNow year] > [dateComponentsBirth year] && [dateComponentsNow month] < [dateComponentsBirth month]) {
        months = [dateComponentsNow month] - [dateComponentsBirth month] + 12;
    } else if ([dateComponentsNow year] > [dateComponentsBirth year] && [dateComponentsNow month] == [dateComponentsBirth month]) {
        months = 11;
    } else {
        months = [dateComponentsNow month] - [dateComponentsBirth month];
    }
    
    NSLog(@"months:%d", months);
    
    if ([dateComponentsNow year] == [dateComponentsBirth year] && [dateComponentsNow month] == [dateComponentsBirth month]) {
        days = [dateComponentsNow day] - [dateComponentsBirth day];
    }
    
    if (years == 0 && months == 0) {
        if (days == 1) {
            return [NSString stringWithFormat:@"%d %@", days, NSLocalizedString(@"day", @"day")];
        } else {
            return [NSString stringWithFormat:@"%d %@", days, NSLocalizedString(@"days", @"days")];
        }
    } else if (years == 0) {
        if (months == 1) {
            return [NSString stringWithFormat:@"%d %@", months, NSLocalizedString(@"month", @"month")];
        } else {
            return [NSString stringWithFormat:@"%d %@", months, NSLocalizedString(@"months", @"months")];
        }
    } else if ((years != 0) && (months == 0)) {
        if (years == 1) {
            return [NSString stringWithFormat:@"%d %@", years, NSLocalizedString(@"year", @"year")];
        } else {
            return [NSString stringWithFormat:@"%d %@", years, NSLocalizedString(@"years", @"years")];
        }
    } else {
        if ((years == 1) && (months == 1)) {
            return [NSString stringWithFormat:@"%d %@ %d %@", years, NSLocalizedString(@"year and", @"year and"), months, NSLocalizedString(@"month", @"month")];
        } else if (years == 1) {
            return [NSString stringWithFormat:@"%d %@ %d %@", years, NSLocalizedString(@"year and", @"year and"), months, NSLocalizedString(@"months", @"months")];
        } else if (months == 1) {
            return [NSString stringWithFormat:@"%d %@ %d %@", years, NSLocalizedString(@"years and", @"years and"), months, NSLocalizedString(@"month", @"month")];
        } else {
            return [NSString stringWithFormat:@"%d %@ %d %@", years, NSLocalizedString(@"years and", @"years and"), months, NSLocalizedString(@"months", @"months")];
        }
        
    }
    
}


-(void) setUser:(NSDictionary *) user
{
    NSString *name = [NSString stringWithFormat:@"%@ %@",[user objectForKey:@"first_name"],[user objectForKey:@"last_name"]];
    [nameLabel setText:name];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *age = [self age:[dateFormatter dateFromString:[user objectForKey:@"birthday"]]];
    [ageLabel setText:age];
    
    NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",user[@"id"]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [activityIndicator startAnimating];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [activityIndicator stopAnimating];
        [backgroundImageView setImage:[UIImage imageWithData:data]];
    }];
}

@end
