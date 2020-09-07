//
//  StarMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "StarMessage.h"

NAMESPACE_ZY_BEGIN

StarMessage::StarMessage(unsigned int code, unsigned int param)
: m_code(code)
, m_param(param)
{
}

StarMessage::~StarMessage()
{
}

void StarMessage::setCode(unsigned int code)
{
    m_code = code;
}

unsigned int StarMessage::getCode() const
{
    return m_code;
}

void StarMessage::setParam(unsigned int param)
{
    m_param = param;
}

unsigned int StarMessage::getParam() const
{
    return m_param;
}

NAMESPACE_ZY_END
