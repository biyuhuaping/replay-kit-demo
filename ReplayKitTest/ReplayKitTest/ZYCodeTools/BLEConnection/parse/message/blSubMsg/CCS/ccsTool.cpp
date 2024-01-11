//
//  BlMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "ccsTool.h"
#include <memory.h>

NAMESPACE_ZY_BEGIN

int getCCSItemValue(BYTE* data, int size, ccs_item_value* value)
{
    int offset = 0;
    memcpy(&value->configIdx, data+offset, 2);
    offset+=2;
    size_t len = strlen((const char*)(data+offset));
    if (len > size-offset) {
        return 0;
    }
//    if (value->value == NULL) {
//        value->value = (char*)calloc(len+1, 1);
//    }
//    memcpy(value->value, data+offset, len+1);
    value->value = ((const char*)(data+offset));
    offset += len+1;
    return offset;
}

int getCCSItemValueList(BYTE* data, int size, std::vector<ccs_item_value>& itemValueList)
{
    int offset = 0;
    int minSize = sizeof(uint16)+1;
    while (offset+minSize <= size) {
        ccs_item_value value;
        offset += getCCSItemValue(data+offset, size-offset, &value);
        itemValueList.push_back(value);
    }
    return offset;
}

int getSyncItemValue(BYTE* data, int size, ccs_sync_value* value)
{
    int offset = 0;
    memcpy(&value->configIdx, data+offset, 1);
    offset+=1;
    size_t len = strlen((const char*)(data+offset));
    if (len > size-offset) {
        return 0;
    }
    //    if (value->value == NULL) {
    //        value->value = (char*)calloc(len+1, 1);
    //    }
    //    memcpy(value->value, data+offset, len+1);
    value->value = ((const char*)(data+offset));
    offset += len+1;
    return offset;
}

int getSyncItemValueList(BYTE* data, int size, std::vector<ccs_sync_value>& itemValueList)
{
    int offset = 0;
    int minSize = sizeof(uint8)+1;
    while (offset+minSize <= size) {
        ccs_sync_value value;
        offset += getSyncItemValue(data+offset, size-offset, &value);
        itemValueList.push_back(value);
    }
    return offset;
}

NAMESPACE_ZY_END
