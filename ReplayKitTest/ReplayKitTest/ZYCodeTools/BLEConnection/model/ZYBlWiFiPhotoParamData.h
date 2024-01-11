//
//  ZYBlWiFiPhotoParamData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

@interface ZYBlWiFiPhotoParamData : ZYBlData

/**
 <#Description#>参数编号 查询相机参数中的para_num
 */
@property (nonatomic, readwrite) NSUInteger paramId;

/**
 <#Description#>参数值 查询相机参数中的para_value
 */
@property (nonatomic, readonly) NSUInteger paramValue;

@end
