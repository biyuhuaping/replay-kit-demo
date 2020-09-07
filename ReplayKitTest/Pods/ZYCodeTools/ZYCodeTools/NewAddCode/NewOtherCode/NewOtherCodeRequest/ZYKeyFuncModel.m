//
//  ZYKeyFuncModel.m
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/24.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#import "ZYKeyFuncModel.h"
#import "ZYBleProtocol.h"

@implementation ZYKeyFuncModel

///通过值初始化
-(instancetype)initWithKeyInfo:(uint16)keyInfo{
    self = [super init];
    if (self) {
        _keyInfo = keyInfo;
        _keyValue = keyInfo & 0x0f;
        _keyEvent = (keyInfo & 0xf0) >> 4;
        _keyGroup = (keyInfo & 0x0f00) >> 8;
        _keyType = (keyInfo & 0x7000) >> 12;
    }
    return self;
}

///通过值初始化
-(instancetype)initWithKeyType:(ZYkeyType)keyType keyGroup:(ZYkeyGroup)keyGroup keyEvent:(ZYkeyEvent)keyEvent keyValue:(uint8)keyValue{
    self = [super init];
    if (self) {
        _keyValue = keyValue;
        _keyEvent = keyEvent;
        _keyGroup = keyGroup;
        _keyType = keyType;
        _keyInfo = makeKeyTypeGroupParam(_keyType << 12, _keyGroup << 8, _keyEvent << 4, _keyValue);
    }
    return self;
}
@end
