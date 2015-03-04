//
//  TFTwinsViewController.m
//  ParseStarterProject
//
//  Created by Parag Dulam on 28/01/15.
//
//

#import "TFTwinsViewController.h"
#import "TFCameraViewController.h"
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "TFUserProfileView.h"
#import "TFFriendsHeaderView.h"
#import "TFAddImageCollectionViewCell.h"
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>
#import "TFEmptyCollectionViewCell.h"
#import "AppDelegate.h"
#import "UserInfo.h"
#import "FaceImage.h"
#import "TFAppManager.h"
#import "TFFriendCollectionViewCell.h"
#import "CollectionBackgroundView.h"
#import "MBProgressHUD.h"
#import "CSStickyHeaderFlowLayout.h"
#import "WYPopOverController.h"

#define BOY_COLOR [UIColor colorWithRed:33.f/255.f green:133.f/255.f blue:190.f/255.f alpha:1.f]
#define GIRL_COLOR [UIColor colorWithRed:238.f/255.f green:86.f/255.f blue:122.f/255.f alpha:1.f]


@interface TFTwinsViewController ()<PFLogInViewControllerDelegate,TFCameraViewControllerDelegate,UIActionSheetDelegate,TFUserProfileViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,NSFetchedResultsControllerDelegate>
{
}


@property (nonatomic,strong) PFLogInViewController *loginViewController;
@property (nonatomic,strong) UIViewController *profileViewController;
@property (nonatomic,strong) WYPopoverController *popOverController;
@property (nonatomic,strong) UserInfo *userInfo;
@property (nonatomic,strong) NSIndexPath *selectedIndexPath;
@property (nonatomic,strong) PFFile *selectedImageFile;
@property (nonatomic,strong) CollectionBackgroundView *backgroundView;
@property (nonatomic,strong,readonly) UIColor *appColor;



@property (nonatomic,strong,readonly) NSArray *faceImages;
@property (nonatomic,strong,readonly) NSArray *lookalikes;
@property (nonatomic,strong) NSArray *friends;
@property (nonatomic,strong) MBProgressHUD *progressHUD;




@end

@implementation TFTwinsViewController


-(NSArray *) faceImages{
    if (self.userInfo) {
        return [TFAppManager faceImagesForUserid:self.userInfo.facebookId];
    }
    return nil;
}


-(NSArray *) lookalikes
{
    return [TFAppManager lookalikesForUserid:self.userInfo.facebookId];
}


-(UIColor *) appColor
{
    UIColor *retVal = [UIColor darkGrayColor];
    UserInfo *uInfo = self.userInfo;
    if ([uInfo.gender isEqualToString:@"male"]) {
        retVal = BOY_COLOR;
    } else if ([uInfo.gender isEqualToString:@"female"]) {
        retVal = GIRL_COLOR;
    }
    return retVal;
}


-(AppDelegate *) appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController setNavigationBarHidden:YES];
    
    // Do any additional setup after loading the view.
    [self.collectionView registerClass:[TFAddImageCollectionViewCell class]
            forCellWithReuseIdentifier:@"TFAddImageCollectionViewCell"];
    [self.collectionView registerClass:[PFCollectionViewCell class]
            forCellWithReuseIdentifier:@"PFCollectionViewCell"];
    [self.collectionView registerClass:[TFEmptyCollectionViewCell class]
            forCellWithReuseIdentifier:@"TFEmptyCollectionViewCell"];
    [self.collectionView registerClass:[TFFriendCollectionViewCell class]
            forCellWithReuseIdentifier:@"TFFriendCollectionViewCell"];


    [self.collectionView setAlwaysBounceVertical:YES];
    
    // Then register a class to use for the header.
    [self.collectionView registerClass:[TFUserProfileView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
              withReuseIdentifier:@"TFUserProfileView"];
    [self.collectionView registerClass:[TFFriendsHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:@"TFFriendsHeaderView"];
    
    
    [self setNeedsStatusBarAppearanceUpdate];
    if ([[PFUser currentUser] sessionToken]) {
        [self doPostLogin];
    } else {
        [self performSelector:@selector(showLoginView:) withObject:[NSNumber numberWithBool:NO] afterDelay:.3f];
    }
}



-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}



-(void) showLoginView:(NSNumber *) animated
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate flushDatabase];
    self.loginViewController = [[PFLogInViewController alloc] init];
    [self.loginViewController setFields:PFLogInFieldsFacebook];
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


-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (NSString *)age:(NSDate *)dateOfBirth {
    
    NSInteger years;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponentsNow = [calendar components:unitFlags fromDate:[NSDate date]];
    NSDateComponents *dateComponentsBirth = [calendar components:unitFlags fromDate:dateOfBirth];
    
    if (([dateComponentsNow month] < [dateComponentsBirth month]) ||
        (([dateComponentsNow month] == [dateComponentsBirth month]) && ([dateComponentsNow day] < [dateComponentsBirth day]))) {
        years = [dateComponentsNow year] - [dateComponentsBirth year] - 1;
    } else {
        years = [dateComponentsNow year] - [dateComponentsBirth year];
    }
    return [NSString stringWithFormat:@"%d",years];
}


-(void) doPostLogin
{
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.progressHUD setLabelText:@"Getting User Info..."];
    [TFAppManager saveCurrentUserWithCompletionBlock:^(id object, NSError *error) {
        self.userInfo = object;
        [self.collectionView setBackgroundColor:self.appColor];
        [self.navigationController.navigationBar setBarTintColor:self.appColor];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:2]];

        [self.progressHUD setLabelText:@"Getting User Images..."];
        [TFAppManager getFaceImagesForUserId:self.userInfo.facebookId
                             completionBlock:^(id object, NSError *error) {
                                 if (object) {
                                     [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                     [self.progressHUD setLabelText:@"Looking for lookalikes..."];
                                     
                                     for (int i = 0; i < [self.faceImages count] ; i++) {
                                         id obj = [self.faceImages objectAtIndex:i];
                                         if ([obj isKindOfClass:[FaceImage class]]) {
                                             [TFAppManager getLookalikesForFaceImage:obj
                                                                 withCompletionBlock:^(id object, NSError *error) {
                                                                     if(object) {
                                                                         
                                                                         [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
                                                                     }
                                                                     }];                                                                                                              }
                                         if ([self.faceImages lastObject] == obj) {
                                             [self.progressHUD hide:YES];
                                         }
                                     }
                                 } else if (!object) {
                                     [self.progressHUD hide:YES];
                                 } else {
                                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                         message:[error localizedDescription]
                                                                                        delegate:nil
                                                                               cancelButtonTitle:@"Ok"
                                                                               otherButtonTitles:nil];
                                     [alertView show];
                                 }
                             }];
    }];
    
    [TFAppManager getUserFriendsWithCompletionBlock:^(id object, NSError *error) {
        self.friends = [object objectForKey:@"data"];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:2]];
    }];
    
}




#pragma mark - NSFetchedResultsControllerDelegate


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath,newIndexPath]];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
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

-(void) cameraViewController:(TFCameraViewController *) vc didCapturePictureWithData:(NSData *) imageData WithIndex:(int)indx
{
    [vc dismissViewControllerAnimated:YES completion:^{
        
        self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [TFAppManager saveFaceImageData:imageData
                                AtIndex:indx
                            ForUserInfo:self.userInfo
                      withProgressBlock:^(NSString *progressString,int percentDone) {
                                  [self.progressHUD setLabelText:progressString];
                              }
                    WithCompletionBlock:^(id object, int type ,NSError *error) {
                        if (error) {
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                message:[error localizedDescription]
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"Ok"
                                                                      otherButtonTitles:nil];
                            [alertView show];
                            [self.progressHUD hide:YES];
                        } else {
                            FaceImage *fImage = (FaceImage *)object;
                            switch (type) {
                                case 0:
                                {
                                    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                }
                                    break;
                                case 1:
                                {
                                    if (fImage) {
                                        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
                                    }
                                    [self.progressHUD hide:YES];
                                }
                                    break;
                                    
                                default:
                                    break;
                            }
                        }
                    }];
    }];
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
            return 3; //hard coded purposely
            break;
        case 1:
            return self.lookalikes.count ? self.lookalikes.count : 1;
            break;
        case 2:
            return self.friends.count ? self.friends.count : 1;
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
    switch (indexPath.section) {
        case 0:
        {
            CGFloat width = [UIScreen mainScreen].bounds.size.width;
            CGFloat height = [UIScreen mainScreen].bounds.size.height;
            CGFloat ratio = height/width;
            return CGSizeMake(94, 94 * ratio);
        }
            break;
        case 1:
        {
            if (self.lookalikes.count) {
                CGFloat width = [UIScreen mainScreen].bounds.size.width;
                CGFloat height = [UIScreen mainScreen].bounds.size.height;
                CGFloat ratio = height/width;
                return CGSizeMake(94, 94 * ratio);
            } else {
                return CGSizeMake(300,80);
            }
        }
            break;
        case 2:
        {
            if (self.friends.count) {
                return CGSizeMake(94, 94);
            } else {
                return CGSizeMake(300,80);
            }
        }
            break;
        default:
            break;
    }
    return CGSizeZero;
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
            header.backgroundColor = self.appColor;
            [header setUserInfo:self.userInfo];
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
            header.backgroundColor = self.appColor;
            NSMutableString *headerText = [NSMutableString stringWithFormat:@"%@'s ",[[self userInfo] firstName]];
            if (indexPath.section == 1) {
                [headerText appendString:@"Lookalikes"];
            } else {
                [headerText appendString:@"Friends"];
            }
            [header setHeaderText:headerText];
            return header;
        }
            break;
        default:
            break;
    }
    return nil;
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    switch (indexPath.section) {
        case 0:
        {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TFAddImageCollectionViewCell" forIndexPath:indexPath];
            TFAddImageCollectionViewCell *aCell = (TFAddImageCollectionViewCell *)cell;
            aCell.backgroundColor = [UIColor clearColor];
            if (indexPath.row < [self.faceImages count]) {
                FaceImage *faceImage = [self.faceImages objectAtIndex:indexPath.row];
                [aCell setHideFooterView:NO];
                [aCell.addButton setTintColor:self.appColor];
                UIImage *image = [UIImage imageWithData:faceImage.image];
                [aCell.imageView setImage:nil];
                [aCell.imageView setImage:image];
            }
        }
            break;
        case 1:
        {
            if (self.lookalikes.count) {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TFAddImageCollectionViewCell" forIndexPath:indexPath];
                TFAddImageCollectionViewCell *aCell = (TFAddImageCollectionViewCell *)cell;
                aCell.backgroundColor = [UIColor clearColor];
                id obj =  [self.lookalikes objectAtIndex:indexPath.row];
                FaceImage *faceImage = (FaceImage *)obj;
                [aCell setHideFooterView:YES];
                [aCell.addButton setTintColor:self.appColor];
                UIImage *image = [UIImage imageWithData:faceImage.image];
                [aCell.imageView setImage:image];
            } else {
                cell = (TFEmptyCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TFEmptyCollectionViewCell" forIndexPath:indexPath];
                TFEmptyCollectionViewCell *aCell = (TFEmptyCollectionViewCell *)cell;
                [aCell setText:@"We didn't find any lookalikes for you yet, but we will notify you in case someone who looks like you signs up."];
            }
        }
            break;
        case 2:
        {
            if (self.friends.count) {
                cell = (TFFriendCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TFFriendCollectionViewCell" forIndexPath:indexPath];
                TFFriendCollectionViewCell *aCell = (TFFriendCollectionViewCell *)cell;
                [aCell setFriend:[self.friends objectAtIndex:indexPath.row]];
            } else {
                cell = (TFEmptyCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TFEmptyCollectionViewCell" forIndexPath:indexPath];
                TFEmptyCollectionViewCell *aCell = (TFEmptyCollectionViewCell *)cell;
                [aCell setText:@"None of your facebook friends have signed up for TwinFinder yet! :("];
            }
        }
            break;

        default:
        {
            cell = (PFCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PFCollectionViewCell" forIndexPath:indexPath];
            cell.backgroundColor = [UIColor whiteColor];
        }
            break;
    }
    return cell;
}


-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            self.selectedIndexPath = indexPath;
            if( [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront])
            {
                TFCameraViewController *cameraViewController = [[TFCameraViewController alloc] initWithIndex:indexPath.row];
                [cameraViewController setDelegate:self];
                [self presentViewController:cameraViewController animated:YES completion:NULL];
            } else {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                [imagePicker setDelegate:self];
                [self presentViewController:imagePicker animated:YES completion:NULL];
            }
        }
            break;
            
        case 1:
        {
            WYPopoverBackgroundView *popoverAppearance = [WYPopoverBackgroundView appearance];
            
            [popoverAppearance setOuterCornerRadius:4];
            [popoverAppearance setOuterShadowBlurRadius:0];
            [popoverAppearance setOuterShadowColor:[UIColor clearColor]];
            [popoverAppearance setOuterShadowOffset:CGSizeMake(0, 0)];
            
            [popoverAppearance setGlossShadowColor:[UIColor clearColor]];
            [popoverAppearance setGlossShadowOffset:CGSizeMake(0, 0)];
            
            [popoverAppearance setBorderWidth:8];
            [popoverAppearance setArrowHeight:10];
            [popoverAppearance setArrowBase:20];
            
            [popoverAppearance setInnerCornerRadius:4];
            [popoverAppearance setInnerShadowBlurRadius:0];
            [popoverAppearance setInnerShadowColor:[UIColor clearColor]];
            [popoverAppearance setInnerShadowOffset:CGSizeMake(0, 0)];
            
            [popoverAppearance setFillTopColor:self.appColor];
            [popoverAppearance setOuterStrokeColor:self.appColor];

            FaceImage *faceImage = [self.lookalikes objectAtIndex:indexPath.row];
            self.profileViewController = [[UIViewController alloc] init];
            TFUserProfileView *userProfileView = [[TFUserProfileView alloc] initWithFrame:CGRectMake(0, 0, 280, 60)];
            [userProfileView setUserInfo:faceImage.createdBy];
            [userProfileView setAgeText:[NSString stringWithFormat:@"%@%% match",faceImage.confidence]];
            self.profileViewController.view = userProfileView;
            [self.profileViewController setPreferredContentSize:CGSizeMake(280, 60)];
            self.popOverController = [[WYPopoverController alloc] initWithContentViewController:self.profileViewController];
            TFAddImageCollectionViewCell *cell = (TFAddImageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
            [self.popOverController presentPopoverFromRect:cell.frame inView:cell.superview permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
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
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alertView show];
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
