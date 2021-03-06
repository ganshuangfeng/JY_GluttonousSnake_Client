//------------------------------------------------------------------------------
// Copyright (c) 2018-2019 Beijing Bytedance Technology Co., Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

#import <BUAdSDK/BUFullscreenVideoAd.h>
#import "UnityAppController.h"
#import "BUToUnityAdManager.h"

const char* AutonomousStringCopy1(const char* string)
{
    if (string == NULL) {
        return NULL;
    }
    
    char* res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}

// IFullScreenVideoAdListener callbacks.
typedef void(*FullScreenVideoAd_OnError)(int code, const char* message, int context);
typedef void(*FullScreenVideoAd_OnFullScreenVideoAdLoad)(void* fullScreenVideoAd, int context);
typedef void(*FullScreenVideoAd_OnFullScreenVideoCached)(int context);

// IRewardAdInteractionListener callbacks.
typedef void(*FullScreenVideoAd_OnAdShow)(int context);
typedef void(*FullScreenVideoAd_OnAdVideoBarClick)(int context);
typedef void(*FullScreenVideoAd_OnAdClose)(int context);
typedef void(*FullScreenVideoAd_OnVideoComplete)(int context);
typedef void(*FullScreenVideoAd_OnVideoError)(int context);
typedef void(*FullScreenVideoAd_OnRewardVerify)(
    bool fullScreenVerify, int fullScreenAmount, const char* fullScreenName, int context);

// The BURewardedVideoAdDelegate implement.
@interface FullScreenVideoAd : NSObject
@end

@interface FullScreenVideoAd () <BUFullscreenVideoAdDelegate>
@property (nonatomic, strong) BUFullscreenVideoAd *fullScreenVideoAd;

@property (nonatomic, assign) int loadContext;
@property (nonatomic, assign) FullScreenVideoAd_OnError onError;
@property (nonatomic, assign) FullScreenVideoAd_OnFullScreenVideoAdLoad onFullScreenVideoAdLoad;
@property (nonatomic, assign) FullScreenVideoAd_OnFullScreenVideoCached onFullScreenVideoCached;

@property (nonatomic, assign) int interactionContext;
@property (nonatomic, assign) FullScreenVideoAd_OnAdShow onAdShow;
@property (nonatomic, assign) FullScreenVideoAd_OnAdVideoBarClick onAdVideoBarClick;
@property (nonatomic, assign) FullScreenVideoAd_OnAdClose onAdClose;
@property (nonatomic, assign) FullScreenVideoAd_OnVideoComplete onVideoComplete;
@property (nonatomic, assign) FullScreenVideoAd_OnVideoError onVideoError;
@property (nonatomic, assign) FullScreenVideoAd_OnRewardVerify onRewardVerify;
@end

@implementation FullScreenVideoAd

+ (FullScreenVideoAd *)sharedInstance {
    
    static FullScreenVideoAd *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

/**
 ??????????????????????????????
 */
- (void)fullscreenVideoMaterialMetaAdDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd {
            self.onFullScreenVideoAdLoad((__bridge void*)self, self.loadContext);
}

/**
 ????????????????????????????????????
 */
- (void)fullscreenVideoAdVideoDataDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd {
      
    self.onFullScreenVideoCached(self.loadContext);

}

/**
 ?????????????????????
 */
- (void)fullscreenVideoAdWillVisible:(BUFullscreenVideoAd *)fullscreenVideoAd {
    self.onAdShow(self.interactionContext);
}

/**
 ?????????????????????
 */
- (void)fullscreenVideoAdDidVisible:(BUFullscreenVideoAd *)fullscreenVideoAd {

}

/**
 ????????????????????????
 */
- (void)fullscreenVideoAdWillClose:(BUFullscreenVideoAd *)fullscreenVideoAd {

}

/**
 ??????????????????
 */
- (void)fullscreenVideoAdDidClose:(BUFullscreenVideoAd *)fullscreenVideoAd {
    self.onAdClose(self.interactionContext);
}

/**
 ??????????????????
 */
- (void)fullscreenVideoAdDidClick:(BUFullscreenVideoAd *)fullscreenVideoAd {
    self.onAdVideoBarClick(self.interactionContext);
}

/**
 ??????????????????????????????
 
 @param fullscreenVideoAd ??????????????????
 @param error ????????????
 */
- (void)fullscreenVideoAd:(BUFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error {
    self.onError((int)error.code, AutonomousStringCopy1([[error localizedDescription] UTF8String]), self.loadContext);
}

/**
 ???????????????????????????????????????
 
 @param fullscreenVideoAd ??????????????????
 @param error ????????????
 */
- (void)fullscreenVideoAdDidPlayFinish:(BUFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error {
    self.onVideoComplete(self.interactionContext);
}

/**
 ??????????????????????????????

 @param fullscreenVideoAd ??????????????????
 */
- (void)fullscreenVideoAdDidClickSkip:(BUFullscreenVideoAd *)fullscreenVideoAd {

}



@end

#if defined (__cplusplus)
extern "C" {
#endif

void UnionPlatform_FullScreenVideoAd_Load(
    const char* slotID,
    const char* userID,
    FullScreenVideoAd_OnError onError,
    FullScreenVideoAd_OnFullScreenVideoAdLoad onFullScreenVideoAdLoad,
    FullScreenVideoAd_OnFullScreenVideoCached onFullScreenVideoCached,
    int context) {

    BUFullscreenVideoAd* fullScreenVideoAd = [[BUFullscreenVideoAd alloc] initWithSlotID:[[NSString alloc] initWithUTF8String:slotID]];
    
    FullScreenVideoAd* instance = [FullScreenVideoAd sharedInstance]; //[[FullScreenVideoAd alloc] init];
    instance.fullScreenVideoAd = fullScreenVideoAd;
    instance.onError = onError;
    instance.onFullScreenVideoAdLoad = onFullScreenVideoAdLoad;
    instance.onFullScreenVideoCached = onFullScreenVideoCached;
    instance.loadContext = context;
    fullScreenVideoAd.delegate = instance;
    [fullScreenVideoAd loadAdData];
    
    // ????????????????????????+1
    [[BUToUnityAdManager sharedInstance] addAdManager:instance];

    (__bridge_retained void*)instance;
}

void UnionPlatform_FullScreenVideoAd_SetInteractionListener(
    void* fullScreenVideoAdPtr,
    FullScreenVideoAd_OnAdShow onAdShow,
    FullScreenVideoAd_OnAdVideoBarClick onAdVideoBarClick,
    FullScreenVideoAd_OnAdClose onAdClose,
    FullScreenVideoAd_OnVideoComplete onVideoComplete,
    FullScreenVideoAd_OnVideoError onVideoError,
    int context) {
    FullScreenVideoAd* fullScreenVideoAd = [FullScreenVideoAd sharedInstance]; //(__bridge FullScreenVideoAd*)fullScreenVideoAdPtr;
    fullScreenVideoAd.onAdShow = onAdShow;
    fullScreenVideoAd.onAdVideoBarClick = onAdVideoBarClick;
    fullScreenVideoAd.onAdClose = onAdClose;
    fullScreenVideoAd.onVideoComplete = onVideoComplete;
    fullScreenVideoAd.onVideoError = onVideoError;
    fullScreenVideoAd.interactionContext = context;
}

void UnionPlatform_FullScreenVideoAd_ShowFullScreenVideoAd(void* fullscreenVideoAdPtr) {
    FullScreenVideoAd* fullscreenVideoAd = [FullScreenVideoAd sharedInstance]; //(__bridge FullScreenVideoAd*)fullscreenVideoAdPtr;
    [fullscreenVideoAd.fullScreenVideoAd showAdFromRootViewController:GetAppController().rootViewController];}

void UnionPlatform_FullScreenVideoAd_Dispose(void* fullscreenVideoAdPtr) {
    
    FullScreenVideoAd *fullscreenVideoAd = (__bridge_transfer FullScreenVideoAd*)fullscreenVideoAdPtr;
    [[BUToUnityAdManager sharedInstance] deleteAdManager:fullscreenVideoAd];
}

#if defined (__cplusplus)
}
#endif
