//
//  ZYBlOtherDeviceInfoData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/7/13.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

@interface ZYBlOtherDeviceInfoData : ZYBlData

/**
 本机信息
 */
@property (nonatomic, readwrite, copy) NSString* localInfo;

/**
 状态标志 0为可用 1为占用
 */
@property (nonatomic, readonly) NSUInteger flag;

/**
 信息内容 从稳定器返回的信息
 */
@property (nonatomic, readonly, copy) NSString* remoteInfo;

@end
