//
//  ZYBlWiFiPhotoInfoData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

@interface ZYBlWiFiPhotoCtrlData : ZYBlData

/**
 标识 相机操作指令中的para_num
 */
@property (nonatomic, readwrite) NSUInteger num;

/**
 标识 相机操作指令中的para_value
 */
@property (nonatomic, readwrite) NSUInteger value;

@end
