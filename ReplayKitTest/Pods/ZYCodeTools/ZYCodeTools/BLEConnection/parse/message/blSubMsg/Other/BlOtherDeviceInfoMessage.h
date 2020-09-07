//
//  BlOtherDeviceInfoMessage.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLOTHERDEVICEINFOMESSAGE_H__
#define __BLOTHERDEVICEINFOMESSAGE_H__

#include "BlOtherMessage.h"

NAMESPACE_ZY_BEGIN

class BlOtherDeviceInfoMessage : public BlOtherMessage
{
public:
    BlOtherDeviceInfoMessage();
    virtual ~BlOtherDeviceInfoMessage();
    
    bool buildRequest(const char* szDeviceInfo);
    virtual bool buildResponse(BYTE* data, int size);
    virtual int subType() const;
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint8 status;
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
    //response:
    char m_info[MAX_NAME_SIZE];
};

NAMESPACE_ZY_END

#endif /* __BLOTHERDEVICEINFOMESSAGE_H__ */
