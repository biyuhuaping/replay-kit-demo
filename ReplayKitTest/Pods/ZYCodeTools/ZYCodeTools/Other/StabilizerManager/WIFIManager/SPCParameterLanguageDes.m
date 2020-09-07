//
//  SPCParameterLanguageDes.m
//  ZYCamera
//
//  Created by liuxing on 2018/11/20.
//  Copyright © 2018 ZYAPPTEAM. All rights reserved.
//

#import "SPCParameterLanguageDes.h"

@interface SPCParameterLanguageDes()

@property (copy, nonatomic) NSDictionary *languageDic;

@property (copy, nonatomic) NSDictionary *desDic;

@end

@implementation SPCParameterLanguageDes

- (NSString *)getTableName:(NSString *)name {
    
    NSString *tableName = name;
    NSDictionary *dic = self.desDic;
    if ([dic.allKeys containsObject:name]) {
         tableName = dic[name];
    }
    
    return tableName;
}

- (NSMutableArray*)languageFilter:(NSMutableArray *)res {
    
    NSInteger index = [self languageIndex];
    NSDictionary *languageFilterDic = self.languageDic[@"output"];
    
    NSInteger c = res.count;
    for (NSInteger i = 0 ; i < c; ++i) {
        NSString *key = res[i];
        if ([languageFilterDic.allKeys containsObject:key]) {
            NSString *langDes = languageFilterDic[key][index];
            [res replaceObjectAtIndex:i withObject:langDes];
        }
    }
    return res;
}

- (NSString *)languageDescripiton:(NSString *)content {
    
    NSInteger index = [self languageIndex];
    
    NSDictionary *dic = self.languageDic[@"output"];
    if ([dic.allKeys containsObject:content]) {
        content = dic[content][index];
    }
    return content;
}

#pragma -mark 如果要本地化，记得处理他
//typedef NS_ENUM(NSInteger,LanguageType) {
//    LanguageTypeEn = 0,
//    LanguageTypeCH,
//    LanguageTypeTW,
//};

- (NSInteger)languageIndex {
    return 0;
//    LanguageType type = AppDelegate.shareAppDelegate.currentLanguageType;
//    NSInteger index = 0;
//    if (type == LanguageTypeTW) index = 2;
//    else if (type == LanguageTypeCH) index = 1;
//
//    return index;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.languageDic = @{
                             @"output": @{
                                     @"SUPERVIEW":@[@"SUPR",@"SUPR",@"SUPR"],
                                     @"WIDE":@[@"Wide",@"宽",@"寬"],
                                     @"Linear":@[@"Linear",@"线性",@"線性"],
                                     @"Medium":@[@"Medium",@"中",@"中"],
                                     @"Narrow":@[@"Narrow",@"窄",@"窄"],
                                     @"Max":@[@"Max",@"最大",@"最大"],
                                     @"5 min":@[@"5min",@"5分钟",@"5分鐘"],
                                     @"20 min":@[@"20min",@"20分钟",@"20分鐘"],
                                     @"60 min":@[@"60min",@"60分钟",@"60分鐘"],
                                     @"120 min":@[@"120min",@"120分钟",@"120分鐘"],
                                     @"0.5s":@[@"0.5s",@"0.5秒",@"0.5秒"],
                                     @"1s":@[@"1s",@"1秒",@"1秒"],
                                     @"2s":@[@"2s",@"2秒",@"2秒"],
                                     @"5s":@[@"5s",@"5秒",@"5秒"],
                                     @"10s":@[@"10s",@"10秒",@"10秒"],
                                     @"30s":@[@"30s",@"30秒",@"30秒"],
                                     @"60s":@[@"60s",@"60秒",@"60秒"],
                                     @"Auto":@[@"Auto",@"自动",@"自動"],
                                     @"4s":@[@"4s",@"4秒",@"4秒"],
                                     @"15s":@[@"15s",@"15秒",@"15秒"],
                                     @"20s":@[@"20s",@"20秒",@"20秒"],
                                     @"1 min":@[@"1min",@"1分钟",@"1分鐘"],
                                     @"2 min":@[@"2min",@"2分钟",@"2分鐘"],
                                     @"30 min":@[@"30min",@"30分钟",@"30分鐘"],
                                     @"3p/1s":@[@"3pic/1s",@"3张/1秒",@"3張/1秒"],
                                     @"5p/1s":@[@"5pic/1s",@"5张/1秒",@"5張/1秒"],
                                     @"10p/1s":@[@"10pic/1s",@"10张/1秒",@"10張/1秒"],
                                     @"10p/2s":@[@"10pic/2s",@"10张/2秒",@"10張/2秒"],
                                     @"10p/3s":@[@"10pic/3s",@"10张/3秒",@"10張/3秒"],
                                     @"30p/1s":@[@"30pic/1s",@"30张/1秒",@"30張/1秒"],
                                     @"30p/2s":@[@"30pic/2s",@"30张/2秒",@"30張/2秒"],
                                     @"30p/3s":@[@"30pic/3s",@"30张/3秒",@"30張/3秒"],
                                     @"30p/6s":@[@"30pic/6s",@"30张/6秒",@"30張/6秒"],
                                     @"Native":@[@"Native",@"原生",@"原生"],
                                     
                                     @"3min":@[@"3min",@"3分钟",@"3分鐘"],
//                                     @"5min":@[@"5min",@"5分钟",@"5分鐘"],
                                     @"15min":@[@"15min",@"15分钟",@"15分鐘"],
//                                     @"30min":@[@"30min",@"30分钟",@"30分鐘"],
                                     @"No sleep":@[@"Never",@"从不",@"從不"],
                                     @"Never":@[@"Never",@"从不",@"從不"],
                                     }
                             };
        
        self.desDic = @{
                        @"SUPR":@"SUPERVIEW",@"SUPR":@"SUPERVIEW",@"SUPR":@"SUPERVIEW",
                        @"Wide":@"WIDE",@"宽":@"WIDE",@"寬":@"WIDE",
                        @"Linear":@"Linear",@"线性":@"Linear",@"線性":@"Linear",
                        @"Medium":@"Medium",@"中":@"Medium",@"中":@"Medium",
                        @"Narrow":@"Narrow",@"窄":@"Narrow",@"窄":@"Narrow",
                        @"Max":@"Max",@"最大":@"Max",@"最大":@"Max",
                        @"5min":@"5 min",@"5分钟":@"5 min",@"5分鐘":@"5 min",
                        @"20min":@"20 min",@"20分钟":@"20 min",@"20分鐘":@"20 min",
                        @"60min":@"60 min",@"60分钟":@"60 min",@"60分鐘":@"60 min",
                        @"120min":@"120 min",@"120分钟":@"120 min",@"120分鐘":@"120 min",
                        @"0.5s":@"0.5s",@"0.5秒":@"0.5s",@"0.5秒":@"0.5s",
                        @"1s":@"1s",@"1秒":@"1s",@"1秒":@"1s",
                        @"2s":@"2s",@"2秒":@"2s",@"2秒":@"2s",
                        @"5s":@"5s",@"5秒":@"5s",@"5秒":@"5s",
                        @"10s":@"10s",@"10秒":@"10s",@"10秒":@"10s",
                        @"30s":@"30s",@"30秒":@"30s",@"30秒":@"30s",
                        @"60s":@"60s",@"60秒":@"60s",@"60秒":@"60s",
                        @"Auto":@"Auto",@"自动":@"Auto",@"自動":@"Auto",
                        @"4s":@"4s",@"4秒":@"4s",@"4秒":@"4s",
                        @"15s":@"15s",@"15秒":@"15s",@"15秒":@"15s",
                        @"20s":@"20s",@"20秒":@"20s",@"20秒":@"20s",
                        @"1min":@"1 min",@"1分钟":@"1 min",@"1分鐘":@"1 min",
                        @"2min":@"2 min",@"2分钟":@"2 min",@"2分鐘":@"2 min",
                        @"30min":@"30 min",@"30分钟":@"30 min",@"30分鐘":@"30 min",
                        @"3pic/1s":@"3p/1s",@"3张/1秒":@"3p/1s",@"3張/1秒":@"3p/1s",
                        @"5pic/1s":@"5p/1s",@"5张/1秒":@"5p/1s",@"5張/1秒":@"5p/1s",
                        @"10pic/1s":@"10p/1s",@"10张/1秒":@"10p/1s",@"10張/1秒":@"10p/1s",
                        @"10pic/2s":@"10p/2s",@"10张/2秒":@"10p/2s",@"10張/2秒":@"10p/2s",
                        @"10pic/3s":@"10p/3s",@"10张/3秒":@"10p/3s",@"10張/3秒":@"10p/3s",
                        @"30pic/1s":@"30p/1s",@"30张/1秒":@"30p/1s",@"30張/1秒":@"30p/1s",
                        @"30pic/2s":@"30p/2s",@"30张/2秒":@"30p/2s",@"30張/2秒":@"30p/2s",
                        @"30pic/3s":@"30p/3s",@"30张/3秒":@"30p/3s",@"30張/3秒":@"30p/3s",
                        @"30pic/6s":@"30p/6s",@"30张/6秒":@"30p/6s",@"30張/6秒":@"30p/6s",
                        @"Native":@"Native",@"原生":@"Native",@"原生":@"Native",
                        
                        @"3min":@"3min",@"3分钟":@"3min",@"3分鐘":@"3min",
//                        @"5min":@"5min",@"5分钟":@"5min",@"5分鐘":@"5min",
                        @"15min":@"15min",@"15分钟":@"15min",@"15分鐘":@"15min",
//                        @"30min":@"30min",@"30分钟":@"30min",@"30分鐘":@"30min",
                        @"Never":@"No sleep",@"从不":@"No sleep",@"從不":@"No sleep",
                        @"Never":@"Never",@"从不":@"Never",@"從不":@"Never",
                        };
    }
    return self;
}

@end
