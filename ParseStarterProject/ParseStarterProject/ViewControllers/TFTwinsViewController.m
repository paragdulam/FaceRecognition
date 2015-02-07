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
#import "TFFriendsHeaderView.h"
#import "TFAddImageCollectionViewCell.h"
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>



@interface TFTwinsViewController ()<PFLogInViewControllerDelegate,TFCameraViewControllerDelegate,UIActionSheetDelegate,TFUserProfileViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
}


@property (nonatomic,strong) TFLoginViewController *loginViewController;
@property (nonatomic,strong) NSDictionary *profileInfo;
@property (nonatomic,strong) NSIndexPath *selectedIndexPath;
@property (nonatomic,strong) PFFile *selectedImageFile;


@end

@implementation TFTwinsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.collectionView registerClass:[TFAddImageCollectionViewCell class]
            forCellWithReuseIdentifier:@"TFAddImageCollectionViewCell"];
    [self.collectionView setAlwaysBounceVertical:YES];
    
    // Then register a class to use for the header.
    [self.collectionView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
    [self.collectionView setScrollIndicatorInsets:UIEdgeInsetsMake(20, 0, 0, 0)];
    [self.collectionView registerClass:[TFUserProfileView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
              withReuseIdentifier:@"TFUserProfileView"];
    [self.collectionView registerClass:[TFFriendsHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:@"TFFriendsHeaderView"];
    
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
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
        }];
    } else {
        [self performSelector:@selector(showLoginView:) withObject:[NSNumber numberWithBool:NO] afterDelay:.3f];
    }
}



-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}



-(void) showLoginView:(NSNumber *) animated
{
    self.loginViewController = [[TFLoginViewController alloc] init];
    [self.loginViewController setFields:PFLogInFieldsFacebook | PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsPasswordForgotten];
    [self.loginViewController setDelegate:self];
    [self presentViewController:self.loginViewController animated:[animated boolValue] completion:NULL];
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




#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    CIImage* image = [CIImage imageWithCGImage:pickedImage.CGImage];
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
    NSArray* features = [detector featuresInImage:image];
    int count = 0;
    for(CIFaceFeature* faceFeature in features)
    {
        if (faceFeature) {
            count ++;
        }
    }
    if (count == 1)
    {
        //process the image
    } else {
        UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The image that you select should have one and only one face in it.Click a selfie, may be." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alrt show];
    }
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [PFUser logOut];
        [self showLoginView:[NSNumber numberWithBool:YES]];
    }
}


#pragma mark - TFUserProfileViewDelegate


-(void)profileButtonTappedInHeaderView:(TFUserProfileView *) view
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    [actionSheet setDelegate:self];
    [actionSheet addButtonWithTitle:@"Log Out"];
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.destructiveButtonIndex = 0;
    actionSheet.cancelButtonIndex = 1;
    [actionSheet showInView:self.view];
}

#pragma mark - TFCameraViewControllerDelegate

-(void) cameraViewController:(TFCameraViewController *) vc didCapturePictureWithData:(NSData *) imageData
{
    [vc dismissViewControllerAnimated:YES completion:NULL];
    PFFile *imageFile = [PFFile fileWithData:imageData contentType:@"image/jpeg"];
    self.selectedImageFile = imageFile;
    [self.collectionView reloadItemsAtIndexPaths:@[self.selectedIndexPath]];
}

-(void) cameraViewControllerDidCancel:(TFCameraViewController *) vc
{
    [vc dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)cv {
    
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)cv numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 3;
            break;
        case 1:
            return self.objects.count;
            break;
        case 2:
            return 3;
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
        case 1:
        case 2:
            return CGSizeMake(collectionView.frame.size.width, 40);
            break;
        default:
            break;
    }
    return CGSizeZero;
}


-(CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat ratio = height/width;
    return CGSizeMake(100, 100 * ratio);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)cv viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            TFUserProfileView *header = nil;
            header = [cv dequeueReusableSupplementaryViewOfKind:kind
                                            withReuseIdentifier:@"TFUserProfileView"
                                                   forIndexPath:indexPath];
            header.bounds = CGRectMake(0, 0, cv.frame.size.width, 60);
            header.delegate = self;
            if (self.profileInfo) {
                [header setUser:self.profileInfo];
            }
            return header;
        }
            break;
        case 1:
        case 2:
        {
            TFFriendsHeaderView *header = nil;
            header = [cv dequeueReusableSupplementaryViewOfKind:kind
                                            withReuseIdentifier:@"TFFriendsHeaderView"
                                                   forIndexPath:indexPath];
            header.bounds = CGRectMake(0, 0, cv.frame.size.width, 40);
            if (self.profileInfo) {
                NSMutableString *headerText = [NSMutableString stringWithFormat:@"%@'s ",[self.profileInfo objectForKey:@"first_name"]];
                if (indexPath.section == 1) {
                    [headerText appendString:@"Lookalikes"];
                } else {
                    [headerText appendString:@"Friends"];
                }
                [header setHeaderText:headerText];
            }
            return header;
        }
            break;
        default:
            break;
    }
    return nil;
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
    TFAddImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TFAddImageCollectionViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    switch (indexPath.section) {
        case 0:
        {
            if (self.selectedIndexPath) {
                if (indexPath.section == self.selectedIndexPath.section &&
                    indexPath.row == self.selectedIndexPath.row) {
                    [self.selectedImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        [cell.imageView setImage:[UIImage imageWithData:data]];
                    }];
                }
            }
        }
            break;
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
    self.selectedIndexPath = indexPath;
    switch (indexPath.section) {
        case 0:
        {
            if( [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront ])
            {
                TFCameraViewController *cameraViewController = [[TFCameraViewController alloc] init];
                [cameraViewController setDelegate:self];
                [self presentViewController:cameraViewController animated:YES completion:NULL];
            } else {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                [imagePicker setDelegate:self];
                [self presentViewController:imagePicker animated:YES completion:NULL];
            }
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
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
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
