//
//  BlCCSAnsMessage.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLOTHERCHECKMD5MESSAGE_H__
#define __BLOTHERCHECKMD5MESSAGE_H__

#include "BlOtherMessage.h"

NAMESPACE_ZY_BEGIN

class BlOtherCheckMD5Message : public BlOtherMessage
{
public:
    BlOtherCheckMD5Message();
    virtual ~BlOtherCheckMD5Message();
    
    bool buildRequest(const char* szMD5);
    virtual bool buildResponse(BYTE* data, int size);
    virtual int subType() const;
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
    //response:
    uint8 m_status;
    
};

NAMESPACE_ZY_END

#endif /* __BLOTHERCHECKMD5MESSAGE_H__ */
