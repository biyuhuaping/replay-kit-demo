//
//  ZYLiveAssist.h
//  ZYImageTools
//
//  Created by Frost Zhang on 2017/4/7.
//  Copyright © 2017年 Frost Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <UIKit/UIKit.h>

@interface ZYLiveAssist : NSObject

/// 流状态
typedef NS_ENUM (NSUInteger, ZYLiveState) {
    /// 准备
    ZYLiveReady = 0,
    /// 连接中
    ZYLivePending = 1,
    /// 已连接
    ZYLiveStart = 2,
    /// 已断开
    ZYLiveStop = 3,
    /// 连接出错
    ZYLiveError = 4,
    ///  正在刷新
    ZYLiveRefresh = 5
};

typedef NS_ENUM (NSUInteger, ZYLiveSocketError) {
    ZYLiveSocketError_PreView = 201,              ///< 预览失败
    ZYLiveSocketError_GetStreamInfo = 202,        ///< 获取流媒体信息失败
    ZYLiveSocketError_ConnectSocket = 203,        ///< 连接socket失败
    ZYLiveSocketError_Verification = 204,         ///< 验证服务器失败
    ZYLiveSocketError_ReConnectTimeOut = 205      ///< 重新连接服务器超时
};

@property(nonatomic, readonly) ZYLiveState state;
@property(nonatomic, readonly) NSDictionary* info;
@property(nonatomic, readonly) NSDictionary* config;
@property(nonatomic, readonly) ZYLiveSocketError error;

+(instancetype) defaultAssist;

-(void) startWithUrl:(NSURL*)url;
-(void) startWithUrl:(NSURL*)url withOptions:(NSDictionary*)options;
-(void) startWithPlatform:(NSDictionary*)options block:(void (^)(NSError* error))block;
-(void) finish;

-(void)pushFrame:(CVPixelBufferRef)pixelBuffer;

@end

extern NSString* const ZYLiveOutputPlatform;
extern NSString* const ZYLiveOutputPlatformFacebook;
extern NSString* const ZYLiveOutputPlatformWeibo;

extern NSString* const ZYLiveOutputOpenId;
extern NSString* const ZYLiveOutputAccessToken;
extern NSString* const ZYLiveOutputTitle;
extern NSString* const ZYLiveOutputVideoSize;
extern NSString* const ZYLiveOutputVideoFrameRate;
extern NSString* const ZYLiveOutputVideoBitRate;
extern NSString* const ZYLiveOutputVideoGroupOfPicture;
extern NSString* const ZYLiveOutputVideoAutoRotate;
extern NSString* const ZYLiveOutputAudioSampleRate;
extern NSString* const ZYLiveOutputAudioBitRate;

//option for weibo live
extern NSString* const ZYLiveOutputSummary;      //不超过130个汉字
extern NSString* const ZYLiveOutputPublished;    //0：公开发布，1：仅自己可见，默认为0
extern NSString* const ZYLiveOutputImage;        //封面图地址，注意封面图的宽高和直播的宽高比例要一致
extern NSString* const ZYLiveOutputReplay;       //是否录制，0：不录制，1：录制，默认为1
extern NSString* const ZYLiveOutputPanolive;     //是否全景直播，0：不是，1：是，默认为0



