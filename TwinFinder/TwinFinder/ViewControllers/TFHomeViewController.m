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
#import "TFProfileViewController.h"
#import "DACircularProgressView.h"
#import "TFTextFieldView.h"
#import "UserInfo.h"

@interface TFHomeViewController ()<PFLogInViewControllerDelegate,TFBaseContentViewDelegate,TFPhotoContentViewDelegate,TFCameraViewControllerDelegate>
{
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
    dataBackgroundView.contentView.textFieldView.hidden = YES;

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
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.appDelegate clickedPicturePath]]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfFile:[self.appDelegate clickedPicturePath]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [dataBackgroundView.contentView.imageView1 setImage:[UIImage imageWithData:imageData]];
                [dataBackgroundView.contentView.photoButton1 setTitle:@"Added" forState:UIControlStateNormal];
            });
        });
    } else {
        [dataBackgroundView.contentView.imageView1 setImage:[UIImage imageNamed:@"singleface"]];
    }
    
    if (![[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self.appDelegate matchesPath] error:nil] count]) {
        [dataBackgroundView.contentView.imageView2 setImage:[UIImage imageNamed:@"twofaces"]];
    }
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
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
            TFProfileViewController *profileViewController = [[TFProfileViewController alloc] init];
            [self presentViewController:profileViewController animated:YES completion:NULL];
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
            NSData *imageData = [NSData dataWithContentsOfFile:[self.appDelegate clickedPicturePath]];
            if (imageData) {
                [TFAppManager saveFaceImageData:imageData
                                        AtIndex:0
                                      ForUserId:[PFUser currentUser].objectId
                              withProgressBlock:^(NSString *progressString, int progress) {
                                  CGFloat percentage = (float)progress * 0.01;
                                  [dataBackgroundView.contentView.progressView setProgress:percentage  animated:YES];
                              }
                            WithCompletionBlock:^(id object, int type, NSError *error) {
                                [dataBackgroundView.contentView.photoButton1 setTitle:@"Added" forState:UIControlStateNormal];
                            }];
            }
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
    
    UserInfo *userInfo = (UserInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:[TFAppManager appDelegate].managedObjectContext];
    userInfo.parse_id = user.objectId;
    [[TFAppManager appDelegate].managedObjectContext save:nil];
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
