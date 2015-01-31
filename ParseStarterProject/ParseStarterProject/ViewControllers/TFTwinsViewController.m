//
//  TFTwinsViewController.m
//  ParseStarterProject
//
//  Created by Parag Dulam on 28/01/15.
//
//

#import "TFTwinsViewController.h"
#import "TFLoginViewController.h"
#import "TFCameraViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>


@interface TFTwinsViewController ()<PFLogInViewControllerDelegate>

@property (nonatomic,strong) TFLoginViewController *loginViewController;

@end

@implementation TFTwinsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![[PFUser currentUser] sessionToken]) {
        self.loginViewController = [[TFLoginViewController alloc] init];
        [self.loginViewController setFields:PFLogInFieldsFacebook];
        [self.loginViewController setDelegate:self];
        [self presentViewController:self.loginViewController animated:NO completion:NULL];
    } else {
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            NSLog(@"result %@",result);
            
        }];
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - PFLogInViewControllerDelegate

- (BOOL)logInViewController:(PFLogInViewController *)logInController
shouldBeginLogInWithUsername:(NSString *)username
                   password:(NSString *)password
{
    return YES;
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [logInController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    
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
