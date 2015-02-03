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
#import "TFUserProfileView.h"


@interface TFTwinsViewController ()<PFLogInViewControllerDelegate>
{
}


@property (nonatomic,strong) TFLoginViewController *loginViewController;
@property (nonatomic,strong) NSDictionary *profileInfo;


@end

@implementation TFTwinsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.collectionView registerClass:[UICollectionViewCell class]
            forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [self.collectionView setAlwaysBounceVertical:YES];
    
    // Then register a class to use for the header.
    
    [self.collectionView registerClass:[TFUserProfileView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
              withReuseIdentifier:@"TFUserProfileView"];
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
            self.profileInfo = result;
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(PFQuery *) queryForCollection
{
    PFQuery *userQuery = [PFUser query];
    [userQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
    return userQuery;
}



#pragma mark - UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)cv {
    
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)cv numberOfItemsInSection:(NSInteger)section {
    
    return self.objects.count;
}


-(CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(collectionView.frame.size.width, 200);
}


-(CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100, 100);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)cv viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    TFUserProfileView *header = [cv dequeueReusableSupplementaryViewOfKind:kind
                                                    withReuseIdentifier:@"TFUserProfileView"
                                                           forIndexPath:indexPath];
    header.frame = CGRectMake(0, 0, cv.frame.size.width, 200.f);
    if (self.profileInfo) {
        [header setUser:self.profileInfo];
    }
    header.backgroundColor = indexPath.section == 0 ? [UIColor yellowColor] : [UIColor redColor];
    return header;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor yellowColor];
    return cell;
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
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"result %@",result);
    }];
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
