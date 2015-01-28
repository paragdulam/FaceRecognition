//
//  TFCameraViewController.m
//  ParseStarterProject
//
//  Created by Parag Dulam on 28/01/15.
//
//

#import "TFCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "TFCameraOverlayView.h"
#import "UNIRest.h"

@interface TFCameraViewController ()

@property(nonatomic,strong) AVCaptureStillImageOutput *stillImageOutput;

@end

@implementation TFCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    AVCaptureDevice *inputDevice = [self frontCamera];
    NSError *error = nil;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    if ( [session canAddInput:deviceInput] )
        [session addInput:deviceInput];
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    if ([session canAddOutput:self.stillImageOutput]) {
        [session addOutput:self.stillImageOutput];
    }
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    CALayer *rootLayer = [[self view] layer];
    [rootLayer setMasksToBounds:YES];
    [previewLayer setFrame:CGRectMake(0, 0, rootLayer.bounds.size.width, rootLayer.bounds.size.height)];
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    [session startRunning];

    TFCameraOverlayView *overlay = [[TFCameraOverlayView alloc] init];
    [overlay setFrame:self.view.bounds];
    [self.view addSubview:overlay];
 
    
    UIButton *captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [captureButton setTitle:@"Capture" forState:UIControlStateNormal];
    [captureButton addTarget:self action:@selector(captureButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    captureButton.frame = CGRectMake(0, 0, 80, 30);
    captureButton.center = CGPointMake(overlay.center.x, overlay.frame.size.height - 100.f);
    [overlay addSubview:captureButton];
}


-(void)captureButtonTapped:(UIButton *) btn
{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            break;
        }
    }
    
    NSLog(@"about to request a capture from: %@", self.stillImageOutput);
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        if (imageSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            NSDictionary *headers = @{@"X-Mashape-Key": @"UR6cNZe0jWmshJTIjaQAEOdVfM02p1BvCy1jsnd3dGcYwJe14p", @"Accept": @"application/json"};
            UNIUrlConnection *asyncConnection = [[UNIRest get:^(UNISimpleRequest *request) {
                [request setUrl:@"https://lambda-face-detection-and-recognition.p.mashape.com/detect?images=http%3A%2F%2Fwww.lambdal.com%2Ftest2.jpg"];
                [request setHeaders:headers];
            }] asJsonAsync:^(UNIHTTPJsonResponse *response, NSError *error) {
                NSInteger code = response.code;
                NSDictionary *responseHeaders = response.headers;
                UNIJsonNode *body = response.body;
                NSData *rawBody = response.rawBody;
            }];
        }
    }];
}

- (AVCaptureDevice *)frontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
