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


@interface TFHomeViewController ()<PFLogInViewControllerDelegate,TFBaseContentViewDelegate,TFPhotoContentViewDelegate,TFCameraViewControllerDelegate,TFImagesViewDelegate,MFMailComposeViewControllerDelegate,GADInterstitialDelegate>
{
}

@property (nonatomic,strong) TFLoginViewController *loginViewController;
@property (nonatomic,strong) UIButton *logoutButton;
@property (nonatomic,weak) AppDelegate *appDelegate;
@property(nonatomic, strong) GADInterstitial *interstitial;


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
                                                  }];
    
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


-(void)logoutButtonTapped:(UIButton *) btn
{
    [PFUser logOut];
    [self.appDelegate flushDatabase];
    [TFAppManager logout];
    
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation removeObjectForKey:@"user"];
    [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil)
         {
             NSLog(@"ParsePushUserResign save error.");
         }
     }];
    
    [self showLoginView:[NSNumber numberWithBool:YES]];
}

- (GADInterstitial *)createAndLoadInterstitial {
    GADInterstitial *interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-4512831376775086/9680376458"];
    interstitial.delegate = self;
    GADRequest *request = [GADRequest request];
    request.testDevices = @[kGADSimulatorID,@"0cd059293bbf2ef79fa5cb8a7530afc1"];
    [interstitial loadRequest:request];
    return interstitial;
}

-(void) doPostLogin
{
    dataBackgroundView.contentView.imagesView.hidden = YES;
    dataBackgroundView.contentView.imageView2.hidden = NO;
    dataBackgroundView.contentView.photoButton2.enabled = NO;
    [dataBackgroundView.contentView.photoButton2 setTitle:@"Start Search" forState:UIControlStateNormal];
    [dataBackgroundView.contentView.photoButton1 setTitle:@"Add Photo" forState:UIControlStateNormal];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.appDelegate clickedPicturePath]]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            UserInfo *userInfo = [TFAppManager userWithId:[PFUser currentUser].objectId];
            UIImage *profileImage = [UIImage imageNamed:userInfo.national];
            [dataBackgroundView.profilePicButton setImage:profileImage forState:UIControlStateNormal];
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
                
                
                NSString *name = [[userInfo objectForKey:@"name"] length] ? [userInfo objectForKey:@"name"] : @"Name";
                NSString *age = [[userInfo objectForKey:@"age"] length] ? [userInfo objectForKey:@"age"] : @"Age";
                NSString *city = [[userInfo objectForKey:@"city"] length] ? [userInfo objectForKey:@"city"] : @"City";
                NSString *national = [[userInfo objectForKey:@"national"] length] ? [userInfo objectForKey:@"national"] : @"Nationality";
                
                NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] init];
                NSMutableAttributedString *commaString = [[NSMutableAttributedString alloc] initWithString:@","];
                NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:name];
                if ([name isEqualToString:@"Name"]) {
                    [nameString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, nameString.string.length)];
                }
                [finalString appendAttributedString:nameString];
                [finalString appendAttributedString:commaString];
                NSMutableAttributedString *ageString = [[NSMutableAttributedString alloc] initWithString:age];
                if ([age isEqualToString:@"Age"]) {
                    [ageString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, ageString.string.length)];
                }
                [finalString appendAttributedString:ageString];
                [finalString appendAttributedString:commaString];
                NSMutableAttributedString *cityString = [[NSMutableAttributedString alloc] initWithString:city];
                if ([city isEqualToString:@"City"]) {
                    [cityString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, cityString.string.length)];
                }
                [finalString appendAttributedString:cityString];
                [finalString appendAttributedString:commaString];
                NSMutableAttributedString *nationalString = [[NSMutableAttributedString alloc] initWithString:national];
                if ([national isEqualToString:@"Nationality"]) {
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

    
    NSString *name = userInfo.name.length ? userInfo.name : @"Name";
    NSString *age = userInfo.age.length ? userInfo.age : @"Age";
    NSString *city = userInfo.city.length ? userInfo.city : @"City";
    NSString *national = userInfo.national.length ? userInfo.national : @"Nationality";
    
    NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *commaString = [[NSMutableAttributedString alloc] initWithString:@","];
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:name];
    if ([name isEqualToString:@"Name"]) {
        [nameString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, nameString.string.length)];
    }
    [finalString appendAttributedString:nameString];
    [finalString appendAttributedString:commaString];
    NSMutableAttributedString *ageString = [[NSMutableAttributedString alloc] initWithString:age];
    if ([age isEqualToString:@"Age"]) {
        [ageString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, ageString.string.length)];
    }
    [finalString appendAttributedString:ageString];
    [finalString appendAttributedString:commaString];
    NSMutableAttributedString *cityString = [[NSMutableAttributedString alloc] initWithString:city];
    if ([city isEqualToString:@"City"]) {
        [cityString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, cityString.string.length)];
    }
    [finalString appendAttributedString:cityString];
    [finalString appendAttributedString:commaString];
    NSMutableAttributedString *nationalString = [[NSMutableAttributedString alloc] initWithString:national];
    if ([national isEqualToString:@"Nationality"]) {
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
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The selected user has not configured his profile." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
    }
}


-(void) imagesView:(TFImagesView *) view tappedView:(MAImageView *) imgView
{
    FaceImage *faceImage = [TFAppManager faceImageWithFaceImageId:imgView.idString];
    CGFloat progress = [faceImage.confidence floatValue]/100.f;
    [dataBackgroundView.contentView.progressView setProgress:progress animated:YES];
    [dataBackgroundView.contentView.progressLabel setText:[NSString stringWithFormat:@"%@%%",faceImage.confidence]];
    [dataBackgroundView.contentView.progressLabel sizeToFit];
    UserInfo *userInfo = faceImage.createdBy;

    NSString *name = userInfo.name.length ? userInfo.name : @"Name";
    NSString *age = userInfo.age.length ? userInfo.age : @"Age";
    NSString *city = userInfo.city.length ? userInfo.city : @"City";
    NSString *national = userInfo.national.length ? userInfo.national : @"Nationality";
    
    NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *commaString = [[NSMutableAttributedString alloc] initWithString:@","];
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:name];
    if ([name isEqualToString:@"Name"]) {
        [nameString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, nameString.string.length)];
    }
    [finalString appendAttributedString:nameString];
    [finalString appendAttributedString:commaString];
    NSMutableAttributedString *ageString = [[NSMutableAttributedString alloc] initWithString:age];
    if ([age isEqualToString:@"Age"]) {
        [ageString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, ageString.string.length)];
    }
    [finalString appendAttributedString:ageString];
    [finalString appendAttributedString:commaString];
    NSMutableAttributedString *cityString = [[NSMutableAttributedString alloc] initWithString:city];
    if ([city isEqualToString:@"City"]) {
        [cityString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, cityString.string.length)];
    }
    [finalString appendAttributedString:cityString];
    [finalString appendAttributedString:commaString];
    NSMutableAttributedString *nationalString = [[NSMutableAttributedString alloc] initWithString:national];
    if ([national isEqualToString:@"Nationality"]) {
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
}

-(void) cameraViewControllerDidCancel:(TFCameraViewController *) vc
{
    [vc dismissViewControllerAnimated:YES completion:NULL];
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

    NSString *name = userInfo.name.length ? userInfo.name : @"Name";
    NSString *age = userInfo.age.length ? userInfo.age : @"Age";
    NSString *city = userInfo.city.length ? userInfo.city : @"City";
    NSString *national = userInfo.national.length ? userInfo.national : @"Nationality";
    
    NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *commaString = [[NSMutableAttributedString alloc] initWithString:@","];
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:name];
    if ([name isEqualToString:@"Name"]) {
        [nameString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, nameString.string.length)];
    }
    [finalString appendAttributedString:nameString];
    [finalString appendAttributedString:commaString];
    NSMutableAttributedString *ageString = [[NSMutableAttributedString alloc] initWithString:age];
    if ([age isEqualToString:@"Age"]) {
        [ageString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, ageString.string.length)];
    }
    [finalString appendAttributedString:ageString];
    [finalString appendAttributedString:commaString];
    NSMutableAttributedString *cityString = [[NSMutableAttributedString alloc] initWithString:city];
    if ([city isEqualToString:@"City"]) {
        [cityString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, cityString.string.length)];
    }
    [finalString appendAttributedString:cityString];
    [finalString appendAttributedString:commaString];
    NSMutableAttributedString *nationalString = [[NSMutableAttributedString alloc] initWithString:national];
    if ([national isEqualToString:@"Nationality"]) {
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
                                if (!error) {
                                    [dataBackgroundView.contentView.photoButton1 setTitle:@"Added" forState:UIControlStateNormal];
                                    dataBackgroundView.contentView.photoButton2.enabled = YES;
                                } else {
                                    [self showErrorAlert:error];
                                }
                            }];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please click a selfie and tap the add button to upload it to our server." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alertView show];
            }
        }
            break;
        case 2:
        {
//            TFAdVideoViewController *adVideoViewController = [[TFAdVideoViewController alloc] init];
//            [self presentViewController:adVideoViewController animated:YES completion:NULL];
            self.interstitial = [self createAndLoadInterstitial];
            
            //face recognition.
            FaceImage *faceImage = [TFAppManager faceImageWithUserId:[PFUser currentUser].objectId];
            if (faceImage) {
                __block int index = 0;
                [TFAppManager getLookalikesForFaceImage:faceImage withCompletionBlock:^(id object, NSError *error) {
                    if (!error) {
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
                        [dataBackgroundView.contentView.photoButton2 setTitle:@"Search Again" forState:UIControlStateNormal];
                        [imageView setImageURL:[NSURL URLWithString:fImage.image_url] forFileId:fImage.parse_id];
                        CGFloat progress = [faceImage.confidence floatValue]/100.f;
                        [dataBackgroundView.contentView.progressView setProgress:progress animated:YES];
                        [dataBackgroundView.contentView.progressView setProgress:progress animated:YES];
                        [dataBackgroundView.contentView.progressLabel setText:[NSString stringWithFormat:@"%@%%",faceImage.confidence]];
                        [dataBackgroundView.contentView.progressLabel sizeToFit];
                        UserInfo *userInfo = faceImage.createdBy;
                        
                        NSString *name = userInfo.name.length ? userInfo.name : @"Name";
                        NSString *age = userInfo.age.length ? userInfo.age : @"Age";
                        NSString *city = userInfo.city.length ? userInfo.city : @"City";
                        NSString *national = userInfo.national.length ? userInfo.national : @"Nationality";
                        
                        NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] init];
                        NSMutableAttributedString *commaString = [[NSMutableAttributedString alloc] initWithString:@","];
                        NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:name];
                        if ([name isEqualToString:@"Name"]) {
                            [nameString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, nameString.string.length)];
                        }
                        [finalString appendAttributedString:nameString];
                        [finalString appendAttributedString:commaString];
                        NSMutableAttributedString *ageString = [[NSMutableAttributedString alloc] initWithString:age];
                        if ([age isEqualToString:@"Age"]) {
                            [ageString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, ageString.string.length)];
                        }
                        [finalString appendAttributedString:ageString];
                        [finalString appendAttributedString:commaString];
                        NSMutableAttributedString *cityString = [[NSMutableAttributedString alloc] initWithString:city];
                        if ([city isEqualToString:@"City"]) {
                            [cityString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, cityString.string.length)];
                        }
                        [finalString appendAttributedString:cityString];
                        [finalString appendAttributedString:commaString];
                        NSMutableAttributedString *nationalString = [[NSMutableAttributedString alloc] initWithString:national];
                        if ([national isEqualToString:@"Nationality"]) {
                            [nationalString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14.f] range:NSMakeRange(0, nationalString.string.length)];
                        }
                        [finalString appendAttributedString:nationalString];
                        [dataBackgroundView.descLabel setAttributedText:finalString];
                    } else {
                        [self showErrorAlert:error];
                    }
                }];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please click a selfie and tap the add button to upload it to our server." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alertView show];
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alertView show];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    
}

@end
