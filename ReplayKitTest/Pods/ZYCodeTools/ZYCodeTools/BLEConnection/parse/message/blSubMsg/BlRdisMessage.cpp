//
//  BlRdisMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/8.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlRdisMessage.h"
#include <assert.h>
#include "RdisControlCoder.h"

static zy::RdisControlCoder rdisCoder;

NAMESPACE_ZY_BEGIN

BlRdisMessage::BlRdisMessage()
: BlMessage()
, m_rdisMessage(NULL)
{
}

BlRdisMessage::~BlRdisMessage()
{
    SAFE_RELEASE_PRT(m_rdisMessage);
}

bool BlRdisMessage::buildRequest(const RdisMessage* message)
{
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(RdisMessage::RDIS_ALL_INFO);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventRdis;
    
    int headLen = sizeof(m_head);
    
    BYTE* data;
    int len = 0;
    rdisCoder.encode(message, &data, &len);
    
    int allLen = headLen+len;
    BYTE* allData = (BYTE*)calloc(1, allLen);
    memcpy(allData, &m_head, headLen);
    memcpy(allData+headLen, data, len);
    setBody(allData, allLen, false);
    
    if (data != NULL) {
        free(data);
        data = NULL;
    }
    
    return true;
}

bool BlRdisMessage::buildResponse(BYTE* data, int size)
{
    assert(size == sizeof(RdisMessage::RDIS_ALL_INFO));
    
    m_rdisMessage = rdisCoder.decode(data, size);
    return true;
}

const RdisMessage* BlRdisMessage::getRdisMessage() const
{
    return m_rdisMessage;
}

NAMESPACE_ZY_END
