//
//  ZYDeviceStabilizer+KeyFunc.h
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/24.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#import "ZYDeviceStabilizer.h"
#import "ZYKeyFuncModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZYDeviceStabilizer (KeyFunc)

/// 读取设备的按键信息
/// @param keyType 按键类型，默认为独立按键
/// @param keyGroup 键组
/// @param keyEvent 按键的事件
/// @param keyValue 按键值
/// @param completionHandler 回调，keyFuns为支持的自定义类型
-(void)readKeyFunWithKeyType:(ZYkeyType)keyType keyGroup:(ZYkeyGroup)keyGroup keyEvent:(ZYkeyEvent)keyEvent keyValue:(uint8_t)keyValue completionHandler:(void(^)(BOOL success,ZYkeyFunc curruntkeyFun,NSArray *keyFuns))completionHandler;

/// 读取设备的按键信息
/// @param funcModel 按键的模型
/// @param completionHandler 回调，keyFuns为支持的自定义类型
-(void)readKeyFunWithKeyKeyFuncModel:(ZYKeyFuncModel *)funcModel completionHandler:(void(^)(BOOL success,ZYkeyFunc curruntkeyFun,NSArray *keyFuns))completionHandler;

/// 设置自定义设备的按键信息
/// @param funcModel 按键的模型
/// @param completionHandler 回调，keyFuns为支持的自定义类型
-(void)setKeyFunWithKeyKeyFuncModel:(ZYKeyFuncModel *)funcModel keyFunc:(ZYkeyFunc)keyFun completionHandler:(void(^)(BOOL success))completionHandler;

/// 设置自定义设备的按键信息
/// @param keyType 按键类型，默认为独立按键
/// @param keyGroup 键组
/// @param keyEvent 按键的事件
/// @param keyValue 按键值
/// @param keyFun keyFun
/// @param completionHandler 回调，keyFuns为支持的自定义类型
-(void)setKeyFunWithKeyType:(ZYkeyType)keyType keyGroup:(ZYkeyGroup)keyGroup keyEvent:(ZYkeyEvent)keyEvent keyValue:(uint8_t)keyValue keyFunc:(ZYkeyFunc)keyFun completionHandler:(void(^)(BOOL success))completionHandler;
@end

NS_ASSUME_NONNULL_END
