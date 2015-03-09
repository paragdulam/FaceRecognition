//
//  TFProfileViewController.m
//  TwinFinder
//
//  Created by Parag Dulam on 08/03/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import "TFProfileViewController.h"
#import "TFTextFieldView.h"
#import "TFBaseContentView.h"
#import "TFPhotoContentView.h"
#import "DACircularProgressView.h"

@interface TFProfileViewController ()
{
    UIButton *cancelButton;
}

@end

@implementation TFProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dataBackgroundView.contentView.photoButton2.hidden = YES;
    dataBackgroundView.contentView.progressView.hidden = YES;
    dataBackgroundView.bottomButton2.hidden = YES;
    [dataBackgroundView.bottomButton1 setTitle:NSLocalizedString(@"Camera", nil) forState:UIControlStateNormal];
    
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:cancelButton];
}


-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    cancelButton.frame = CGRectMake(0, 0, 50, 50);
    cancelButton.center = CGPointMake(30,appNameLabel.center.y);
}

-(void) cancelButtonTapped:(UIButton *)btn
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
