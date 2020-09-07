//
//  ZYBlSendActiveKeyData.h
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"
typedef NS_ENUM(NSInteger,ActiveStatue) {
    ActiveStatueNone = 0,
    ActiveStatueActive,
    ActiveStatueExpire
};

NS_ASSUME_NONNULL_BEGIN

@interface ZYBlSendActiveKeyData : ZYBlData
/**
 数据码
 */
@property (nonatomic, readwrite) NSData* keyData;

/**
 状态标志 0 未激活  0x01 激活 0x02 过期
 */
@property (nonatomic, readonly) NSUInteger activeStatue;
@end

NS_ASSUME_NONNULL_END
