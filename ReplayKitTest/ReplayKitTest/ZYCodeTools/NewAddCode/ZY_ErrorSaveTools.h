//
//  ZY_ErrorSaveTools.h
//  fmdb
//
//  Created by zz on 2020/5/27.
//  Copyright © 2020 zz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZY_ErrorSaveToolsData : NSObject
// 错误码
@property (nonatomic, assign) int err_code;
// 错误字符串
@property (nonatomic, strong) NSString *err_msg;
// 日期
@property (nonatomic, strong) NSString *date;
// 时间
@property (nonatomic, strong) NSString *time;
// 时间戳 以1970为标准
@property (nonatomic, assign) double time_val;
// 二进制数据
@property (nonatomic, strong) NSData *data;

// 构造保存至数据库的对象
- (instancetype)initWith:(int)code msg:(NSString *)msg data:(NSData *)d;

// 对象转换为字典
- (NSDictionary *)toDic;
@end

@interface ZY_ErrorSaveTools : NSObject
+ (instancetype)sharedInstance;
// 保存数据
- (void)save:(ZY_ErrorSaveToolsData *)d;

// 按日期删除数据
- (void)deleteWithDate:(NSDate *)date;

// 删除某日期之前的所有数据
- (void)deleteBeforeDate:(NSDate *)date;

// 删除某日期之前的所有数据(以时间戳为准)
- (void)deleteBeforeDateWithTimeval:(double)time_val;

// 查询数据根据日期
- (NSArray<ZY_ErrorSaveToolsData*> *)lookupWithDate:(NSDate *)date;

// 查询数据根据个数
- (NSArray<ZY_ErrorSaveToolsData*> *)lookupWithCount:(int)count;

// 返回日期 格式为 yyyy-MM-dd
+ (NSString *)dateFromDate:(NSDate *)date;

// 返回时间 格式为 HH:mm:ss
+ (NSString *)timeFromDate:(NSDate *)date;
@end

NS_ASSUME_NONNULL_END
