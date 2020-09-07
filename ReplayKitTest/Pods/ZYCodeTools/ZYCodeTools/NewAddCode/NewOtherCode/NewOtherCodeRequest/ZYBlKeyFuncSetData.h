//
//  ZYBlKeyFuncSetData.h
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"




NS_ASSUME_NONNULL_BEGIN

@interface ZYBlKeyFuncSetData : ZYBlData
/**
bit15    bit14-12    bit11-8    bit7-4    bit3-0
bool_keys_flag = 0    key_type    key_group    key_event    key_value
按键类型    按键键组    按键事件    按键值

*/
@property (nonatomic) uint16 keyInfo;

@property (nonatomic) uint8 keyFunc;

@end

NS_ASSUME_NONNULL_END
