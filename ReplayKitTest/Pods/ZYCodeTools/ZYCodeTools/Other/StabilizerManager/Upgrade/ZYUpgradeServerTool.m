//
//  ZYUpgradeServerTool.m
//  ZYCamera
//
//  Created by 吴伟祥 on 2019/10/8.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//
#define kHardwareUpgrade @"Hardware_Upgrade"
//#import "ZYNetwrokManager.h"
#import "ZYHardwareUpgradeModel.h"
#import "ZYDeviceManager.h"

#import "ZYModuleUpgrade.h"

#import "SSZipArchive.h"

//#import "NSString+StringLength.h"
#import "ZYStablizerDefineENUM.h"

#import "ZYStabilizerTools.h"
#import "ZYUpgradeServerTool.h"
#import "ZYUpgradeDirectTools.h"
#import <AFNetworking/AFNetworking.h>
#define kTimeOutReques   15 //网络请求的超时时间

@interface ZYUpgradeServerTool (){
    // 下载句柄
    NSURLSessionDownloadTask *_downloadTask;
}

@end

@implementation ZYUpgradeServerTool
static  ZYUpgradeServerTool  *shareSingleton = nil;

+( instancetype ) shareInstant{
    static  dispatch_once_t  onceToken;
    dispatch_once ( &onceToken, ^ {
        
        shareSingleton  =  [[super allocWithZone:NULL] init] ;
        
    } );
    return shareSingleton;
}

+(id) allocWithZone:(struct _NSZone *)zone {
    
    return [self shareInstant] ;
    
}

-(id) copyWithZone:(struct _NSZone *)zone {
    
    return [ZYUpgradeServerTool shareInstant]  ;
    
}
-(void)serverCheckNeedUpgradeWithrefID:(NSUInteger)refID softVersion:(NSString *)softVersion moduleMessage:(ZYModuleUpgrade_New_Model *)modulMessage handler:(void (^)(BOOL isNeedUpdate))handler{
    @weakify(self)
    //软件版本没有的时候需要屏蔽设备
    if (softVersion.length == 0) {
        if (handler) {
            handler(NO);
        }
        return;
    }
    [self pingnetworkwithhandle:^(BOOL success) {
        @strongify(self)
        if (success) {
            [self p_serverCheckNeedUpgradeWithrefID:refID softVersion:softVersion moduleMessage:modulMessage handler:handler];
        }
        else{
            if (modulMessage == nil) {
                ZYQueryRespondData *respondsData =[[ZYQueryRespondDataBase sharedDataBase] getQueryRespondDataWithRefId:refID softVersion:softVersion];
                if (handler) {
                    if (respondsData) {
                        handler([respondsData needUpdate]);
                    }
                    else{
                        handler(NO);
                        
                    }
                }
            }
            else{
                for (ZYUpgradableInfoModel *model in modulMessage.modules) {
                    
                    ZYQueryRespondData *respondsData =[[ZYQueryRespondDataBase sharedDataBase] getQueryRespondDataWithRefId:model.modelNumber softVersion:[NSString stringWithFormat:@"%ld",model.version]];
                    if ([respondsData needUpdate]) {
                        if (handler) {
                            handler(YES);
                        }
                        return ;
                    }
                    
                }
                if (handler) {
                    handler(NO);
                }
                //NSLog(@"本地模块化升级判断逻辑");
            }
            
        }
    }];
}

-(void)p_serverCheckNeedUpgradeWithrefID:(NSUInteger)refID softVersion:(NSString *)softVersion moduleMessage:(ZYModuleUpgrade_New_Model *)modulMessage handler:(void (^)(BOOL isNeedUpdate))handler{
    
    
    
    if (modulMessage == nil) {
        [self p_serverCheckNeedUpgradeWithrefID:refID softVersion:softVersion handler:handler];
    }
    else{
        __block NSUInteger totalCount = modulMessage.modules.count;
        __block BOOL isNeedUpdateBlock = NO;
        for (ZYUpgradableInfoModel *model in modulMessage.modules) {
            [self p_serverCheckNeedUpgradeWithrefID:model.modelNumber softVersion:[NSString stringWithFormat:@"%ld",model.version] handler:^(BOOL isDownRespond) {
                isNeedUpdateBlock = isNeedUpdateBlock || isDownRespond;
                totalCount -= 1;
                if (totalCount == 0) {
                    if (handler) {
                        handler(isNeedUpdateBlock);
                    }
                }
            }];
        }
        //NSLog(@"模块化升级判断逻辑");
    }
    
}

-(ZYModuleUpgrade_New_Model *)newModelWithDic:(NSDictionary *)dic{
    return nil;
}

-(void)p_serverCheckNeedUpgradeWithrefID:(NSUInteger)refID softVersion:(NSString *)softVersion handler:(void (^)(BOOL isDownRespond))handler{
#pragma -mark 记得加语言，默认为en
    NSString *url = nil;
    
    if (self.downLoadUrl) {
        url = self.downLoadUrl(refID,[ZYStabilizerTools softwareVersionForDisplay:softVersion]);
    }
    if (url == nil) {
        if (handler) {
            handler(NO);
        }
        //NSLog(@"外部没有给出下载地址");
        return;
    }
    
    [self p_urlRequest:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || data == nil) {
            if (handler) {
                handler(NO);
            }
        }
        else{
            id obj= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                
                int intErrCode = [[obj objectForKey:@"errcode"] intValue];
                BOOL addSuccess = [[ZYQueryRespondDataBase sharedDataBase] addQueryRespondDataWithrefID:refID softVersion:softVersion responds:obj];
                NSDictionary *tempDic = obj;
                if (intErrCode == 0 &&addSuccess && [ZYQueryRespondData needUpdate:tempDic]) {
                    if (handler) {
                        handler(YES);
                    }
                }
                else{
                    if (handler) {
                        handler(NO);
                    }
                    
                }
                
            }
            else{
                if (handler) {
                    handler(NO);
                }
            }
        }
    }];
}

-(NSURLSessionDataTask *)p_urlRequest:(NSString *)url completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTimeOutReques];
    if (self.allHTTPHeaderFields.count > 0) {
        __weak NSMutableURLRequest *weakRequest = request;
        [self.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [weakRequest setValue:obj forHTTPHeaderField:key];
        }];
        
    }
    NSURLSession *session=[NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:completionHandler];
    [dataTask resume];
    return dataTask;
}

-(void)pingnetworkwithPingUrl:(NSString *(^)())handler{
    
    
}
/**
 ping地址
 
 @param handler 回调
 */
-(void)pingnetworkwithhandle:(void (^)(BOOL success))handler{
    NSString *url = @"http://api.zhiyun-tech.com/v1/ping";
    if (self.pingNetworkUrl) {
        url = self.pingNetworkUrl();
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 2.申明返回的结果是二进制类型
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // 3.如果报接受类型不一致请替换一致text/html  或者 text/plain
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
    [manager.requestSerializer setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    //    [AFJSONRequestSerializer addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];//加上这句话
    // 4.请求超时，时间设置
    manager.requestSerializer.timeoutInterval = 1.5;
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BLOCK_EXEC(handler, YES);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BLOCK_EXEC(handler, NO);
    }];
    
    
    return;
    //    NSString *str = @"http://api.zhiyun-tech.com/v1/ping";
    //    [ZYNetwrokManager requestAFURL:SERVER_API_Ping httpMethod:0 parameters:nil timeoutInterval:1 succeed:^(id data) {
    //#ifdef DEBUG
    //        //NSLog(@"succeess Ping===============");
    //#endif
    //        BLOCK_EXEC(handler, YES);
    //    } failure:^(NSError *error) {
    //        BLOCK_EXEC(handler, NO);
    //    }];
}

+(BOOL)checkLocalByConnectedData:(ZYConnectedData *)connectedData{
    
    ZYModuleUpgrade_New_Model *model = [ZYModuleUpgrade_New_Model initWithDic:connectedData.moduleMessageDic andCurrentModelNumber:connectedData.refID];
    
    if (model) {
#pragma -mark 新的模块升级
        return [self checkLocalByModules:model.modules ByRefId:connectedData.refID softVersion:nil];
    }
    else{
        return [self p_singCheckFireExistWithConnected:connectedData];
    }
}

+(BOOL)p_singCheckFireExistWithConnected:(ZYConnectedData *)connectedData{
    ZYQueryRespondData *data = [[ZYQueryRespondDataBase sharedDataBase] getQueryRespondDataWithRefId:connectedData.refID softVersion:connectedData.softVersion];
    if (data == nil) {
        return NO;
    }
    ZYHDupgrade *upgradeModel = [[ZYHDupgrade alloc] initWithZYQueryRespondsDic:data.respondsDic andRefId:connectedData.refID];
    NSString *fodlerPath = [ZYUpgradeDirectTools ZYUpgradeDirPathWithRefID:connectedData.refID softVersion:upgradeModel.version];
    NSString *fileNameIsZip = [upgradeModel savefileURLName];
    if (fileNameIsZip) {
        fodlerPath = [fodlerPath stringByAppendingPathComponent:fileNameIsZip];
    }
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:fodlerPath isDirectory:&isDir]) {
        NSError *error;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fodlerPath error:&error];
        
        if (fileAttributes && !error) {
            if ([fileAttributes fileExtensionHidden]) {
                return NO;
            }
            else{
                return YES;
                
            }
        }
    }
    return NO;
}


+(BOOL)upgratedataURLByModules:(NSArray <ZYUpgradableInfoModel *>*)modules ByRefId:(NSUInteger)refID softVersion:(NSString *)softVersion{
    if (modules.count == 0) {
        return NO;
    }
    
    BOOL localContain = YES;
    for (ZYUpgradableInfoModel *model in modules) {
        
        NSString *innerSoftVersion = [NSString stringWithFormat:@"%ld",model.version ];
        //NSLog(@"innnnn= %@ configUpgradeData =%@",innerSoftVersion,softVersion);
        if (softVersion.length > 0 && model.modelType != ZYUpgradableInfoModelTypeExternal) {
            
            innerSoftVersion = softVersion;
        }
        //NSLog(@"innnnnlate= %@",innerSoftVersion);
        
        ZYQueryRespondData *data = [[ZYQueryRespondDataBase sharedDataBase] getQueryRespondDataWithRefId:model.modelNumber softVersion:innerSoftVersion];
        
        if (data == nil) {
#pragma -mark 如果设备没有获取到后台信息的话，继续运行就OK了
            continue;
            //            return NO;
        }
        ZYHDupgrade *upgradeModel = [[ZYHDupgrade alloc] initWithZYQueryRespondsDic:data.respondsDic andRefId:refID];
        if (upgradeModel.needUpdate == NO && upgradeModel.forceUpdate == NO) {
            if (modules.count == 1) {
                return NO;
            }
            continue;
        }
        if (upgradeModel.version.length == 0) {
            return NO;
        }
        NSString *fodlerPath = [ZYUpgradeDirectTools ZYUpgradeDirPathWithRefID:model.modelNumber softVersion:upgradeModel.version];
        
        NSString *fileNameIsZip = [upgradeModel saveDirName];
        if (fileNameIsZip) {
            fodlerPath = [fodlerPath stringByAppendingPathComponent:fileNameIsZip];
        }
        //NSLog(@"%@",model.upgrateExtention);
        NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fodlerPath error:nil];
        if (fileList.count > 0) {
            BOOL innerContain = NO;
            for (NSString *tempAttrFile1 in fileList) {
                NSString *tempAttrFile = [fodlerPath stringByAppendingPathComponent:tempAttrFile1];
                NSError *error;
                BOOL isDir = NO;
                if (![[NSFileManager defaultManager] fileExistsAtPath:tempAttrFile isDirectory:&isDir]) {
                    continue;
                }
                if (isDir) {
                    continue;
                }
                NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:tempAttrFile error:&error];
                
                if (fileAttributes && !error) {
                    if ([fileAttributes fileExtensionHidden]) {
                        continue;
                    }
                    else{
                        innerContain = [[model.upgrateExtention lowercaseString] containsString:[[tempAttrFile1 pathExtension] lowercaseString]];
                        if (innerContain) {
                            model.needUpdate = upgradeModel.needUpdate || upgradeModel.forceUpdate;
                            model.upgratedataURL = tempAttrFile;
                            break;
                        }
                    }
                    
                }else{
                    break;
                }
            }
            if (innerContain == NO) {
                return NO;
            }
        }
        else{
            return NO;
        }
    }
    return localContain;
}

/// 检查安装包是否存在
/// @param modules 模块信息
/// @param refID 设备ID
/// @param softVersion 软件版本
+(BOOL)checkLocalByModules:(NSArray <ZYUpgradableInfoModel *>*)modules ByRefId:(NSUInteger)refID softVersion:(NSString *)softVersion{
    return  [self upgratedataURLByModules:modules ByRefId:refID softVersion:softVersion];
}

/// 下载安装包
/// @param refID refID
/// @param softVersion s软件版本
/// @param success 下载成功
/// @param progresses 下载进度
/// @param failure 下载失败
-(void)downloadAndCompressByRefId:(NSUInteger)refID softVersion:(NSString *)softVersion success:(void (^)(void))success progress:(void (^)(float))progresses failure:(void (^)(NSError *error))failure{
    ZYQueryRespondData *data = [[ZYQueryRespondDataBase sharedDataBase] getQueryRespondDataWithRefId:refID softVersion:softVersion];
    ZYHDupgrade *upModel = [[ZYHDupgrade alloc] initWithZYQueryRespondsDic:data.respondsDic andRefId:refID ];
    [self downloadAndCompressByModel:upModel success:success progress:progresses failure:failure];
}


#pragma mark DownLoad

-(void)downloadAndCompressByModel:(ZYHDupgrade *)model success:(void (^)(void))success progress:(void (^)(float progress))progresses failure:(void (^)(NSError *error))failure{
    if (model.fileURL.length) {
        //        self.upgardeStatus = ZYUpgradeStatusDownloading;
        NSString* encodedString = model.fileURL_downLoadURL;
        //        NSString *urlStr = [encodedString spaceEscaping];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodedString]];
        NSString *lastPathComponent = [model.fileURL lastPathComponent];
        NSString *fodlerPath = [ZYUpgradeDirectTools ZYUpgradeDirPathWithRefID:model.refID softVersion:model.version];
        NSString *saveString = [fodlerPath stringByAppendingPathComponent:lastPathComponent ];
        unlink([saveString UTF8String]);
        [self downloadWithRequest:request progress:^(NSProgress *downloadProgress) {
            float pro = 1.0 *downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
            BLOCK_EXEC(progresses,pro);
            
        } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            NSURL *url = [NSURL fileURLWithPath:saveString];
            return url;
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            if (error) {
                //NSLog(@"下载失败，删除文件失败.");
                [[NSFileManager defaultManager] removeItemAtURL:filePath error:nil];
                BLOCK_EXEC(failure,error);
                return ;
            }
            //移除之前的版本
            [ZYUpgradeDirectTools removeAllFileInRefID:model.refID withOutSoftVersion:model.version];
            if ([lastPathComponent localizedCaseInsensitiveContainsString:@".zip"]) {
                NSString *newFolder = [lastPathComponent stringByDeletingPathExtension];
                
                newFolder = [fodlerPath stringByAppendingPathComponent:newFolder];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                BOOL isDir = NO;
                BOOL existed = [fileManager fileExistsAtPath:newFolder isDirectory:&isDir];
                if ( !(isDir == YES && existed == YES) ) {//如果文件夹不存在
                    [fileManager createDirectoryAtPath:newFolder withIntermediateDirectories:YES attributes:nil error:nil];
                }
                
                
                
                [SSZipArchive unzipFileAtPath:filePath.path toDestination:fodlerPath progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
                    NSString *origionString = [fodlerPath stringByAppendingPathComponent:entry];
                    BOOL isDir = NO;
                    BOOL existed = [fileManager fileExistsAtPath:origionString isDirectory:&isDir];
                    if (isDir == NO && existed) {
                        NSString *desString = [newFolder stringByAppendingPathComponent:[entry lastPathComponent]];
                        if (![desString isEqualToString:origionString]) {
                            NSError *errorMess;
                            [[NSFileManager defaultManager] copyItemAtPath:origionString toPath:desString error:&errorMess];
                            if (errorMess) {
                                //NSLog(@"文件移动出错");
                            }
                        }
                        
                    }
                    //NSLog(@"progress entry:%@ total:%ld   entryNumber:%ld ",entry,total , entryNumber);
                } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
                    //                                        //NSLog(@"completionHandler success:%d  path:%@ error:%@",succeeded,path,error);
                    NSString *newFolder = [lastPathComponent stringByDeletingPathExtension];
                    newFolder = [fodlerPath stringByAppendingPathComponent:newFolder];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    BOOL isDir = NO;
                    BOOL existed = [fileManager fileExistsAtPath:newFolder isDirectory:&isDir];
                    if (!existed) {
                        NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fodlerPath error:nil];
                        for (NSString *tempAttrFile1 in fileList) {
                            NSString *tempAttrFile = [fodlerPath stringByAppendingPathComponent:tempAttrFile1];
                            NSError *error;
                            NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:tempAttrFile error:&error];
                            if (fileAttributes && !error) {
                                if ([fileAttributes fileExtensionHidden]) {
                                    continue;
                                }
                                else{
                                    isDir = NO;
                                    existed = [fileManager fileExistsAtPath:tempAttrFile isDirectory:&isDir];
                                    if (isDir) {
                                        [fileManager createDirectoryAtPath:newFolder withIntermediateDirectories:YES attributes:nil error:nil];
                                        NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:tempAttrFile];
                                        NSString *pathTemp;
                                        while ((pathTemp = [dirEnum nextObject]) != nil) {
                                            [fileManager moveItemAtPath:[NSString stringWithFormat:@"%@/%@",tempAttrFile,pathTemp]
                                                                 toPath:[NSString stringWithFormat:@"%@/%@",newFolder,pathTemp]
                                                                  error:NULL];
                                        }
                                        [fileManager removeItemAtPath:tempAttrFile error:nil];
                                    }
                                }
                                
                            }else{
                                continue;
                            }
                        }
                    }
                    
                    if (succeeded) {
                        BLOCK_EXEC(success);
                        
                    }else{
                        BLOCK_EXEC(failure,error);
                    }
                    
                } ];
                
            }
            
            
        }];
    }else{
        NSError *error = [NSError errorWithDomain:@"fileUrl is null" code:-1 userInfo:nil];
        BLOCK_EXEC(failure,error);
        
        //        self.upgardeStatus = ZYUpgradeStatusUnfindFitSerise;
        
    }
}

#pragma mark - Download
- (void)downloadWithRequest:(NSURLRequest *)request
                   progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
          completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler{
    
    
    
    //1.创建会话管理者
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    //2.下载文件
    /*
     第一个参数:请求对象
     第二个参数:progress 进度回调 downloadProgress
     第三个参数:destination 回调(目标位置)
     有返回值
     targetPath:临时文件路径
     response:响应头信息
     第四个参数:completionHandler 下载完成之后的回调
     filePath:最终的文件路径
     */
    _downloadTask = [manager downloadTaskWithRequest:request progress:downloadProgressBlock destination:destination completionHandler:completionHandler];
    
    //3.执行Task
    [_downloadTask resume];
    
}


#pragma mark - Privatey function

/**
 初始化
 
 @return
 */
-(instancetype)init{
    if (self = [super init]) {
        NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *oldPath =[cacheDirectory stringByAppendingPathComponent:kHardwareUpgrade];
        if ([fileManager fileExistsAtPath:oldPath]) {
            [fileManager removeItemAtPath:oldPath error:nil];
        }
    }
    return self;
}
/**
 查询目录地址
 
 @param basepath 基本路径
 @return <#return value description#>
 */
-(NSString *)queryFileNameByPath:(NSString *)basepath SubString:(NSString *)SubString {
    // 工程目录
    NSString *BASE_PATH = basepath;
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *myDirectoryEnumerator = [myFileManager enumeratorAtPath:BASE_PATH];
    
    BOOL isDir = NO;
    BOOL isExist = NO;
    
    //列举目录内容，可以遍历子目录
    for (NSString *path in myDirectoryEnumerator.allObjects) {
        
        isExist = [myFileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", BASE_PATH, path] isDirectory:&isDir];
        if (isDir) {
            //NSLog(@"目录路径: %@", path);    // 目录路径
        } else {
            //NSLog(@"文件路径: %@", path);    // 文件路径
        }
        if ([path containsString:SubString] && ![path localizedStandardContainsString:@"MACOSX"]) {
            return [basepath stringByAppendingPathComponent:path];
            
        }
        
    }
    return basepath;
}

-(void)p_updateLocalDataSource{
    [self pingnetworkwithhandle:^(BOOL success) {
        if (success) {
            NSArray *array = [[ZYConnectedDataBase sharedDataBase] selectLastConnectedDataWithLimitCount:5];
            for (ZYConnectedData *connectedData in array) {
                ZYModuleUpgrade_New_Model *model = [ZYModuleUpgrade_New_Model initWithDic:connectedData.moduleMessageDic andCurrentModelNumber:connectedData.refID];
                [self p_serverCheckNeedUpgradeWithrefID:connectedData.refID softVersion:connectedData.softVersion moduleMessage:model handler:^(BOOL isNeedUpdate) {
                    
                }];
                
            }
        }
    }];
}


-(void)updateLocalDataSource{
    [self p_updateLocalDataSource];
}


-(NSString *)versionStringByModels:(NSArray<ZYHDupgrade*> *)models{
    int upgraeCount = [models count];
    if (upgraeCount) {
        NSMutableString *ms = [NSMutableString new];
        for (int i = 0 ; i < upgraeCount; i++) {
            ZYHDupgrade *hd = [models objectAtIndex:i];
            if (i != upgraeCount - 1 && upgraeCount != 1) {
                [ms appendString:[NSString stringWithFormat:@"%@、",hd.version]];
                
            }else{
                if (hd.version) {
                    [ms appendString:hd.version];
                }
            }
        }
        return ms;
        
    }
    return nil;
}



-(NSString *)releaseNotesStringWithModels:(NSArray<ZYHDupgrade *>*)models{
    int upgraeCount = [models count];
    if (upgraeCount) {
        NSMutableString *ms = [NSMutableString new];
        for (int i = 0 ; i < upgraeCount; i++) {
            ZYHDupgrade *hd = [models objectAtIndex:i];
            if (i != upgraeCount - 1) {
                [ms appendString:[NSString stringWithFormat:@"%@.\n\n",hd.releaseNotes]];
                
            }else{
                if (hd.releaseNotes) {
                    [ms appendString:hd.releaseNotes];
                    
                }
                
            }
        }
        return ms;
        
    }
    return nil;
    
}
/**
 通过设备类型检查是否需要升级，发通知kHardwareIsNeedUpgrade反馈是否需要
 
 @param deviceModel 设备类型
 */
+(void)checkLocalDatasorceIsNeedToUpgradeByRefId:(NSUInteger)refId{
    
    NSString *str = [ZYBleDeviceDataModel translateToModelNumber:refId];
    if ([str isEqualToString:modelNumberUnknown]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHardwareIsNeedUpgrade object:nil userInfo:@{@"needUpdate":@(NO)}];
        return;
    }
    __block ZYConnectedData *connectedData = [[ZYConnectedDataBase sharedDataBase] selectLastConnectedDataWithRefID:refId];
    if (connectedData == nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHardwareIsNeedUpgrade object:nil userInfo:@{@"needUpdate":@(NO)}];
        return;
    }
    
    ZYModuleUpgrade_New_Model *model = [ZYModuleUpgrade_New_Model initWithDic:connectedData.moduleMessageDic andCurrentModelNumber:refId];
    
    [[ZYUpgradeServerTool shareInstant] serverCheckNeedUpgradeWithrefID:connectedData.refID softVersion:connectedData.softVersion moduleMessage:model handler:^(BOOL isNeedUpdate) {
        if ([NSThread currentThread] == [NSThread mainThread]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHardwareIsNeedUpgrade object:nil userInfo:@{@"needUpdate":@(isNeedUpdate),kLocalUpgradeModel:connectedData}];
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kHardwareIsNeedUpgrade object:nil userInfo:@{@"needUpdate":@(isNeedUpdate),kLocalUpgradeModel:connectedData}];
                
            });
            
        }
        
    }];
    
}
-(void)cancelDownload{
    [_downloadTask cancel];
    
    [ZYDeviceManager defaultManager].stablizerDevice.hardwareUpgradeManager.upgardeStatus = ZYUpgradeStatusDownloadFailure;
    
}
//升级的按照包的列表，只要把这些文件里面的大小计算就行，删除也只要删除对应的文件
+(NSMutableArray *) upgradeSoftwareFiles{
    return [ZYUpgradeDirectTools upgradeSoftwareFiles];
}
@end
