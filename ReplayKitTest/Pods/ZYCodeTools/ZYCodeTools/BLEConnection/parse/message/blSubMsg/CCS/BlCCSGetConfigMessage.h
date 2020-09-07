//
//  BlCCSGetConfigMessage.hpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLCCSGETCONFIGMESSAGE_H__
#define __BLCCSGETCONFIGMESSAGE_H__

#include "BlCCSMessage.h"
#include "ccsTool.h"
#include <vector>

NAMESPACE_ZY_BEGIN

class BlCCSGetConfigMessage : public BlCCSMessage
{
public:
    BlCCSGetConfigMessage();
    virtual ~BlCCSGetConfigMessage();
    
    bool buildRequest(uint16 configIdx);
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
    //response
    std::vector<ccs_item_value> m_itemlist;
};

NAMESPACE_ZY_END

#endif /* __BLCCSGETCONFIGMESSAGE_H__ */
