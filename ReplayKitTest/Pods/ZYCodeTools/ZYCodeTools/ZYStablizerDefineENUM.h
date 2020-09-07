//
//  ZYStablizerDefineENUM.h
//  ZYCamera
//
//  Created by Liao GJ on 2018/9/5.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//
#ifndef ZYStablizerDefineENUM_h
#define ZYStablizerDefineENUM_h

//检测block是否可用
#define BLOCK_EXEC(block, ...) if (block) { block(__VA_ARGS__); };
#define BLOCK_EXEC_ON_MAINQUEUE(block, ...) dispatch_async(dispatch_get_main_queue(), ^{ \
    if (block) { block(__VA_ARGS__); }; \
    });
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

//Wi-Fi链路获取到心跳的通知
#define kWifiReciveHearBeat @"kWifiReciveHearBeat"
/**
 传输数据的解析方式
 
 - ZYCodeParseStar: star协议
 - ZYCodeParseBl: zybl协议
 - ZYCodeParseUsb: zyusb协议
 */

typedef NS_ENUM(NSInteger, ZYCodeParseFormat) {
    ZYCodeParseStar = 0,
    ZYCodeParseBl,
    ZYCodeParseUsb,
};

/**
 传输数据的方式
 
 - ZYTrasmissionTypeBLE: 通过蓝牙传输
 - ZYTrasmissionTypeWIFI: 通过WIFI传输
 - ZYTrasmissionTypeUSB: 通过USB传输
 */
typedef NS_ENUM(NSInteger, ZYTrasmissionType) {
    ZYTrasmissionTypeBLE = 0,
    ZYTrasmissionTypeWIFI,
    ZYTrasmissionTypeUSB,
};

/**
 请求的当前状态
 
 - ZYBleDeviceRequestStateUnknown: 未知状态
 - ZYBleDeviceRequestStateResponse: 回应
 - ZYBleDeviceRequestStateTimeout: 超时
 - ZYBleDeviceRequestStateFail: 失败
 - ZYBleDeviceRequestStateIgnore: 忽略
 */
typedef NS_ENUM(NSInteger, ZYBleDeviceRequestState) {
    ZYBleDeviceRequestStateUnknown = 0,
    ZYBleDeviceRequestStateResponse = 1,
    ZYBleDeviceRequestStateTimeout = 2,
    ZYBleDeviceRequestStateFail = 3,
    ZYBleDeviceRequestStateIgnore = 4,
};

typedef NS_ENUM(NSInteger, ZYBleTimeoutOfDataProcessing){
    ZYBlePriorityToResend = 0,
    ZYBleLowPriorityToResend = 1,
    ZYBleDoNotToResend = 2,
};

typedef NS_ENUM(NSInteger, ZYBleDeviceRequestMask){
    ZYBleDeviceRequestMaskUnique = 0,
    ZYBleDeviceRequestMaskUpdate = 1,
    ZYBleDeviceRequestMaskMulty = 2,
};

typedef void(^compeletionHandler)(ZYBleDeviceRequestState state, NSUInteger param);

#endif /* ZYStablizerDefineENUM_h */
