//
//  ZYConnectedDeviceInfoDataBase.h
//  ZYCodeTools
//
//  Created by Liao GJ on 2020/5/21.
//  Copyright © 2020 ZHIYUN. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface ZYConnectedDeviceInfo : NSObject

@property (nonatomic, assign) int ID;//模型的ID
@property(nonatomic, copy)NSString *phoneid;//手机ID
@property (nonatomic, strong) NSDate *btsDate;//创建的日期
@property (nonatomic, strong) NSDate *etsDate;//更新的日期


@property (nonatomic, assign) int refID;//设备的序列号比如0x0600为图传盒子对应的解析为model
@property(nonatomic, copy)NSString *deviceid;//设备的deviceName 名字
@property(nonatomic, copy)NSString *serial_num;//产品序列号
@property(nonatomic, copy)NSString *camera;//相机名字

@property(nonatomic, copy)NSString *userid;//用户id
@property(nonatomic, copy)NSString *longitude;//经度
@property(nonatomic, copy)NSString *latitude;//纬度


@property(nonatomic, copy)NSString *bts;//使用开始的时间字符串 格式为2018-02-07 02:31:50
@property(nonatomic, copy)NSString *ets;//使用结束的时间字符串 格式为2018-02-07 02:39:50
@property(nonatomic, copy)NSString *model;//modelNumberString;

/// 创建对象
/// @param dic 包含 userid 用户id longitude 经度 latitude 纬度
/// @param refID 产品类型 比如0x0600
/// @param deviceid 设备的deviceName 名字
+(instancetype)deviceInfoWithUserDic:(NSDictionary *)dic refID:(NSUInteger)refID deviceName:(NSString *)deviceid;


@end

@interface ZYConnectedDeviceInfoDataBase : NSObject
+(instancetype)sharedDataBase;

/// 直接添加对象
/// @param dic 包含 userid 用户id longitude 经度 latitude 纬度
/// @param refID 产品类型 比如0x0600
/// @param deviceid 设备的deviceName 名字
- (ZYConnectedDeviceInfo *)addDeviceInfoWithUserDic:(NSDictionary *)dic refID:(NSUInteger)refID deviceName:(NSString *)deviceid;

/**
 *  删除mediaModel
 *
 */
- (BOOL)deleteConnectedDeviceInfo:(ZYConnectedDeviceInfo *)connectedData;

/**
 *  更新mediaModel
 *
 */
- (void)updateConnectedDeviceInfo:(ZYConnectedDeviceInfo *)connectedData;

/// 删除所有
- (BOOL)deleteAllConnectedDeviceInfos;

/**
 *  获取所有数据
 *
 */

/// 获取所有数据同时转换为字典存在数组里面
/// @param toDic 是否转换为字典
- (NSMutableArray *)getAllConnectedDeviceInfosToDicValue:(BOOL)toDic;

/// 获取最多count个
/// @param toDic 是否转换为字典
/// @param count 数量限制
-(NSMutableArray *)getConnectedDeviceInfosToDicValue:(BOOL)toDic withCount:(NSUInteger)count;


/// 转换为字典
/// @param array 字典数据
+(NSMutableArray *)toDictionArrayWithModelArray:(NSArray <ZYConnectedDeviceInfo *>*)array;

/// 删除某个日期一下的数据
/// @param date 删除某个日期一下的数据
- (BOOL)deleteConnectedDeviceInfosBefore:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
