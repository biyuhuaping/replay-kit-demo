//
//  ZYUsbInstructionHeartBeatData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYUsbData.h"

@interface ZYUsbInstructionHeartBeatData : ZYUsbData

/**
 动作
 */
@property (nonatomic, readwrite) NSUInteger flag;

/**
 秒数
 */
@property (nonatomic, readwrite) NSUInteger sec;

/**
 微妙数
 */
@property (nonatomic, readwrite) NSUInteger usec;

@end
