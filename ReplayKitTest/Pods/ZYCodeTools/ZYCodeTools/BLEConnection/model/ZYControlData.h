//
//  ZYControlData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYControlCoder.h"
#import "ZYBleProtocol.h"

//数据是否解析成功，只有解析失败才会发送
#define  kDataParseSuccess  @"kDataParseSuccess"

@interface ZYControlData : NSObject

@property (nonatomic, readwrite) NSUInteger dataType;

-(void*) createRawData;

/**
 通过外部给msgId

 @param msgId 消息号
 @return 
 */
-(void*) createRawDataWithMsgId:(NSUInteger)msgId;

-(void) setRawData:(void*)data;

-(NSDictionary*) toDictionary;
-(NSUInteger) byteUsedlen;

@end
