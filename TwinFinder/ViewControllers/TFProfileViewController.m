//
//  TFProfileViewController.m
//  TwinFinder
//
//  Created by Parag Dulam on 08/03/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import "TFProfileViewController.h"
#import "TFTextFieldView.h"
#import "TFBaseContentView.h"
#import "TFPhotoContentView.h"
#import "DACircularProgressView.h"
#import "AppDelegate.h"
#import "MAImageView.h"
#import "TFCameraViewController.h"
#import "TFAppManager.h"
#import "TFHomeViewController.h"
#import "CountryPicker.h"
#import <GoogleMobileAds/GoogleMobileAds.h>


@interface TFProfileViewController ()<TFBaseContentViewDelegate,TFPhotoContentViewDelegate,TFCameraViewControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,GADBannerViewDelegate>
{
    UIButton *cancelButton;
    UIView *backgroundCountryPickerView;
    UIPickerView *countryPicker;
    UIToolbar *toolBar;
    UITextField *nationalityTextField;
}

@property (nonatomic,strong)    NSArray *countries;
@property (strong, nonatomic) GADBannerView *bannerView;



@end

@implementation TFProfileViewController


-(AppDelegate *) appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.bannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(self.view.frame.size.width, 50)) origin:CGPointMake(0, self.view.frame.size.height - 55)];
    self.bannerView.delegate = self;
    [self.view addSubview:self.bannerView];
    
    self.bannerView.adUnitID = @"ca-app-pub-8389287507606895/2534918963";
    self.bannerView.rootViewController = self;
    GADRequest *request = [GADRequest request];
    [self.bannerView loadRequest:request];

    dataBackgroundView.contentView.backButton.hidden = YES;
    self.countries = @[ @"Abkhazia",
                        @"Afghanistan",
                        @"Aland",
                        @"Albania",
                        @"Algeria",
                        @"American-Samoa",
                        @"Andorra",
                        @"Angola",
                        @"Anguilla",
                        @"Antarctica",
                        @"Antigua-and-Barbuda",
                        @"Argentina",
                        @"Armenia",
                        @"Aruba",
                        @"Australia",
                        @"Austria",
                        @"Azerbaijan",
                        @"Bahamas",
                        @"Bahrain",
                        @"Bangladesh",
                        @"Barbados",
                        @"Basque-Country",
                        @"Belarus",
                        @"Belgium",
                        @"Belize",
                        @"Benin",
                        @"Bermuda",
                        @"Bhutan",
                        @"Bolivia",
                        @"Bosnia-and-Herzegovina",
                        @"Botswana",
                        @"Brazil",
                        @"British-Antarctic-Territory",
                        @"British-Virgin-Islands",
                        @"Brunei",
                        @"Bulgaria",
                        @"Burkina-Faso",
                        @"Burundi",
                        @"Cambodia",
                        @"Cameroon",
                        @"Canada",
                        @"Canary-Islands",
                        @"Cape-Verde",
                        @"Cayman-Islands",
                        @"Central-African-Republic",
                        @"Chad",
                        @"Chile",
                        @"China",
                        @"Christmas-Island",
                        @"Cocos-Keeling-Islands",
                        @"Colombia",
                        @"Commonwealth",
                        @"Comoros",
                        @"Cook-Islands",
                        @"Costa-Rica",
                        @"Cote-dIvoire",
                        @"Croatia",
                        @"Cuba",
                        @"Curacao",
                        @"Cyprus",
                        @"Czech-Republic",
                        @"Democratic-Republic-of-the-Congo",
                        @"Denmark",
                        @"Djibouti",
                        @"Dominica",
                        @"Dominican-Republic",
                        @"East-Timor",
                        @"Ecuador",
                        @"Egypt",
                        @"El-Salvador",
                        @"England",
                        @"Equatorial-Guinea",
                        @"Eritrea",
                        @"Estonia",
                        @"Ethiopia",
                        @"European-Union",
                        @"Falkland-Islands",
                        @"Faroes",
                        @"Fiji",
                        @"Finland",
                        @"France",
                        @"French-Polynesia",
                        @"Gabon",
                        @"Gambia",
                        @"Georgia",
                        @"Germany",
                        @"Ghana",
                        @"Gibraltar",
                        @"Greece",
                        @"Greenland",
                        @"Grenada",
                        @"Guam",
                        @"Guatemala",
                        @"Guernsey",
                        @"Guinea-Bissau",
                        @"Guinea",
                        @"Guyana",
                        @"Haiti",
                        @"Honduras",
                        @"Hong-Kong",
                        @"Hungary",
                        @"Iceland",
                        @"India",
                        @"Indonesia",
                        @"Iran",
                        @"Iraq",
                        @"Ireland",
                        @"Isle-of-Man",
                        @"Israel",
                        @"Italy",
                        @"Jamaica",
                        @"Japan",
                        @"Jersey",
                        @"Jordan",
                        @"Kazakhstan",
                        @"Kenya",
                        @"Kiribati",
                        @"Kosovo",
                        @"Kuwait",
                        @"Kyrgyzstan",
                        @"Laos",
                        @"Latvia",
                        @"Lebanon",
                        @"Lesotho",
                        @"Liberia",
                        @"Libya",
                        @"Liechtenstein",
                        @"Lithuania",
                        @"Luxembourg",
                        @"Macau",
                        @"Macedonia",
                        @"Madagascar",
                        @"Malawi",
                        @"Malaysia",
                        @"Maldives",
                        @"Mali",
                        @"Malta",
                        @"Mars",
                        @"Marshall-Islands",
                        @"Martinique",
                        @"Mauritania",
                        @"Mauritius",
                        @"Mayotte",
                        @"Mexico",
                        @"Micronesia",
                        @"Moldova",
                        @"Monaco",
                        @"Mongolia",
                        @"Montenegro",
                        @"Montserrat",
                        @"Morocco",
                        @"Mozambique",
                        @"Myanmar",
                        @"Nagorno-Karabakh",
                        @"Namibia",
                        @"NATO",
                        @"Nauru",
                        @"Nepal",
                        @"Netherlands-Antilles",
                        @"Netherlands",
                        @"New-Caledonia",
                        @"New-Zealand",
                        @"Nicaragua",
                        @"Niger",
                        @"Nigeria",
                        @"Niue",
                        @"Norfolk-Island",
                        @"North-Korea",
                        @"Northern-Cyprus",
                        @"Northern-Mariana-Islands",
                        @"Norway",
                        @"Oman",
                        @"Pakistan",
                        @"Palau",
                        @"Palestine",
                        @"Panama",
                        @"Papua-New-Guinea",
                        @"Paraguay",
                        @"Peru",
                        @"Philippines",
                        @"Pitcairn-Islands",
                        @"Poland",
                        @"Portugal",
                        @"Puerto-Rico",
                        @"Qatar",
                        @"Republic-of-the-Congo",
                        @"Romania",
                        @"Russia",
                        @"Rwanda",
                        @"Saint-Barthelemy",
                        @"Saint-Helena",
                        @"Saint-Kitts-and-Nevis",
                        @"Saint-Lucia",
                        @"Saint-Martin",
                        @"Saint-Vincent-and-the-Grenadines",
                        @"Samoa",
                        @"San-Marino",
                        @"Sao-Tome-and-Principe",
                        @"Saudi-Arabia",
                        @"Scotland",
                        @"Senegal",
                        @"Serbia",
                        @"Seychelles",
                        @"Sierra-Leone",
                        @"Singapore",
                        @"Slovakia",
                        @"Slovenia",
                        @"Solomon-Islands",
                        @"Somalia",
                        @"Somaliland",
                        @"South-Africa",
                        @"South-Georgia-and-the-South-Sandwich-Islands",
                        @"South-Korea",
                        @"South-Ossetia",
                        @"South-Sudan",
                        @"Spain",
                        @"Sri-Lanka",
                        @"Sudan",
                        @"Suriname",
                        @"Swaziland",
                        @"Sweden",
                        @"Switzerland",
                        @"Syria",
                        @"Taiwan",
                        @"Tajikistan",
                        @"Tanzania",
                        @"Thailand",
                        @"Togo",
                        @"Tokelau",
                        @"Tonga",
                        @"Trinidad-and-Tobago",
                        @"Tunisia",
                        @"Turkey",
                        @"Turkmenistan",
                        @"Turks-and-Caicos-Islands",
                        @"Tuvalu",
                        @"Uganda",
                        @"Ukraine",
                        @"United-Arab-Emirates",
                        @"United-Kingdom",
                        @"United-States",
                        @"Uruguay",
                        @"US-Virgin-Islands",
                        @"Uzbekistan",
                        @"Vanuatu",
                        @"Vatican-City",
                        @"Venezuela",
                        @"Vietnam",
                        @"Wales",
                        @"Wallis-And-Futuna",
                        @"Western-Sahara",
                        @"Yemen",
                        @"Zambia",
                        @"Zimbabwe"];
    
    dataBackgroundView.contentView.photoButton2.hidden = YES;
    dataBackgroundView.contentView.progressView.hidden = YES;
    dataBackgroundView.contentView.imageView2.hidden = YES;
    [dataBackgroundView.bottomButton1 setTitle:NSLocalizedString(@"Update Profile", nil) forState:UIControlStateNormal];
    [dataBackgroundView.bottomButton2 setTitle:NSLocalizedString(@"Camera", nil) forState:UIControlStateNormal];
    [dataBackgroundView.contentView bringSubviewToFront:dataBackgroundView.contentView.textFieldView];
    
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [self.view addSubview:cancelButton];

    backgroundCountryPickerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 240)];
    [self.view addSubview:backgroundCountryPickerView];
    
    countryPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44.f, backgroundCountryPickerView.frame.size.width, 216)];
    countryPicker.dataSource = self;
    countryPicker.delegate = self;
    countryPicker.backgroundColor = [UIColor colorWithRed:243.f/255.f green:243.f/255.f blue:243.f/255.f alpha:1.f];
    [backgroundCountryPickerView addSubview:countryPicker];
    
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, backgroundCountryPickerView.frame.size.width, 44)];
    UIBarButtonItem *flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
    [toolBar setItems:@[flexiSpace,doneButton]];
    [backgroundCountryPickerView addSubview:toolBar];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.appDelegate profilePicturePath]]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfFile:[self.appDelegate profilePicturePath]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [dataBackgroundView.contentView.imageView1 setImage:[UIImage imageWithData:imageData]];
                [dataBackgroundView.contentView.photoButton1 setTitle:NSLocalizedString(@"Take New Picture", nil) forState:UIControlStateNormal];
            });
        });
    } else {
        [dataBackgroundView.contentView.imageView1 setImage:[UIImage imageNamed:@"singleface"]];
    }
}


- (void)doneButtonTapped:(id)sender
{
    [dataBackgroundView.contentView.textFieldView updateUserInfoToParse];
    [UIView beginAnimations:nil context:NULL];
    
    CGRect pickerFrame = backgroundCountryPickerView.frame;
    pickerFrame.origin.y = self.view.frame.size.height;
    backgroundCountryPickerView.frame = pickerFrame;
    
    [UIView commitAnimations];
}

- (void)showErrorAlert:(NSError *)err
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[err localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
    [alertView show];
}

-(void) cameraViewController:(TFCameraViewController *) vc didCapturePictureWithData:(NSData *) imageData WithIndex:(int) indx
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [imageData writeToFile:[appDelegate profilePicturePath] atomically:YES];
    [vc dismissViewControllerAnimated:YES completion:NULL];
    [dataBackgroundView.contentView.imageView1 setImage:[UIImage imageWithData:imageData]];
}

-(void) cameraViewControllerDidCancel:(TFCameraViewController *) vc
{
    [vc dismissViewControllerAnimated:YES completion:NULL];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}



- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.countries count];
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.countries objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [nationalityTextField setText:[self.countries objectAtIndex:row]];
    [dataBackgroundView.contentView.textFieldView textFieldDidChange:nationalityTextField];
}

- (void) baseContentView:(TFBaseContentView *)view didSelectNationalityTextField:(UITextField *)textField
{
    nationalityTextField = textField;
    
    [UIView beginAnimations:nil context:NULL];
    
    CGRect pickerFrame = backgroundCountryPickerView.frame;
    pickerFrame.origin.y = self.view.frame.size.height - 240.f;
    backgroundCountryPickerView.frame = pickerFrame;
    
    [UIView commitAnimations];
}

-(void) baseContentView:(TFBaseContentView *) view buttonTapped:(UIButton *) btn
{
    switch (btn.tag) {
        case 1:
        {
            [self dismissViewControllerAnimated:YES completion:NULL];
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

-(void) photoContentView:(TFPhotoContentView *) view buttonTapped:(UIButton *) btn
{
    switch (btn.tag) {
        case 1:
        {
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
                                    [dataBackgroundView.contentView.photoButton1 setTitle:NSLocalizedString(@"Take New Picture", nil) forState:UIControlStateNormal];
                                    UINavigationController *navController = (UINavigationController *)self.presentingViewController;
                                    TFHomeViewController *homeViewController = (TFHomeViewController *)[navController.viewControllers firstObject];
                                    [homeViewController doPostLogin];
                                } else {
                                    [self showErrorAlert:error];
                                }
                            }];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please click a selfie and tap the add button to upload it to our server.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
                [alertView show];
            }
        }
            break;
            
        default:
            break;
    }
}


-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    cancelButton.frame = CGRectMake(0, 0, 50, 50);
    cancelButton.center = CGPointMake(30,appNameLabel.center.y);
}

-(void) cancelButtonTapped:(UIButton *)btn
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
