//
//  ZYQueryRespondDataBase.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/11/1.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZYQueryRespondData : NSObject
@property (nonatomic, assign) int ID;//模型的ID
@property (nonatomic, assign) int refID;//设备的序列号比如0x0600为图传盒子
@property (nonatomic, copy) NSString *softVersion;//软件版本
@property (nonatomic, strong) NSData *responds;//后台的回掉数据
@property (nonatomic, strong) NSDate *creatDate;//创建的日期
@property (nonatomic, strong) NSDate *updateDataDate;//更新的日期
@property (nonatomic, strong,readonly) NSDictionary *respondsDic;//后台的回掉的数据解析

@property (nonatomic,readonly) BOOL needUpdate;//是否需要升级

/// 网络请求回来的数据
/// @param refID refiID
/// @param softVersion 软件版本
/// @param responds 网络请求回来的数据
+(instancetype)queryRespondDataWithrefID:(NSUInteger)refID softVersion:(NSString *)softVersion responds:(NSDictionary *)responds;

/// 需要升级
/// @param respondsDic 字典
+(BOOL)needUpdate:(NSDictionary *)respondsDic;

@end

@interface ZYQueryRespondDataBase : NSObject

/// 添加网络请求回来的数据
/// @param refID refiID
/// @param softVersion 软件版本
/// @param responds 网络请求回来的数据
- (BOOL)addQueryRespondDataWithrefID:(NSUInteger)refID softVersion:(NSString *)softVersion responds:(NSDictionary *)responds;

+(instancetype)sharedDataBase;
#pragma mark - mediaModel
/**
 *  添加mediaModel
 *
 */
- (BOOL)addQueryRespondData:(ZYQueryRespondData *)queryRespondData;

/**
 *  删除mediaModel
 *
 */
- (BOOL)deleteQueryRespondData:(ZYQueryRespondData *)queryRespondData;
/**
 *  更新mediaModel
 *
 */
- (void)updateQueryRespondData:(ZYQueryRespondData *)queryRespondData;

/**
 *  获取所有数据
 *
 */
- (NSMutableArray *)getAllQueryRespondData;

/// 获取某一个版本的信息
/// @param refId refID
/// @param softVersion 软件版本
-(ZYQueryRespondData *)getQueryRespondDataWithRefId:(NSUInteger)refId softVersion:(NSString *)softVersion;

@end

NS_ASSUME_NONNULL_END
