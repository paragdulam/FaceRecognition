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
    backgroundImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.logInView insertSubview:backgroundImageView atIndex:1];
    [backgroundImageView setImage:[UIImage imageNamed:@"1"]];
    
    appNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [appNameLabel setFont:[UIFont boldSystemFontOfSize:42.f]];
    [appNameLabel setText:@"twinfinder"];
    [appNameLabel sizeToFit];
    [self.logInView setLogo:appNameLabel];
    
    logoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [logoImageView setImage:[UIImage imageNamed:@"logo"]];
    [logoImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.logInView insertSubview:logoImageView atIndex:2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGPoint logoCenter = self.logInView.logo.center;
    logoCenter.y = 60.f;
    self.logInView.logo.center = logoCenter;
    
    CGRect facebookFrame = self.logInView.facebookButton.frame;
    facebookFrame.origin.y = CGRectGetMaxY(self.logInView.logo.frame) + 10.f;
    self.logInView.facebookButton.frame = facebookFrame;
    
    CGRect twitterFrame = self.logInView.twitterButton.frame;
    twitterFrame.origin.y = facebookFrame.origin.y;
    self.logInView.twitterButton.frame = twitterFrame;
    
    CGRect userNameTextFrame = self.logInView.usernameField.frame;
    userNameTextFrame.origin.y = CGRectGetMaxY(self.logInView.facebookButton.frame) + facebookFrame.origin.x;
    self.logInView.usernameField.frame = userNameTextFrame;
    
    CGRect passwordTextFrame = self.logInView.passwordField.frame;
    passwordTextFrame.origin.y = CGRectGetMaxY(self.logInView.usernameField.frame);
    self.logInView.passwordField.frame = passwordTextFrame;
    
    CGRect loginFrame = self.logInView.logInButton.frame;
    loginFrame.origin.y = CGRectGetMaxY(self.logInView.passwordField.frame) + 16.f;
    self.logInView.logInButton.frame = loginFrame;
    
    CGRect passwordForgottenFrame = self.logInView.passwordForgottenButton.frame;
    passwordForgottenFrame.size.width = facebookFrame.size.width;
    passwordForgottenFrame.origin.x = facebookFrame.origin.x;
    passwordForgottenFrame.origin.y = CGRectGetMaxY(loginFrame) + 16.f;
    self.logInView.passwordForgottenButton.frame = passwordForgottenFrame;
    
    CGRect signUpFrame = self.logInView.signUpButton.frame;
    signUpFrame.origin.x = twitterFrame.origin.x;
    signUpFrame.origin.y = passwordForgottenFrame.origin.y;
    signUpFrame.size = passwordForgottenFrame.size;
    self.logInView.signUpButton.frame = signUpFrame;
    
    CGRect logoFrame = logoImageView.frame;
    logoFrame.origin.y = CGRectGetMaxY(signUpFrame) + 16;
    logoFrame.size.width = [UIScreen mainScreen].bounds.size.width ;
    logoFrame.size.height = [UIScreen mainScreen].bounds.size.height - CGRectGetMaxY(signUpFrame) - 32.f;
    logoImageView.frame = logoFrame;
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
