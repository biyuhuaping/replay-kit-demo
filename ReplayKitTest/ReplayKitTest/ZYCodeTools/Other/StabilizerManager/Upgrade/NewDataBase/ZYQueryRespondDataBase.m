//
//  ZYQueryRespondDataBase.m
//  ZYCamera
//
//  Created by Liao GJ on 2019/11/1.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYQueryRespondDataBase.h"
#import <FMDB.h>
#import "ZYUpgradeDirectTools.h"
#import "ZYBleDeviceDataModel.h"

#define RespondDataBaseName  @"ZYQueryRespondDataBase.sqlite"

@interface ZYQueryRespondData()
@property (nonatomic, strong,readwrite) NSDictionary *respondsDic;//后台的回掉的数据解析

@end


@implementation ZYQueryRespondData


- (instancetype)init
{
    self = [super init];
    if (self) {
        _creatDate = [NSDate date];
        _updateDataDate = _creatDate;
    }
    return self;
}

+(instancetype)queryRespondDataWithrefID:(NSUInteger)refID softVersion:(NSString *)softVersion responds:(NSDictionary *)responds{
    NSString *modelNumberString = [ZYBleDeviceDataModel translateToModelNumber:refID];
#pragma -mark接收机不需要这个判断
//    if ([modelNumberString isEqualToString:modelNumberUnknown]) {
//        return nil;
//    }
    if (refID == 0) {
        return nil;
    }
    if (softVersion == nil || softVersion.length == 0) {
        return nil;
    }
    
    NSData *data = nil;
    if ([responds isKindOfClass:[NSDictionary class]]) {
        NSError *error;
        data= [NSJSONSerialization dataWithJSONObject:responds options:NSJSONWritingPrettyPrinted error:&error];
        if (error) {
            NSLog(@"modulMessage 字典错误 ");
            return nil;
        }
    }
    else{
        data = [NSData data];
    }
    
    ZYQueryRespondData *connectecedData = [[ZYQueryRespondData alloc] init];
    connectecedData.softVersion = softVersion;
    connectecedData.refID = (int)refID;
    connectecedData.responds = data;
    connectecedData.respondsDic = responds;
    return connectecedData;
}

/// 需要升级
/// @param respondsDic 字典
+(BOOL)needUpdate:(NSDictionary *)respondsDic{
    if ([respondsDic isKindOfClass:[NSDictionary class]]) {
        NSArray *arrTemp =  [respondsDic objectForKey:@"firmwares"] ;
        if ([arrTemp.firstObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *innerDic = arrTemp.firstObject;
            if ([[innerDic objectForKey:@"needUpdate"] intValue] || [[innerDic objectForKey:@"forceUpdate"] intValue]) {
                return YES;
            }
        }
    }
    return NO;
}


-(BOOL)needUpdate{
    return [[self class] needUpdate:self.respondsDic];
}

-(NSString *)description{
    
    return [NSString stringWithFormat:@"id = %d refId = %d _softVersion = %@ _creatDate=%@ _updateDataDate=%@ _respondsDic = %@",_ID,_refID,_softVersion,_creatDate,_updateDataDate,_respondsDic];
}
@end

static ZYQueryRespondDataBase *_DBCtl = nil;
@interface ZYQueryRespondDataBase()<NSCopying,NSMutableCopying>

@property (nonatomic, strong) FMDatabaseQueue *dbqueue;

@end
@implementation ZYQueryRespondDataBase

+(instancetype)sharedDataBase{
    
    if (_DBCtl == nil) {
        
        _DBCtl = [[ZYQueryRespondDataBase alloc] init];
        
        [_DBCtl initDataBase];
        
    }
    
    return _DBCtl;
    
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    
    if (_DBCtl == nil) {
        
        _DBCtl = [super allocWithZone:zone];
        
    }
    
    return _DBCtl;
    
}

-(id)copy{
    
    return self;
    
}

-(id)mutableCopy{
    
    return self;
    
}

-(id)copyWithZone:(NSZone *)zone{
    
    return self;
    
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    
    return self;
    
}


-(void)initDataBase{
    
    
    // 文件路径
    
    NSString *filePath = [[ZYUpgradeDirectTools ZYUpgradeDirectBasePath] stringByAppendingPathComponent:RespondDataBaseName];
    
    // 实例化FMDataBase对象
    
    
    //    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    //#ifdef DEBUG
    //
    //        NSLog(@"%@存在",RespondDataBaseName);
    //#endif
    //        return;
    //    }
    _dbqueue= [FMDatabaseQueue databaseQueueWithPath:filePath];
    
    [_dbqueue inDatabase:^(FMDatabase *db) {
        // 创表
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS ZYQueryRespondDataBase (id integer PRIMARY KEY AUTOINCREMENT,'ZYQueryRespondData_refID' INTEGER,'ZYQueryRespondData_creatDate' TEXT,'ZYQueryRespondData_updateDataDate' TEXT,'ZYQueryRespondData_softVersion' VARCHAR,'ZYQueryRespondData_responds' VARCHAR)"];
        if (result) {
            NSLog(@"==创建成功");
            
        }else {
            NSLog(@"==创建失败");
        }
    }];
    
}

-(BOOL)addQueryRespondDataWithrefID:(NSUInteger)refID softVersion:(NSString *)softVersion responds:(NSDictionary *)responds{
    ZYQueryRespondData *connectData = [ZYQueryRespondData queryRespondDataWithrefID:refID softVersion:softVersion responds:responds];
    if (connectData) {
        return [self addQueryRespondData:connectData];
    }
    else{
        NSLog(@"连接的设备添加到连接列表失败");
        return NO;
    }
}

-(BOOL)addQueryRespondData:(ZYQueryRespondData *)queryRespondData{
    
    
    
    ZYQueryRespondData *temp = [self getQueryRespondDataWithRefId:queryRespondData.refID softVersion:queryRespondData.softVersion];
    if (temp) {
        [self updateQueryRespondData:queryRespondData];
    }
    else{
        [_dbqueue inDatabase:^(FMDatabase * _Nonnull db) {
            BOOL result = [db executeUpdate:@"INSERT INTO ZYQueryRespondDataBase(ZYQueryRespondData_refID,ZYQueryRespondData_creatDate,ZYQueryRespondData_updateDataDate,ZYQueryRespondData_softVersion,ZYQueryRespondData_responds)VALUES(?,?,?,?,?)",@(queryRespondData.refID),queryRespondData.creatDate,queryRespondData.updateDataDate,queryRespondData.softVersion,queryRespondData.responds];
            NSLog(@"respond ==== ============ %d",result);
        }];
    }
    return YES;
    
    
    
    //    [_dbqueue inDatabase:^(FMDatabase * _Nonnull db) {
    //        [db executeUpdate:@"INSERT INTO ZYQueryRespondData(ZYQueryRespondData_refID,ZYQueryRespondData_creatDate,ZYQueryRespondData_updateDataDate,ZYQueryRespondData_softVersion,ZYQueryRespondData_responds)VALUES(?,?,?,?,?)",queryRespondData.refID,queryRespondData.creatDate,queryRespondData.updateDataDate,queryRespondData.softVersion,queryRespondData.responds];
    //    }];
    //    return YES;
}

- (BOOL)deleteQueryRespondData:(ZYQueryRespondData *)queryRespondData{
    if (queryRespondData == nil) {
        return YES;
    }
    [_dbqueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM ZYQueryRespondDataBase WHERE ZYQueryRespondData_refID = ?", @(queryRespondData.refID)];
        
    }];
    return YES;
    
}

-(void)updateQueryRespondData:(ZYQueryRespondData *)queryRespondData{
    
    if (queryRespondData == nil) {
        return;
    }
    [_dbqueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        [db executeUpdate:@"UPDATE 'ZYQueryRespondDataBase' SET  ZYQueryRespondData_updateDataDate = ?, ZYQueryRespondData_responds = ?  WHERE ZYQueryRespondData_refID = ? AND ZYQueryRespondData_softVersion = ?",[NSDate date],queryRespondData.responds,@(queryRespondData.refID),queryRespondData.softVersion];
    }];
    
}

-(ZYQueryRespondData *)getQueryRespondDataWithRefId:(NSUInteger)refId softVersion:(NSString *)softVersion{
    __block NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    [_dbqueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *res = [db executeQuery:@"SELECT * FROM 'ZYQueryRespondDataBase' WHERE ZYQueryRespondData_refID = ? AND ZYQueryRespondData_softVersion = ?",@(refId),softVersion];
        [dataArray addObjectsFromArray:[self p_convertDataByResultSet:res]];
        
    }];    
    if (dataArray.count > 0) {
        if (dataArray.count > 1) {
            NSLog(@"存的数据太多，不对了========================");
        }
        return dataArray.firstObject;
    }
    else{
        return nil;
    }
}

-(NSMutableArray *)getAllQueryRespondData{
    __block NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    [_dbqueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *res = [db executeQuery:@"SELECT * FROM 'ZYQueryRespondDataBase'"];
        [dataArray addObjectsFromArray:[self p_convertDataByResultSet:res]];
        
    }];
    
    return dataArray;
}

-(NSMutableArray *)p_convertDataByResultSet:(FMResultSet *)res{
    __block NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    while ([res next]) {
        ZYQueryRespondData *model = [[ZYQueryRespondData alloc] init];
        model.ID = [res intForColumn:@"id"] ;
        model.refID = [res intForColumn:@"ZYQueryRespondData_refID"] ;
        model.softVersion = [res stringForColumn:@"ZYQueryRespondData_softVersion"] ;
        model.responds = [res dataForColumn:@"ZYQueryRespondData_responds"] ;
        model.creatDate = [res dateForColumn:@"ZYQueryRespondData_creatDate"] ;
        model.updateDataDate = [res dateForColumn:@"ZYQueryRespondData_updateDataDate"] ;
        if (model.responds) {
            model.respondsDic = [NSJSONSerialization JSONObjectWithData:model.responds options:NSJSONReadingMutableContainers error:nil];
        }
        [dataArray addObject:model];
    }
    return dataArray;
}


@end
