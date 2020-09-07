//
//  BlAsynStarMessage.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/8.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLASYNSTARMESSAGE_H__
#define __BLASYNSTARMESSAGE_H__

#include "BlMessage.h"
#include "StarMessage.h"


NAMESPACE_ZY_BEGIN

class BlAsynStarMessage : public BlMessage
{
public:
    BlAsynStarMessage();
    virtual ~BlAsynStarMessage();
    
    bool buildRequest(uint16 code, uint16 param);
    virtual bool buildResponse(BYTE* data, int size);
    
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
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

#endif /* __BLASYNSTARMESSAGE_H__ */
