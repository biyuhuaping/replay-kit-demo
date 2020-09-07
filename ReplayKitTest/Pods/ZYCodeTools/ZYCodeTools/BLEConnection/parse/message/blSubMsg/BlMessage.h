//
//  BlMessage.hpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLMESSAGE_H__
#define __BLMESSAGE_H__

#include <stdio.h>
#include "common_def.h"
#include "BaseMessage.h"
#include "blMsgdef.h"

NAMESPACE_ZY_BEGIN

class BlMessage : public BaseMessage
{
public:
    BlMessage();
    virtual ~BlMessage();
    
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        unsigned short headCode;
        unsigned short lenght;
        //默认小端
        unsigned char command:4;
        unsigned char address:4;
        unsigned char status;
    } head;
#pragma pack(pop)
    
    void setHead(const head& head);
    head& getHead() const;
    BYTE* getBody() const;
    int getBodySize() const;
    void setBody(BYTE* body, int len, bool copy = true, bool freeWithDone = true);
    unsigned short getCrc() const;
    void setCrc(unsigned short crc);
    
    virtual bool buildResponse(BYTE* data, int size);
protected:
    head m_head;
    BYTE* m_body;
    int m_bodySize;
    unsigned short m_crc;
    bool m_free;
};

NAMESPACE_ZY_END

#endif /* __BLMESSAGE_H__ */
