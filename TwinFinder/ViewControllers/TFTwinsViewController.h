//
//  TFTwinsViewController.h
//  ParseStarterProject
//
//  Created by Parag Dulam on 28/01/15.
//
//

#import <ParseUI/ParseUI.h>
#import "AppDelegate.h"


@class FaceImage;

@interface TFTwinsViewController : PFQueryCollectionViewController

@property (nonatomic,readonly) AppDelegate *appDelegate;
@property (nonatomic,strong) FaceImage *selectedFaceImage;

@end
