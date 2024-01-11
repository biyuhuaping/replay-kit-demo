//
//  ZYBlWiFiPhotoNoticeData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

@interface ZYBlWiFiPhotoNoticeData : ZYBlData

/**
 <#Description#>编号 通知参数变更中的para_num
 */
@property (nonatomic, readonly) NSUInteger paramId;

/**
 <#Description#>值 通知参数变更中的para_value
 */
@property (nonatomic, readonly) NSUInteger paramValue;

@end
