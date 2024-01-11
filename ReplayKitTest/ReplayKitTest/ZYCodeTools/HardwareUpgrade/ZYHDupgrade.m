//
//  ZYHDupgrade.m
//  ZYCamera
//
//  Created by 吴伟祥 on 2018/9/5.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYHDupgrade.h"
@implementation ZYHDupgrade

-(instancetype)initWithZYQueryRespondsDic:(NSDictionary *)respondsDic andRefId:(NSUInteger)refID
{
    self = [super init];
    if (self) {
        if ([respondsDic isKindOfClass:[NSDictionary class]]) {
            NSArray *arrTemp =  [respondsDic objectForKey:@"firmwares"] ;
            if ([arrTemp.firstObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *innerDic = arrTemp.firstObject;
                _needUpdate = [[innerDic objectForKey:@"needUpdate"] boolValue];
                _forceUpdate = [[innerDic objectForKey:@"forceUpdate"] boolValue];
                _version = [innerDic objectForKey:@"version"];
                _fileURL = [innerDic objectForKey:@"fileURL"] ;
                _releaseDate = [innerDic objectForKey:@"releaseDate"];
                _notice = [innerDic objectForKey:@"notice"] ;
                _releaseNotes = [innerDic objectForKey:@"releaseNotes"] ;
                _notice = [innerDic objectForKey:@"notice"] ;
                _filesize = [innerDic objectForKey:@"filesize"] ;
                _refID = refID;
                
                id otaUpdateT = [innerDic objectForKey:@"otaUpdate"];
                if (otaUpdateT) {
                    _otaUpdate = [otaUpdateT boolValue];
                }
                else{
                    _otaUpdate = YES;
                }
                
            }
        }
        else{
            return nil;
        }
    }
    return self;
}

- (NSString *)fileURL_downLoadURL{
    NSString* encodedString = [_fileURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    return encodedString;
}

-(NSString *)saveDirName{
    if ([[self.fileURL lowercaseString] containsString:@".zip"]) {
        return [[self.fileURL lastPathComponent] stringByDeletingPathExtension];
    }
    return nil;
}

-(NSString *)savefileURLName{
    return [self.fileURL lastPathComponent];
}
@end
