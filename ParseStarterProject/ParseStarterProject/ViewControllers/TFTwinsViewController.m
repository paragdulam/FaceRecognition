//
//  TFTwinsViewController.m
//  ParseStarterProject
//
//  Created by Parag Dulam on 28/01/15.
//
//

#import "TFTwinsViewController.h"
#import "TFLoginViewController.h"
#import <Parse/Parse.h>


@interface TFTwinsViewController ()<PFLogInViewControllerDelegate>

@end

@implementation TFTwinsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}


-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![[PFUser currentUser] isAuthenticated]) {
        TFLoginViewController *loginViewController = [[TFLoginViewController alloc] init];
        [loginViewController setFields:PFLogInFieldsFacebook];
        [loginViewController setDelegate:self];
        [self presentViewController:loginViewController animated:NO completion:NULL];
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
