//
//  MAImageView.m
//  MobilyAssignment
//
//  Created by Parag Dulam on 28/02/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import "MAImageView.h"
#import "AppDelegate.h"

@interface MAImageView ()
{
    UIActivityIndicatorView *activityIndicator;
}

@end

@implementation MAImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.hidesWhenStopped = YES;
        [self addSubview:activityIndicator];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.hidesWhenStopped = YES;
        [self addSubview:activityIndicator];
        activityIndicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    activityIndicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}



-(void) setImageURL:(NSURL *) url forFileId:(NSString *) idString
{
    [self setImage:nil];
    self.idString = idString;
    [activityIndicator startAnimating];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",documentsDirectory,idString];
    if ([[NSFileManager defaultManager] fileExistsAtPath:idString]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSLog(@"saved Path %@",filePath);
            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setImage:image];
                [activityIndicator stopAnimating];
            });
        });
    } else {
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [data writeToFile:filePath atomically:YES];
            });
            [self setImage:[UIImage imageWithData:data]];
            [activityIndicator stopAnimating];
        }];
    }
}

@end
