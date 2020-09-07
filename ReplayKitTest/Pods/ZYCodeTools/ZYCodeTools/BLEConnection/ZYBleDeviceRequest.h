//
//  ZYBleDeviceRequest.h
//  ZYCamera
//
//  Created by Frost Zhang on 2017/1/10.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYStablizerDefineENUM.h"
@class ZYControlCoder;
@class ZYControlData;

@interface ZYBleDeviceRequest : NSObject
@property (nonatomic) BOOL noNeedToUpdateDataCache;//不需要更新cache

@property (nonatomic, readonly) NSUInteger code;
@property (nonatomic, readonly) NSUInteger param;
@property (nonatomic, readwrite, copy) compeletionHandler handler;
@property(nonatomic, assign) ZYBleTimeoutOfDataProcessing timeouProcessing;
@property (nonatomic, readonly) BOOL needResponse;
@property (nonatomic, readonly, getter=isWaiting) BOOL waiting;
@property (nonatomic, readwrite) BOOL packedWithNext;
@property (nonatomic, readonly) NSUInteger realCode;
@property (nonatomic, readonly) BOOL blocked;
@property (nonatomic, readwrite) ZYBleDeviceRequestMask mask;

/// 需要快速发送出去
@property (nonatomic) BOOL needSendSoon;

/// 延时多少毫秒
@property (assign, nonatomic) NSUInteger delayMillisecond;

/**
用于发送数据的时候的编码格式
 */
@property (nonatomic)         ZYCodeParseFormat parseFormat;

/**
 数据传输的方式，是Wi-Fi还是蓝牙，以后用的USB，目前是USB和Wi-Fi是一样的
 */
@property (nonatomic)         ZYTrasmissionType trasmissionType;

/**
 通过指令代号和参数创建请求

 @param code 指令代号
 @param param 指令参数
 @return 请求对象
 */
-(instancetype) initWithCodeAndParam:(NSUInteger)code param:(NSNumber*)param;

/**
 从二进制数据中解析出指令代号和指令参数

 @param data 二进制数据
 @param aCode 解析出的指令代号
 @param aParam 解析出的指令参数
 @return 数据解析是否成功
 */
+(BOOL) parseDataToCodeAndParam:(NSData*)data code:(NSUInteger*)aCode param:(NSUInteger*)aParam;


/**
 通过二进制数据创建请求

 @param data 二进制数据
 @return 请求对象
 */
-(instancetype) initWithBytes:(NSData*)data;

/**
 判断二进制数据是否符合请求格式

 @param data 二进制数据
 @return 是否符合格式
 */
+(BOOL) isValidData:(NSData*)data;

/**
 生成二进制数据

 @return 请求的二进制数据
 */
-(NSData*) translateToBinaryWithCoder:(ZYControlCoder*)coder;

/**
 倒计时(用于请求超时)

 @param millisecond 毫秒
 @param block 倒计时完成回调
 */
-(void) startCountdown:(NSUInteger)millisecond block:(void (^)(void))block;

/**
 结束倒计时
 */
-(void) finishCountdown;

/**
 Description 判断是否是按键事件
 
 @return Yes:是
 */
-(BOOL) isKeyEvent;

/**
 Description 判断指令类型是否相同
 
 @return Yes:是
 */
-(BOOL) isSameWithCode:(NSUInteger)code;


/**
 <#Description#> 判断指令类型是否相同

 @param request 指令对象
 @return Yes:是
 */
-(BOOL) isSameCodeWithRequest:(ZYBleDeviceRequest*)request;

/**
 <#Description#> 通知结果

 @param request 请求
 @param state 状态
 @param coder 编码器
 */
-(void) notifyResultWithRequest:(ZYBleDeviceRequest*)request state:(ZYBleDeviceRequestState)state coder:(ZYControlCoder*)coder;

/**
 Description 如果该指令需要通知则发送
 
 @param coder 编码器
 @return Yes:是
 */
-(BOOL) postNotificationIfNeed:(ZYControlCoder*)coder;


@end

extern ZYBleDeviceRequest* buildRequestWithControlData(ZYControlData* data);
