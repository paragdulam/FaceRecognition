//
//  TFFriendCollectionViewCell.m
//  ParseStarterProject
//
//  Created by Parag Dulam on 25/02/15.
//
//

#import "TFFriendCollectionViewCell.h"
#import "ParseStarterProjectAppDelegate.h"

@interface TFFriendCollectionViewCell ()
{
    UIImageView *imageView;
    UIActivityIndicatorView *activityIndicator;
}


@end

@implementation TFFriendCollectionViewCell


-(id) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        
        self.layer.cornerRadius = frame.size.width/2;
        self.clipsToBounds = YES;
        
        imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:imageView];
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [imageView addSubview:activityIndicator];
        activityIndicator.center = imageView.center;
    }
    return self;
}

-(void) setFriend:(NSDictionary *) friendDict
{
    NSString *friendId = [friendDict objectForKey:@"id"];
    ParseStarterProjectAppDelegate *appDelegate = (ParseStarterProjectAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[appDelegate applicationDocumentsDirectory].path,friendId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:NO]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                [imageView setImage:[UIImage imageWithData:data]];
            });
        });
    } else {
        NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",friendId];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [activityIndicator startAnimating];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [data writeToFile:filePath atomically:YES];
            });
            [activityIndicator stopAnimating];
            [imageView setImage:[UIImage imageWithData:data]];
        }];
    }
}

@end

