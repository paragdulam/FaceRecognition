//
//  TFBaseContentView.m
//  TwinFinder
//
//  Created by Parag Dulam on 08/03/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import "TFBaseContentView.h"
#import "TFPhotoContentView.h"
#import "UserInfo.h"
#import "TFTextFieldView.h"
#import "AppDelegate.h"
#import "TFAppManager.h"

@interface TFBaseContentView()<TFPhotoContentViewDelegate,TFTextFieldViewDelegate>
{
}

@end

@implementation TFBaseContentView

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
        self.profilePicButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.profilePicButton.backgroundColor = [UIColor blackColor];
        [self addSubview:self.profilePicButton];
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.activityIndicator.hidesWhenStopped = YES;
        [self.profilePicButton addSubview:self.activityIndicator];
        [self.profilePicButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
        
        self.descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.descLabel setFont:[UIFont boldSystemFontOfSize:14.f]];
        self.descLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.descLabel];
        
        self.locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:self.locationLabel];
        
        self.bottomButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bottomButton1.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
        [self.bottomButton1 setTitle:NSLocalizedString(@"Create a profile", nil) forState:UIControlStateNormal];
        [self.bottomButton1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.bottomButton1 addTarget:self action:@selector(bottomButton1Tapped:) forControlEvents:UIControlEventTouchUpInside];
        self.bottomButton1.tag = 1;
        
        self.gradientLayer1 = [CAGradientLayer layer];
        self.gradientLayer1.colors = @[(id)[UIColor lightGrayColor].CGColor,
                                       (id)[UIColor whiteColor].CGColor];
        self.gradientLayer1.frame = self.bottomButton1.bounds;
        [self.bottomButton1.layer insertSublayer:self.gradientLayer1 atIndex:0];
        
        [self addSubview:self.bottomButton1];
        
        self.bottomButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bottomButton2.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
        [self.bottomButton2 setTitle:NSLocalizedString(@"Camera", nil) forState:UIControlStateNormal];
        [self.bottomButton2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.bottomButton2 addTarget:self action:@selector(bottomButton2Tapped:) forControlEvents:UIControlEventTouchUpInside];
        self.bottomButton2.tag = 2;
        
        self.gradientLayer2 = [CAGradientLayer layer];
        self.gradientLayer2.colors = @[(id)[UIColor lightGrayColor].CGColor,
                                       (id)[UIColor whiteColor].CGColor];
        self.gradientLayer2.frame = self.bottomButton2.bounds;
        [self.bottomButton2.layer insertSublayer:self.gradientLayer2 atIndex:0];
        
        [self addSubview:self.bottomButton2];
        
        self.contentView = [[TFPhotoContentView alloc] initWithFrame:CGRectZero];
        self.contentView.textFieldView.delegate = self;
        self.contentView.backgroundColor = [UIColor colorWithRed:210.f/255.f green:221.f/255.f blue:227.f/255.f alpha:1];
        [self addSubview:self.contentView];
        
        UserInfo *userInfo = [TFAppManager userWithId:[PFUser currentUser].objectId];
        NSString *name = userInfo.name.length ? userInfo.name : @"Name";
        NSString *age = userInfo.age.length ? userInfo.age : @"Age";
        NSString *city = userInfo.city.length ? userInfo.city : @"City";
        NSString *national = userInfo.national.length ? userInfo.national : @"Nationality";
        
        NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] init];
        NSMutableAttributedString *commaString = [[NSMutableAttributedString alloc] initWithString:@","];
        NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:name];
        if ([name isEqualToString:@"Name"]) {
            [nameString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, nameString.string.length)];
        }
        [finalString appendAttributedString:nameString];
        [finalString appendAttributedString:commaString];
        NSMutableAttributedString *ageString = [[NSMutableAttributedString alloc] initWithString:age];
        if ([age isEqualToString:@"Age"]) {
            [ageString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, ageString.string.length)];
        }
        [finalString appendAttributedString:ageString];
        [finalString appendAttributedString:commaString];
        NSMutableAttributedString *cityString = [[NSMutableAttributedString alloc] initWithString:city];
        if ([city isEqualToString:@"City"]) {
            [cityString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, cityString.string.length)];
        }
        [finalString appendAttributedString:cityString];
        [finalString appendAttributedString:commaString];
        NSMutableAttributedString *nationalString = [[NSMutableAttributedString alloc] initWithString:national];
        if ([national isEqualToString:@"Nationality"]) {
            [nationalString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, nationalString.string.length)];
        }
        [finalString appendAttributedString:nationalString];
        [self.descLabel setAttributedText:finalString];

        
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"profile.updated" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            UserInfo *uInfo = (UserInfo *)[note object];
            
            NSString *name = uInfo.name.length ? uInfo.name : @"Name";
            NSString *age = uInfo.age.length ? uInfo.age : @"Age";
            NSString *city = uInfo.city.length ? uInfo.city : @"City";
            NSString *national = uInfo.national.length ? uInfo.national : @"Nationality";
            
            NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] init];
            NSMutableAttributedString *commaString = [[NSMutableAttributedString alloc] initWithString:@","];
            NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:name];
            if ([name isEqualToString:@"Name"]) {
                [nameString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, nameString.string.length)];
            }
            [finalString appendAttributedString:nameString];
            [finalString appendAttributedString:commaString];
            NSMutableAttributedString *ageString = [[NSMutableAttributedString alloc] initWithString:age];
            if ([age isEqualToString:@"Age"]) {
                [ageString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, ageString.string.length)];
            }
            [finalString appendAttributedString:ageString];
            [finalString appendAttributedString:commaString];
            NSMutableAttributedString *cityString = [[NSMutableAttributedString alloc] initWithString:city];
            if ([city isEqualToString:@"City"]) {
                [cityString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, cityString.string.length)];
            }
            [finalString appendAttributedString:cityString];
            [finalString appendAttributedString:commaString];
            NSMutableAttributedString *nationalString = [[NSMutableAttributedString alloc] initWithString:national];
            if ([national isEqualToString:@"Nationality"]) {
                [nationalString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, nationalString.string.length)];
            }
            [finalString appendAttributedString:nationalString];
            [self.descLabel setAttributedText:finalString];
            
        }];
    }
    return self;
}


-(void) deallo
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void) textFieldView:(TFTextFieldView *) view didUpdateUser:(UserInfo *) userInfo
{
    NSString *name = userInfo.name.length ? userInfo.name : @"Name";
    NSString *age = userInfo.age.length ? userInfo.age : @"Age";
    NSString *city = userInfo.city.length ? userInfo.city : @"City";
    NSString *national = userInfo.national.length ? userInfo.national : @"Nationality";
    
    NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *commaString = [[NSMutableAttributedString alloc] initWithString:@","];
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:name];
    if ([name isEqualToString:@"Name"]) {
        [nameString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, nameString.string.length)];
    }
    [finalString appendAttributedString:nameString];
    [finalString appendAttributedString:commaString];
    NSMutableAttributedString *ageString = [[NSMutableAttributedString alloc] initWithString:age];
    if ([age isEqualToString:@"Age"]) {
        [ageString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, ageString.string.length)];
    }
    [finalString appendAttributedString:ageString];
    [finalString appendAttributedString:commaString];
    NSMutableAttributedString *cityString = [[NSMutableAttributedString alloc] initWithString:city];
    if ([city isEqualToString:@"City"]) {
        [cityString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, cityString.string.length)];
    }
    [finalString appendAttributedString:cityString];
    [finalString appendAttributedString:commaString];
    NSMutableAttributedString *nationalString = [[NSMutableAttributedString alloc] initWithString:national];
    if ([national isEqualToString:@"Nationality"]) {
        [nationalString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, nationalString.string.length)];
    }
    [finalString appendAttributedString:nationalString];
    [self.descLabel setAttributedText:finalString];
}



-(void) layoutSubviews
{
    [super layoutSubviews];
    self.profilePicButton.frame = CGRectMake(10, 10, 44, 44);
    self.profilePicButton.layer.cornerRadius = self.profilePicButton.frame.size.width/2;
    self.profilePicButton.clipsToBounds = YES;
    self.profilePicButton.layer.borderWidth = 1.f;
    self.profilePicButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.activityIndicator.center = CGPointMake(self.profilePicButton.frame.size.width/2,
                                           self.profilePicButton.frame.size.height/2);
    
    self.descLabel.frame = CGRectMake(CGRectGetMaxX(self.profilePicButton.frame) + 10,
                                 10,
                                 self.frame.size.width - 30 - self.profilePicButton.frame.size.width,
                                 self.profilePicButton.frame.size.height);
    
    self.bottomButton2.frame = CGRectMake(0, 0, 217, 36);
    self.bottomButton2.layer.cornerRadius = 10.f;
    self.bottomButton2.clipsToBounds = YES;
    self.gradientLayer2.frame = self.bottomButton2.bounds;
    self.bottomButton2.center = CGPointMake(self.frame.size.width/2, CGRectGetMaxY(self.frame) - 40.f);
    
    self.bottomButton1.frame = CGRectMake(0, 0, 217, 36);
    self.bottomButton1.layer.cornerRadius = 10.f;
    self.bottomButton1.clipsToBounds = YES;
    self.gradientLayer1.frame = self.bottomButton1.bounds;
    self.bottomButton1.center = CGPointMake(self.frame.size.width/2, CGRectGetMinY(self.bottomButton2.frame) - 30.f);
    
    self.contentView.frame = CGRectMake(0, CGRectGetMaxY(self.profilePicButton.frame) + 10, self.frame.size.width, self.frame.size.height - CGRectGetMaxY(self.profilePicButton.frame) - 60 - self.bottomButton2.frame.size.height - self.bottomButton1.frame.size.height);
}



-(void) bottomButton1Tapped:(UIButton *) btn
{
    if ([self.delegate respondsToSelector:@selector(baseContentView:buttonTapped:)]) {
        [self.delegate baseContentView:self buttonTapped:btn];
    }
}


-(void) bottomButton2Tapped:(UIButton *) btn
{
    if ([self.delegate respondsToSelector:@selector(baseContentView:buttonTapped:)]) {
        [self.delegate baseContentView:self buttonTapped:btn];
    }
}

#pragma mark - TFPhotoContentViewDelegate


-(void) photoContentView:(TFPhotoContentView *) view buttonTapped:(UIButton *) btn
{
    if ([self.delegate respondsToSelector:@selector(baseContentView:buttonTapped:)]) {
        [self.delegate baseContentView:self buttonTapped:btn];
    }
}


@end
