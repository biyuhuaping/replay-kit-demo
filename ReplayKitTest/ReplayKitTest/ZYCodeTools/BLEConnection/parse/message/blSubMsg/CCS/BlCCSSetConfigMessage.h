//
//  BlWiFiStatusMessage.hpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLCCSSETCONFIGMESSAGE_H__
#define __BLCCSSETCONFIGMESSAGE_H__

#include "BlCCSMessage.h"

NAMESPACE_ZY_BEGIN

class BlCCSSetConfigMessage : public BlCCSMessage
{
public:
    BlCCSSetConfigMessage();
    virtual ~BlCCSSetConfigMessage();
    
    bool buildRequest(int configIdx, const char* szValue);
    virtual bool buildResponse(BYTE* data, int size);
    virtual int subType() const;
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint8 status;
        uint16 configIdx;
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
    char* m_configValue;
};

NAMESPACE_ZY_END

#endif /* __BLCCSSETCONFIGMESSAGE_H__ */
