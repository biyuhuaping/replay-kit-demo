//
//  ZYUpgradableInfoModel.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 升级模块链路
 
 - ZYUpgradableChannelBle:  蓝牙
 - ZYUpgradableChannelWiFi: WiFi
 */
typedef NS_ENUM(NSUInteger, ZYUpgradableChannel) {
    ZYUpgradableChannelBle        =   0,
    ZYUpgradableChannelWiFi       =   1,
};

/**
 升级模块链路
 
 - ZYUpgradableChannelBle:  蓝牙
 - ZYUpgradableChannelWiFi: WiFi
 */
typedef NS_ENUM(NSUInteger, ZYUpgradableInfoModelType) {
    ZYUpgradableInfoModelTypeNormal        =   0,
    ZYUpgradableInfoModelTypeExternal      =   1,
};

@interface ZYUpgradableInfoModel : NSObject
//是否需要升级
@property(nonatomic, assign)  BOOL needUpdate;


/// 是外部设备还是内部设备
@property(nonatomic, assign)  ZYUpgradableInfoModelType modelType;

/// 是外部设备ZYUpgradableInfoModelTypeExternal 才有对应的值
@property(nonatomic, readwrite,copy) NSString *modelTypeExternalName;

/**
产品型号
*/
@property(nonatomic, readwrite) NSUInteger modelNumber;

/**
 设备代号 star_ble 6.2
 */
@property(nonatomic, readwrite) NSUInteger deviceId;

/**
 设备版本
 */
@property(nonatomic, readwrite) NSUInteger version;

/**
 设备升级链路
 */
@property(nonatomic, readwrite) ZYUpgradableChannel channel;

/**
 升级包的后缀比如.css .ptz .update .cov
 */
@property(nonatomic, readwrite,copy) NSString *upgrateExtention;

//升级的时候安装包的数据信息
@property(nonatomic, strong)NSData *data;

/// 升级包的地址,一定要更新url才有data
@property(nonatomic, readwrite,copy) NSString *upgratedataURL;


/**
 |dependency   |依赖性              |0      |0表示可选, 1表示必须|
 */
@property(nonatomic, assign)BOOL  dependency;
//更新链路和deviceID
-(void) updateDeviceIdAndChannel:(NSUInteger)value;

//获取设备ID
+(NSUInteger)deviceIDWithValue:(NSUInteger)value;
//更新链路
+(ZYUpgradableChannel)updateChannel:(NSUInteger)value;

/// 通过refIDs初始化
/// @param modelNumber 设备ID比如0x0600图传盒子
-(instancetype)initWithModelNumber:(NSUInteger)modelNumber;

@end
