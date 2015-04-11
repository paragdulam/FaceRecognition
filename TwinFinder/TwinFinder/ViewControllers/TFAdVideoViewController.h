#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#import "IMAAdsLoader.h"
#import "IMAAVPlayerContentPlayhead.h"

@interface TFAdVideoViewController : UIViewController<IMAAdsLoaderDelegate,
                                             IMAAdsManagerDelegate>

// Content Player
/// UIView in which we will render our AVPlayer for content.
@property(nonatomic, strong) UIView *videoView;
/// Content video player.
@property(nonatomic, strong) AVPlayer *contentPlayer;

// SDK
/// Entry point for the SDK. Used to make ad requests.
@property(nonatomic, strong) IMAAdsLoader *adsLoader;
// Container which lets the SDK know where to render ads.
@property(nonatomic, strong) IMAAdDisplayContainer *adDisplayContainer;
// Rendering settings for ads.
@property(nonatomic, strong) IMAAdsRenderingSettings *adsRenderingSettings;
// Playhead used by the SDK to track content video progress and insert mid-rolls.
@property(nonatomic, strong) IMAAVPlayerContentPlayhead *contentPlayhead;
/// Main point of interaction with the SDK. Created by the SDK as the result of an ad request.
@property(nonatomic, strong) IMAAdsManager *adsManager;

@end

