//
//  TFChatViewController.h
//  TwinFinder
//
//  Created by Parag Dulam on 27/03/15.
//  Copyright (c) 2015 Parag Dulam. All rights reserved.
//

#import "JSQMessagesViewController.h"

@class UserInfo;

@interface TFChatViewController : JSQMessagesViewController

@property (nonatomic,strong) UserInfo *toUser;

-(id) initWithRecipient:(UserInfo *) userInfo;

@end
