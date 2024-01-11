//
//  ZYUpgradeDirectTools.m
//  ZYCamera
//
//  Created by Liao GJ on 2019/11/1.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYUpgradeDirectTools.h"
#define ZYUpgradeDirFather   @"ZYUpgradeDirFather" //升级数据包的第一个版本
#define ZYUpgradeDirVersionData1   @"ZYUpgradeDirVersionData1" //升级数据包的第一个版本

@implementation ZYUpgradeDirectTools
+(NSString *)ZYUpgradeDirectBasePath{
    NSString *cacheString = [self ZYUpgradeDirPath];
    NSString *dirDataBase = [cacheString stringByAppendingPathComponent:ZYUpgradeDirVersionData1];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:dirDataBase isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {//如果文件夹不存在
        [fileManager createDirectoryAtPath:dirDataBase withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dirDataBase;
}

+(NSString *)ZYUpgradeDirPath{
    NSString *cacheString = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dirFather = [cacheString stringByAppendingPathComponent:ZYUpgradeDirFather];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:dirFather isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {//如果文件夹不存在
        [fileManager createDirectoryAtPath:dirFather withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dirFather;
}

/// 升级的文件夹父节点下面的RefID下面的软件版本文件夹
+(NSString *)ZYUpgradeDirPathWithRefID:(NSUInteger)refID softVersion:(NSString *)softVersion{
    if (softVersion.length > 0) {
        
        NSString *dirRefID = [self ZYUpgradeDirPathWithRefID:refID];
        
        NSString *dirSoftVersion = [dirRefID stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",softVersion]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir  = NO;
        BOOL existed = [fileManager fileExistsAtPath:dirSoftVersion isDirectory:&isDir];
        if ( !(isDir == YES && existed == YES) ) {//如果文件夹不存在
            [fileManager createDirectoryAtPath:dirSoftVersion withIntermediateDirectories:YES attributes:nil error:nil];
        }
        return dirSoftVersion;
    }
    else{
        return nil;
    }
}

+(NSString *)ZYUpgradeDirPathWithRefID:(NSUInteger)refID{
    NSString *cacheString = [self ZYUpgradeDirPath];
    
    NSString *dirRefID = [cacheString stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",refID]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:dirRefID isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {//如果文件夹不存在
        [fileManager createDirectoryAtPath:dirRefID withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dirRefID;
}

+(void)removeAllFileInRefID:(NSUInteger)refID withOutSoftVersion:(NSString *)softVersion{
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSString *filePath = [self ZYUpgradeDirPathWithRefID:refID];
    NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:filePath error:nil];
     for (NSString * str in dirArray) {
         if ([str isEqualToString:softVersion]) {
             continue;
         }
         else{
             NSString *subPath  = [filePath stringByAppendingPathComponent:str];
             if ([fileManger fileExistsAtPath:subPath])
            {
                [fileManger removeItemAtPath:subPath error:nil];
            }
        }
    }
}

+(NSMutableArray *)upgradeSoftwareFiles{
    NSString *cacheString = [self ZYUpgradeDirPath];
     NSString *dirDataBase = [cacheString stringByAppendingPathComponent:ZYUpgradeDirVersionData1];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:cacheString])
    {
        NSError *error;
        NSArray *arrayA = [manager contentsOfDirectoryAtPath:cacheString error:&error];
        if (error) {
            return array;
        }
        for (NSString *fileName in arrayA) {
            if ([fileName isEqualToString:ZYUpgradeDirVersionData1]) {
                continue;
            }
            NSString* fileAbsolutePath = [cacheString stringByAppendingPathComponent:fileName];
            if ([fileAbsolutePath isEqualToString:dirDataBase]) {
                continue;
            }
            [array addObject:fileAbsolutePath];
        }
//        NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:cacheString] objectEnumerator];
//        NSString* fileName;
//        while ((fileName = [childFilesEnumerator nextObject]) != nil){
//            if ([fileName isEqualToString:ZYUpgradeDirVersionData1]) {
//                continue;
//            }
//            NSString* fileAbsolutePath = [cacheString stringByAppendingPathComponent:fileName];
//            if ([fileAbsolutePath isEqualToString:dirDataBase]) {
//                continue;
//            }
//            [array addObject:fileAbsolutePath];
//        }
    }
    
    return array;
}


@end
