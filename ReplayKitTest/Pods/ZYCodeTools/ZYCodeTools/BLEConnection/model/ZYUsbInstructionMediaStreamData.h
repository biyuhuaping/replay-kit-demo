//
//  ZYUsbInstructionBlData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYUsbData.h"
#import "ZYBlData.h"

@interface ZYUsbInstructionMediaStreamData : ZYUsbData

/**
 实时图传状态
 */
@property (nonatomic, readonly) NSUInteger cmdStatus;

/**
 是否开启
 */
@property (nonatomic, readwrite) NSUInteger flag;

@end
