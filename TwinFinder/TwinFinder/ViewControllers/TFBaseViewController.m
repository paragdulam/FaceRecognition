//
//  TFBaseViewController.m
//  TwinFinder
//
//  Created by Parag Dulam on 08/03/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import "TFBaseViewController.h"
#import "TFBaseContentView.h"
#import "TFPhotoContentView.h"

@interface TFBaseViewController ()<TFBaseContentViewDelegate,TFPhotoContentViewDelegate>

@end

@implementation TFBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [backgroundImageView setImage:[UIImage imageNamed:@"1"]];
    [self.view addSubview:backgroundImageView];
    
    appNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [appNameLabel setFont:[UIFont boldSystemFontOfSize:42.f]];
    [appNameLabel setText:@"twinfinder"];
    [appNameLabel sizeToFit];
    [self.view addSubview:appNameLabel];
    
    homeViewBackground = [[UIView alloc] initWithFrame:CGRectZero];
    homeViewBackground.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:homeViewBackground];
    
    dataBackgroundView = [[TFBaseContentView alloc] initWithFrame:CGRectZero];
    dataBackgroundView.delegate = self;
    dataBackgroundView.contentView.delegate = self;
    dataBackgroundView.backgroundColor = [UIColor blackColor];
    [homeViewBackground addSubview:dataBackgroundView];
    
    [dataBackgroundView.profilePicButton setImage:[UIImage imageNamed:@"logo_small"] forState:UIControlStateNormal];
    self.viewState = NORMAL;
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    backgroundImageView.frame = self.view.bounds;
    
    CGPoint logoCenter = appNameLabel.center;
    logoCenter.x = self.view.frame.size.width/2;
    logoCenter.y = 60.f;
    appNameLabel.center = logoCenter;
    
    homeViewBackground.frame = CGRectMake(5, CGRectGetMaxY(appNameLabel.frame) + 10.f, self.view.frame.size.width - 10, self.view.frame.size.height - CGRectGetMaxY(appNameLabel.frame) - 15.f);
    
    dataBackgroundView.frame = CGRectMake(5, 5, homeViewBackground.frame.size.width - 10, homeViewBackground.frame.size.height - 10);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
