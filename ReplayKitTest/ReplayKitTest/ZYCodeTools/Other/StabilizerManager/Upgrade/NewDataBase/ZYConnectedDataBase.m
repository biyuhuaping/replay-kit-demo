//
//  ZYConnectedDataBase.m
//  ZYCamera
//
//  Created by Liao GJ on 2019/11/1.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYConnectedDataBase.h"
#import "ZYUpgradeDirectTools.h"
#import <FMDB.h>
#import "ZYBleDeviceDataModel.h"

#define ZYConnectedDataName  @"ZYConnectedDataBase.sqlite"
#define maxLimiteCount   5 //最多保存的数据个数

@interface ZYConnectedData()
@property (nonatomic, strong,readwrite) NSMutableDictionary *moduleMessageDic;//模块信息

@end

@implementation ZYConnectedData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _creatDate = [NSDate date];
        _updateDataDate = _creatDate;
    }
    return self;
}

/// 初始化对象
/// @param refID 设备的序列号比如0x0600为图传盒子
/// @param softVersion 软件版本
/// @param deviceName 连接过的设备名字
/// @param modulMessage 模块信息
+(instancetype)connectedDataWithrefID:(NSUInteger)refID softVersion:(NSString *)softVersion deviceName:(NSString *)deviceName moduleMessage:(NSDictionary *)modulMessage{
    NSString *modelNumberString = [ZYBleDeviceDataModel translateToModelNumber:refID];
    if ([modelNumberString isEqualToString:modelNumberUnknown]) {
        return nil;
    }
    
    if (softVersion == nil || softVersion.length == 0) {
        return nil;
    }
        
    if (deviceName == nil) {
        deviceName = @"";
    }
    NSData *data = nil;
    if ([modulMessage isKindOfClass:[NSDictionary class]]) {
        NSError *error;
        data= [NSJSONSerialization dataWithJSONObject:modulMessage options:NSJSONWritingPrettyPrinted error:&error];
        if (error) {
            NSLog(@"modulMessage 字典错误 ");
            return nil;
        }
    }
    else{
        data = [NSData data];
    }
    
    ZYConnectedData *ConnectedData = [[ZYConnectedData alloc] init];
    ConnectedData.softVersion = softVersion;
    ConnectedData.refID = (int)refID;
    ConnectedData.deviceName = deviceName;
    ConnectedData.moduleMessage = data;
    ConnectedData.moduleMessageDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

    return ConnectedData;
}

-(NSString *)description{
    NSDictionary *dictionary = [NSDictionary dictionary];
    if (_moduleMessage != nil) {
           dictionary =  [NSJSONSerialization JSONObjectWithData:_moduleMessage options:NSJSONReadingMutableLeaves error:nil];
    }

    return [NSString stringWithFormat:@"id = %d refId = %d _softVersion = %@ _deviceName = %@ _moduleMessage = %@ _creatDate=%@ _updateDataDate=%@",_ID,_refID,_softVersion,_deviceName,dictionary,_creatDate,_updateDataDate];
}

-(NSString *)modelNumberString{
    return [ZYBleDeviceDataModel translateToModelNumber:_refID];
}

@end

static ZYConnectedDataBase *_DBCtl = nil;
@interface ZYConnectedDataBase()<NSCopying,NSMutableCopying>

@property (nonatomic, strong) FMDatabaseQueue *dbqueue;

@end

@implementation ZYConnectedDataBase
+(instancetype)sharedDataBase{
    
    if (_DBCtl == nil) {
        
        _DBCtl = [[ZYConnectedDataBase alloc] init];
        
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
    
    NSString *filePath = [[ZYUpgradeDirectTools ZYUpgradeDirectBasePath] stringByAppendingPathComponent:ZYConnectedDataName];

    // 实例化FMDataBase对象
    
//
//    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
//#ifdef DEBUG
//
//        NSLog(@"%@存在",filePath);
//#endif
//        _dbqueue= [FMDatabaseQueue databaseQueueWithPath:filePath];
//        return;
//    }
    _dbqueue= [FMDatabaseQueue databaseQueueWithPath:filePath];

    [_dbqueue inDatabase:^(FMDatabase *db) {
        // 创表
//        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS myInfo (myId integer PRIMARY KEY AUTOINCREMENT,myName text NOT NULL)"];

//        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS zyConnectedDataBase (id integer PRIMARY KEY AUTOINCREMENT,'ZYConnectedData_refID' INTEGER)"];

        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS ZYConnectedDataBase (id integer PRIMARY KEY AUTOINCREMENT,'ZYConnectedData_refID' INTEGER,'ZYConnectedData_creatDate' TEXT,'ZYConnectedData_updateDataDate' TEXT,'ZYConnectedData_softVersion' VARCHAR,'ZYConnectedData_deviceName' VARCHAR,'ZYConnectedData_moduleMessage' VARCHAR)"];
        if (result) {
            NSLog(@"创建成功");

        }else {
            NSLog(@"创建失败");
        }
    }];
    
}

-(BOOL)addConnectedDataWithrefID:(NSUInteger)refID softVersion:(NSString *)softVersion deviceName:(NSString *)deviceName moduleMessage:(NSDictionary *)modulMessage{
    ZYConnectedData *connectData = [ZYConnectedData connectedDataWithrefID:refID softVersion:softVersion deviceName:deviceName moduleMessage:modulMessage];
    if (connectData) {
        NSLog(@"add====%@",connectData);
        return [self addConnectedData:connectData];
    }
    else{
        NSLog(@"连接的设备添加到连接列表失败");
        return NO;
    }
}
/**
 *  添加mediaModel
 *
 */
- (BOOL)addConnectedData:(ZYConnectedData *)ConnectedData{
    
    ZYConnectedData *temp = [self getConnectedDataWithDeviceName:ConnectedData.deviceName];
    if (temp) {
        [self updateConnectedData:ConnectedData];
    }
    else{
              [_dbqueue inDatabase:^(FMDatabase * _Nonnull db) {
        //          BOOL result = [db executeUpdate:@"INSERT INTO myInfo (myId,myName) VALUES (?,?)",@1,@"yu"];
        //          BOOL result = [db executeUpdate:@"INSERT INTO zyConnectedDataBase(ZYConnectedData_refID)VALUES(?)",@(ConnectedData.refID)];

                  BOOL result = [db executeUpdate:@"INSERT INTO ZYConnectedDataBase(ZYConnectedData_refID,ZYConnectedData_creatDate,ZYConnectedData_updateDataDate,ZYConnectedData_softVersion,ZYConnectedData_deviceName,ZYConnectedData_moduleMessage)VALUES(?,?,?,?,?,?)",[NSNumber numberWithInt:ConnectedData.refID],ConnectedData.creatDate,ConnectedData.updateDataDate,ConnectedData.softVersion,ConnectedData.deviceName,ConnectedData.moduleMessage];
                  NSLog(@"inset ============ %d",result);
              }];
    }
      return YES;
}

/**
 *  删除mediaModel
 *
 */
- (BOOL)deleteConnectedData:(ZYConnectedData *)ConnectedData{
    if (ConnectedData == nil) {
            
           return NO;
    }
    if (ConnectedData.deviceName.length > 0) {
        [_dbqueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:@"DELETE FROM ZYConnectedDataBase WHERE ZYConnectedData_deviceName = ?", ConnectedData.deviceName];
           
        }];
        return YES;
    }
    return NO;
}
/**
 *  更新mediaModel
 *
 */
- (void)updateConnectedData:(ZYConnectedData *)ConnectedData{
    if (ConnectedData == nil) {
         return;
     }
     [_dbqueue inDatabase:^(FMDatabase * _Nonnull db) {
         [db executeUpdate:@"UPDATE 'ZYConnectedDataBase' SET  ZYConnectedData_updateDataDate = ?, ZYConnectedData_moduleMessage = ? ,ZYConnectedData_softVersion = ? WHERE ZYConnectedData_deviceName = ?",[NSDate date],ConnectedData.moduleMessage,ConnectedData.softVersion,ConnectedData.deviceName];
     }];
}

/**
 *  获取所有数据
 *
 */
- (NSMutableArray *)getAllConnectedDatas{
    __block NSMutableArray *dataArray = [[NSMutableArray alloc] init];
  [_dbqueue inDatabase:^(FMDatabase * _Nonnull db) {
      FMResultSet *res = [db executeQuery:@"SELECT * FROM 'ZYConnectedDataBase'"];
      [dataArray addObjectsFromArray:[self p_convertDataByResultSet:res]];

  }];
    NSLog(@"%@",dataArray);
    return dataArray;
}

/// 获取某一个版本的信息
/// @param refId refID
-(NSMutableArray *)getConnectedDataWithRefID:(NSUInteger)refId{
    __block NSMutableArray *dataArray = [[NSMutableArray alloc] init];
       [_dbqueue inDatabase:^(FMDatabase * _Nonnull db) {
           FMResultSet *res = [db executeQuery:@"SELECT * FROM 'ZYConnectedDataBase' WHERE ZYConnectedData_refID = ?",@(refId)];
           [dataArray addObjectsFromArray:[self p_convertDataByResultSet:res]];

       }];
    return dataArray;
}

-(ZYConnectedData *)selectLastConnectedDataWithRefID:(NSUInteger)refId{
    __block NSMutableArray *dataArray = [[NSMutableArray alloc] init];
          [_dbqueue inDatabase:^(FMDatabase * _Nonnull db) {
              FMResultSet *res = [db executeQuery:@"SELECT * FROM 'ZYConnectedDataBase' WHERE ZYConnectedData_refID = ? ORDER BY ZYConnectedData_updateDataDate DESC Limit 1",@(refId)];
              [dataArray addObjectsFromArray:[self p_convertDataByResultSet:res]];

          }];
    if (dataArray.count > 0) {
        return dataArray.firstObject;
    }
    else{
        return nil;
    }
}

-(NSMutableArray *)selectLastConnectedDataWithLimitCount:(NSUInteger)limit{
    __block NSMutableArray *dataArray = [[NSMutableArray alloc] init];
          [_dbqueue inDatabase:^(FMDatabase * _Nonnull db) {
              FMResultSet *res = [db executeQuery:@"SELECT * FROM 'ZYConnectedDataBase' ORDER BY ZYConnectedData_updateDataDate DESC Limit ?",@(limit)];
              [dataArray addObjectsFromArray:[self p_convertDataByResultSet:res]];

          }];
       return dataArray;
}



/// 通过名字获取对象
/// @param deviceName deviceName
-(ZYConnectedData *)getConnectedDataWithDeviceName:(NSString *)deviceName
{
    __block NSMutableArray *dataArray = [[NSMutableArray alloc] init];
       [_dbqueue inDatabase:^(FMDatabase * _Nonnull db) {
           FMResultSet *res = [db executeQuery:@"SELECT * FROM 'ZYConnectedDataBase' WHERE ZYConnectedData_deviceName = ?",deviceName];
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

-(NSMutableArray *)p_convertDataByResultSet:(FMResultSet *)res{
    __block NSMutableArray *dataArray = [[NSMutableArray alloc] init];

    while ([res next]) {
        ZYConnectedData *model = [[ZYConnectedData alloc] init];
        model.ID = [res intForColumn:@"id"];
        model.refID = [res intForColumn:@"ZYConnectedData_refID"] ;
        model.softVersion = [res stringForColumn:@"ZYConnectedData_softVersion"] ;
        model.moduleMessage = [res dataForColumn:@"ZYConnectedData_moduleMessage"] ;
        model.creatDate = [res dateForColumn:@"ZYConnectedData_creatDate"] ;
        model.updateDataDate = [res dateForColumn:@"ZYConnectedData_updateDataDate"] ;
        model.deviceName = [res stringForColumn:@"ZYConnectedData_deviceName"] ;
        if (model.moduleMessage) {
            model.moduleMessageDic = [NSJSONSerialization JSONObjectWithData:model.moduleMessage options:NSJSONReadingMutableContainers error:nil];
        }
        [dataArray addObject:model];
    }
    return dataArray;
}


@end
