//
//  ZY_ErrorSaveTools.m
//  fmdb
//
//  Created by zz on 2020/5/27.
//  Copyright © 2020 zz. All rights reserved.
//

#import "ZY_ErrorSaveTools.h"
#import <FMDB.h>

#define ZY_ErrorSaveToolsDir     @"ZY_ErrorSaveTools"
#define ZY_ErrorSaveToolsFileName   @"ZY_ErrorSaveTools.sqlite"

@interface ZY_ErrorSaveToolsData()
@end
@implementation ZY_ErrorSaveToolsData
- (instancetype)initWith:(int)code msg:(NSString *)msg data:(NSData *)d
{
    self = [super init];
    if (!self) return nil;
    self.err_code = code;
    self.err_msg = msg;
    self.data = d;
    
    NSDate *tmp = [NSDate date];
    self.date = [ZY_ErrorSaveTools dateFromDate:tmp];
    self.time = [ZY_ErrorSaveTools timeFromDate:tmp];
    self.time_val = tmp.timeIntervalSince1970;
    return self;
}

- (NSDictionary *)toDic
{
    NSMutableDictionary *dic = [@{} mutableCopy];
    [dic setValue:@(self.err_code) forKey:@"err_code"];
    if (self.err_msg)
        [dic setValue:self.err_msg forKey:@"err_msg"];
    
    if (self.data)
        [dic setValue:self.data forKey:@"err_data"];
    
    return dic;
}
@end

@interface ZY_ErrorSaveTools()
{
    FMDatabaseQueue *queue;
}
@end

static ZY_ErrorSaveTools *obj = nil;
@implementation ZY_ErrorSaveTools
+ (instancetype)sharedInstance
{
    if (!obj)
    {
        @synchronized (self)
        {
            if (!obj)
                obj = [[ZY_ErrorSaveTools alloc] init];
        }
    }
    return obj;
}

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    
    NSString *dir = [self create_dir];
    NSString *file = [dir stringByAppendingFormat:@"/%@", ZY_ErrorSaveToolsFileName];
    queue = [FMDatabaseQueue databaseQueueWithPath:file];
    if (!queue) return nil;
    [queue inDatabase:^(FMDatabase * _Nonnull db)
    {
        [db executeUpdate:@"create table if not exists ZY_ErrorSaveTools(id integer PRIMARY KEY AUTOINCREMENT, date text, time text, time_val double(16, 8), err_code integer, err_msg text, err_data blob)"];
    }];
    
    return self;
}

- (void)save:(ZY_ErrorSaveToolsData *)d
{
    [queue inDatabase:^(FMDatabase * _Nonnull db)
    {
        [db executeUpdate:@"insert into ZY_ErrorSaveTools(date, time, time_val, err_code, err_msg, err_data) values(?, ?, ?, ?, ?, ?)", d.date, d.time, [NSNumber numberWithDouble:d.time_val], [NSNumber numberWithInt:d.err_code], d.err_msg, d.data];
    }];
}

- (void)deleteWithDate:(NSDate *)date
{
    [queue inDatabase:^(FMDatabase * _Nonnull db)
    {
        [db executeUpdate:@"delete from ZY_ErrorSaveTools where date=?", [ZY_ErrorSaveTools dateFromDate:date]];
    }];
}

- (void)deleteBeforeDate:(NSDate *)date
{
    [queue inDatabase:^(FMDatabase * _Nonnull db)
    {
        [db executeUpdate:@"delete from ZY_ErrorSaveTools where time_val<?", [NSNumber numberWithDouble:date.timeIntervalSince1970]];
    }];
}

- (void)deleteBeforeDateWithTimeval:(double)time_val
{
    // 此处浮点数不能精确到等于 因此在当前时间戳上加5us做筛选
    [queue inDatabase:^(FMDatabase * _Nonnull db)
    {
        [db executeUpdate:@"delete from ZY_ErrorSaveTools where time_val<?", [NSNumber numberWithDouble:time_val+0.000005]];
    }];
}

- (NSArray<ZY_ErrorSaveToolsData*> *)lookupWithDate:(NSDate *)date
{
    NSMutableArray *array = [@[] mutableCopy];
    [queue inDatabase:^(FMDatabase * _Nonnull db)
    {
        FMResultSet *result = [db executeQuery:@"select * from ZY_ErrorSaveTools where date=?", [ZY_ErrorSaveTools dateFromDate:date]];
        while(result.next)
        {
            ZY_ErrorSaveToolsData *tmp = [[ZY_ErrorSaveToolsData alloc] init];
            tmp.date = [result stringForColumn:@"date"];
            tmp.time = [result stringForColumn:@"time"];
            tmp.time_val = [result doubleForColumn:@"time_val"];
            tmp.err_code = [result intForColumn:@"err_code"];
            tmp.err_msg = [result stringForColumn:@"err_msg"];
            tmp.data = [result dataForColumn:@"err_data"];
            if (tmp) [array addObject:tmp];
        }
    }];
    
    return array;
}

- (NSArray<ZY_ErrorSaveToolsData *> *)lookupWithCount:(int)count
{
    NSMutableArray *array = [@[] mutableCopy];
    [queue inDatabase:^(FMDatabase * _Nonnull db)
    {
        FMResultSet *result = [db executeQuery:@"select * from ZY_ErrorSaveTools limit ?", [NSNumber numberWithInt:count]];
        while(result.next)
        {
            ZY_ErrorSaveToolsData *tmp = [[ZY_ErrorSaveToolsData alloc] init];
            tmp.date = [result stringForColumn:@"date"];
            tmp.time = [result stringForColumn:@"time"];
            tmp.time_val = [result doubleForColumn:@"time_val"];
            tmp.err_code = [result intForColumn:@"err_code"];
            tmp.err_msg = [result stringForColumn:@"err_msg"];
            tmp.data = [result dataForColumn:@"err_data"];
            
            NSDictionary *dic = [tmp toDic];
            if (tmp) [array addObject:tmp];
        }
    }];
    
    return array;
}

+ (NSString *)dateFromDate:(NSDate *)date
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd";
    
    return [format stringFromDate:date];
}

+ (NSString *)timeFromDate:(NSDate *)date
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"HH:mm:ss";
    
    return [format stringFromDate:date];
}

- (NSString *)create_dir
{
    NSString *dir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingFormat:@"/%@", ZY_ErrorSaveToolsDir];
    BOOL isDir = NO;
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDir];
    if (!(isDir == YES && existed == YES))
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    return dir;
}

@end
