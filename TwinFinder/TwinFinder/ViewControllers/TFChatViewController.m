//
//  TFChatViewController.m
//  TwinFinder
//
//  Created by Parag Dulam on 27/03/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import "TFChatViewController.h"
#import "TFAppManager.h"
#import "UserInfo.h"
#import "Message.h"
#import "JSQMessage.h"
#import "JSQMessagesBubbleImageFactory.h"
#import "JSQMessagesAvatarImageFactory.h"
#import "UIColor+JSQMessages.h"
#import "FaceImage.h"
#import "JSQMessagesBubbleImage.h"
#import "DACircularProgressView.h"

@interface TFChatViewController ()

@end

@implementation TFChatViewController


-(id) initWithRecipient:(UserInfo *) userInfo
{
    if (self = [super init]) {
        self.toUser = userInfo;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:68.f/255.f green:138.f/255.f blue:197.f/255.f alpha:1.f]];
    [self.navigationItem setTitle:[NSString stringWithFormat:@"Chat with %@",self.toUser.name]];
    DACircularProgressView *progressView = [[DACircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 35.f, 35.f)];
    progressView.trackTintColor = [UIColor blackColor];
    progressView.progressTintColor = [UIColor greenColor];
    progressView.thicknessRatio = 0.1;
    FaceImage *faceImage = [TFAppManager faceImageWithUserId:self.toUser.parse_id];
    CGFloat progress = [faceImage.confidence floatValue] * 0.01;
    [progressView setProgress:progress animated:YES];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:progressView];
    [[TFAppManager appDelegate] setChatViewController:self];
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadMessages];
}

-(void) loadMessages
{
    [TFAppManager loadMessagesFromUser:[TFAppManager userWithId:[PFUser currentUser].objectId] ToUser:self.toUser completionBlock:^(NSError *error) {
        [self finishReceivingMessageAnimated:YES];
    }];
}



-(void) cancelButtonTapped:(UIBarButtonItem *) btn
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(id<JSQMessageData>) collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [[TFAppManager messagesForFromUser:[TFAppManager userWithId:[PFUser currentUser].objectId] ToUser:self.toUser] objectAtIndex:indexPath.item];
    JSQMessage *aMessage = [[JSQMessage alloc] initWithSenderId:message.fromUser.parse_id
                                              senderDisplayName:message.fromUser.name
                                                           date:message.created_at
                                                           text:message.text];
    return aMessage;
}

-(void) didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    [TFAppManager addMessageWithText:text ToUser:self.toUser onDate:date];
    UserInfo *fromUser = [TFAppManager userWithId:[PFUser currentUser].objectId];

    PFQuery *innerQuery = [PFUser query];
    
    // Use hasPrefix: to only match against the month/date
    [innerQuery whereKey:@"objectId" equalTo:self.toUser.parse_id];
    
    // Build the actual push notification target query
    PFQuery *query = [PFInstallation query];
    
    // only return Installations that belong to a User that
    // matches the innerQuery
    [query whereKey:@"user" matchesQuery:innerQuery];
    
    // Send the notification.
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:query];
    [push setMessage:[NSString stringWithFormat:@"%@:%@",fromUser.name,text]];
    [push sendPushInBackground];

    [self finishSendingMessageAnimated:YES];
}


-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    Message *message = [[TFAppManager messagesForFromUser:[TFAppManager userWithId:[PFUser currentUser].objectId] ToUser:self.toUser] objectAtIndex:indexPath.item];
    
    if ([message.fromUser.parse_id isEqualToString:self.senderId]) {
        return [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    }
    return [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
}


-(id<JSQMessageAvatarImageDataSource>) collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [[TFAppManager messagesForFromUser:[TFAppManager userWithId:[PFUser currentUser].objectId] ToUser:self.toUser] objectAtIndex:indexPath.item];

    if ([self.senderId isEqualToString:message.fromUser.parse_id]) {
        return [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithContentsOfFile:[[TFAppManager appDelegate] clickedPicturePath]] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    } else {
        FaceImage *faceImage = [TFAppManager faceImageWithUserId:message.toUser.parse_id];
        NSString *imagePath = [NSString stringWithFormat:@"%@/%@",[[TFAppManager appDelegate] applicationDocumentsDirectory].path,faceImage.parse_id];
        return [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithContentsOfFile:imagePath] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    }
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [TFAppManager messageCountForFromUser:[TFAppManager userWithId:[PFUser currentUser].objectId] ToUser:self.toUser];
    
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
