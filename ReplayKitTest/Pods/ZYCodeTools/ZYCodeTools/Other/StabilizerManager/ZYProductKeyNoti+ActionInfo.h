//
//  ZYProductKeyNoti+ActionInfo.h
//  ZYCamera
//
//  Created by iOS on 2019/4/23.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYProductKeyNoti.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZYProductKeyNoti (ActionInfo)

// 筛选符合 originValue 的指令集合
+ (NSArray *)filterActionArray:(NSUInteger)originValue sourceArray:(NSArray <ZYKeysAction *>*)sourceArray;

+ (NSArray <ZYKeysAction *>*)groupZeroActionInfo;

+ (NSArray <ZYKeysAction *>*)group2ndActionInfo;

+ (NSArray <ZYKeysAction *>*)group4ThActionInfo;

+ (NSArray <ZYKeysAction *>*)allKeysActionInfo;

@end

NS_ASSUME_NONNULL_END
