//
//  ZYBlOtherCustomFileData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/7/13.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlOtherCustomFileData.h"
#import "BlOtherCustomFileMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlOtherCustomFileMessage);

@interface ZYBlOtherCustomFileData()
{
    BlOtherCustomFileMessage* _message;
}
@end

@implementation ZYBlOtherCustomFileData

@synthesize message = _message;

// 发送数据前，先发送待发送数据长度
+ (instancetype)dataForSendLengthInfo:(NSUInteger)lengthValue
{
    uint32_t lengthValueHL = lengthValue;
    NSLog(@"发送长度转换  %x  %x",lengthValue, lengthValueHL);
    Byte lengthDataByte[10] = {0};
    memcpy(lengthDataByte, &lengthValueHL, sizeof(uint32_t));
    NSData *lengthData = [NSData dataWithBytes:lengthDataByte length:10];
    return [ZYBlOtherCustomFileData dataForSendWithPage:0 data:lengthData];
}

// 获取json数据用户
+ (instancetype)dataWithPage:(int)page direction:(int)direction dataType:(ZYBlOtherCustomFileDataFormat)dataType
{
    NSArray *dataTypeStrArr = @[@"support", @"pathShot", @"pathPoint",@"modules"];
    if ((dataType <= 0) || (dataType > dataTypeStrArr.count)) {
        return nil;
    }
    ZYBlOtherCustomFileData *info = [[ZYBlOtherCustomFileData alloc] init];
    info.direction = direction;
    info.page = page;
    info.data = [dataTypeStrArr[dataType-1] dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"// 获取json数据用户:%@",dataTypeStrArr[dataType-1]);

    [info createRawData];
    return info;
}

// 发送数据用
+ (instancetype)dataForSendWithPage:(int)page data:(NSData *)data
{
    ZYBlOtherCustomFileData *info = [[ZYBlOtherCustomFileData alloc] init];
    info.direction = 0;
    info.page = page;
    info.data = data;
    [info createRawData];
    return info;
}

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlOtherCustomFileMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlOtherCustomFileMessage);
    if (self.dataType == 0) {
        message->buildRequest(_page,_direction,_data.length, (unsigned char*)(_data.bytes));
    }
    return self.message;
}

-(void) setRawData:(void*)data
{
    [self setRawData:data freeWhenDone:YES];
}

-(void) setRawData:(void*)data freeWhenDone:(BOOL)free
{
    self.free = free;
    CAST_MESSAGE(BlOtherCustomFileMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (BlOtherCustomFileMessage*)data;
}

-(int) page
{
    CAST_MESSAGE(BlOtherCustomFileMessage);
    return message->m_data.body.page;
}

-(NSData*) data
{
    CAST_MESSAGE(BlOtherCustomFileMessage);
    return [NSData dataWithBytes:message->m_data.body.data length:sizeof(message->m_data.body.data)];
}

-(UInt8)direction{
    CAST_MESSAGE(BlOtherCustomFileMessage);
    return message->m_data.body.direction;
}

-(NSString *)supportStr{
    if (self.page != 0x00000000) {
        
        NSMutableData *data = [[NSMutableData alloc] initWithData:self.data];
        BYTE byte[1];
        byte[0] = 0x00;
        [data appendData:[NSData dataWithBytes:byte length:1]];
        NSString *str = [NSString stringWithFormat:@"%s",self.data.bytes];
        return str;
    }
    else{
        return nil;
    }
}

-(BOOL)isSupport{
    if (self.page == 0xffff) {
        
        NSMutableData *data = [[NSMutableData alloc] initWithData:self.data];
        BYTE byte[1];
        byte[0] = 0x00;
        [data appendData:[NSData dataWithBytes:byte length:1]];
        NSString *str = [NSString stringWithFormat:@"%s",self.data.bytes];
        if (str.length > 0) {
            return YES;
        }
        return NO;
    }
    else{
        return NO;
    }
}

-(NSInteger)count{
    if (self.page == 0x00) {
        CAST_MESSAGE(BlOtherCustomFileMessage);
        BYTE *data = message->m_data.body.data;
        
        
        uint32 value = (data[3] << 24 )|(data[2] << 16 )|(data[1] << 8 )|(data[0]);
        NSLog(@"value = %d count = %f",value, ceil(value / 10.0));
        return ceil(value / 10.0);
    }
    return -1;
}

- (NSString *)description{
    NSString *desString = [NSString stringWithFormat:@"<direction:%d, page:%d, data:%@>", self.direction, self.page, self.data];
    return desString;
}

@end
