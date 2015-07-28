//
//  TFImageViewController.m
//  TwinFinder
//
//  Created by Parag Dulam on 7/26/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import "TFImageViewController.h"
#import <iAd/iAd.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "TFLoginViewController.h"
#import "AppDelegate.h"
#import "UserInfo.h"
#import "TFAppManager.h"
#import "TFHomeViewController.h"

@interface TFImageViewController ()<ADBannerViewDelegate>

@property (strong, nonatomic) ADBannerView *bannerView;
@property (strong, nonatomic) TFLoginViewController *loginViewController;

@end

@implementation TFImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [imageView setImage:[UIImage imageNamed:@"1"]];
    [self.view addSubview:imageView];
    
    
    UIButton *findTwinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    findTwinButton.backgroundColor = [UIColor whiteColor];
    [findTwinButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    findTwinButton.layer.cornerRadius = 10.f;
    findTwinButton.clipsToBounds = YES;
    [findTwinButton setTitle:NSLocalizedString(@"Find your twin", nil) forState:UIControlStateNormal];
    findTwinButton.frame = CGRectMake(0, 0, 280.f, 35.f);
    findTwinButton.center = CGPointMake(self.view.center.x, 100.f);
    [findTwinButton addTarget:self action:@selector(findTwinButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:findTwinButton];
    
    
    self.bannerView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, 320, 50)];
    self.bannerView.delegate = self;
    [self.view addSubview:self.bannerView];

    UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    logoutButton.backgroundColor = [UIColor redColor];
    [logoutButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    logoutButton.layer.cornerRadius = 10.f;
    logoutButton.clipsToBounds = YES;
    [logoutButton setTitle:NSLocalizedString(@"Log out", nil) forState:UIControlStateNormal];
    logoutButton.frame = CGRectMake(0, 0, 280.f, 35.f);
    logoutButton.center = CGPointMake(self.view.center.x, self.bannerView.frame.origin.y - 40.f);
    [logoutButton addTarget:self action:@selector(logoutTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logoutButton];
    
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


- (void) logoutTapped:(UIButton *)btn
{
    [PFUser logOut];
    [[TFAppManager appDelegate] flushDatabase];
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

- (void)findTwinButtonTapped:(UIButton *)btn
{
    TFHomeViewController *homeViewController = [[TFHomeViewController alloc] init];
    [self.navigationController pushViewController:homeViewController animated:YES];
}


#pragma mark - PFLogInViewControllerDelegate


- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    UserInfo *userInfo = (UserInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:[TFAppManager appDelegate].managedObjectContext];
    userInfo.parse_id = user.objectId;
    [[TFAppManager appDelegate].managedObjectContext save:nil];
    
//    [self doPostLogin];
    
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
