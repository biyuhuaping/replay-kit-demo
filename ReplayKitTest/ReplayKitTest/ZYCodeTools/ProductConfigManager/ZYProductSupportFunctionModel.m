//
//  ZYProductSupportFunctionModel.m
//  ZYCamera
//
//  Created by Liao GJ on 2019/8/30.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYProductSupportFunctionModel.h"
#include "active.h"

@interface ZYProductSupportFunctionModel()

@property (nonatomic,readwrite)          float       precisionPitch;
@property (nonatomic,readwrite)          float       precisionRoll;
@property (nonatomic,readwrite)          float       precisionYaw;
@end


@implementation ZYProductSupportFunctionModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        _battery = 1;
        _bleMtu = 20;
        _ccs = NO;
        _update = UpdateTypeNoSupport;
        _motionControl = NO;
        _photo = NO;
        _video = NO;
        _digitalZoom = NO;
        _moveline = MovelineTypeNoSupport;
        _jsonData = NO;
        _links = LinkTypeBleNormal;
        _carry = NO;
        _ble_hid = Ble_hidTypeNoSupport;
        _tracking = NO;
        _oem = NO;
        _autotune = NO;
        _wifichannel = NO;
        _wifimodel = NO;
        _bhTest = NO;
        _calibration = NO;
        _gimbalMode = @[@0,@1,@2];
        _resetPosition = NO;
        _cameraList = @[@0,@1,@2,@3];
        _activate = ActivateTypeNoSupport;
        _activateAESkey = nil;
        _identifier = @"0905";
        _storymode = NO;
        _movelimit = @[];
        _keyredefine = @[];
        _motorStrength = @[@0,@1,@2];
        _motorStrengthCustom = @[@[@0,@0],@[@0,@0],@[@0,@0]];
        _motorStrengthAdjustNotify = NO;
        _hvswitch = 0;
        _joystickspeed = @[@-1];
        _usrscene = @[];
        _forceversion = -1;
        _preset = @[];
        _presetlimit = @[@[@[@0,@120],@[@0,@100],@[@0,@200],@[@0,@30]],
                         @[@[@0,@120],@[@0,@100],@[@0,@200],@[@0,@30]],
                         @[@[@0,@120],@[@0,@100],@[@0,@200],@[@0,@30]]];
        _storyAtrribute = @{};

        _precisionPitch = 0.01;
        _precisionRoll = 0.01;
        _precisionYaw = 0.01;
        
    }
    return self;
}
-(ZYProductSupportFunctionModel *)p_copy{
    ZYProductSupportFunctionModel *model = [[ZYProductSupportFunctionModel alloc] init];
    model.battery = _battery;
    model.bleMtu = _bleMtu;
    model.ccs = _ccs;
    model.update = _update;
    model.motionControl = _motionControl;
    model.photo = _photo;
    model.video = _video;
    model.digitalZoom = _digitalZoom;
    model.moveline = _moveline;
    model.jsonData = _jsonData;
    model.links = _links;
    model.carry = _carry;
    model.ble_hid = _ble_hid;
    model.productIdNumber = _productIdNumber;
    model.tracking = _tracking;
    model.oem = _oem;
    model.autotune = _autotune;
    model.wifichannel = _wifichannel;
    model.wifimodel = _wifimodel;
    model.bhTest = _bhTest;
    model.calibration = _calibration;
    model.gimbalMode = _gimbalMode;
    model.resetPosition = _resetPosition;
    model.cameraList = _cameraList;
    model.activate = _activate;
    model.activateAESkey = _activateAESkey;
    model.identifier = _identifier;
    model.storymode = _storymode;
    model.movelimit = _movelimit;
    model.keyredefine = _keyredefine;
    model.motorStrength = _motorStrength;
    model.motorStrengthCustom = _motorStrengthCustom;
    model.motorStrengthAdjustNotify = _motorStrengthAdjustNotify;
    model.hvswitch = _hvswitch;
    model.joystickspeed = _joystickspeed;
    model.usrscene = _usrscene;
    model.forceversion = _forceversion;
    model.preset = _preset;
    model.presetlimit = _presetlimit;
    model.storyAtrribute = _storyAtrribute;
    return model;
}

-(NSArray *)presetMove{
    if (_preset.count >= 2) {
        return _preset[1];
        
    }
    else{
        return @[@[@120,@100,@200,@2.0],@[@120,@100,@200,@5.0],@[@120,@100,@200,@5.0]];
    }
}

-(NSArray *)presetWalk{
    if (_preset.count >= 1) {
        return _preset[0];
        
    }
    else{
        return @[@[@80,@25,@100,@2.0],@[@80,@25,@100,@5.0],@[@80,@45,@100,@5.0]];
    }
}

-(BOOL)notifySupportPosition{
    if (_storyAtrribute && [_storyAtrribute isKindOfClass:[NSDictionary class]]) {
        id notiObj = [_storyAtrribute objectForKey:@"notify"];
        if ([notiObj isKindOfClass:[NSNumber class]]) {
            NSNumber *number = notiObj;
            return [number boolValue];
        }
    }
    return NO;
}

-(BOOL)durationSupportPosition{
    if (_storyAtrribute && [_storyAtrribute isKindOfClass:[NSDictionary class]]) {
        id notiObj = [_storyAtrribute objectForKey:@"duration"];
        if ([notiObj isKindOfClass:[NSNumber class]]) {
            NSNumber *number = notiObj;
            return [number boolValue];
        }
    }
    return NO;
}

-(NSDictionary *)precision{
    if (_storyAtrribute && [_storyAtrribute isKindOfClass:[NSDictionary class]]) {
          id notiObj = [_storyAtrribute objectForKey:@"precision"];
          if ([notiObj isKindOfClass:[NSDictionary class]]) {
              return notiObj;
          }
      }
      return nil;
}

-(float)precisionPitch{
    NSDictionary *temp = [self precision];
    if (temp) {
        NSArray *arr = [temp objectForKey:@"pitch"];
        if (arr && arr.count > 0) {
            return [arr[0] floatValue];
        }

    }
    return _precisionPitch;
}

-(float)precisionRoll{
    NSDictionary *temp = [self precision];
      if (temp) {
          NSArray *arr = [temp objectForKey:@"roll"];
          if (arr && arr.count > 0) {
              return [arr[0] floatValue];
          }

      }
      return _precisionRoll;
}

-(float)precisionYaw{
    NSDictionary *temp = [self precision];
      if (temp) {
          NSArray *arr = [temp objectForKey:@"yaw"];
          if (arr && arr.count > 0) {
              return [arr[0] floatValue];
          }

      }
      return _precisionYaw;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"电池节数= %lu mtu=%lu 是否支持ccs指令 = %d 固件升级 = %d 体感指令 = %d,拍照指令= %d 录像指令=%d 电子变焦 = %d 离线轨迹拍摄 = %x ,是否传输获取数据配置指令 = %ld 连接的方式 = %d 切换搭载设备类型 = %ld HID设备心跳指令 %d  产品ID=<%x> 跟踪= %d oem = %d autotune = %d wifichannel = %d wifimodel = %d",(unsigned long)_battery,(unsigned long)_bleMtu,_ccs,(long)_update,_motionControl,_photo,_video,_digitalZoom,(long)_moveline,_jsonData,(long)_links,_carry,_ble_hid,_productIdNumber,_tracking,_oem,_autotune,_wifichannel,_wifimodel];
}
+(ZYProductSupportFunctionModel *)functionModelWithDic:(NSDictionary *)dic{
    ZYProductSupportFunctionModel *model = [[ZYProductSupportFunctionModel alloc] init];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        [model setValuesForKeysWithDictionary:dic];
    }
    return model;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
-(void)setNilValueForKey:(NSString *)key{
    NSLog(@"%s",__func__);
    NSLog(@"key = %@",key);
    
}

- (nullable id)valueForUndefinedKey:(NSString *)key{
    NSLog(@"%s",__func__);
    NSLog(@"key = %@",key);
    return [NSNull null];
}

-(id)copy{
    return [self p_copy];
    
}

-(id)mutableCopy{
    return [self p_copy];
}

-(BOOL)supportCameraListSetting{
   if (self.cameraList.count > 0) {
       if (self.cameraList.count == 1 && [self.cameraList.firstObject intValue] == 0) {
           return NO;
       }
       else{
           return YES;
       }
   }
    return NO;
}

-(BOOL)supportKeyRedfineSetting{
   if (self.keyredefine.count > 0) {
        return YES;
   }
    return NO;
}

-(BOOL)needAppForceUpgrade{
    if (_forceversion == -1) {
        return NO;
    }
    return YES;
}

-(BOOL)forceUpgradeWith:(NSString *)softVersion{
    if ([self needAppForceUpgrade]) {
        if ([softVersion intValue] < _forceversion) {
            return YES;
        }
        return NO;
    }
    else{
        return NO;
    }
}

-(NSData *)encodeEncrypt:(NSData *)encrpyData{
    NSData *AESkeyData = self.activateAESkeyData;
    if (AESkeyData == nil) {
        NSLog(@"aesKey为空");
        return nil;
    }
    
    if (self.activateAESkey.length == 32) {
        uint8_t out_buffer[16];
        memset(out_buffer, 0x00, sizeof(out_buffer));
        AES_ECB_encryptWithBuff([encrpyData bytes],[AESkeyData bytes],out_buffer);
        return [NSData dataWithBytes:out_buffer length:16];
    }
    else{
        unsigned char dataEncode[16];
        memset(dataEncode, 0x00, sizeof(dataEncode));
        memcpy(dataEncode, [encrpyData bytes], sizeof(dataEncode));

        active_aes_encryptWithBuff(dataEncode, [AESkeyData bytes]);
        return [NSData dataWithBytes:dataEncode length:16];

    }
    
}

-(NSData *)decodeEncrypt:(NSData *)decrpyData{
    NSData *AESkeyData = self.activateAESkeyData;
    if (AESkeyData == nil) {
        NSLog(@"aesKey为空");
        return nil;
    }
    
    if (self.activateAESkey.length == 32) {
        uint8_t out_buffer[16];
        memset(out_buffer, 0x00, sizeof(out_buffer));
        AES_ECB_decryptWithBuff([decrpyData bytes],[AESkeyData bytes],out_buffer);
        return [NSData dataWithBytes:out_buffer length:16];

    }
    else{
        unsigned char dataDecode[16];
        memset(dataDecode, 0x00, sizeof(dataDecode));
        memcpy(dataDecode, [decrpyData bytes], sizeof(dataDecode));
        
        active_aes_decryptWithBuff(dataDecode, [AESkeyData bytes]);
        return [NSData dataWithBytes:dataDecode length:16];

    }

}


-(NSData *)activateAESkeyData{
    if (self.activateAESkey.length > 0) {
        return [ZYProductSupportFunctionModel convertHexStrToData:self.activateAESkey];
    }
    return nil;
}

// 十六进制转换为普通字符串的。
+(NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i+= 2){
        unsigned int anInt;
        NSString*hexCharStr= [str substringWithRange:range];
        NSScanner*scanner= [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        NSData*entity= [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        range.location+= range.length;
        range.length= 2;
    }
    return hexData;
}
@end
