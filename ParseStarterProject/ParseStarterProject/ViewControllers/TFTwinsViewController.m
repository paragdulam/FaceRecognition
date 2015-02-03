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


@interface TFTwinsViewController ()<PFLogInViewControllerDelegate,TFCameraViewControllerDelegate>
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
    [self.collectionView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
    [self.collectionView registerClass:[TFUserProfileView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
              withReuseIdentifier:@"TFUserProfileView"];
    [self setNeedsStatusBarAppearanceUpdate];
    if ([[PFUser currentUser] sessionToken]) {
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            self.profileInfo = result;
            if ([[self.profileInfo objectForKey:@"gender"] isEqualToString:@"male"]) {
                [self.collectionView setBackgroundColor:[UIColor blueColor]];
            } else {
                [self.collectionView setBackgroundColor:[UIColor magentaColor]];
            }
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        }];
    } else {
        [self performSelector:@selector(showLoginView) withObject:nil afterDelay:.3f];
    }
}



-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}



-(void) showLoginView
{
    self.loginViewController = [[TFLoginViewController alloc] init];
    [self.loginViewController setFields:PFLogInFieldsFacebook];
    [self.loginViewController setDelegate:self];
    [self presentViewController:self.loginViewController animated:NO completion:NULL];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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


#pragma mark - TFCameraViewControllerDelegate

-(void) cameraViewController:(TFCameraViewController *) vc didCapturePicture:(PFFile *) imageFile
{
    
}

-(void) cameraViewControllerDidCancel:(TFCameraViewController *) vc
{
    
}


#pragma mark - UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)cv {
    
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)cv numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 3;
            break;
        case 1:
            return self.objects.count;
            break;
        default:
            break;
    }
    return 0;
}


-(CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return CGSizeMake(collectionView.frame.size.width, 60);
            break;
            
        default:
            break;
    }
    return CGSizeZero;
}


-(CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100, 100);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)cv viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    TFUserProfileView *header = nil;
    header = [cv dequeueReusableSupplementaryViewOfKind:kind
                                    withReuseIdentifier:@"TFUserProfileView"
                                           forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
        {
            header.bounds = CGRectMake(0, 0, cv.frame.size.width, 60);
            if (self.profileInfo) {
                [header setUser:self.profileInfo];
            }
        }
            break;
        case 1:
        {
            header.bounds = CGRectZero;
        }
            break;
        default:
            break;
    }
    return header;
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.cornerRadius = cell.frame.size.width/2;
    cell.clipsToBounds = YES;
    
    switch (indexPath.section) {
        case 1:
        {
            cell.backgroundColor = [UIColor whiteColor];
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}


-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            TFCameraViewController *cameraViewController = [[TFCameraViewController alloc] init];
            [cameraViewController setDelegate:self];
            [self presentViewController:cameraViewController animated:YES completion:NULL];
        }
            break;
            
        default:
            break;
    }
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
        self.profileInfo = result;
        if ([[self.profileInfo objectForKey:@"gender"] isEqualToString:@"male"]) {
            [self.collectionView setBackgroundColor:[UIColor blueColor]];
        } else {
            [self.collectionView setBackgroundColor:[UIColor magentaColor]];
        }
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
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
