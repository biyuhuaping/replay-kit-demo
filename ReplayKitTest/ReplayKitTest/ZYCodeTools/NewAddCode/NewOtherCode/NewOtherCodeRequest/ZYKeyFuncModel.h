//
//  ZYKeyFuncModel.h
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/24.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "common_def.h"

typedef NS_ENUM(NSInteger,ZYkeyType) {
    ZYkeyTypeSingle = 0,
    ZYkeyTypeEncode = 1,
    ZYkeyTypePressure = 2,
};

typedef NS_ENUM(NSInteger,ZYkeyGroup) {
    ZYkeyGroup0 = 0,
    ZYkeyGroup1 = 1,
    ZYkeyGroup2 = 2,
    ZYkeyGroup3 = 3,
    ZYkeyGroup4 = 4,
};

typedef NS_ENUM(NSInteger,ZYkeyEvent) {
    ZYkeyEventNone = 0,
    ZYkeyEventPress,
    ZYkeyEventRelease,
    ZYkeyEventClick,
    ZYkeyEventPress1S,
    ZYkeyEventPress3S,
    ZYkeyEventDoubleClick,
    ZYkeyEventTripleClick,

};
typedef NS_ENUM(NSInteger,ZYkeyFunc) {
    ZYkeyFunc_NONE = 0,//无功能
    ZYkeyFunc_DEFAULT, //默认出厂功能
    ZYkeyFunc_GCUMOD_PRE,//切换上一个云台模式
    KEY_FUNC_GCUMOD_NEXT,//切换下一个云台模式
    ZYkeyFunc_GCUMOD_PF,//切换PF云台模式
    ZYkeyFunc_GCUMOD_L,//切换L云台模式
    ZYkeyFunc_GCUMOD_F,//切换F云台模式
    ZYkeyFunc_GCUMOD_POV,//切换POV云台模式
    ZYkeyFunc_GCUMOD_GO,//切换GO云台模式
    ZYkeyFunc_GCUMOD_V,//切换V云台模式
    ZYkeyFunc_SLEEP_AWAKE,//休眠/唤醒
    ZYkeyFunc_HVSWITCH,//横竖拍切换
    ZYkeyFunc_SLEEP,//休眠
    ZYkeyFunc_AWAKE,//唤醒
    ZYkeyFunc_APP_PHOTOVIDEO = 0xB0,//APP切换拍照/摄像
    ZYkeyFunc_APP_CUSTOMMENU,//呼出自定义菜单

};

NS_ASSUME_NONNULL_BEGIN

@interface ZYKeyFuncModel : NSObject

/// 键值
@property (nonatomic) uint8 keyValue;
/// 按键的事件
@property (nonatomic) ZYkeyEvent keyEvent;
/// 键组
@property (nonatomic) ZYkeyGroup keyGroup;
/// 按键类型
@property (nonatomic) ZYkeyType keyType;
///封装之后的值
@property (nonatomic) uint16 keyInfo;
///通过值初始化
-(instancetype)initWithKeyInfo:(uint16)keyInfo;

///通过值初始化
-(instancetype)initWithKeyType:(ZYkeyType)keyType keyGroup:(ZYkeyGroup)keyGroup keyEvent:(ZYkeyEvent)keyEvent keyValue:(uint8)keyValue;
@end

NS_ASSUME_NONNULL_END
