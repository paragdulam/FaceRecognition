//
//  TFCameraViewController.h
//  ParseStarterProject
//
//  Created by Parag Dulam on 28/01/15.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol TFCameraViewControllerDelegate;

@interface TFCameraViewController : UIViewController

@property(nonatomic,weak) id<TFCameraViewControllerDelegate>delegate;

@end


@protocol TFCameraViewControllerDelegate <NSObject>

-(void) cameraViewController:(TFCameraViewController *) vc didCapturePictureWithData:(NSData *) imageData;
-(void) cameraViewControllerDidCancel:(TFCameraViewController *) vc;

@end
