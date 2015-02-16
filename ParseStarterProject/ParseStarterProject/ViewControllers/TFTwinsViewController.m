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
#import "TFEmptyCollectionViewCell.h"
#import "ParseStarterProjectAppDelegate.h"
#import "UserInfo.h"
#import "FaceImage.h"



@interface TFTwinsViewController ()<PFLogInViewControllerDelegate,TFCameraViewControllerDelegate,UIActionSheetDelegate,TFUserProfileViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
}


@property (nonatomic,strong) TFLoginViewController *loginViewController;
@property (nonatomic,strong) UserInfo *userInfo;
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
    if ([self.userInfo.gender isEqualToString:@"male"]) {
        retVal = [UIColor colorWithRed:31.f/255.f green:75.f/255.f blue:207.f/255.f alpha:1.f];
    } else if ([self.userInfo.gender isEqualToString:@"female"]) {
        retVal = [UIColor colorWithRed:243.f/255.f green:80.f/255.f blue:144.f/255.f alpha:1.f];
    }
    return retVal;
}

-(ParseStarterProjectAppDelegate *) appDelegate
{
    return (ParseStarterProjectAppDelegate *)[[UIApplication sharedApplication] delegate];
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

    [self.collectionView setAlwaysBounceVertical:YES];
    
    // Then register a class to use for the header.
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
    ParseStarterProjectAppDelegate *appDelegate = (ParseStarterProjectAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate flushDatabase];
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

//-(PFQuery *) queryForCollection
//{
//    PFQuery *userQuery = [PFUser query];
//    return userQuery;
//}


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
    NSFetchRequest *userRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserInfo"];
    NSArray *users = [self.appDelegate.managedObjectContext executeFetchRequest:userRequest error:nil];
    self.userInfo = [users firstObject];
    [self.collectionView setBackgroundColor:self.appColor];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];

    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSFetchRequest *userRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserInfo"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookId == %@",[result objectForKey:@"id"]];
        [userRequest setPredicate:predicate];
        NSArray *users = [self.appDelegate.managedObjectContext executeFetchRequest:userRequest error:nil];
        if ([users count]) {
            self.userInfo = [users firstObject];
        } else {
            self.userInfo = (UserInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:self.appDelegate.managedObjectContext];
            id facebookId = [result objectForKey:@"id"];
            [self.userInfo setFacebookId:facebookId];
        }
        NSString *birthday = [result objectForKey:@"birthday"];
        if (birthday) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
            NSDate *date = [dateFormatter dateFromString:birthday];
            [self.userInfo setAge:[self age:date]];
        }
        [self.userInfo setName:[result objectForKey:@"name"]];
        [self.userInfo setFirstName:[result objectForKey:@"first_name"]];
        [self.userInfo setLastName:[result objectForKey:@"last_name"]];
        [self.userInfo setGender:[result objectForKey:@"gender"]];
        [self.appDelegate.managedObjectContext save:nil];
        [self.collectionView setBackgroundColor:self.appColor];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
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
        PFQuery *faceImageQuery = [PFQuery queryWithClassName:@"FaceImage"];
        [faceImageQuery whereKey:@"imageIndex" equalTo:[NSNumber numberWithInt:self.selectedIndexPath.row]];
        [faceImageQuery whereKey:@"createdBy" equalTo:[PFUser currentUser]];
        [faceImageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            PFObject *faceImage = nil;
            if ([objects count]) {
                faceImage = [objects firstObject];
            }else {
                faceImage = [PFObject objectWithClassName:@"FaceImage"];
            }
            PFFile *imageFile = [PFFile fileWithData:UIImageJPEGRepresentation(pickedImage, 1.0) contentType:@"image/jpeg"];
            [faceImage setObject:imageFile forKey:@"imageFile"];
            int indx = self.selectedIndexPath.row;
            [faceImage setObject:[NSNumber numberWithInt:indx] forKey:@"imageIndex"];
            [faceImage setObject:[PFUser currentUser] forKey:@"createdBy"];
            [faceImage saveInBackground];
            
            [self.faceImages replaceObjectAtIndex:indx withObject:faceImage];
            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:indx inSection:0]]];
        }];
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
    
    UIImage *anImage = [UIImage imageWithData:imageData];
    CIImage* image = [CIImage imageWithCGImage:anImage.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CINoiseReduction"
                                  keysAndValues: kCIInputImageKey, image,
                        @"inputSharpness", @0.8, nil];
    image = [filter outputImage];
    
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil options:[NSDictionary dictionaryWithObjectsAndKeys:CIDetectorAccuracyHigh,CIDetectorAccuracy,[NSNumber numberWithInt:6],CIDetectorImageOrientation,nil]];
    NSDictionary* imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:6] forKey:CIDetectorImageOrientation];
    NSArray* features = [detector featuresInImage:image options:imageOptions];
    int count = 0;
    for(CIFaceFeature* faceFeature in features)
    {
        if (faceFeature) {
            count ++;
        }
    }
    if (count == 1)
    {
        NSFetchRequest *imageFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FaceImage"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index == %@ && image_user.facebookId == %@",[NSNumber numberWithInt:indx],self.userInfo.facebookId];
        [imageFetchRequest setPredicate:predicate];
        NSArray *images = [self.appDelegate.managedObjectContext executeFetchRequest:imageFetchRequest error:nil];
        
        FaceImage *faceImage = nil;
        if ([images count]) {
            faceImage = [images firstObject];
        } else {
            faceImage = [NSEntityDescription insertNewObjectForEntityForName:@"FaceImage" inManagedObjectContext:self.appDelegate.managedObjectContext];
        }
        faceImage.image = imageData;
        faceImage.image_user = self.userInfo;
        faceImage.index = [NSNumber numberWithInt:indx];
        [self.appDelegate.managedObjectContext save:nil];
        [self.faceImages replaceObjectAtIndex:indx withObject:faceImage];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } else {
        UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The image that you select should have one and only one face in it.Click a selfie, may be." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alrt show];
    }
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
            return self.objects.count ? self.objects.count : 1;
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
            if (self.objects.count) {
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
                CGFloat width = [UIScreen mainScreen].bounds.size.width;
                CGFloat height = [UIScreen mainScreen].bounds.size.height;
                CGFloat ratio = height/width;
                return CGSizeMake(94, 94 * ratio);
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
            NSMutableString *headerText = [NSMutableString stringWithFormat:@"%@'s ",self.userInfo.firstName];
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
                [aCell.imageView loadInBackground:^(UIImage *image, NSError *error) {
                    [aCell.imageView setImage:image];
                    [aCell setNeedsLayout];
                }];
            }
        }
            break;
        case 1:
        {
            if (self.objects.count) {
                cell = (PFCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PFCollectionViewCell" forIndexPath:indexPath];

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
                cell = (PFCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PFCollectionViewCell" forIndexPath:indexPath];
                
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
