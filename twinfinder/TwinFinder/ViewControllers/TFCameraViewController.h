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
@property(nonatomic,assign) int index;


-(id) initWithIndex:(int) indx;

@end





@protocol TFCameraViewControllerDelegate <NSObject>

-(void) cameraViewController:(TFCameraViewController *) vc didCapturePictureWithData:(NSData *) imageData WithIndex:(int) indx;
-(void) cameraViewControllerDidCancel:(TFCameraViewController *) vc;

@end
