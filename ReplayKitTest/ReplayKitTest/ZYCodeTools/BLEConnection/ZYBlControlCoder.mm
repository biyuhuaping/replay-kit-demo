//
//  ZYBLControlCoder.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlControlCoder.h"
#import "BlControlCoder.h"
#import "blMsgAll.h"
#import "ZYAllControlData.h"
#import "ZYBleProtocol.h"
#import "ZYBleProtocol_internal.h"

@interface ZYBlControlCoder()
{
    zy::BlControlCoder* _coder;
}
@end

@implementation ZYBlControlCoder

-(instancetype) init
{
    if ([super init]) {
        _coder = new zy::BlControlCoder();
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

-(NSData*) encode:(ZYBlData*)blData
{
    _coder->clear();
    zy::BlMessage* rawData = (zy::BlMessage*)[blData createRawData];
    BYTE* data;
    int len = 0;
    _coder->encode(rawData, &data, &len);
    NSData* retData = [NSData dataWithBytes:data length:len];
    free(data);
    data = NULL;
    
    return retData;
}

-(ZYBlData*) decode:(NSData*)data
{
    zy::BlMessage* message = _coder->decode((BYTE*)data.bytes, (int)data.length);
    if (message) {
        ZYBlData* blData = [ZYBlControlCoder buildBlData:message];
        [blData setRawData:message];
        blData.dataType = 1;
        return blData;
    }
    return nil;
}

+(NSString*) descriptionForBlData:(ZYBlData*)data
{
    zy::BlMessage* rawData = (zy::BlMessage*)[data createRawData];
    if (rawData != NULL) {
        const zy::BlMessage::head& head = rawData->getHead();
        if (head.command == ZYBleInteractEvent && head.status == ZYBleInteractEventAsyn) {
            const zy::BlAsynStarMessage* asynStarMessage = (const zy::BlAsynStarMessage*)rawData;
            return [NSString stringWithFormat:@"异步传输事件:%@", starCodeToNSString((NSUInteger)asynStarMessage->m_data.body.starData.data.code)];
        } else {
            char szTxt[128] = {"\0"};
            zy::BlControlCoder::getMessageText(rawData, szTxt, 128);
            return [NSString stringWithUTF8String:szTxt];
        }
    }
    return @"无效事件";
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
    return zy::BlControlCoder::canParse((BYTE*)data.bytes, (int)data.length)?YES:NO;
}

ZYBlData* buildBlWiFiPhotoData(const zy::BlWiFiPhotoMessage* message)
{
    int subType = message->subPhotoType();
    if (subType == ZYBleInteractWifiCmdPhotoInfo) {
        return [[ZYBlWiFiPhotoInfoData alloc] init];
    } else if (subType == ZYBleInteractWifiCmdPhotoParam) {
        return [[ZYBlWiFiPhotoParamData alloc] init];
    } else if (subType == ZYBleInteractWifiCmdPhotoCtrl) {
        return [[ZYBlWiFiPhotoCtrlData alloc] init];
    } else if (subType == ZYBleInteractWifiCmdPhotoNotice) {
        return [[ZYBlWiFiPhotoNoticeData alloc] init];
    } else if (subType == ZYBleInteractWifiCmdPhotoParams) {
        return [[ZYBlWiFiPhotoAllParamData alloc] init];
    }else if (subType == ZYBleInteractWifiCmdCameraInfo) {
        return [[ZYBlWiFiPhotoCameraInfoData alloc] init];
    }
    
    return nil;
}

ZYBlData* buildBlWiFiData(const zy::BlWiFiMessage* message)
{
    int subType = message->subType();
    if (subType == ZYBIWiFiDeviceCmdStatus) {
        return [[ZYBlWiFiStatusData alloc] init];
    } else if (subType == ZYBIWiFiDeviceCmdEnable) {
        return [[ZYBlWiFiEnableData alloc] init];
    } else if (subType == ZYBIWiFiDeviceCmdScan) {
        return [[ZYBlWiFiScanData alloc] init];
    } else if (subType == ZYBIWiFiDeviceCmdConnect) {
        return [[ZYBlWiFiConnectionData alloc] init];
    } else if (subType == ZYBIWiFiDeviceCmdClean) {
        return [[ZYBlWiFiDevCleanData alloc] init];
    } else if (subType == ZYBIWiFiDeviceCmdDevice) {
        return [[ZYBlWiFiDeviceData alloc] init];
    } else if (subType == ZYBIWiFiDeviceCmdErr) {
        return [[ZYBlWiFiErrorData alloc] init];
    } else if (subType == ZYBIWiFiDeviceCmdDisconnect) {
        return [[ZYBlWiFiDisconnetData alloc] init];
    } else if (subType == ZYBIWiFiDeviceCmdPhoto) {
        return buildBlWiFiPhotoData((const zy::BlWiFiPhotoMessage*)message);
    } else if (subType == ZYBIWiFiHotspotCmdStatus) {
        return [[ZYBlWiFiHotspotStatusData alloc] init];
    } else if (subType == ZYBIWiFiHotspotCmdEnable) {
        return [[ZYBlWiFiHotspotEnableData alloc] init];
    } else if (subType == ZYBIWiFiHotspotCmdDisable) {
        return [[ZYBlWiFiHotspotDisableData alloc] init];
    } else if (subType == ZYBIWiFiHotspotCmdReset) {
        return [[ZYBlWiFiHotspotResetData alloc] init];
    } else if (subType == ZYBIWiFiHotspotCmdDhcpClean) {
        return [[ZYBlWiFiHotspotDHCPCleanData alloc] init];
    } else if (subType == ZYBIWiFiHotspotCmdGetSSID) {
        return [[ZYBlWiFiHotspotGetSSIDData alloc] init];
    } else if (subType == ZYBIWiFiHotspotCmdPSW) {
        return [[ZYBlWiFiHotspotPSWData alloc] init];
    } else if (subType == ZYBIWiFiHotspotCmdSetPSW) {
        return [[ZYBlWiFiHotspotSetPSWData alloc] init];
    } else if (subType == ZYBIWiFiHotspotCmdCHN) {
        return [[ZYBlWiFiHotspotSetGetChannel alloc] init];
    } else if (subType == ZYBIWiFiHotspotCmdGET_CHNLIST) {
        return [[ZYBlWiFiHotspotGetCHNList alloc] init];
    } else if (subType == ZYBIWiFiHotspotCmdCHN_SCAN) {
        return [[ZYBlWiFiHotspotScan alloc] init];
    } else {
        return [[ZYBlData alloc] init];
    }
}

ZYBlData* buildBlCCSData(const zy::BlCCSMessage* message)
{
    int subType = message->subType();
    if (subType == ZYBICCSCmdSetConfigValue) {
        return [[ZYBlCCSSetConfigData alloc] init];
    } else if (subType == ZYBICCSCmdGetConfigValue) {
        return [[ZYBlCCSGetConfigData alloc] init];
    } else if (subType == ZYBICCSCmdGetConfigItems) {
        return [[ZYBlCCSGetAvailableConfigData alloc] init];
    } else if (subType == ZYBICCSCmdAns) {
        return [[ZYBlCCSAnsData alloc] init];
    } else {
        return [[ZYBlData alloc] init];
    }
}


ZYBlData* buildStoryData(const zy::BlOtherMessage* message)
{
    int subType = message->subType();
    if (subType == ZYBISTORY_CMD_CTRL_POSITION) {
        return [[ZYBlStoryCtrlPositionData alloc] init];
    }else if (subType == ZYBISTORY_CMD_CTRL_SPEED){
        return [[ZYBlStoryCtrlSpeedData alloc] init];
    }else {
        return [[ZYBlData alloc] init];
    }
}


ZYBlData* buildBlOtherData(const zy::BlOtherMessage* message)
{
    int subType = message->subType();
    if (subType == ZYBIOtherCmdCheckMD5) {
        return [[ZYBlOtherCheckMD5Data alloc] init];
    } else if (subType == ZYBIOtherCmdFileAsyn) {
        return [[ZYBlOtherFileAsynData alloc] init];
    } else if (subType == ZYBIOtherCmdDeviceInfo) {
        return [[ZYBlOtherDeviceInfoData alloc] init];
    }else if (subType == ZYBIOtherCmdSystemTime) {
        return [[ZYBlOtherSystemTimeData alloc] init];
    }else if (subType == ZYBIOtherCmdCustomFile) {
        return [[ZYBlOtherCustomFileData alloc] init];
    } else if (subType == ZYBIOtherCmdSyncData) {
        return [[ZYBlOtherSyncData alloc] init];
    }else if (subType == ZYBIOtherCmdPathData) {
        return [[ZYBlOtherPathData alloc] init];
    }else if (subType == ZYBIOtherCmdDeviceType) {
        return [[ZYBlOtherDeviceTypeData alloc] init];
    }else if (subType == ZYBIOtherCmdMoveLineStatue) {
        return [[ZYBlOtherCmdMoveLineStatueData alloc] init];
    }else if (subType == ZYBIOtherCmdOTAWAIT) {
        return [[ZYBlOtherOTAWaitData alloc] init];
    }else if (subType == ZYBIOtherHeart) {
        return [[ZYBlOtherHeart alloc] init];
    }else if (subType == ZYBIOtherCHECK_ACTIVEINFO) {
        return [[ZYBlCheckActiveInfoData alloc] init];
    }else if (subType == ZYBIOtherSET_ACTIVEINFO) {
        return [[ZYBlSendActiveKeyData alloc] init];
    }else if (subType == ZYBIOtherKEYFUNC_DEFINE_SET) {
        return [[ZYBlKeyFuncSetData alloc] init];
    }else if (subType == ZYBIOtherKEYFUNC_DEFINE_READ) {
        return [[ZYKeyFuncReadData alloc] init];
    }else if (subType == ZYBIOtherTRACKING_MODE) {
        return [[ZYCMDTrackingModeData alloc] init];
    }else if (subType == ZYBIOtherTRACKING_ANCHOR) {
        return [[ZYCMDTrackingAnchorData alloc] init];
    }else {
        return [[ZYBlData alloc] init];
    }
    
}

+(ZYBlData*) buildBlData:(void*)data
{
    const zy::BlMessage* message = (const zy::BlMessage*)data;
    if(message != NULL) {
        const zy::BlMessage::head& head = message->getHead();
        if (head.command == ZYBleInteractEvent) {
            if (head.status == ZYBleInteractEventAsyn) {
                return [[ZYBlAsynStarData alloc] init];
            } else if (head.status == ZYBleInteractEventHandle) {
                return [[ZYBlHandleData alloc] init];
            } else if (head.status == ZYBleInteractEventRdis) {
                return [[ZYBlRdisData alloc] init];
            } else if (head.status == ZYBleInteractEventWifi) {
                return buildBlWiFiData((const zy::BlWiFiMessage*)message);
            } else if (head.status == ZYBleInteractEventCCS) {
                return buildBlCCSData((const zy::BlCCSMessage*)message);
            } else if (head.status == ZYBleInteractEventOther) {
                return buildBlOtherData((const zy::BlOtherMessage*)message);
            } else if (head.status == ZYBleInteractEventSTORY) {
                return buildStoryData((const zy::BlOtherMessage*)message);
            }else if (head.status == ZYBleInteractEventTrack) {
                return [[ZYBlTrackData alloc] init];
            } else {
                return [[ZYBlData alloc] init];
            }
        } else {
            return [[ZYBlData alloc] init];
        }
    }
    return nil;
}

@end


