//
//  ZYBlWiFiPhotoInfoData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

@interface ZYBlWiFiPhotoInfoData : ZYBlData

/**
 <#Description#>参数编号 查询相机信息中的infoId
 */
@property (nonatomic, readwrite) NSUInteger infoId;

/**
 <#Description#>参数内容 查询相机信息中的中的para
 */
@property (nonatomic, readonly, copy) NSString* infoString;

@end
