//
//  BlWiFiPhotoAllParamMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/8.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlWiFiPhotoAllParamMessage.h"
#include <assert.h>
#include "ccsTool.h"


NAMESPACE_ZY_BEGIN

BlWiFiPhotoAllParamMessage::BlWiFiPhotoAllParamMessage()
: zy::BlWiFiPhotoMessage()
{
}

BlWiFiPhotoAllParamMessage::~BlWiFiPhotoAllParamMessage()
{
    
}

bool BlWiFiPhotoAllParamMessage::buildRequest()
{
    m_data.body.cmdType = ZYBIWiFiDeviceCmdPhoto;
    m_data.body.photoCmdType = ZYBleInteractWifiCmdPhotoParams;
    
    BYTE* buff = m_data.buff;
    uint8 status = 0x00;
    FILL_VALUE_WITH_2_FIELD_BV(buff, sizeof(MSG_BODY), status, 1);
    setBody((BYTE*)data, dataLen, false);
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+dataLen;
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventWifi;
    
    return true;
}

bool BlWiFiPhotoAllParamMessage::buildResponse(BYTE* data, int size)
{
    int bodySize = sizeof(BlWiFiPhotoAllParamMessage::MSG_BODY);
    assert(size >= bodySize);
    memcpy(m_data.buff, data, bodySize);
    
    int offset = bodySize;
    //    size_t len = strlen((const char*)(data+offset));
    //    if (len > MAX_NAME_SIZE-1) {
    //        return false;
    //    }
    //    memcpy(m_info, data+offset, len+1);
    //    offset += len+1;
    //TODO 临时测试
    assert(size-bodySize == sizeof(m_allInfo));
    memcpy(&m_allInfo, data+offset, size-bodySize);
    offset += size-bodySize;
    
    assert(size == offset);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlWiFiPhotoAllParamMessage::subPhotoType() const
{
    return ZYBleInteractWifiCmdPhotoParams;
}

NAMESPACE_ZY_END
