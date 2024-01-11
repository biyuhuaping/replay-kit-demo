//
//  ZYConnectedDataBase.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/11/1.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZYConnectedData : NSObject

@property (nonatomic, assign) int ID;//模型的ID
@property (nonatomic, assign) int refID;//设备的序列号比如0x0600为图传盒子
@property (nonatomic, copy) NSString *softVersion;//软件版本
@property (nonatomic, copy) NSString *deviceName;//连接过的设备名字
@property (nonatomic, assign) NSData *moduleMessage;//模块信息
@property (nonatomic, strong) NSDate *creatDate;//创建的日期
@property (nonatomic, strong) NSDate *updateDataDate;//更新的日期
@property (nonatomic, strong,readonly) NSMutableDictionary *moduleMessageDic;//模块信息


/// 设备的系列名字
-(NSString *)modelNumberString;
/// 初始化对象
/// @param refID 设备的序列号比如0x0600为图传盒子
/// @param softVersion 软件版本
/// @param deviceName 连接过的设备名字
/// @param modulMessage 模块信息
+(instancetype)connectedDataWithrefID:(NSUInteger)refID softVersion:(NSString *)softVersion deviceName:(NSString *)deviceName moduleMessage:(NSDictionary *)modulMessage;
@end


@interface ZYConnectedDataBase : NSObject

+(instancetype)sharedDataBase;

/// 添加设备
/// @param refID 设备的序列号比如0x0600为图传盒子
/// @param softVersion 软件版本
/// @param deviceName 连接过的设备名字
/// @param modulMessage 模块信息
- (BOOL)addConnectedDataWithrefID:(NSUInteger)refID softVersion:(NSString *)softVersion deviceName:(NSString *)deviceName moduleMessage:(NSDictionary *)modulMessage;
/**
 *  添加mediaModel
 *
 */
- (BOOL)addConnectedData:(ZYConnectedData *)ConnectedData;

/**
 *  删除mediaModel
 *
 */
- (BOOL)deleteConnectedData:(ZYConnectedData *)ConnectedData;
/**
 *  更新mediaModel
 *
 */
- (void)updateConnectedData:(ZYConnectedData *)ConnectedData;

/**
 *  获取所有数据
 *
 */
- (NSMutableArray *)getAllConnectedDatas;

/// 获取某一个版本的信息
/// @param refId refID
-(NSMutableArray *)getConnectedDataWithRefID:(NSUInteger)refId;
/// 通过名字获取对象
/// @param deviceName deviceName
-(ZYConnectedData *)getConnectedDataWithDeviceName:(NSString *)deviceName;

/// 获取最新的连接的设备
/// @param limit 限制
-(NSMutableArray *)selectLastConnectedDataWithLimitCount:(NSUInteger)limit;

/// 获取连接了的d最后一个
/// @param refId refID
-(ZYConnectedData *)selectLastConnectedDataWithRefID:(NSUInteger)refId;
@end

NS_ASSUME_NONNULL_END
