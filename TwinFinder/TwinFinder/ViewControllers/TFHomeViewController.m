//
//  TFHomeViewController.m
//  TwinFinder
//
//  Created by Parag Dulam on 07/03/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import "TFHomeViewController.h"
#import "TFBaseContentView.h"
#import "TFPhotoContentView.h"
#import <Parse/Parse.h>
#import "TFLoginViewController.h"
#import "AppDelegate.h"
#import "TFAppManager.h"
#import "TFCameraViewController.h"
#import "MAImageView.h"

@interface TFHomeViewController ()<PFLogInViewControllerDelegate,TFBaseContentViewDelegate,TFPhotoContentViewDelegate,TFCameraViewControllerDelegate>
{
    UIImageView *backgroundImageView;
    UILabel *appNameLabel;
    UIView *homeViewBackground;
    TFBaseContentView *dataBackgroundView;
}

@property (nonatomic,strong) TFLoginViewController *loginViewController;
@property (nonatomic,weak) AppDelegate *appDelegate;

@end

@implementation TFHomeViewController


-(AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:YES];
    
    backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
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
    
    if ([[PFUser currentUser] sessionToken]) {
        [self doPostLogin];
    } else {
        [self performSelector:@selector(showLoginView:) withObject:[NSNumber numberWithBool:NO] afterDelay:.3f];
    }
}


-(void) showLoginView:(NSNumber *) animated
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate flushDatabase];
    self.loginViewController = [[TFLoginViewController alloc] init];
    [self.loginViewController setFields:PFLogInFieldsFacebook | PFLogInFieldsTwitter | PFLogInFieldsLogInButton | PFLogInFieldsUsernameAndPassword | PFLogInFieldsPasswordForgotten | PFLogInFieldsSignUpButton];
    [self.loginViewController setDelegate:self];
    [self presentViewController:self.loginViewController animated:[animated boolValue] completion:NULL];
}

-(void) doPostLogin
{
    [TFAppManager saveCurrentUserWithCompletionBlock:^(id object, NSError *error) {
        [dataBackgroundView setUserInfo:object];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self.appDelegate clickedPicturePath]]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData *imageData = [NSData dataWithContentsOfFile:[self.appDelegate clickedPicturePath]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [dataBackgroundView.contentView.imageView1 setImage:[UIImage imageWithData:imageData]];
                });
            });
        } else {
            [dataBackgroundView.contentView.imageView1 setImage:[UIImage imageNamed:@"singleface"]];
            [dataBackgroundView.contentView.imageView2 setImage:[UIImage imageNamed:@"twofaces"]];
        }
    }];
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
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



#pragma mark -  TFCameraViewControllerDelegate

-(void) cameraViewController:(TFCameraViewController *) vc didCapturePictureWithData:(NSData *) imageData WithIndex:(int) indx
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [imageData writeToFile:[appDelegate clickedPicturePath] atomically:YES];
    [vc dismissViewControllerAnimated:YES completion:NULL];
    [dataBackgroundView.contentView.imageView1 setImage:[UIImage imageWithData:imageData]];
}

-(void) cameraViewControllerDidCancel:(TFCameraViewController *) vc
{
    [vc dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - TFBaseContentViewDelegate,TFPhotoContentViewDelegate

-(void) baseContentView:(TFBaseContentView *) view buttonTapped:(UIButton *) btn
{
    switch (btn.tag) {
        case 1:
        {
            //Profile View Controller
        }
            break;
        case 2:
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


-(void) photoContentView:(TFPhotoContentView *)view buttonTapped:(UIButton *)btn
{
    switch (btn.tag) {
        case 1:
        {
            //upload image to parse.
        }
            break;
        case 2:
        {
            //face recognition.
        }
            break;
        default:
            break;
    }
}


#pragma mark - PFLogInViewControllerDelegate


- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [self doPostLogin];
    [logInController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alertView show];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    
}

@end
