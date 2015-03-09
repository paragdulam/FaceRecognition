//
//  TFTextFieldView.m
//  TwinFinder
//
//  Created by Parag Dulam on 09/03/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import "TFTextFieldView.h"

@implementation TFTextFieldView


-(id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        nameTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        nameTextField.backgroundColor = [UIColor whiteColor];
        nameTextField.placeholder = NSLocalizedString(@"Name", nil);
        [self addSubview:nameTextField];
        
        ageTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        ageTextField.backgroundColor = [UIColor whiteColor];
        ageTextField.placeholder = NSLocalizedString(@"Age", nil);
        [self addSubview:ageTextField];
        
        cityTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        cityTextField.backgroundColor = [UIColor whiteColor];
        cityTextField.placeholder = NSLocalizedString(@"City", nil);
        [self addSubview:cityTextField];
        
        locationTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        locationTextField.backgroundColor = [UIColor whiteColor];
        locationTextField.placeholder = NSLocalizedString(@"Land", nil);
        [self addSubview:locationTextField];
        
        nationalTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        nationalTextField.backgroundColor = [UIColor whiteColor];
        nationalTextField.placeholder = NSLocalizedString(@"National.", nil);
        [self addSubview:nationalTextField];
    }
    return self;
}


-(void) layoutSubviews
{
    [super layoutSubviews];
    self.layer.cornerRadius = 10.f;
    self.clipsToBounds = YES;
    
    nameTextField.frame = CGRectMake(5, 5, self.frame.size.width - 10, 30);
    ageTextField.frame = CGRectMake(nameTextField.frame.origin.x, CGRectGetMaxY(nameTextField.frame) + 5, nameTextField.frame.size.width, nameTextField.frame.size.height);
    cityTextField.frame = CGRectMake(ageTextField.frame.origin.x, CGRectGetMaxY(ageTextField.frame) + 5, ageTextField.frame.size.width, ageTextField.frame.size.height);
    locationTextField.frame = CGRectMake(cityTextField.frame.origin.x, CGRectGetMaxY(cityTextField.frame) + 5 , cityTextField.frame.size.width, cityTextField.frame.size.height);
    nationalTextField.frame = CGRectMake(locationTextField.frame.origin.x, CGRectGetMaxY(locationTextField.frame) + 5, locationTextField.frame.size.width, locationTextField.frame.size.height);
    
    nameTextField.layer.cornerRadius = 10.f;
    nameTextField.clipsToBounds = YES;
    
    ageTextField.layer.cornerRadius = 10.f;
    ageTextField.clipsToBounds = YES;
    
    cityTextField.layer.cornerRadius = 10.f;
    cityTextField.clipsToBounds = YES;
    
    locationTextField.layer.cornerRadius = 10.f;
    locationTextField.clipsToBounds = YES;
    
    nationalTextField.layer.cornerRadius = 10.f;
    nationalTextField.clipsToBounds = YES;
}

@end
