//
//  ZYHDupgrade.h
//  ZYCamera
//
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYHDupgrade : NSObject

@property(nonatomic, copy)NSString *hardwareID;

@property(nonatomic, copy)NSString *platform;
/**
 服务器返回的版本
 */
@property(nonatomic, copy)NSString *version;

@property(nonatomic, copy)NSString *fileURL;
@property(nonatomic, copy,readonly)NSString *fileURL_downLoadURL;//下载的地址

@property(nonatomic, copy)NSString *folderURL;

@property(nonatomic, copy)NSString *releaseDate;

@property(nonatomic, copy)NSString *notice;

@property(nonatomic, copy)NSString *releaseNotes;


@property(nonatomic, assign)BOOL  needUpdate ;

@property(nonatomic, assign)BOOL  forceUpdate ;

/// 代表该固件是否支持通过App ota升级
@property(nonatomic, assign)BOOL  otaUpdate;


@property(nonatomic, copy)NSString *filesize;


@property(nonatomic, assign)NSUInteger  refID ;//产品的序列号例如0x0600



/**
 指令查询到的版本
 */
@property(nonatomic, copy)NSString *softwareVersion;


/// 通过respondData初始化话服务器数据
/// @param respondsDic 服务器数据
-(instancetype)initWithZYQueryRespondsDic:(NSDictionary *)respondsDic andRefId:(NSUInteger)refID;


/// 保存的文件夹名字
-(NSString *)saveDirName;

/// 文件的名字
-(NSString *)savefileURLName;

@end
