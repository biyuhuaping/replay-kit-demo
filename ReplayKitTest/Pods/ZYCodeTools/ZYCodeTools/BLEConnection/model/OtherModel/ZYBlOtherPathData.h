//
//  ZYBlOtherPathData.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/4/22.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZYBlOtherPathData : ZYBlData
/**
 flag(1字节) 0:查询 1:设置
 */
@property (nonatomic) uint8 flag;

/**
 state(1字节)
 | state | 状态 |
 
 | :--------:|:-----------------------------|
 | 0x00 | 未执行 |
 | 0x01 | 准备中 |
 | 0x02 | 可执行 |
 | 0x03 | 执行中 |
 | 0x04 | 结束中 |
 | 0x10 | 请求执行 |
 | 0x11 | 请求取消 |
 */
@property (nonatomic) uint8 state;

@end

NS_ASSUME_NONNULL_END
