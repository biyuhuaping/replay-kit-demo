


//
//  ZYConectModel.m
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/4/14.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYConectModel.h"
@implementation ZYConectModel



+(instancetype)connectModelWithOrignalName:(NSString *)oringnalName{
    ZYConectModel *model = [ZYConectModel new];
    model.orignalName = oringnalName;
    model.displayName = oringnalName;
    model.isNeedAutoConnect = @"False";
    return model;
}

+(instancetype)connectModelWithDictionory:(NSDictionary *)dic{
    ZYConectModel *model = [ZYConectModel new];
    model.orignalName = dic[@"orignalName"];
    model.displayName = dic[@"displayName"];
    model.isNeedAutoConnect = dic[@"isNeedAutoConnect"];
    return model;
}

-(NSMutableDictionary *)toDictionary{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.orignalName forKey:@"orignalName"];
    [dic setObject:self.displayName forKey:@"displayName"];
    [dic setObject:self.isNeedAutoConnect forKey:@"isNeedAutoConnect"];

    return dic;
}
@end
