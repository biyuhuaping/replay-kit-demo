//
//  ZYBleFirmwareRequest.h
//  ZYCamera
//
//  Created by Frost Zhang on 2017/3/17.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYBleDeviceRequest.h"

@class ZYControlData;

typedef void(^compeletionWithParamsHandler)(ZYBleDeviceRequestState state, id param);

@interface ZYBleMutableRequest : ZYBleDeviceRequest

@property (nonatomic, readonly) NSUInteger address;
@property (nonatomic, readonly) NSUInteger command;
@property (nonatomic, readwrite, copy) compeletionWithParamsHandler paramsHandler;
@property (nonatomic, readonly, copy) ZYControlData* controlData;

@property (nonatomic, readonly) NSUInteger event;
/*!
 消息ID，用于记录发送的数据消息号
 
 */
@property (nonatomic, readonly) NSUInteger msgId;


@property (nonatomic, readwrite) NSUInteger realCode;


/**
 Description通过指令代号和参数创建请求
 
 @param address 指令地址
 @param aCommand 指令代号
 @return 请求对象
 */
-(instancetype) initWithCodeAndParam:(NSUInteger)address withCommand:(NSUInteger)aCommand;

/**
 Description通过指令代号和参数创建请求

 @param address 指令地址
 @param aCommand 指令代号
 @param aParam 指令2字节参数
 @return 请求对象
 */
-(instancetype) initWithCodeAndParamWith4BytesData:(NSUInteger)address withCommand:(NSUInteger)aCommand param:(NSUInteger)aParam;

/**
 <#Description#>通过指令代号和参数创建请求

 @param address 指令地址
 @param aCommand 指令代号
 @param aParam 指令4字节参数
 @param buff 指令附加参数
 @return 请求对象
 */
-(instancetype) initWithCodeAndParamWith2BytesDataAndBuffer:(NSUInteger)address withCommand:(NSUInteger)aCommand param:(NSUInteger)aParam buffer:(NSData*)buff;


/**
 <#Description#>通过手柄指令代号和参数创建请求

 @param aCommand 指令代号
 @param aParam 指令2字节参数
 @return 请求对象
 */
-(instancetype) initWithHandlerCodeAndParam:(NSUInteger)aCommand param:(NSUInteger)aParam;

/**
 从二进制数据中解析出指令代号和指令参数
 
 @param data 二进制数据
 @param address 解析出的指令地址
 @param command 解析出的指令代号
 @return 数据解析是否成功
 */
+(BOOL) parseDataToCodeAndParam:(NSData*)data adr:(NSUInteger*)address command:(NSUInteger*)command;

/**
 <#Description#>通过控制数据数据创建请求

 @param data 控制数据
 @return 请求对象
 */
-(instancetype) initWithZYControlData:(ZYControlData*)data;

/**
 判断二进制数据是否符合请求格式
 
 @param data 二进制数据
 @return 是否符合格式
 */
+(BOOL) isValidData:(NSData*)data;

/**
 判断数据是否完整
 
 @param data 二进制数据是否完整
 @return 是否符合格式
 */
+(BOOL) isFullData:(NSData*)data len:(NSUInteger*)len;

/**
 生成二进制数据
 
 @return 请求的二进制数据
 */
-(NSData*) translateToBinaryWithCoder:(ZYControlCoder*)coder;


+(NSDictionary*) parseData:(NSData*)data;


/**
 倒计时(用于请求超时)
 
 @param millisecond 毫秒
 @param block 倒计时完成回调
 */
-(void) startCountdown:(NSUInteger)millisecond block:(void (^)(void))block;

/**
 Description 判断是否事件
 
 @return Yes:是
 */
-(BOOL) isEvent;

/**
 Description 判断是否是按键事件

 @return Yes:是
 */
-(BOOL) isKeyEvent;
@end

extern ZYBleMutableRequest* transferDeviceRequestToMutable(ZYBleDeviceRequest* request, ZYControlCoder* coder);
