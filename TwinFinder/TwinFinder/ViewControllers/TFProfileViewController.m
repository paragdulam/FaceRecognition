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
#import "AppDelegate.h"
#import "MAImageView.h"
#import "TFCameraViewController.h"

@interface TFProfileViewController ()<TFBaseContentViewDelegate,TFPhotoContentViewDelegate,TFCameraViewControllerDelegate>
{
    UIButton *cancelButton;
}

@end

@implementation TFProfileViewController


-(AppDelegate *) appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dataBackgroundView.contentView.photoButton2.hidden = YES;
    dataBackgroundView.contentView.progressView.hidden = YES;
    dataBackgroundView.bottomButton2.hidden = YES;
    dataBackgroundView.contentView.imageView2.hidden = YES;
    [dataBackgroundView.bottomButton1 setTitle:NSLocalizedString(@"Camera", nil) forState:UIControlStateNormal];
    
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [self.view addSubview:cancelButton];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.appDelegate profilePicturePath]]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfFile:[self.appDelegate profilePicturePath]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [dataBackgroundView.contentView.imageView1 setImage:[UIImage imageWithData:imageData]];
                [dataBackgroundView.contentView.photoButton1 setTitle:@"Added" forState:UIControlStateNormal];
            });
        });
    } else {
        [dataBackgroundView.contentView.imageView1 setImage:[UIImage imageNamed:@"singleface"]];
    }
}


-(void) cameraViewController:(TFCameraViewController *) vc didCapturePictureWithData:(NSData *) imageData WithIndex:(int) indx
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [imageData writeToFile:[appDelegate profilePicturePath] atomically:YES];
    [vc dismissViewControllerAnimated:YES completion:NULL];
    [dataBackgroundView.contentView.imageView1 setImage:[UIImage imageWithData:imageData]];
}

-(void) cameraViewControllerDidCancel:(TFCameraViewController *) vc
{
    [vc dismissViewControllerAnimated:YES completion:NULL];
}



-(void) baseContentView:(TFBaseContentView *) view buttonTapped:(UIButton *) btn
{
    switch (btn.tag) {
        case 1:
        {
            TFCameraViewController *cameraViewController = [[TFCameraViewController alloc] initWithIndex:0];
            [cameraViewController setDelegate:self];
            [self presentViewController:cameraViewController animated:YES completion:NULL];
        }
            break;
            
        default:
            break;
    }
}

-(void) photoContentView:(TFPhotoContentView *) view buttonTapped:(UIButton *) btn
{
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
