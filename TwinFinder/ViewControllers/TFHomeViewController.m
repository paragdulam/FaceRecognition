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
#import <MessageUI/MessageUI.h>
#import "TFChatViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <iAd/iAd.h>
#import "MBProgressHUD.h"
#import "TFImageViewController.h"



@interface TFHomeViewController ()<PFLogInViewControllerDelegate,TFBaseContentViewDelegate,TFPhotoContentViewDelegate,TFCameraViewControllerDelegate,TFImagesViewDelegate,MFMailComposeViewControllerDelegate,GADInterstitialDelegate,GADBannerViewDelegate,ADBannerViewDelegate>
{
    UIButton *backButton;
}

@property (nonatomic,strong) TFLoginViewController *loginViewController;
@property (nonatomic,strong) UIButton *logoutButton;
@property (nonatomic,weak) AppDelegate *appDelegate;
@property(nonatomic, strong) GADInterstitial *interstitial;
//@property (strong, nonatomic) GADBannerView *bannerView;
@property (strong, nonatomic) ADBannerView *bannerView;

@end

@implementation TFHomeViewController


-(AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.bannerView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, 320, 50)];
    self.bannerView.delegate = self;
    [self.view addSubview:self.bannerView];
    
    [self.navigationController setNavigationBarHidden:YES];
    dataBackgroundView.contentView.textFieldView.hidden = YES;
    dataBackgroundView.contentView.backButton.hidden = YES;
    dataBackgroundView.contentView.imagesView.delegate = self;

    self.logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.logoutButton.frame = CGRectMake(0, 0, 40, 40);
    [self.view addSubview:self.logoutButton];
    [self.logoutButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [self.logoutButton addTarget:self action:@selector(logoutButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"com.user.updated"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      UserInfo *userInfo = [TFAppManager userWithId:[PFUser currentUser].objectId];
                                                      UIImage *profileImage = [UIImage imageNamed:userInfo.national];
                                                      [dataBackgroundView.profilePicButton setImage:profileImage forState:UIControlStateNormal];
                                                      [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"profile_updated"];
                                                      [dataBackgroundView.bottomButton1 setTitle:NSLocalizedString(@"Update Profile", nil) forState:UIControlStateNormal];
    
                                                  }];
//    if ([[PFUser currentUser] sessionToken]) {
        [self doPostLogin];
//    } else {
//        [self performSelector:@selector(showLoginView:) withObject:[NSNumber numberWithBool:NO] afterDelay:.3f];
//    }
}


- (void)backButtonTapped:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
//    TFImageViewController *imageViewController = [[TFImageViewController alloc] init];
//    [self presentViewController:imageViewController animated:NO completion:NULL];
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


-(void)logoutButtonTapped:(UIButton *) btn
{
    [self backButtonTapped:btn];
}

- (GADInterstitial *)createAndLoadInterstitial {
    GADInterstitial *interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-8389287507606895/4011652165"];
    interstitial.delegate = self;
    GADRequest *request = [GADRequest request];
    [interstitial loadRequest:request];
    return interstitial;
}

-(void) doPostLogin
{
    dataBackgroundView.contentView.imagesView.hidden = YES;
    dataBackgroundView.contentView.imageView2.hidden = NO;
    dataBackgroundView.contentView.photoButton2.enabled = NO;
    [dataBackgroundView.contentView.photoButton2 setTitle:NSLocalizedString(@"Start Search", nil) forState:UIControlStateNormal];
    [dataBackgroundView.contentView.photoButton1 setTitle:NSLocalizedString(@"Take Picture", nil) forState:UIControlStateNormal];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.appDelegate clickedPicturePath]]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            UserInfo *userInfo = [TFAppManager userWithId:[PFUser currentUser].objectId];
            UIImage *profileImage = [UIImage imageNamed:userInfo.national];
            [dataBackgroundView.profilePicButton setImage:profileImage forState:UIControlStateNormal];
            NSData *imageData = [NSData dataWithContentsOfFile:[self.appDelegate clickedPicturePath]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [dataBackgroundView.contentView.imageView1 setImage:[UIImage imageWithData:imageData]];
                [dataBackgroundView.contentView.photoButton1 setTitle:NSLocalizedString(@"Take New Picture", nil) forState:UIControlStateNormal];
                dataBackgroundView.contentView.photoButton2.enabled = YES;
            });
        });
    } else {
        [dataBackgroundView.contentView.imageView1 setImage:[UIImage imageNamed:@"singleface"]];
        PFQuery *faceQuery = [PFQuery queryWithClassName:@"FaceImage"];
        [faceQuery whereKey:@"createdBy" equalTo:[PFUser currentUser]];
        [faceQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                PFObject *faceImage = [objects firstObject];
                PFFile *imageFile = [faceImage objectForKey:@"imageFile"];
                [TFAppManager saveFaceImage:faceImage completionBlock:^(id obj, NSError *error) {
                    
                }];
                [dataBackgroundView.contentView.imageView1 setImageURL:[NSURL URLWithString:imageFile.url] forFileId:CLICKED_FACE_PICTURE];
                dataBackgroundView.contentView.photoButton2.enabled = YES;
            } else {
                [self showErrorAlert:error];
            }
        }];
        
        [dataBackgroundView.descLabel setText:@"Loading..."];
        PFQuery *userInfoQuery = [PFQuery queryWithClassName:@"UserInfo"];
        [userInfoQuery whereKey:@"User" equalTo:[PFUser currentUser]];
        [userInfoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                PFObject *userInfo = [objects firstObject];
                [TFAppManager saveUserinfo:userInfo];
                [dataBackgroundView.profilePicButton setImage:[UIImage imageNamed:[userInfo objectForKey:@"national"]] forState:UIControlStateNormal];
                
                
                NSString *name = [[userInfo objectForKey:@"name"] length] ? [userInfo objectForKey:@"name"] : NSLocalizedString(@"Name", nil);
                NSString *age = [[userInfo objectForKey:@"age"] length] ? [userInfo objectForKey:@"age"] : NSLocalizedString(@"Age", nil);
                NSString *city = [[userInfo objectForKey:@"city"] length] ? [userInfo objectForKey:@"city"] : NSLocalizedString(@"City", nil);
                NSString *national = [[userInfo objectForKey:@"national"] length] ? [userInfo objectForKey:@"national"] : NSLocalizedString(@"Nationality", nil);
                
                NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] init];
                NSMutableAttributedString *commaString = [[NSMutableAttributedString alloc] initWithString:@","];
                NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:name];
                if ([name isEqualToString:NSLocalizedString(@"Name", nil)]) {
                    [nameString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, nameString.string.length)];
                }
                [finalString appendAttributedString:nameString];
                [finalString appendAttributedString:commaString];
                NSMutableAttributedString *ageString = [[NSMutableAttributedString alloc] initWithString:age];
                if ([age isEqualToString:NSLocalizedString(@"Age", nil)]) {
                    [ageString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, ageString.string.length)];
                }
                [finalString appendAttributedString:ageString];
                [finalString appendAttributedString:commaString];
                NSMutableAttributedString *cityString = [[NSMutableAttributedString alloc] initWithString:city];
                if ([city isEqualToString:NSLocalizedString(@"City", nil)]) {
                    [cityString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, cityString.string.length)];
                }
                [finalString appendAttributedString:cityString];
                [finalString appendAttributedString:commaString];
                NSMutableAttributedString *nationalString = [[NSMutableAttributedString alloc] initWithString:national];
                if ([national isEqualToString:NSLocalizedString(@"Nationality", nil)]) {
                    [nationalString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, nationalString.string.length)];
                }
                [finalString appendAttributedString:nationalString];
                [dataBackgroundView.descLabel setAttributedText:finalString];
            } else {
                [self showErrorAlert:error];
            }
        }];
    }
    
    if (![[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self.appDelegate matchesPath] error:nil] count]) {
        [dataBackgroundView.contentView.imageView2 setImage:[UIImage imageNamed:@"twofaces"]];
    }
}


- (void)showErrorAlert:(NSError *)err
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[err localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alertView show];
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.logoutButton.center = CGPointMake(25.f, appNameLabel.center.y);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -  MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark -  TFImagesViewDelegate

-(void) imagesView:(TFImagesView *) view longPressedView:(MAImageView *) imgView
{
    [self imagesView:view tappedView:imgView];
    FaceImage *faceImage = [TFAppManager faceImageWithFaceImageId:imgView.idString];
    UserInfo *userInfo = faceImage.createdBy;
    
    NSString *name = userInfo.name.length ? userInfo.name : NSLocalizedString(@"Name", nil);
    NSString *age = userInfo.age.length ? userInfo.age : NSLocalizedString(@"Age", nil);
    NSString *city = userInfo.city.length ? userInfo.city : NSLocalizedString(@"City", nil);
    NSString *national = userInfo.national.length ? userInfo.national : NSLocalizedString(@"Nationality", nil);
    
    NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *commaString = [[NSMutableAttributedString alloc] initWithString:@","];
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:name];
    if ([name isEqualToString:NSLocalizedString(@"Nationality", nil)]) {
        [nameString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, nameString.string.length)];
    }
    [finalString appendAttributedString:nameString];
    [finalString appendAttributedString:commaString];
    NSMutableAttributedString *ageString = [[NSMutableAttributedString alloc] initWithString:age];
    if ([age isEqualToString:NSLocalizedString(@"Age", nil)]) {
        [ageString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, ageString.string.length)];
    }
    [finalString appendAttributedString:ageString];
    [finalString appendAttributedString:commaString];
    NSMutableAttributedString *cityString = [[NSMutableAttributedString alloc] initWithString:city];
    if ([city isEqualToString:NSLocalizedString(@"City", nil)]) {
        [cityString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, cityString.string.length)];
    }
    [finalString appendAttributedString:cityString];
    [finalString appendAttributedString:commaString];
    NSMutableAttributedString *nationalString = [[NSMutableAttributedString alloc] initWithString:national];
    if ([national isEqualToString:NSLocalizedString(@"Nationality", nil)]) {
        [nationalString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, nationalString.string.length)];
    }
    [finalString appendAttributedString:nationalString];
    [dataBackgroundView.descLabel setAttributedText:finalString];

    if (userInfo.parse_id && userInfo.name) {
        TFChatViewController *chatViewController = [[TFChatViewController alloc] initWithRecipient:userInfo];
        UINavigationController *chatNavController = [[UINavigationController alloc] initWithRootViewController:chatViewController];
        [chatViewController setSenderId:[PFUser currentUser].objectId];
        [chatViewController setSenderDisplayName:[TFAppManager userWithId:[PFUser currentUser].objectId].name];
        [self presentViewController:chatNavController animated:YES completion:NULL];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"The selected user has not configured his profile.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
        [alertView show];
    }
}


-(void) imagesView:(TFImagesView *) view tappedView:(MAImageView *) imgView
{
    FaceImage *faceImage = [TFAppManager faceImageWithFaceImageId:imgView.idString];

    dataBackgroundView.contentView.backButton.hidden = NO;
    dataBackgroundView.contentView.imagesView.hidden = YES;
    dataBackgroundView.contentView.imageView2.hidden = NO;
    [dataBackgroundView.contentView.imageView2 setImageURL:[NSURL URLWithString:faceImage.image_url] forFileId:faceImage.parse_id];
    [dataBackgroundView.contentView.photoButton2 setTitle:NSLocalizedString(@"Chat", nil) forState:UIControlStateNormal];
    
    CGFloat progress = [faceImage.confidence floatValue]/100.f;
    [dataBackgroundView.contentView.progressView setProgress:progress animated:YES];
    [dataBackgroundView.contentView.progressLabel setText:[NSString stringWithFormat:@"%@%%",faceImage.confidence]];
    [dataBackgroundView.contentView.progressLabel sizeToFit];
    UserInfo *userInfo = faceImage.createdBy;

    NSString *name = userInfo.name.length ? userInfo.name : NSLocalizedString(@"Name", nil);
    NSString *age = userInfo.age.length ? userInfo.age : NSLocalizedString(@"Age", nil);
    NSString *city = userInfo.city.length ? userInfo.city : NSLocalizedString(@"City", nil);
    NSString *national = userInfo.national.length ? userInfo.national : NSLocalizedString(@"Nationality", nil);
    
    NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *commaString = [[NSMutableAttributedString alloc] initWithString:@","];
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:name];
    if ([name isEqualToString:NSLocalizedString(@"Name", nil)]) {
        [nameString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, nameString.string.length)];
    }
    [finalString appendAttributedString:nameString];
    [finalString appendAttributedString:commaString];
    NSMutableAttributedString *ageString = [[NSMutableAttributedString alloc] initWithString:age];
    if ([age isEqualToString:NSLocalizedString(@"Age", nil)]) {
        [ageString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, ageString.string.length)];
    }
    [finalString appendAttributedString:ageString];
    [finalString appendAttributedString:commaString];
    NSMutableAttributedString *cityString = [[NSMutableAttributedString alloc] initWithString:city];
    if ([city isEqualToString:NSLocalizedString(@"City", nil)]) {
        [cityString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, cityString.string.length)];
    }
    [finalString appendAttributedString:cityString];
    [finalString appendAttributedString:commaString];
    NSMutableAttributedString *nationalString = [[NSMutableAttributedString alloc] initWithString:national];
    if ([national isEqualToString:NSLocalizedString(@"Nationality", nil)]) {
        [nationalString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, nationalString.string.length)];
    }
    [finalString appendAttributedString:nationalString];
    [dataBackgroundView.descLabel setAttributedText:finalString];
    
    UIImage *profileImage = [UIImage imageNamed:userInfo.national];
    [dataBackgroundView.profilePicButton setImage:profileImage forState:UIControlStateNormal];
}


#pragma mark -  TFCameraViewControllerDelegate

-(void) cameraViewController:(TFCameraViewController *) vc didCapturePictureWithData:(NSData *) imageData WithIndex:(int) indx
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [imageData writeToFile:[appDelegate clickedPicturePath] atomically:YES];
    [vc dismissViewControllerAnimated:YES completion:NULL];
    [dataBackgroundView.contentView.imageView1 setImage:[UIImage imageWithData:imageData]];
    
    MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [progressHUD setLabelText:NSLocalizedString(@"Uploading...", nil)];
    [TFAppManager saveFaceImageData:imageData
                            AtIndex:0
                          ForUserId:[PFUser currentUser].objectId
                  withProgressBlock:^(NSString *progressString, int progress) {
                      CGFloat percentage = (float)progress * 0.01;
                      [dataBackgroundView.contentView.progressView setProgress:percentage  animated:YES];
                  }
                WithCompletionBlock:^(id object, int type, NSError *error) {
                    [progressHUD hide:YES];
                    if (!error) {
                        [dataBackgroundView.contentView.photoButton1 setTitle:NSLocalizedString(@"Take New Picture", nil) forState:UIControlStateNormal];
                        dataBackgroundView.contentView.photoButton2.enabled = YES;
                    } else {
                        [self showErrorAlert:error];
                    }
                }];
}

-(void) cameraViewControllerDidCancel:(TFCameraViewController *) vc
{
    [vc dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - GADBannerViewDelegate


- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    
}


#pragma mark - GADInterstitialDelegate


- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    [ad presentFromRootViewController:self];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    
}


#pragma mark - TFBaseContentViewDelegate,TFPhotoContentViewDelegate


-(void) photoContentView:(TFPhotoContentView *) view backbuttonTapped:(UIButton *) btn
{
    dataBackgroundView.contentView.backButton.hidden = YES;
    dataBackgroundView.contentView.imagesView.hidden = NO;
    dataBackgroundView.contentView.imageView2.hidden = YES;
    [dataBackgroundView.contentView.photoButton2 setTitle:NSLocalizedString(@"Search Again", nil) forState:UIControlStateNormal];
}

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


-(void) photoContentViewWasTapped:(TFPhotoContentView *) view
{
    UserInfo *userInfo = [TFAppManager userWithId:[PFUser currentUser].objectId];
    UIImage *profileImage = [UIImage imageNamed:userInfo.national];
    [dataBackgroundView.profilePicButton setImage:profileImage forState:UIControlStateNormal];

    NSString *name = userInfo.name.length ? userInfo.name : NSLocalizedString(@"Name", nil);
    NSString *age = userInfo.age.length ? userInfo.age : NSLocalizedString(@"Age", nil);
    NSString *city = userInfo.city.length ? userInfo.city : NSLocalizedString(@"City", nil);
    NSString *national = userInfo.national.length ? userInfo.national : NSLocalizedString(@"Nationality", nil);
    
    NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *commaString = [[NSMutableAttributedString alloc] initWithString:@","];
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:name];
    if ([name isEqualToString:NSLocalizedString(@"Name", nil)]) {
        [nameString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, nameString.string.length)];
    }
    [finalString appendAttributedString:nameString];
    [finalString appendAttributedString:commaString];
    NSMutableAttributedString *ageString = [[NSMutableAttributedString alloc] initWithString:age];
    if ([age isEqualToString:NSLocalizedString(@"Age", nil)]) {
        [ageString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, ageString.string.length)];
    }
    [finalString appendAttributedString:ageString];
    [finalString appendAttributedString:commaString];
    NSMutableAttributedString *cityString = [[NSMutableAttributedString alloc] initWithString:city];
    if ([city isEqualToString:NSLocalizedString(@"City", nil)]) {
        [cityString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, cityString.string.length)];
    }
    [finalString appendAttributedString:cityString];
    [finalString appendAttributedString:commaString];
    NSMutableAttributedString *nationalString = [[NSMutableAttributedString alloc] initWithString:national];
    if ([national isEqualToString:NSLocalizedString(@"Nationality", nil)]) {
        [nationalString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, nationalString.string.length)];
    }
    [finalString appendAttributedString:nationalString];
    [dataBackgroundView.descLabel setAttributedText:finalString];
    
}


-(void) photoContentView:(TFPhotoContentView *)view buttonTapped:(UIButton *)btn
{
    switch (btn.tag) {
        case 1:
        {
            TFCameraViewController *cameraViewController = [[TFCameraViewController alloc] initWithIndex:0];
            [cameraViewController setDelegate:self];
            [self presentViewController:cameraViewController animated:YES completion:NULL];
        }
            break;
        case 2:
        {
            if (![btn.titleLabel.text isEqualToString:NSLocalizedString(@"Chat", nil)]) {
                self.interstitial = [self createAndLoadInterstitial];
                //face recognition.
                FaceImage *faceImage = [TFAppManager faceImageWithUserId:[PFUser currentUser].objectId];
                if (faceImage) {
                    __block int index = 0;
                    
                    MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    [progressHUD setLabelText:NSLocalizedString(@"Searching...", nil)];
                    
                    [TFAppManager getLookalikesForFaceImage:faceImage withCompletionBlock:^(id object, NSError *error) {
                        [progressHUD hide:YES];
                        if (!error) {
                            if (index < 4 && object) {
                                NSLog(@"index %d",index);
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
                                [dataBackgroundView.contentView.imagesView setHidden:NO];
                                [dataBackgroundView.contentView.imageView2 setHidden:YES];
                                [dataBackgroundView.contentView.photoButton2 setTitle:NSLocalizedString(@"Search Again", nil) forState:UIControlStateNormal];
                                [imageView setImageURL:[NSURL URLWithString:fImage.image_url] forFileId:fImage.parse_id];
                                CGFloat progress = [faceImage.confidence floatValue]/100.f;
                                [dataBackgroundView.contentView.progressView setProgress:progress animated:YES];
                                [dataBackgroundView.contentView.progressView setProgress:progress animated:YES];
                                UserInfo *userInfo = faceImage.createdBy;
                                
                                NSString *name = userInfo.name.length ? userInfo.name : NSLocalizedString(@"Name", nil);
                                NSString *age = userInfo.age.length ? userInfo.age : NSLocalizedString(@"Age", nil);
                                NSString *city = userInfo.city.length ? userInfo.city : NSLocalizedString(@"City", nil);
                                NSString *national = userInfo.national.length ? userInfo.national : NSLocalizedString(@"Nationality", nil);
                                
                                NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] init];
                                NSMutableAttributedString *commaString = [[NSMutableAttributedString alloc] initWithString:@","];
                                NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:name];
                                if ([name isEqualToString:NSLocalizedString(@"Name", nil)]) {
                                    [nameString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, nameString.string.length)];
                                }
                                [finalString appendAttributedString:nameString];
                                [finalString appendAttributedString:commaString];
                                NSMutableAttributedString *ageString = [[NSMutableAttributedString alloc] initWithString:age];
                                if ([age isEqualToString:NSLocalizedString(@"Age", nil)]) {
                                    [ageString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, ageString.string.length)];
                                }
                                [finalString appendAttributedString:ageString];
                                [finalString appendAttributedString:commaString];
                                NSMutableAttributedString *cityString = [[NSMutableAttributedString alloc] initWithString:city];
                                if ([city isEqualToString:NSLocalizedString(@"City", nil)]) {
                                    [cityString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, cityString.string.length)];
                                }
                                [finalString appendAttributedString:cityString];
                                [finalString appendAttributedString:commaString];
                                NSMutableAttributedString *nationalString = [[NSMutableAttributedString alloc] initWithString:national];
                                if ([national isEqualToString:NSLocalizedString(@"Nationality", nil)]) {
                                    [nationalString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, nationalString.string.length)];
                                }
                                [finalString appendAttributedString:nationalString];
                                [dataBackgroundView.descLabel setAttributedText:finalString];
                            }
                        } else {
//                            [self showErrorAlert:error];
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"There is something wrong with the image you just uploaded.Please make sure you take a selfie in bright light.", nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                            [alertView show];
                        }
                    }];
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please click a selfie and tap the add button to upload it to our server.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
                    [alertView show];
                }
            } else {
                [self imagesView:dataBackgroundView.contentView.imagesView longPressedView:dataBackgroundView.contentView.imageView2];
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
    
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"user"] = [PFUser currentUser];
    [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil)
         {
             NSLog(@"ParsePushUserAssign save error.");
         }
     }];
    
    [logInController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
    [alertView show];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    
}

@end
