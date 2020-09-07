//
//  ZYConnectedDeviceInfoDataBase.m
//  ZYCodeTools
//
//  Created by Liao GJ on 2020/5/21.
//  Copyright © 2020 ZHIYUN. All rights reserved.
//

#import "ZYConnectedDeviceInfoDataBase.h"
#import "ZYUpgradeDirectTools.h"
#import <FMDB.h>
#import "ZYBleDeviceDataModel.h"
#import <UIKit/UIKit.h>
#define ZYConnectedDeviceInfoDataName  @"ZYConnectedDeviceInfoDataName.sqlite"

@interface ZYConnectedDeviceInfo()
@property (nonatomic, strong,readwrite) NSMutableDictionary *moduleMessageDic;//模块信息

@end

@implementation ZYConnectedDeviceInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        _btsDate = [NSDate date];
        _etsDate = _btsDate;
        _phoneid = [self getDeviceID];
    }
    return self;
}

-(NSString *)getDeviceID{
    static NSString * uniqueIdentifier = nil;
    if (uniqueIdentifier != nil) {

        return uniqueIdentifier;
    }
    uniqueIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"identifierForVendor"];

    if( !uniqueIdentifier ) {
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
        uniqueIdentifier = [UIDevice currentDevice].identifierForVendor.UUIDString;
#endif
        [[NSUserDefaults standardUserDefaults] setObject:uniqueIdentifier forKey:@"identifierForVendor"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    return uniqueIdentifier;
}

-(NSString *)model{
    return [ZYBleDeviceDataModel translateToModelNumber:_refID];
}

-(NSString *)bts{
    if (self.btsDate) {
        return [self stringValueWithDate:self.btsDate];
    }
    return @"";
}

-(NSString *)ets{
    if (self.etsDate) {
        return [self stringValueWithDate:self.etsDate];
    }
    return @"";
}

//时间字符串
-(NSString *)stringValueWithDate:(NSDate *)date{
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    return [dateFormatter stringFromDate:date];
}
+(instancetype)deviceInfoWithUserDic:(NSDictionary *)dic refID:(NSUInteger)refID deviceName:(NSString *)deviceid
{
    ZYConnectedDeviceInfo *info = [[ZYConnectedDeviceInfo alloc] init];
    
    
    info.userid = [dic objectForKey:@"userid"];
    info.longitude = [dic objectForKey:@"longitude"];
    info.latitude = [dic objectForKey:@"latitude"];
    info.refID = (int)refID;
    info.deviceid = deviceid;
    return info;
}

-(NSDictionary *)toDictionary{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (self.userid != nil) {
        [dic setValue:self.userid forKey:@"userid"];
    }
    if (self.phoneid != nil) {
        [dic setValue:self.phoneid forKey:@"phoneid"];
    }
    if (self.model != nil) {
        [dic setValue:self.model forKey:@"model"];
    }
    if (self.deviceid != nil) {
        [dic setValue:self.deviceid forKey:@"deviceid"];
    }
    if (self.longitude != nil) {
        [dic setValue:self.longitude forKey:@"longitude"];
    }
    if (self.latitude != nil) {
        [dic setValue:self.latitude forKey:@"latitude"];
    }
    if (self.serial_num != nil) {
        [dic setValue:self.serial_num forKey:@"serial_num"];
    }
    if (self.camera != nil) {
        [dic setValue:self.camera forKey:@"camera"];
    }
    if (self.bts != nil) {
        [dic setValue:self.bts forKey:@"bts"];
    }
    if (self.ets != nil) {
        [dic setValue:self.ets forKey:@"ets"];
    }
    return dic;
}


@end

static ZYConnectedDeviceInfoDataBase *_DBCtl = nil;

@interface ZYConnectedDeviceInfoDataBase()
@property (nonatomic, strong) FMDatabaseQueue *dbqueue;

@end

@implementation ZYConnectedDeviceInfoDataBase

+(instancetype)sharedDataBase{
    
    if (_DBCtl == nil) {
        
        _DBCtl = [[ZYConnectedDeviceInfoDataBase alloc] init];
        
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
    
    NSString *filePath = [[ZYUpgradeDirectTools ZYUpgradeDirectBasePath] stringByAppendingPathComponent:ZYConnectedDeviceInfoDataName];


    _dbqueue= [FMDatabaseQueue databaseQueueWithPath:filePath];

    [_dbqueue inDatabase:^(FMDatabase *db) {

        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS ZYConnectedDeviceInfoDataBase (id integer PRIMARY KEY AUTOINCREMENT,'refID' INTEGER,'btsDate' TEXT,'etsDate' TEXT,'phoneid' VARCHAR,'deviceid' VARCHAR,'serial_num' VARCHAR,'camera' VARCHAR,'userid' VARCHAR,'longitude' VARCHAR,'latitude' VARCHAR)"];
        if (result) {
            NSLog(@"创建成功");

        }else {
            NSLog(@"创建失败");
        }
    }];
    
}

- (ZYConnectedDeviceInfo *)addDeviceInfoWithUserDic:(NSDictionary *)dic refID:(NSUInteger)refID deviceName:(NSString *)deviceid{
    ZYConnectedDeviceInfo *connectData = [ZYConnectedDeviceInfo deviceInfoWithUserDic:dic refID:refID deviceName:deviceid];
    if (connectData) {

        BOOL success = [self addConnectedDeviceInfo:connectData];
        return connectData;

    }
    else{
        NSLog(@"连接的设备添加到连接列表失败");
        return nil;
    }
}
/**
 *  添加mediaModel
 *
 */
- (BOOL)addConnectedDeviceInfo:(ZYConnectedDeviceInfo *)connectedData{
    [_dbqueue inDatabase:^(FMDatabase * _Nonnull db) {
          BOOL result = [db executeUpdate:@"INSERT INTO ZYConnectedDeviceInfoDataBase(refID,btsDate,etsDate,phoneid,deviceid,serial_num,camera,userid,longitude,latitude)VALUES(?,?,?,?,?,?,?,?,?,?)",[NSNumber numberWithInt:connectedData.refID],connectedData.btsDate,connectedData.etsDate,connectedData.phoneid,connectedData.deviceid,connectedData.serial_num,connectedData.camera,connectedData.userid,connectedData.longitude,connectedData.latitude];
      }];
      return YES;
}

/**
 *  删除mediaModel
 *
 */
- (BOOL)deleteConnectedDeviceInfo:(ZYConnectedDeviceInfo *)connectedData{
    if (connectedData == nil) {
            
           return NO;
    }
    __block BOOL delete = NO;
    [_dbqueue inDatabase:^(FMDatabase *db) {
        delete = [db executeUpdate:@"DELETE FROM ZYConnectedDeviceInfoDataBase WHERE btsDate = ?", connectedData.btsDate];
       
    }];
    return delete;

}

- (BOOL)deleteAllConnectedDeviceInfos{
    __block BOOL delete = NO;
    [_dbqueue inDatabase:^(FMDatabase *db) {
        delete = [db executeUpdate:@"DELETE FROM ZYConnectedDeviceInfoDataBase"];
       
    }];
    return delete;

}

- (BOOL)deleteConnectedDeviceInfosBefore:(NSDate *)date{
    __block BOOL delete = NO;
    [_dbqueue inDatabase:^(FMDatabase *db) {
//        NSString *string = [NSString stringWithFormat:];
        delete = [db executeUpdate:@"DELETE FROM ZYConnectedDeviceInfoDataBase WHERE btsDate <= ?",date];
       
    }];
    return delete;

}
/**
 *  更新mediaModel
 *
 */
- (void)updateConnectedDeviceInfo:(ZYConnectedDeviceInfo *)connectedData{
    if (connectedData == nil) {
         return;
     }
     [_dbqueue inDatabase:^(FMDatabase * _Nonnull db) {
         [db executeUpdate:@"UPDATE 'ZYConnectedDeviceInfoDataBase' SET  etsDate = ?, serial_num = ? ,camera = ? WHERE btsDate = ?",[NSDate date],connectedData.serial_num,connectedData.camera,connectedData.btsDate];
     }];
}

/**
 *  获取所有数据
 *
 */
- (NSMutableArray *)getAllConnectedDeviceInfosToDicValue:(BOOL)toDic{
    __block NSMutableArray *dataArray = [[NSMutableArray alloc] init];
  [_dbqueue inDatabase:^(FMDatabase * _Nonnull db) {
      FMResultSet *res = [db executeQuery:@"SELECT * FROM 'ZYConnectedDeviceInfoDataBase'"];
      [dataArray addObjectsFromArray:[self p_convertDataByResultSet:res toDic:toDic]];

  }];
    return dataArray;
}

-(NSMutableArray *)getConnectedDeviceInfosToDicValue:(BOOL)toDic withCount:(NSUInteger)count{
      __block NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    [_dbqueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *str = [NSString stringWithFormat:@"SELECT * FROM 'ZYConnectedDeviceInfoDataBase' LIMIT %d",count];
        FMResultSet *res = [db executeQuery:str];
        [dataArray addObjectsFromArray:[self p_convertDataByResultSet:res toDic:toDic]];

    }];
      return dataArray;
}

-(NSMutableArray *)p_convertDataByResultSet:(FMResultSet *)res toDic:(BOOL)toDic{
    __block NSMutableArray *dataArray = [[NSMutableArray alloc] init];

    while ([res next]) {
        ZYConnectedDeviceInfo *model = [[ZYConnectedDeviceInfo alloc] init];
        model.ID = [res intForColumn:@"id"];
        model.refID = [res intForColumn:@"refID"] ;
        model.etsDate = [res dateForColumn:@"etsDate"] ;
        model.btsDate = [res dateForColumn:@"btsDate"] ;
        model.phoneid = [res stringForColumn:@"phoneid"] ;
        model.deviceid = [res stringForColumn:@"deviceid"] ;
        model.serial_num = [res stringForColumn:@"serial_num"] ;
        model.camera = [res stringForColumn:@"camera"] ;
        model.userid = [res stringForColumn:@"userid"] ;
        model.longitude = [res stringForColumn:@"longitude"] ;
        model.latitude = [res stringForColumn:@"latitude"] ;
        if (toDic) {
            NSDictionary *dicTemp = [model toDictionary];
            [dataArray addObject:dicTemp];
        }
        else{
            [dataArray addObject:model];
        }
    }
    return dataArray;
}
+(NSMutableArray *)toDictionArrayWithModelArray:(NSArray <ZYConnectedDeviceInfo *>*)array{
    NSMutableArray *returnArray = [NSMutableArray array];
    for (ZYConnectedDeviceInfo *infoModel in array) {
        [returnArray addObject:[infoModel toDictionary]];
    }
   return returnArray;
}
@end
