//
//  ZYBlCheckActiveInfoData.h
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZYBlCheckActiveInfoData : ZYBlData

/**
 状态标志 0 未激活  0x01 激活 0x02 过期
 */
@property (nonatomic, readonly) NSUInteger activeStatue;

@property (nonatomic, readonly) NSData    *activedata;

@property (nonatomic, readwrite) NSData   *activedataDecode;

@end

NS_ASSUME_NONNULL_END
