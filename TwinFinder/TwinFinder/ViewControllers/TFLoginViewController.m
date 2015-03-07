//
//  TFLoginViewController.m
//  TwinFinder
//
//  Created by Parag Dulam on 07/03/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import "TFLoginViewController.h"

@interface TFLoginViewController ()
{
    UILabel *appNameLabel;
    UIImageView *logoImageView;
    UIImageView *backgroundImageView;
    
}
@end

@implementation TFLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:backgroundImageView];
    [backgroundImageView setImage:[UIImage imageNamed:@"1"]];
    
    appNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [appNameLabel setFont:[UIFont boldSystemFontOfSize:42.f]];
    [appNameLabel setText:@"twinfinder"];
    [appNameLabel sizeToFit];
    [self.logInView setLogo:appNameLabel];
    
    logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 180, 170)];
    [logoImageView setImage:[UIImage imageNamed:@"logo"]];
    [self.logInView addSubview:logoImageView];
    logoImageView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGPoint logoCenter = self.logInView.logo.center;
    logoCenter.y = 90.f;
    self.logInView.logo.center = logoCenter;
    
    CGRect facebookFrame = self.logInView.facebookButton.frame;
    facebookFrame.origin.y = 160.f;
    self.logInView.facebookButton.frame = facebookFrame;
    
    CGRect twitterFrame = self.logInView.twitterButton.frame;
    twitterFrame.origin.y = 160.f;
    self.logInView.twitterButton.frame = twitterFrame;
    
    CGRect userNameTextFrame = self.logInView.usernameField.frame;
    userNameTextFrame.origin.y = CGRectGetMaxY(self.logInView.facebookButton.frame) + facebookFrame.origin.x;
    self.logInView.usernameField.frame = userNameTextFrame;
    
    CGRect passwordTextFrame = self.logInView.passwordField.frame;
    passwordTextFrame.origin.y = CGRectGetMaxY(self.logInView.usernameField.frame);
    self.logInView.passwordField.frame = passwordTextFrame;

    
//    UIImageView *logoView = (UIImageView *)self.logInView.logo;
//    CGRect logoFrame = self.logInView.logo.frame;
//    logoFrame.size = logoView.image.size;
//    self.logInView.logo.frame = logoFrame;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
