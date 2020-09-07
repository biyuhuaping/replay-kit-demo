//
//  ZYBlCCSGetAvailableConfigData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/7/13.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

@interface CCSConfigItem : NSObject
/**
 参数项编号
 */
@property (nonatomic, readwrite) NSUInteger idx;
/**
 可用参数列表
 */
@property (nonatomic, readwrite) NSArray<NSString*>* itemLists;

@end


@interface ZYBlCCSGetAvailableConfigData : ZYBlData
/**
 状态
 */
@property (nonatomic, readonly) NSUInteger cmdStatus;
/**
 参数项编号
 */
@property (nonatomic, readwrite) NSUInteger idx;
/**
 可用参数列表
 */
@property (nonatomic, readonly, strong) NSArray<CCSConfigItem*>* configs;
@end
