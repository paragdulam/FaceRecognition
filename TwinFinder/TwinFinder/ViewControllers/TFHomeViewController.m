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
#import "TFImagesView.h"
#import "UserInfo.h"
#import "FaceImage.h"
#import "TFImagesView.h"

@interface TFHomeViewController ()<PFLogInViewControllerDelegate,TFBaseContentViewDelegate,TFPhotoContentViewDelegate,TFCameraViewControllerDelegate,TFImagesViewDelegate>
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
    dataBackgroundView.contentView.photoButton2.enabled = NO;
    dataBackgroundView.contentView.imagesView.delegate = self;;

    
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
                dataBackgroundView.contentView.photoButton2.enabled = YES;
            });
        });
    } else {
        [dataBackgroundView.contentView.imageView1 setImage:[UIImage imageNamed:@"singleface"]];
        PFQuery *faceQuery = [PFQuery queryWithClassName:@"FaceImage"];
        [faceQuery whereKey:@"createdBy" equalTo:[PFUser currentUser]];
        [faceQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            PFObject *faceImage = [objects firstObject];
            PFFile *imageFile = [faceImage objectForKey:@"imageFile"];
            [TFAppManager saveFaceImage:faceImage completionBlock:^(id obj, NSError *error) {
                
            }];
            [dataBackgroundView.contentView.imageView1 setImageURL:[NSURL URLWithString:imageFile.url] forFileId:faceImage.objectId];
            dataBackgroundView.contentView.photoButton2.enabled = YES;
        }];
        
        [dataBackgroundView.descLabel setText:@"Loading..."];
        PFQuery *userInfoQuery = [PFQuery queryWithClassName:@"UserInfo"];
        [userInfoQuery whereKey:@"User" equalTo:[PFUser currentUser]];
        [userInfoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            PFObject *userInfo = [objects firstObject];
            [TFAppManager saveUserinfo:userInfo];
            [dataBackgroundView.descLabel setText:[NSString stringWithFormat:@"%@,%@,%@,%@,%@",[userInfo objectForKey:@"name"],[userInfo objectForKey:@"age"],[userInfo objectForKey:@"city"],[userInfo objectForKey:@"location"],[userInfo objectForKey:@"national"]]];
        }];
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



#pragma mark -  TFImagesViewDelegate

-(void) imagesView:(TFImagesView *) view tappedView:(MAImageView *) imgView
{
    FaceImage *faceImage = [TFAppManager faceImageWithFaceImageId:imgView.idString];
    CGFloat progress = [faceImage.confidence floatValue]/100.f;
    [dataBackgroundView.contentView.progressView setProgress:progress animated:YES];
    [dataBackgroundView.contentView.progressView setProgress:progress animated:YES];
    [dataBackgroundView.contentView.progressLabel setText:[NSString stringWithFormat:@"%@%%",faceImage.confidence]];
    [dataBackgroundView.contentView.progressLabel sizeToFit];
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
            FaceImage *faceImage = [TFAppManager faceImageWithUserId:[PFUser currentUser].objectId];
            if (faceImage) {
                __block int index = 0;
                [TFAppManager getLookalikesForFaceImage:faceImage withCompletionBlock:^(id object, NSError *error) {
                    FaceImage *fImage = (FaceImage *)object;
                    MAImageView *imageView = nil;
                    switch (index) {
                        case 0:
                            imageView = dataBackgroundView.contentView.imagesView.imageView1;
                            break;
                        case 1:
                            imageView = dataBackgroundView.contentView.imagesView.imageView2;
                            break;
                        case 2:
                            imageView = dataBackgroundView.contentView.imagesView.imageView3;
                            break;
                        case 3:
                            imageView = dataBackgroundView.contentView.imagesView.imageView4;
                            break;
                            
                        default:
                            break;
                    }
                    index ++;
                    [dataBackgroundView.contentView.imageView2 setHidden:YES];
                    [dataBackgroundView.contentView.photoButton2 setTitle:@"Search Again" forState:UIControlStateNormal];
                    [imageView setImageURL:[NSURL URLWithString:fImage.image_url] forFileId:fImage.parse_id];
                    CGFloat progress = [faceImage.confidence floatValue]/100.f;
                    [dataBackgroundView.contentView.progressView setProgress:progress animated:YES];
                    [dataBackgroundView.contentView.progressView setProgress:progress animated:YES];
                    [dataBackgroundView.contentView.progressLabel setText:[NSString stringWithFormat:@"%@%%",faceImage.confidence]];
                    [dataBackgroundView.contentView.progressLabel sizeToFit];
                }];
            }
        }
            break;
        default:
            break;
    }
}


#pragma mark - PFLogInViewControllerDelegate


- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    UserInfo *userInfo = (UserInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:[TFAppManager appDelegate].managedObjectContext];
    userInfo.parse_id = user.objectId;
    [[TFAppManager appDelegate].managedObjectContext save:nil];

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
