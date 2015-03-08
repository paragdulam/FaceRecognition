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
#import "AppDelegate.h"

@interface TFBaseContentView()<TFPhotoContentViewDelegate>
{
    UIButton *profilePicButton;
    UILabel *descLabel;
    UILabel *locationLabel;
    UIButton *bottomButton1;
    CAGradientLayer *gradientLayer1;
    UIButton *bottomButton2;
    CAGradientLayer *gradientLayer2;
    UIActivityIndicatorView *activityIndicator;
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
        profilePicButton = [UIButton buttonWithType:UIButtonTypeCustom];
        profilePicButton.backgroundColor = [UIColor blackColor];
        [self addSubview:profilePicButton];
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.hidesWhenStopped = YES;
        [profilePicButton addSubview:activityIndicator];
        
        descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        descLabel.textColor = [UIColor whiteColor];
        [self addSubview:descLabel];
        
        locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:locationLabel];
        
        bottomButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [bottomButton1.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
        [bottomButton1 setTitle:NSLocalizedString(@"Create a profile", nil) forState:UIControlStateNormal];
        [bottomButton1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [bottomButton1 addTarget:self action:@selector(bottomButton1Tapped:) forControlEvents:UIControlEventTouchUpInside];
        bottomButton1.tag = 1;
        
        gradientLayer1 = [CAGradientLayer layer];
        gradientLayer1.colors = @[(id)[UIColor lightGrayColor].CGColor,
                                 (id)[UIColor whiteColor].CGColor];
        gradientLayer1.frame = bottomButton1.bounds;
        [bottomButton1.layer insertSublayer:gradientLayer1 atIndex:0];
        
        [self addSubview:bottomButton1];
        
        bottomButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [bottomButton2.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
        [bottomButton2 setTitle:NSLocalizedString(@"Camera", nil) forState:UIControlStateNormal];
        [bottomButton2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [bottomButton2 addTarget:self action:@selector(bottomButton2Tapped:) forControlEvents:UIControlEventTouchUpInside];
        bottomButton2.tag = 2;
        
        gradientLayer2 = [CAGradientLayer layer];
        gradientLayer2.colors = @[(id)[UIColor lightGrayColor].CGColor,
                                  (id)[UIColor whiteColor].CGColor];
        gradientLayer2.frame = bottomButton2.bounds;
        [bottomButton2.layer insertSublayer:gradientLayer2 atIndex:0];
        
        [self addSubview:bottomButton2];
        
        self.contentView = [[TFPhotoContentView alloc] initWithFrame:CGRectZero];
        self.contentView.backgroundColor = [UIColor colorWithRed:210.f/255.f green:221.f/255.f blue:227.f/255.f alpha:1];
        [self addSubview:self.contentView];
    }
    return self;
}


-(void) layoutSubviews
{
    [super layoutSubviews];
    profilePicButton.frame = CGRectMake(10, 10, 44, 44);
    profilePicButton.layer.cornerRadius = profilePicButton.frame.size.width/2;
    profilePicButton.clipsToBounds = YES;
    profilePicButton.layer.borderWidth = 1.f;
    profilePicButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    activityIndicator.center = CGPointMake(profilePicButton.frame.size.width/2,
                                           profilePicButton.frame.size.height/2);
    
    descLabel.frame = CGRectMake(CGRectGetMaxX(profilePicButton.frame) + 10,
                                 10,
                                 self.frame.size.width - 30 - profilePicButton.frame.size.width,
                                 profilePicButton.frame.size.height);
    
    bottomButton2.frame = CGRectMake(0, 0, 217, 36);
    bottomButton2.layer.cornerRadius = 10.f;
    bottomButton2.clipsToBounds = YES;
    gradientLayer2.frame = bottomButton2.bounds;
    bottomButton2.center = CGPointMake(self.frame.size.width/2, CGRectGetMaxY(self.frame) - 40.f);
    
    bottomButton1.frame = CGRectMake(0, 0, 217, 36);
    bottomButton1.layer.cornerRadius = 10.f;
    bottomButton1.clipsToBounds = YES;
    gradientLayer1.frame = bottomButton1.bounds;
    bottomButton1.center = CGPointMake(self.frame.size.width/2, CGRectGetMinY(bottomButton2.frame) - 30.f);
    
    self.contentView.frame = CGRectMake(0, CGRectGetMaxY(profilePicButton.frame) + 10, self.frame.size.width, self.frame.size.height - CGRectGetMaxY(profilePicButton.frame) - 60 - bottomButton2.frame.size.height - bottomButton1.frame.size.height);
}


-(void) setUserInfo:(id) userInfo
{
    UserInfo *user = (UserInfo *)userInfo;
    [descLabel setText:[NSString stringWithFormat:@"%@,%@",user.firstName,user.age]];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[appDelegate applicationDocumentsDirectory].path,user.facebookId];
    BOOL no = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&no]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                [profilePicButton setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
            });
        });
    } else {
        NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",user.facebookId];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [activityIndicator startAnimating];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [data writeToFile:filePath atomically:YES];
            });
            [activityIndicator stopAnimating];
            [profilePicButton setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
        }];
    }
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
