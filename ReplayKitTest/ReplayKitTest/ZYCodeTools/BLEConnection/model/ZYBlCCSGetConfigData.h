//
//  ZYBlCCSGetConfigData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/7/13.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"
@class CCSConfigItem;

@interface ZYBlCCSGetConfigData : ZYBlData

/**
 参数项编号
 */
@property (nonatomic, readwrite) NSUInteger idx;

/**
 可用参数
 */
@property (nonatomic, readonly, strong) NSString* value;

/**
 参数项编号
 */
@property (nonatomic, readonly) NSUInteger cmdStatus;

/**
 可用参数列表
 */
@property (nonatomic, readonly, strong) NSArray<CCSConfigItem*>* configs;

@end
