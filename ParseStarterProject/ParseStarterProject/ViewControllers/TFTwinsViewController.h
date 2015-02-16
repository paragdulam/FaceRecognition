//
//  TFTwinsViewController.h
//  ParseStarterProject
//
//  Created by Parag Dulam on 28/01/15.
//
//

#import <ParseUI/ParseUI.h>
#import "ParseStarterProjectAppDelegate.h"

@interface TFTwinsViewController : PFQueryCollectionViewController

@property (nonatomic,readonly) ParseStarterProjectAppDelegate *appDelegate;

@end
