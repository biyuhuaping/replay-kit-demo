//
//  ZYRdisControlCoder.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYRdisControlCoder.h"
#import "RdisControlCoder.h"
#import "blMsgAll.h"
#import "ZYAllControlData.h"

@interface ZYRdisControlCoder()
{
    zy::RdisControlCoder* _coder;
}
@end

@implementation ZYRdisControlCoder

//-(instancetype) init
//{
//    if ([super init]) {
//        _coder = new zy::BlControlCoder();
//    }
//    return self;
//}
//
//-(void) dealloc
//{
//    if (_coder) {
//        delete _coder;
//        _coder = NULL;
//    }
//}
//
//-(NSData*) encode:(ZYBlData*)blData
//{
//    _coder->clear();
//    zy::BlMessage* rawData = (zy::BlMessage*)[blData createRawData];
//    BYTE* data;
//    int len = 0;
//    _coder->encode(rawData, &data, &len);
//    NSData* retData = [NSData dataWithBytes:data length:len];
//    free(data);
//    data = NULL;
//
//    return retData;
//}
//
//-(ZYBlData*) decode:(NSData*)data
//{
//    zy::BlMessage* message = _coder->decode((BYTE*)data.bytes, (int)data.length);
//    if (message) {
//        ZYBlData* blData = [ZYBlControlCoder buildBlData:message];
//        [blData setRawData:message];
//        blData.dataType = 1;
//        return blData;
//    }
//    return nil;
//}
//
//-(NSString*) descriptionForBlData:(ZYBlData*)data
//{
//    zy::BlMessage* rawData = (zy::BlMessage*)[data createRawData];
//    char szTxt[128] = {"\0"};
//    _coder->getMessageText(rawData, szTxt, 128);
//    return [NSString stringWithUTF8String:szTxt];
//}
//
//-(BOOL) isValid:(NSData*)data
//{
//    return _coder->isValid((BYTE*)data.bytes, (int)data.length)?YES:NO;
//}
//
//-(NSUInteger) dataUsedLen
//{
//    return _coder->getCurrentSize();
//}
//
//-(void) enableBigEndian:(BOOL)big_endian
//{
//    _coder->enableBigEndian(big_endian);
//}
//
//+(BOOL) canParse:(NSData*)data
//{
//    return zy::BlControlCoder::canParse((BYTE*)data.bytes, (int)data.length)?YES:NO;
//}
//
//ZYBlData* buildBlWiFiPhotoData(const zy::BlWiFiPhotoMessage* message)
//{
//    int subType = message->subPhotoType();
//    if (subType == ZYBleInteractWifiCmdPhotoInfo) {
//        return [[ZYBlWiFiPhotoInfoData alloc] init];
//    } else if (subType == ZYBleInteractWifiCmdPhotoParam) {
//        if (dynamic_cast<const zy::BlWiFiPhotoParamMessage*>(message)) {
//            return [[ZYBlWiFiPhotoParamData alloc] init];
//        } else {
//            return [[ZYBlWiFiPhotoAllParamData alloc] init];
//        }
//    } else if (subType == ZYBleInteractWifiCmdPhotoCtrl) {
//        return [[ZYBlWiFiPhotoCtrlData alloc] init];
//    } else if (subType == ZYBleInteractWifiCmdPhotoNotice) {
//        return [[ZYBlWiFiPhotoNoticeData alloc] init];
//    }
//    return nil;
//}
//
//ZYBlData* buildBlWiFiData(const zy::BlWiFiMessage* message)
//{
//    int subType = message->subType();
//    if (subType == ZYBleInteractWifiCmdStatus) {
//        return [[ZYBlWiFiStatusData alloc] init];
//    } else if (subType == ZYBleInteractWifiCmdEnable) {
//        return [[ZYBlWiFiEnableData alloc] init];
//    } else if (subType == ZYBleInteractWifiCmdScan) {
//        return [[ZYBlWiFiScanData alloc] init];
//    } else if (subType == ZYBleInteractWifiCmdConnect) {
//        return [[ZYBlWiFiConnectionData alloc] init];
//    } else if (subType == ZYBleInteractWifiCmdClean) {
//        return [[ZYBlWiFiDevCleanData alloc] init];
//    } else if (subType == ZYBleInteractWifiCmdDevice) {
//        return [[ZYBlWiFiDeviceData alloc] init];
//    } else if (subType == ZYBleInteractWifiCmdErr) {
//        return [[ZYBlWiFiErrorData alloc] init];
//    } else if (subType == ZYBleInteractWifiCmdDisconnect) {
//        return [[ZYBlWiFiDisconnetData alloc] init];
//    } else if (subType == ZYBleInteractWifiCmdPhoto) {
//        return buildBlWiFiPhotoData((const zy::BlWiFiPhotoMessage*)message);
//    } else {
//        return [[ZYBlData alloc] init];
//    }
//}
//
+(ZYRdisData*) buildRdisData:(void*)data
{
    const zy::RdisMessage* message = (const zy::RdisMessage*)data;
    return [[ZYRdisData alloc]init];;
}

@end


