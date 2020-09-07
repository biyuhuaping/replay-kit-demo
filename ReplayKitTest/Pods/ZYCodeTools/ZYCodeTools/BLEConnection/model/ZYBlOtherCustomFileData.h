//
//  ZYBlOtherCustomFileData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/7/13.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

//  支持的格式
typedef NS_ENUM(NSUInteger, ZYBlOtherCustomFileDataFormat) {
    ZYBlOtherCustomFileDataFormatUndefined = 0,
    ZYBlOtherCustomFileDataFormatSupport,
    ZYBlOtherCustomFileDataFormatPathShot,
    ZYBlOtherCustomFileDataFormatPathPoint,
    ZYBlOtherCustomFileDataFormatModules
};

#define ZYBlOtherCustomFileData_CODE_AUTHCHECK 0xffff

#define ZYBlOtherCustomFileData_CODE_PAGEINFO 0x0

@interface ZYBlOtherCustomFileData : ZYBlData

/**
 direction = 0，表示由请求方往被请求方传输（发送数据给稳定器），direction = 0x01，表示由被请求方往请求方运输（获取稳定器的数据）。
 */
@property (nonatomic, readwrite) UInt8 direction;

/**
 页面序号 0为请求长度 1-n为请求对应页内容 0xffff询问是否支持;
 */
@property (nonatomic, readwrite) int page;

/**
 状态标志 内容
 */
@property (nonatomic, readwrite) NSData* data;

/**
 当page为0xffff才有效

 */
@property (nonatomic, copy) NSString *supportStr;


/**
 当page为0xffff才有效
 */
@property (nonatomic)         BOOL isSupport;

/**
 当page为0才有效,否则返回-1；
 */
@property (nonatomic)         NSInteger count;



/**
 快捷初始化

 @param direction direction
 @param page page
 @param dataType dataType
 @return ZYBlOtherCustomFileData 实例
 */
+ (instancetype)dataWithPage:(int)page direction:(int)direction dataType:(ZYBlOtherCustomFileDataFormat)dataType;



/**
 发送文件数据时用

 @param page 页码
 @param data 数据
 */
+ (instancetype)dataForSendWithPage:(int)page data:(NSData *)data;


/**
 发送数据前，先发送待发送数据长度

 @param lengthValue 待发送数据长度
 */
+ (instancetype)dataForSendLengthInfo:(NSUInteger)lengthValue;

@end
