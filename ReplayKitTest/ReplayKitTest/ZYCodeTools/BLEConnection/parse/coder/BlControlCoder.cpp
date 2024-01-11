//
//  BlControlCoder.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlControlCoder.h"
#include "crc.h"
#include "blMsgdef.h"
#include "blMsgAll.h"
#include <assert.h>

#define CHECK_HEAD_CODE(data, Code) (((data[1]<<8) | data[0]) == Code)
#define MAX_INFO_LEN 128

NAMESPACE_ZY_BEGIN

BlMessage* buildBlMessage(const BlMessage::head& head, BYTE* body, int bodyLen, int crc);
void getBlWiFiMessageTxt(const BlWiFiMessage* message, char* szText, int size);
void getBlWiFiPhotoMessageTxt(const BlWiFiPhotoMessage* message, char* szText, int size);
void getBlCCSMessageTxt(const BlCCSMessage* message, char* szText, int size);
void getBlOtherMessageTxt(const BlOtherMessage* message, char* szText, int size);
void getBlStoryMessageTxt(const BlStoryMessage* message, char* szText, int size);
BlControlCoder::BlControlCoder()
: ControlCoder()
{
    enableBigEndian(false);
}

BlControlCoder::~BlControlCoder()
{
    
}

int BlControlCoder::pushValue(const BlMessage::head& head, BYTE* body, int bodyLen)
{
    this->writeData((BYTE*)&head, sizeof(BlMessage::head));
    this->writeData(body, bodyLen);
    
    int offset = (sizeof(head)-2);
    unsigned int crc = zy::crc(this->getBuffer()+offset, this->getCurrentSize()-offset);
    this->writeValue(crc, 2, m_bigEndian);
    return m_current;
}

int BlControlCoder::popValue(BlMessage::head& head, BYTE** body, int* bodyLen, unsigned short* crc)
{
    this->readData((BYTE*)&head, sizeof(BlMessage::head));
    *bodyLen = head.lenght-2;
    *body = (BYTE*)malloc(*bodyLen);
    this->readData(*body, *bodyLen);
    unsigned int crcValue;
    this->readValue(&crcValue, 2, m_bigEndian);
    *crc = crcValue;
    return 0;
}

int BlControlCoder::encode(BYTE** data, int* len, bool isCopy)
{
    //memcpy(*data, m_buff+dataStart, dataLen);
    int dataLen = this->getCurrentSize();
    if (!isCopy) {
        *len = dataLen;
        *data = (BYTE*)malloc(dataLen);
    }
    memcpy(*data, m_buff, dataLen);
    return dataLen;
}

int BlControlCoder::encode(const BlMessage* message, BYTE** data, int* len)
{
    this->pushValue(message->getHead(), message->getBody(), message->getBodySize());
    this->encode(data, len, false);
    return *len;
}

BlMessage* BlControlCoder::decode(BYTE* data, int len)
{
    BlMessage::head head;
    if (this->tryParseHead(data, len, &head)) {
        int totalLen = calcBlMessageLength(&head);
        
        BlMessage::head head;
        BYTE* body = NULL;
        int bodyLen = 0;
        unsigned short crc = 0;
        
        this->resetData(data, totalLen);
        this->popValue(head, &body, &bodyLen, &crc);
        
        BlMessage* message = buildBlMessage(head, body, bodyLen, crc);
        
        //TODO 缺少crc
        return message;
    }
    return NULL;
}

bool BlControlCoder::isValid(BYTE* data, int len)
{
    BlMessage::head head;
    return this->tryParseHead(data, len, &head);
}

bool BlControlCoder::tryParseHead(BYTE* data, int len, BlMessage::head* head)
{
    if (len < 2)
        return false;
    if (!(CHECK_HEAD_CODE(data, BL_HEAD_CODE_SEND)
          || CHECK_HEAD_CODE(data, BL_HEAD_CODE_RECV))) {
        return false;
    }
    if (len < sizeof(BlMessage::head)) {
        return false;
    }
    
    memcpy(head, data, sizeof(BlMessage::head));
    
    int totalLen = calcBlMessageLength(head);
    if (len < totalLen) {
        return false;
    }
    
    return true;
}

bool BlControlCoder::canParse(BYTE* data, int len)
{
    if (len < 2)
        return false;
    
    if (!(CHECK_HEAD_CODE(data, BL_HEAD_CODE_SEND)
          || CHECK_HEAD_CODE(data, BL_HEAD_CODE_RECV))) {
        return false;
    }
    
    return true;
}

void BlControlCoder::getMessageText(const BlMessage* message, char* szText, int size)
{
    const int txtlen = MAX_INFO_LEN;
    char messageTxt[txtlen];
    memset(messageTxt, 0, txtlen);
    snprintf(messageTxt, txtlen-1, "%s", "unknown bl message");
    const BlMessage::head& head = message->getHead();
    if (head.command == ZYBleInteractEvent) {
        if (head.status == ZYBleInteractEventAsyn) {
            snprintf(messageTxt, txtlen-1, "%s", "异步传输事件");
        } else if (head.status == ZYBleInteractEventRdis) {
            snprintf(messageTxt, txtlen-1, "%s", "RDIS控制数据事件");
        } else if (head.status == ZYBleInteractEventHandle) {
            snprintf(messageTxt, txtlen-1, "%s", "手柄事件");
        } else if (head.status == ZYBleInteractEventWifi) {
            char wifiMessageTxt[txtlen];
            memset(wifiMessageTxt, 0, txtlen);
            getBlWiFiMessageTxt((const BlWiFiMessage*)message, wifiMessageTxt, txtlen);
            snprintf(messageTxt, txtlen-1, "%s_%s", "wifi控制事件", wifiMessageTxt);
        } else if (head.status == ZYBleInteractEventOther) {
            char wifiMessageTxt[txtlen];
            memset(wifiMessageTxt, 0, txtlen);
            getBlOtherMessageTxt((const BlOtherMessage*)message, wifiMessageTxt, txtlen);
            snprintf(messageTxt, txtlen-1, "%s_%s", "其他控制事件", wifiMessageTxt);
        } else if (head.status == ZYBleInteractEventCCS) {
            char wifiMessageTxt[txtlen];
            memset(wifiMessageTxt, 0, txtlen);
            getBlCCSMessageTxt((const BlCCSMessage*)message, wifiMessageTxt, txtlen);
            snprintf(messageTxt, txtlen-1, "%s_%s", "相机控制系统事件", wifiMessageTxt);
        }else if (head.status == ZYBleInteractEventSTORY) {
            char storyMessageTxt[txtlen];
            memset(storyMessageTxt, 0, txtlen);
            getBlStoryMessageTxt((const BlStoryMessage*)message, storyMessageTxt, txtlen);
            snprintf(messageTxt, txtlen-1, "%s_%s", "Story控制系统事件", storyMessageTxt);
        }  else if (head.status == ZYBleInteractEventTrack) {
            snprintf(messageTxt, txtlen-1, "%s", "跟踪事件");
        }
    } else if (head.command == ZYBleInteractSync) {
        snprintf(messageTxt, txtlen-1, "%s", "同步及获取设备信息");
    } else if (head.command == ZYBleInteractUpdateWrite) {
        snprintf(messageTxt, txtlen-1, "%s", "向设备写入固件");
    } else if (head.command == ZYBleInteractCheck) {
        snprintf(messageTxt, txtlen-1, "%s", "校验设备固件");
    } else if (head.command == ZYBleInteractByPass) {
        snprintf(messageTxt, txtlen-1, "%s", "旁路设备，使其向下转发所接收的命令");
    } else if (head.command == ZYBleInteractReset) {
        snprintf(messageTxt, txtlen-1, "%s", "重启设备");
    } else if (head.command == ZYBleInteractAppgo) {
        snprintf(messageTxt, txtlen-1, "%s", "运行设备");
    } else if (head.command == ZYBleInteractBootReset) {
        snprintf(messageTxt, txtlen-1, "%s", "重启设备并进入升级模式");
    }
    snprintf(szText, size-1, "%s", messageTxt);
}


int BlControlCoder::calcBlMessageLength(const BlMessage::head* head)
{
    return sizeof(BlMessage::head)-2+head->lenght+2;
}

BlWiFiPhotoMessage* buildBlWifiPhotoMessage(BYTE* body, int bodyLen)
{
    BlWiFiPhotoMessage* message = NULL;
    int photoCmdType = body[1];
    uint8 photoParamId;
    if (photoCmdType == ZYBleInteractWifiCmdPhotoInfo) {
        message = new BlWiFiPhotoInfoMessage();
    } else if (photoCmdType == ZYBleInteractWifiCmdPhotoParam) {
        message = new BlWiFiPhotoParamMessage();
    } else if (photoCmdType == ZYBleInteractWifiCmdPhotoCtrl) {
        message = new BlWiFiPhotoCtrlMessage();
    } else if (photoCmdType == ZYBleInteractWifiCmdPhotoNotice) {
        message = new BlWiFiPhotoNoticeMessage();
    } else if (photoCmdType == ZYBleInteractWifiCmdPhotoParams) {
        message = new BlWiFiPhotoAllParamMessage();
    }
    else if (photoCmdType == ZYBleInteractWifiCmdCameraInfo) {
        message = new BlWiFiPhotoCameraInfoMessage();
    }
    
    return message;
}

BlWiFiMessage* buildBlWifiMessage(BYTE* body, int bodyLen)
{
    BlWiFiMessage* message = NULL;
    int cmdType = body[0];
    if (cmdType == ZYBIWiFiDeviceCmdKey) {
        message = new BlWiFiMessage();
    } else if (cmdType == ZYBIWiFiDeviceCmdStatus) {
        message = new BlWiFiStatusMessage();
    } else if (cmdType == ZYBIWiFiDeviceCmdEnable) {
        message = new BlWiFiEnableMessage();
    } else if (cmdType == ZYBIWiFiDeviceCmdScan) {
        message = new BlWiFiScanMessage();
    } else if (cmdType == ZYBIWiFiDeviceCmdConnect) {
        message = new BlWiFiConnectionMessage();
    } else if (cmdType == ZYBIWiFiDeviceCmdClean) {
        message = new BlWiFiDevCleanMessage();
    } else if (cmdType == ZYBIWiFiDeviceCmdDevice) {
        message = new BlWiFiDeviceMessage();
    } else if (cmdType == ZYBIWiFiDeviceCmdErr) {
        message = new BlWiFiErrorMessage();
    } else if (cmdType == ZYBIWiFiDeviceCmdDisconnect) {
        message = new BlWiFiDisconnectMessage();
    } else if (cmdType == ZYBIWiFiDeviceCmdPhoto) {
        return buildBlWifiPhotoMessage(body, bodyLen);
    } else if (cmdType == ZYBIWiFiHotspotCmdStatus) {
        message = new BlWiFiHotspotStatusMessage();
    } else if (cmdType == ZYBIWiFiHotspotCmdEnable) {
        message = new BlWiFiHotspotEnableMessage();
    } else if (cmdType == ZYBIWiFiHotspotCmdDisable) {
        message = new BlWiFiHotspotDisableMessage();
    } else if (cmdType == ZYBIWiFiHotspotCmdReset) {
        message = new BlWiFiHotspotResetMessage();
    } else if (cmdType == ZYBIWiFiHotspotCmdDhcpClean) {
        message = new BlWiFiHotspotDHCPCleanMessage();
    } else if (cmdType == ZYBIWiFiHotspotCmdGetSSID) {
        message = new BlWiFiHotspotGetSSIDMessage();
    } else if (cmdType == ZYBIWiFiHotspotCmdPSW) {
        message = new BlWiFiHotspotPSWMessage();
    } else if (cmdType == ZYBIWiFiHotspotCmdSetPSW) {
        message = new BlWiFiHotspotSETPSWMessage();
    } else if (cmdType == ZYBIWiFiHotspotCmdCHN) {
        message = new BlWiFiHotspotCHNMessage();
    } else if (cmdType == ZYBIWiFiHotspotCmdGET_CHNLIST) {
        message = new BlWiFiHotspotGET_CHNLISTMessage();
    } else if (cmdType == ZYBIWiFiHotspotCmdCHN_SCAN) {
        message = new BlWiFiHotspotCHN_SCANMessage();
    } else {
        assert(false);
    }
    return message;
}

BlCCSMessage* buildBlCCSMessage(BYTE* body, int bodyLen)
{
    BlCCSMessage* message = NULL;
    int cmdType = body[0];
    if (cmdType == ZYBICCSCmdSetConfigValue) {
        message = new BlCCSSetConfigMessage();
    } else if (cmdType == ZYBICCSCmdGetConfigValue) {
        message = new BlCCSGetConfigMessage();
    } else if (cmdType == ZYBICCSCmdGetConfigItems) {
        message = new BlCCSGetAvailableConfigMessage();
    } else if (cmdType == ZYBICCSCmdAns) {
        message = new BlCCSAnsMessage();
    } else {
        assert(false);
    }
    return message;
}

BlStoryMessage* buildBlStoryMessage(BYTE* body, int bodyLen)
{
    BlStoryMessage* message = NULL;
    int cmdType = body[0];
    if (cmdType == ZYBISTORY_CMD_CTRL_POSITION) {
        message = new BlStoryCtrlPositionMessage();
    } else if (cmdType == ZYBISTORY_CMD_CTRL_SPEED) {
        message = new BlStoryCtrlSpeedMessage();
    }  else {
        assert(false);
    }
    return message;
}

BlOtherMessage* buildBlOtherMessage(BYTE* body, int bodyLen)
{
    BlOtherMessage* message = NULL;
    int cmdType = body[0];
    if (cmdType == ZYBIOtherCmdCheckMD5) {
        message = new BlOtherCheckMD5Message();
    } else if (cmdType == ZYBIOtherCmdFileAsyn) {
        message = new BlOtherFileAsynMessage();
    } else if (cmdType == ZYBIOtherCmdDeviceInfo) {
        message = new BlOtherDeviceInfoMessage();
    } else if (cmdType == ZYBIOtherCmdSystemTime) {
        message = new BlOtherSystemTimeMessage();
    } else if (cmdType == ZYBIOtherCmdCustomFile) {
        message = new BlOtherCustomFileMessage();
    } else if (cmdType == ZYBIOtherCmdPathData) {
        message = new BlOtherCMDPathDataMessage();
    } else if (cmdType == ZYBIOtherCmdSyncData) {
        message = new BlOtherCMDSyncDataMessage();
    } else if (cmdType == ZYBIOtherCmdDeviceType) {
        message = new BlOtherCMDDeviceTypeMessage();
    }else if (cmdType == ZYBIOtherCmdMoveLineStatue) {
        message = new BlOtherMoveLineStatusMessage();
    } else if (cmdType == ZYBIOtherCmdOTAWAIT) {
        message = new BlOtherOTAWaitMessage();
    }else if (cmdType == ZYBIOtherHeart) {
        message = new BlOtherHeartMessage();
    }else if (cmdType == ZYBIOtherCHECK_ACTIVEINFO) {
        message = new BlOtherCMD_CHECK_ACTIVEINFOMessage();
    }else if (cmdType == ZYBIOtherSET_ACTIVEINFO) {
        message = new BlOtherCMD_SEND_ACTIVEKEYMessage();
    }else if (cmdType == ZYBIOtherKEYFUNC_DEFINE_SET) {
        message = new BlOtherCMD_KEYFUNC_DEFINE_SETMessage();
    }else if (cmdType == ZYBIOtherKEYFUNC_DEFINE_READ) {
        message = new BlOtherCMD_KEYFUNC_DEFINE_READMessage();
    }else if (cmdType == ZYBIOtherTRACKING_MODE) {
        message = new BlOtherCMD_TRACKING_MODEMessage();
    }else if (cmdType == ZYBIOtherTRACKING_ANCHOR) {
        message = new BlOtherCMD_TRACKING_ANCHORMessage();
    }else {
//        assert(false);
    }
    return message;
}

BlMessage* buildBlMessage(const BlMessage::head& head, BYTE* body, int bodyLen, int crc)
{
    BlMessage* message = NULL;
    if (head.command == ZYBleInteractEvent) {
        if (head.status == ZYBleInteractEventAsyn) {
            message = new BlAsynStarMessage();
        } else if (head.status == ZYBleInteractEventHandle) {
            message = new BlHandleMessage();
        } else if (head.status == ZYBleInteractEventRdis) {
            message = new BlRdisMessage();
        } else if (head.status == ZYBleInteractEventWifi) {
            message = buildBlWifiMessage(body, bodyLen);
        } else if (head.status == ZYBleInteractEventOther) {
            message = buildBlOtherMessage(body, bodyLen);
        } else if (head.status == ZYBleInteractEventCCS) {
            message = buildBlCCSMessage(body, bodyLen);
        } else if (head.status == ZYBleInteractEventSTORY) {
            message = buildBlStoryMessage(body, bodyLen);
        }else if (head.status == ZYBleInteractEventTrack) {
            message = new BlTrackMessage();
        }
    }
    if (message == NULL) {
        message = new BlMessage();
    }
    message->setHead(head);
    message->buildResponse(body, bodyLen);
    message->setCrc(crc);
    return message;
}

void getBlWiFiMessageTxt(const BlWiFiMessage* message, char* szText, int size)
{
    const int txtlen = MAX_INFO_LEN;
    char messageTxt[txtlen];
    memset(messageTxt, 0, txtlen);
    snprintf(messageTxt, txtlen-1, "%s", "unkown bl WiFi message");
    int cmdType = message->subType();
    if (cmdType == ZYBIWiFiDeviceCmdKey) {
        snprintf(messageTxt, txtlen-1, "%s", "传输键值");
    } else if (cmdType == ZYBIWiFiDeviceCmdStatus) {
        snprintf(messageTxt, txtlen-1, "%s", "获取wifi模块状态");
    } else if (cmdType == ZYBIWiFiDeviceCmdEnable) {
        snprintf(messageTxt, txtlen-1, "%s", "使能/关闭WIFI模块");
    } else if (cmdType == ZYBIWiFiDeviceCmdScan) {
        snprintf(messageTxt, txtlen-1, "%s", "开始/停止扫描");
    } else if (cmdType == ZYBIWiFiDeviceCmdConnect) {
        snprintf(messageTxt, txtlen-1, "%s", "连接wifi设备");
    } else if (cmdType == ZYBIWiFiDeviceCmdClean) {
        snprintf(messageTxt, txtlen-1, "%s", "清除连接设备信息");
    } else if (cmdType == ZYBIWiFiDeviceCmdDevice) {
        snprintf(messageTxt, txtlen-1, "%s", "获取扫描到的设备信息");
    } else if (cmdType == ZYBIWiFiDeviceCmdErr) {
        snprintf(messageTxt, txtlen-1, "%s", "获取错误代码");
    } else if (cmdType == ZYBIWiFiDeviceCmdDisconnect) {
        snprintf(messageTxt, txtlen-1, "%s", "中断连接");
    } else if (cmdType == ZYBIWiFiDeviceCmdPhoto) {
        char wifiMessageTxt[txtlen];
        memset(wifiMessageTxt, 0, txtlen);
        getBlWiFiPhotoMessageTxt((const BlWiFiPhotoMessage*)message, wifiMessageTxt, txtlen);
        snprintf(messageTxt, txtlen-1, "%s_%s", "相机控制相关指令", wifiMessageTxt);
    } else if (cmdType == ZYBIWiFiHotspotCmdStatus) {
        snprintf(messageTxt, txtlen-1, "%s", "获取wifi模块状态");
    } else if (cmdType == ZYBIWiFiHotspotCmdEnable) {
        snprintf(messageTxt, txtlen-1, "%s", "使能WIFI模块");
    } else if (cmdType == ZYBIWiFiHotspotCmdDisable) {
        snprintf(messageTxt, txtlen-1, "%s", "禁能WIFI模块");
    } else if (cmdType == ZYBIWiFiHotspotCmdReset) {
        snprintf(messageTxt, txtlen-1, "%s", "重启wifi模块");
    } else if (cmdType == ZYBIWiFiHotspotCmdDhcpClean) {
        snprintf(messageTxt, txtlen-1, "%s", "清除DHCP池中的设备信息");
    } else if (cmdType == ZYBIWiFiHotspotCmdGetSSID) {
        snprintf(messageTxt, txtlen-1, "%s", "获取wifi模块广播名");
    } else if (cmdType == ZYBIWiFiHotspotCmdPSW) {
        snprintf(messageTxt, txtlen-1, "%s", "获取wifi模块密码");
    }else if (cmdType == ZYBIWiFiHotspotCmdSetPSW) {
        snprintf(messageTxt, txtlen-1, "%s", "设置wifi模块密码");
    }
    snprintf(szText, size-1, "%s", messageTxt);
}

void getBlWiFiPhotoMessageTxt(const BlWiFiPhotoMessage* message, char* szText, int size)
{
    const int txtlen = MAX_INFO_LEN;
    char messageTxt[txtlen];
    memset(messageTxt, 0, txtlen);
    snprintf(messageTxt, txtlen-1, "%s", "unkown bl WiFi Photo message");
    int cmdType = message->subPhotoType();
    if (cmdType == ZYBleInteractWifiCmdPhotoInfo) {
        snprintf(messageTxt, txtlen-1, "%s", "查询相机信息");
    } else if (cmdType == ZYBleInteractWifiCmdPhotoParam) {
        snprintf(messageTxt, txtlen-1, "%s", "查询相机参数");
    } else if (cmdType == ZYBleInteractWifiCmdPhotoCtrl) {
        snprintf(messageTxt, txtlen-1, "%s", "相机操作指令");
    } else if (cmdType == ZYBleInteractWifiCmdPhotoNotice) {
        snprintf(messageTxt, txtlen-1, "%s", "通知参数变更");
    } else if (cmdType == ZYBleInteractWifiCmdPhotoParams) {
        snprintf(messageTxt, txtlen-1, "%s", "查询相机所有参数");
    }else if (cmdType == ZYBleInteractWifiCmdCameraInfo) {
        snprintf(messageTxt, txtlen-1, "%s", "获取或者设置相机型号");
    }
    snprintf(szText, size-1, "%s", messageTxt);
}

void getBlOtherMessageTxt(const BlOtherMessage* message, char* szText, int size)
{
    const int txtlen = MAX_INFO_LEN;
    char messageTxt[txtlen];
    memset(messageTxt, 0, txtlen);
    snprintf(messageTxt, txtlen-1, "%s", "unkown bl Other message");
    int cmdType = message->subType();
    if (cmdType == ZYBIOtherCmdCheckMD5) {
        snprintf(messageTxt, txtlen-1, "%s", "MD5值校验");
    } else if (cmdType == ZYBIOtherCmdFileAsyn) {
        snprintf(messageTxt, txtlen-1, "%s", "文件是否异步传输");
    } else if (cmdType == ZYBIOtherCmdDeviceInfo) {
        snprintf(messageTxt, txtlen-1, "%s", "检查当前设备能否控制图传设备");
    } else if (cmdType == ZYBIOtherCmdSystemTime) {
        snprintf(messageTxt, txtlen-1, "%s", "同步手机，稳定器系统时间");
    } else if (cmdType == ZYBIOtherCmdCustomFile) {
        snprintf(messageTxt, txtlen-1, "%s", "传输文件");
    }
    else if (cmdType == ZYBIOtherCmdPathData) {
        snprintf(messageTxt, txtlen-1, "%s", "路径");
    }
    else if (cmdType == ZYBIOtherCmdSyncData) {
        snprintf(messageTxt, txtlen-1, "%s", "同步状态");
    }
    else if (cmdType == ZYBIOtherCmdDeviceType) {
        snprintf(messageTxt, txtlen-1, "%s", "设备类型");
    }
    else if (cmdType == ZYBIOtherCmdMoveLineStatue) {
        snprintf(messageTxt, txtlen-1, "%s", "离线延时状态指示");
    }else if (cmdType == ZYBIOtherCmdOTAWAIT) {
        snprintf(messageTxt, txtlen-1, "%s", "CMD_OTA_WAIT等待");
    }else if (cmdType == ZYBIOtherHeart) {
        snprintf(messageTxt, txtlen-1, "%s", "HID_心跳");
    }else if (cmdType == ZYBIOtherCHECK_ACTIVEINFO) {
        snprintf(messageTxt, txtlen-1, "%s", "检查是否激活设备");
    }else if (cmdType == ZYBIOtherSET_ACTIVEINFO) {
        snprintf(messageTxt, txtlen-1, "%s", "发送激活密钥");
    }else if (cmdType == ZYBIOtherKEYFUNC_DEFINE_SET) {
        snprintf(messageTxt, txtlen-1, "%s", "设置按键类型");
    }else if (cmdType == ZYBIOtherKEYFUNC_DEFINE_READ) {
        snprintf(messageTxt, txtlen-1, "%s", "读取按键类型");
    }else if (cmdType == ZYBIOtherTRACKING_MODE) {
        snprintf(messageTxt, txtlen-1, "%s", "跟踪模式的设置和读取");
    }else if (cmdType == ZYBIOtherTRACKING_ANCHOR) {
        snprintf(messageTxt, txtlen-1, "%s", "锚点的设置和读取");
    }
    
    snprintf(szText, size-1, "%s", messageTxt);
}

void getBlCCSMessageTxt(const BlCCSMessage* message, char* szText, int size)
{
    const int txtlen = MAX_INFO_LEN;
    char messageTxt[txtlen];
    memset(messageTxt, 0, txtlen);
    snprintf(messageTxt, txtlen-1, "%s", "unkown bl CCS message");
    int cmdType = message->subType();
    if (cmdType == ZYBICCSCmdSetConfigValue) {
        snprintf(messageTxt, txtlen-1, "%s", "设定指定CONFIG当前值");
    } else if (cmdType == ZYBICCSCmdGetConfigValue) {
        snprintf(messageTxt, txtlen-1, "%s", "获取指定CONFIG当前值");
    } else if (cmdType == ZYBICCSCmdGetConfigItems) {
        snprintf(messageTxt, txtlen-1, "%s", "获取指定CONFIG的可用项列表");
    } else if (cmdType == ZYBICCSCmdAns) {
        snprintf(messageTxt, txtlen-1, "%s", "相机控制应答指令");
    }
    snprintf(szText, size-1, "%s", messageTxt);
}

void getBlStoryMessageTxt(const BlStoryMessage* message, char* szText, int size)
{
    const int txtlen = MAX_INFO_LEN;
    char messageTxt[txtlen];
    memset(messageTxt, 0, txtlen);
    snprintf(messageTxt, txtlen-1, "%s", "unkown bl Story message");
    int cmdType = message->subType();
    if (cmdType == ZYBISTORY_CMD_CTRL_POSITION) {
        snprintf(messageTxt, txtlen-1, "%s", "角度控制方式");
    } else if (cmdType == ZYBISTORY_CMD_CTRL_SPEED) {
        snprintf(messageTxt, txtlen-1, "%s", "速度控制方式");
    }
    snprintf(szText, size-1, "%s", messageTxt);
}

NAMESPACE_ZY_END
