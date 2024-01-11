//
//  ZYBlCCSSetConfigData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/7/13.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

@interface ZYBlCCSSetConfigData : ZYBlData

/**
 参数项编号
 */
@property (nonatomic, readwrite) NSUInteger cmdStatus;

/**
 参数项编号
 */
@property (nonatomic, readwrite) NSUInteger idx;

/**
 参数项设置
 */
@property (nonatomic, readwrite) NSString* value;

@end
