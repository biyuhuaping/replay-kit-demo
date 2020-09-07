//
//  ZYBlWiFiPhotoCameraInfoData.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/4/22.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

typedef NS_ENUM(NSInteger, ZYBl_CameraManufactureType) {
    ZYBl_CameraManufactureTypeFail = 0,             // 0:查询过失败了
    ZYBl_CameraManufactureTypeQuerying,             // 1:正在查询
    ZYBl_CameraManufactureTypeSony,                 // 2:索尼
    ZYBl_CameraManufactureTypePanasonic,            // 3:松下
    ZYBl_CameraManufactureTypeCanon,                // 4:佳能
    ZYBl_CameraManufactureTypeGoPro,                // 5:go pro
    ZYBl_CameraManufactureTypeFuji,                 // 6:富士
    ZYBl_CameraManufactureTypeGo_Pro_evo2,          // 7:Go_Pro_evo2
    ZYBl_CameraManufactureTypeSJCAM,                // 8:SJCAM
    ZYBl_CameraManufactureTypeCount,                // 个数
};

NS_ASSUME_NONNULL_BEGIN

@interface ZYBlWiFiPhotoCameraInfoData : ZYBlData
/**
 |flag|        |
 |:-------:|:----:|
 |  0x00 |   获取相机型号 |
 |  0x80 |   设置相机型号 |
 */
@property (nonatomic) uint8 flag;

/**
 
 |data|        |
 |:-------:|:----:|
 |  0x00 |   错误 |
 |  0x01 |   正在查询 |
 |  0x02 |   Sony |
 |  0x03 |   Panasonic  |
 |  0x04 |   Canon |
 |  0x05 |   Go_Pro |
 |  0x06 |   富士 |
 |  0x07 |   Go_Pro_evo2 |
 |  0x08 |   SJCAM |
 */
@property (nonatomic) uint8 value;

// 用于设置相机厂商
+ (instancetype)dataForSetManufacturer:(ZYBl_CameraManufactureType)type;

// 用于获取相机厂商
+ (instancetype)dataForGetManufacturer;

@end

NS_ASSUME_NONNULL_END
