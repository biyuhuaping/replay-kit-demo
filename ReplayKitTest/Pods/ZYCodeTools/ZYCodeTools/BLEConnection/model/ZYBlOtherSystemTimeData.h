//
//  ZYBlOtherSystemTimeData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/7/13.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

@interface ZYBlOtherSystemTimeData : ZYBlData

/**
 状态标志 1为异步
 */
@property (nonatomic, readonly) NSUInteger status;

/**
 状态标志 秒
 */
@property (nonatomic, readwrite) NSUInteger sec;

/**
 状态标志 微妙
 */
@property (nonatomic, readwrite) NSUInteger usec;

@end
