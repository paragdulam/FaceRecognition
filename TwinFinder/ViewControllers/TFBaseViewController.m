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
#import <GoogleMobileAds/GoogleMobileAds.h>


@interface TFBaseViewController ()<TFBaseContentViewDelegate,TFPhotoContentViewDelegate>

@property (strong, nonatomic) GADBannerView *bannerView;

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
    self.bannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(self.view.frame.size.width, 50)) origin:CGPointMake(0, self.view.frame.size.height - 55)];
    [self.view addSubview:self.bannerView];
    self.bannerView.adUnitID = @"ca-app-pub-8389287507606895/2534918963";
    self.bannerView.rootViewController = self;
    GADRequest *request = [GADRequest request];
    [self.bannerView loadRequest:request];

}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    backgroundImageView.frame = self.view.bounds;
    
    CGPoint logoCenter = appNameLabel.center;
    logoCenter.x = self.view.frame.size.width/2;
    logoCenter.y = 40.f;
    appNameLabel.center = logoCenter;
    
    homeViewBackground.frame = CGRectMake(5, CGRectGetMaxY(appNameLabel.frame), self.view.frame.size.width - 10, self.view.frame.size.height - CGRectGetMaxY(appNameLabel.frame) - 60.f );
    
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
