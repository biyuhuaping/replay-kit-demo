//
//  RdisMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "RdisMessage.h"

NAMESPACE_ZY_BEGIN

RdisMessage::RdisMessage()
{
    memset(&m_rdis, 0, sizeof(m_rdis));
}

RdisMessage::~RdisMessage()
{
}

void RdisMessage::setRdisInfo(const RDIS_ALL_INFO& info)
{
    m_rdis = info;
}

const RdisMessage::RDIS_ALL_INFO& RdisMessage::getRdisInfo() const
{
    return m_rdis;
}

NAMESPACE_ZY_END
