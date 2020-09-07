//
//  BlCCSAnsMessage.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLCCSANSMESSAGE_H__
#define __BLCCSANSMESSAGE_H__

#include "BlCCSMessage.h"
#include "StarMessage.h"

NAMESPACE_ZY_BEGIN

class BlCCSAnsMessage : public BlCCSMessage
{
public:
    BlCCSAnsMessage();
    virtual ~BlCCSAnsMessage();
    
    bool buildRequest();
    virtual bool buildResponse(BYTE* data, int size);
    virtual int subType() const;
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint8 status;
        uint8 cmdId;
        union{
            star_struct data;
            uint8 buff[STAR_DATA_LEN];
        } starData;
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
};

NAMESPACE_ZY_END

#endif /* __BLCCSANSMESSAGE_H__ */
