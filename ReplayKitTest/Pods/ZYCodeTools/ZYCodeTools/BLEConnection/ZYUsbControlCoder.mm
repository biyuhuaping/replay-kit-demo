//
//  ZYUsbControlCoder.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYUsbControlCoder.h"
#import "UsbControlCoder.h"
#import "usbMsgAll.h"
#import "ZYAllControlData.h"
#import "ZYBlControlCoder.h"

ZYUsbData* buildUsbData(const zy::UsbMessage* message);

@interface ZYUsbControlCoder()
{
    zy::UsbControlCoder* _coder;
}
@end

@implementation ZYUsbControlCoder

-(instancetype) init
{
    if ([super init]) {
        _coder = new zy::UsbControlCoder();
    }
    return self;
}

-(void) dealloc
{
    if (_coder) {
        delete _coder;
        _coder = NULL;
    }
}

-(NSData*) encode:(ZYControlData*)data
{
    if ([data isKindOfClass:[ZYUsbData class] ]) {
        return [self encodeWithUsbData:(ZYUsbData*)data];
    } else if ([data isKindOfClass:[ZYBlData class] ]) {
        return [self encodeWithBlData:(ZYBlData*)data];
    } else {
        return nil;
    }
}

-(ZYControlData*) decode:(NSData*)data
{
    zy::UsbMessage* message = _coder->decode((BYTE*)data.bytes, (int)data.length);
    if (message) {
        ZYUsbData* usbData = buildUsbData(message);
        [usbData setRawData:message];
        usbData.dataType = 1;
        return usbData;
    }
    return nil;
}

-(NSString*) descriptionForBlData:(ZYUsbData*)data
{
    zy::UsbMessage* rawData = (zy::UsbMessage*)[data createRawData];
    char szTxt[128] = {"\0"};
    _coder->getMessageText(rawData, szTxt, 128);
    return [NSString stringWithUTF8String:szTxt];
}

-(NSData*) encodeWithUsbData:(ZYUsbData*)usbData
{
    _coder->clear();
    zy::UsbMessage* rawData = (zy::UsbMessage*)[usbData createRawData];
    BYTE* data;
    int len = 0;
    _coder->encode(rawData, &data, &len);
    NSData* retData = [NSData dataWithBytes:data length:len];
    free(data);
    data = NULL;
    
    return retData;
}

-(NSData*) encodeWithBlData:(ZYBlData*)blData
{
    _coder->clear();
    ZYUsbInstructionBlData* usbData = [[ZYUsbInstructionBlData alloc] init];
    usbData.blData = blData;
    zy::UsbMessage* rawData = (zy::UsbMessage*)[usbData createRawData];
    BYTE* data;
    int len = 0;
    _coder->encode(rawData, &data, &len);
    NSData* retData = [NSData dataWithBytes:data length:len];
    free(data);
    data = NULL;
    
    return retData;
}

-(ZYBlData*) decodeWithBlData:(NSData*)data
{
    return nil;
}

+(NSString*) descriptionForUsbData:(ZYUsbData*)data
{
    if ([data isKindOfClass:[ZYUsbInstructionBlData class]]) {
        ZYUsbInstructionBlData* usbBlData = (ZYUsbInstructionBlData*)data;
        return [NSString stringWithFormat:@"USB协议指令:序号(%lu)%@", (unsigned long)data.uid, [ZYBlControlCoder descriptionForBlData:usbBlData.blData]];
    } else {
        zy::UsbMessage* rawData = (zy::UsbMessage*)[data createRawData];
        char szTxt[128] = {"\0"};
        zy::UsbControlCoder::getMessageText(rawData, szTxt, 128);
        return [NSString stringWithUTF8String:szTxt];
    }
}

-(BOOL) isValid:(NSData*)data
{
    return _coder->isValid((BYTE*)data.bytes, (int)data.length)?YES:NO;
}

-(NSUInteger) dataUsedLen
{
    return _coder->getCurrentSize();
}

-(void) enableBigEndian:(BOOL)big_endian
{
    _coder->enableBigEndian(big_endian);
}

+(BOOL) canParse:(NSData*)data
{
    return zy::UsbControlCoder::canParse((BYTE*)data.bytes, (int)data.length)?YES:NO;
}

@end

ZYUsbData* buildUsbData(const zy::UsbMessage* message)
{
    int messageType = message->messageType();
    if (messageType == ZYUMTMedia) {
        return [[ZYUsbMediaData alloc] init];
    } else if (messageType == ZYUMTInstructionStar) {
        return [[ZYUsbInstructionStarData alloc] init];
    } else if (messageType == ZYUMTInstructionBl) {
        return [[ZYUsbInstructionBlData alloc] init];
    } else if (messageType == ZYUMTInstructionMS) {
        return [[ZYUsbInstructionMediaStreamData alloc] init];
    } else if (messageType == ZYUMTInstructionHB) {
        return [[ZYUsbInstructionHeartBeatData alloc] init];
    }
    return nil;
}

