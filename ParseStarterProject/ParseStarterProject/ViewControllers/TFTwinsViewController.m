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
@property (nonatomic,strong) NSDictionary *userInfo;
@property (nonatomic,strong) NSIndexPath *selectedIndexPath;
@property (nonatomic,strong) PFFile *selectedImageFile;
@property (nonatomic,strong,readonly) UIColor *appColor;


@property (nonatomic,strong) NSMutableArray *faceImages;
@property (nonatomic,strong) NSArray *friends;



@end

@implementation TFTwinsViewController


-(UIColor *) appColor
{
    UIColor *retVal = [UIColor darkGrayColor];
    if ([[self.userInfo objectForKey:@"gender"] isEqualToString:@"male"]) {
        retVal = [UIColor blueColor];
    } else if ([[self.userInfo objectForKey:@"gender"] isEqualToString:@"female"]) {
        retVal = [UIColor magentaColor];
    }
    return retVal;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.collectionView registerClass:[TFAddImageCollectionViewCell class]
            forCellWithReuseIdentifier:@"TFAddImageCollectionViewCell"];
    [self.collectionView registerClass:[PFCollectionViewCell class]
            forCellWithReuseIdentifier:@"PFCollectionViewCell"];

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
    self.faceImages = [[NSMutableArray alloc] initWithObjects:[NSNull null],[NSNull null],[NSNull null], nil];
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
    self.loginViewController = [[TFLoginViewController alloc] init];
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


-(void) objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    [PFObject pinAll:self.objects];
}

-(PFQuery *) queryForCollection
{
    PFQuery *userQuery = [PFUser query];
    return userQuery;
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
    self.userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"];
    [self.collectionView setBackgroundColor:self.appColor];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
    
    PFQuery *faceImageQuery = [PFQuery queryWithClassName:@"FaceImage"];
    //[faceImageQuery fromLocalDatastore];
    [faceImageQuery whereKey:@"createdBy" equalTo:[PFUser currentUser]];
    [faceImageQuery orderByAscending:@"imageIndex"];
    [faceImageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *obj in objects) {
            NSNumber *index = [obj objectForKey:@"imageIndex"];
            [self.faceImages replaceObjectAtIndex:[index intValue] withObject:obj];
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        }
    }];

    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"UserInfo"];
        [self.collectionView setBackgroundColor:self.appColor];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
    }];
    
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        self.friends = [result objectForKey:@"data"];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:2]];
    }];
    
    [PFCloud callFunctionInBackground:@"getMyFacialImages" withParameters:nil block:^(id object, NSError *error) {
        
    }];
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

-(void) cameraViewController:(TFCameraViewController *) vc didCapturePictureWithData:(NSData *) imageData WithIndex:(int)indx
{
    [vc dismissViewControllerAnimated:YES completion:NULL];
    PFQuery *faceImageQuery = [PFQuery queryWithClassName:@"FaceImage"];
    [faceImageQuery whereKey:@"imageIndex" equalTo:[NSNumber numberWithInt:indx]];
    [faceImageQuery whereKey:@"createdBy" equalTo:[PFUser currentUser]];
    [faceImageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *faceImage = nil;
        if ([objects count]) {
            faceImage = [objects firstObject];
        }else {
            faceImage = [PFObject objectWithClassName:@"FaceImage"];
        }
        PFFile *imageFile = [PFFile fileWithData:imageData contentType:@"image/jpeg"];
        [faceImage setObject:imageFile forKey:@"imageFile"];
        [faceImage setObject:[NSNumber numberWithInt:self.selectedIndexPath.row] forKey:@"imageIndex"];
        [faceImage setObject:[PFUser currentUser] forKey:@"createdBy"];
        [faceImage pinInBackground];
        [faceImage saveInBackground];
        
        [self.faceImages replaceObjectAtIndex:indx withObject:faceImage];
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:indx inSection:0]]];
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
            return 3;
            break;
        case 1:
            return self.objects.count;
            break;
        case 2:
            return self.friends.count;
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
    return CGSizeMake(94, 94 * ratio);
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
            NSMutableString *headerText = [NSMutableString stringWithFormat:@"%@'s ",[self.userInfo objectForKey:@"first_name"]];
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
            id obj =  [self.faceImages objectAtIndex:indexPath.row];
            if (![obj isKindOfClass:[NSNull class]]) {
                PFObject *faceImage = (PFObject *)obj;
                PFFile *imageFile = [faceImage objectForKey:@"imageFile"];
                [aCell.imageView setFile:imageFile];
                [aCell.imageView loadInBackground];
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
            if( [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront ])
            {
                TFCameraViewController *cameraViewController = [[TFCameraViewController alloc] initWithIndex:indexPath.row];
                [cameraViewController setDelegate:self];
                [self presentViewController:cameraViewController animated:YES completion:NULL];
                self.selectedIndexPath = indexPath;
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
    [self doPostLogin];
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
