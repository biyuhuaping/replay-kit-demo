//
//  ZYControlData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYControlData.h"

@implementation ZYControlData

-(instancetype) init
{
    if ([super init]) {
        self.dataType = 0;
    }
    return self;
}

-(NSDictionary*) toDictionary
{
    return @{};
}

-(NSUInteger) byteUsedlen
{
    return 0;
}
/**
 通过外部给msgId
 
 @param msgId 消息号
 @return
 */
-(void*) createRawDataWithMsgId:(NSUInteger)msgId{
    NSLog(@"需要子类实现");
    return nil;
}

@end
