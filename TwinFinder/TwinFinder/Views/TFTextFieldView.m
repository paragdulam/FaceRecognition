//
//  TFTextFieldView.m
//  TwinFinder
//
//  Created by Parag Dulam on 09/03/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import "TFTextFieldView.h"
#import <Parse/Parse.h>
#import "UserInfo.h"
#import "TFAppManager.h"
#import "HTAutocompleteTextField.h"
#import "HTAutocompleteManager.h"

@interface TFTextFieldView ()<UITextFieldDelegate>

@property (nonatomic) UserInfo *userInfo;

@end

@implementation TFTextFieldView


-(id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        nameTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        nameTextField.backgroundColor = [UIColor whiteColor];
        nameTextField.placeholder = NSLocalizedString(@"Name", nil);
        nameTextField.font = [UIFont boldSystemFontOfSize:14.f];
        nameTextField.delegate = self;
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, nameTextField.frame.size.height)];
        nameTextField.leftView = leftView;
        [nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:nameTextField];
        
        ageTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        ageTextField.backgroundColor = [UIColor whiteColor];
        ageTextField.placeholder = NSLocalizedString(@"Age", nil);
        ageTextField.font = [UIFont boldSystemFontOfSize:14.f];
        ageTextField.delegate = self;
        leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, nameTextField.frame.size.height)];
        ageTextField.leftView = leftView;
        [ageTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:ageTextField];
        
        cityTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        cityTextField.backgroundColor = [UIColor whiteColor];
        cityTextField.placeholder = NSLocalizedString(@"City", nil);
        cityTextField.font = [UIFont boldSystemFontOfSize:14.f];
        cityTextField.delegate = self;
        leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, nameTextField.frame.size.height)];
        cityTextField.leftView = leftView;
        [cityTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:cityTextField];
        
        nationalTextField = [[HTAutocompleteTextField alloc] initWithFrame:CGRectZero];
        nationalTextField.autocompleteDisabled = NO;
        nationalTextField.autocompleteDataSource = [HTAutocompleteManager sharedManager];
        nationalTextField.autoCompleteTextFieldDelegate = self;
        nationalTextField.autocompleteType = HTAutocompleteTypeCountry;
        nationalTextField.backgroundColor = [UIColor whiteColor];
        nationalTextField.placeholder = NSLocalizedString(@"National.", nil);
        nationalTextField.font = [UIFont boldSystemFontOfSize:14.f];
        nationalTextField.delegate = self;
        leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, nameTextField.frame.size.height)];
        nationalTextField.leftView = leftView;
        [nationalTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:nationalTextField];
 
        [self fetchUserInfo];        
    }
    return self;
}


-(void) fetchUserInfo
{
    self.userInfo = [TFAppManager userWithId:[PFUser currentUser].objectId];
    nameTextField.text = self.userInfo.name;
    ageTextField.text = self.userInfo.age;
    cityTextField.text = self.userInfo.city;
    nationalTextField.text = self.userInfo.national;
    if ([self.delegate respondsToSelector:@selector(textFieldView:didUpdateUser:)]) {
        [self.delegate textFieldView:self didUpdateUser:self.userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"profile.updated" object:self.userInfo];
    }
}

-(void)textFieldDidChange:(UITextField *) textField
{
    if (textField == nameTextField) {
        self.userInfo.name = textField.text;
    } else if (textField == ageTextField) {
        self.userInfo.age = textField.text;
    } else if (textField == cityTextField) {
        self.userInfo.city = textField.text;
    } else if (textField == nationalTextField) {
        self.userInfo.national = textField.text;
    }
    [[TFAppManager appDelegate].managedObjectContext save:nil];
    if ([self.delegate respondsToSelector:@selector(textFieldView:didUpdateUser:)]) {
        [self.delegate textFieldView:self didUpdateUser:self.userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"profile.updated" object:self.userInfo];
    }
}




-(void) textFieldDidEndEditing:(UITextField *)textField
{
    [self updateUserInfoToParse];
}

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    
}

-(void) updateUserInfoToParse
{
    PFQuery *userInfoQuery = [PFQuery queryWithClassName:@"UserInfo"];
    [userInfoQuery whereKey:@"User" equalTo:[PFUser currentUser]];
    [userInfoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *userInfo = nil;
        if ([objects count]) {
            userInfo = [objects firstObject];
        } else {
            userInfo = [PFObject objectWithClassName:@"UserInfo"];
        }
        [userInfo setObject:nameTextField.text forKey:@"name"];
        [userInfo setObject:ageTextField.text forKey:@"age"];
        [userInfo setObject:cityTextField.text forKey:@"city"];
        [userInfo setObject:nationalTextField.text forKey:@"national"];
        [userInfo setObject:[PFUser currentUser] forKey:@"User"];
        [userInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [TFAppManager saveUserinfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.user.updated" object:[TFAppManager userWithId:userInfo.objectId]];
        }];
    }];
}



- (void)autoCompleteTextFieldDidAutoComplete:(HTAutocompleteTextField *)autoCompleteField
{
    
}


- (void)autocompleteTextField:(HTAutocompleteTextField *)autocompleteTextField didChangeAutocompleteText:(NSString *)autocompleteText
{
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == nameTextField) {
        [ageTextField becomeFirstResponder];
    } else if (textField == ageTextField) {
        [cityTextField becomeFirstResponder];
    } else if (textField == cityTextField) {
        [nationalTextField becomeFirstResponder];
    } else {
        [nationalTextField resignFirstResponder];
    }
    return YES;
}


-(void) layoutSubviews
{
    [super layoutSubviews];
    self.layer.cornerRadius = 10.f;
    self.clipsToBounds = YES;
    
    nameTextField.frame = CGRectMake(5, 5, self.frame.size.width - 10, 30);
    ageTextField.frame = CGRectMake(nameTextField.frame.origin.x, CGRectGetMaxY(nameTextField.frame) + 5, nameTextField.frame.size.width, nameTextField.frame.size.height);
    cityTextField.frame = CGRectMake(ageTextField.frame.origin.x, CGRectGetMaxY(ageTextField.frame) + 5, ageTextField.frame.size.width, ageTextField.frame.size.height);
    nationalTextField.frame = CGRectMake(cityTextField.frame.origin.x, CGRectGetMaxY(cityTextField.frame) + 5, cityTextField.frame.size.width, cityTextField.frame.size.height);
    
    nameTextField.layer.cornerRadius = 10.f;
    nameTextField.clipsToBounds = YES;
    
    ageTextField.layer.cornerRadius = 10.f;
    ageTextField.clipsToBounds = YES;
    
    cityTextField.layer.cornerRadius = 10.f;
    cityTextField.clipsToBounds = YES;
    
    nationalTextField.layer.cornerRadius = 10.f;
    nationalTextField.clipsToBounds = YES;
}

@end
