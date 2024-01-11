//
//  BlControlCoder.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "UsbControlCoder.h"
#include "crc.h"
#include "usbMsgDef.h"
#include "UsbMsgAll.h"
#include "BlControlCoder.h"
#include <assert.h>

#define CHECK_HEAD_CODE(data, Code) (((data[1]<<8) | data[0]) == Code)
#define MAX_INFO_LEN 128

NAMESPACE_ZY_BEGIN

//UsbMessage* buildUsbMessage(const UsbMessage::headCode& headCode, BYTE* body, int bodyLen);
//void getBlWiFiMessageTxt(const BlWiFiMessage* message, char* szText, int size);
//void getBlWiFiPhotoMessageTxt(const BlWiFiPhotoMessage* message, char* szText, int size);

UsbControlCoder::UsbControlCoder()
: ControlCoder()
{
    enableBigEndian(false);
}

UsbControlCoder::~UsbControlCoder()
{
    
}

int UsbControlCoder::encode(BYTE** data, int* len, bool isCopy)
{
    //memcpy(*data, m_buff+dataStart, dataLen);
    int dataLen = this->getCurrentSize();
    if (!isCopy) {
        *len = dataLen;
        *data = (BYTE*)malloc(dataLen);
    }
    memcpy(*data, m_buff, dataLen);
    return dataLen;
}

int UsbControlCoder::encode(const UsbMessage* message, BYTE** data, int* len)
{
    this->writeData(message->getHeadPtr(), message->getHeadSize());
    this->writeData(message->getBuff(), message->getBuffSize());
    this->encode(data, len, false);
    return *len;
}

UsbMessage* UsbControlCoder::decode(BYTE* data, int len)
{
    UsbMessage::headCode headCode;
    if (this->tryParseHead(data, len, &headCode)) {
        UsbMessage* message = buildUsbMessage(headCode, data, len);
        //TODO 缺少crc
        return message;
    }
    return NULL;
}

bool UsbControlCoder::isValid(BYTE* data, int len)
{
    UsbMessage::headCode code;
    return this->tryParseHead(data, len, &code);
}

bool UsbControlCoder::tryParseHead(BYTE* data, int len, UsbMessage::headCode* headCode)
{
    if (len < sizeof(UsbMessage::headCode)) {
        return false;
    }
    
    memcpy(headCode, data, sizeof(UsbMessage::headCode));
    int totalLen = 0;
    
    if (headCode->type == UsbMessageTypeInstruction)
    {
        int headLen = sizeof(UsbInstructionMessage::head);
        if (len < headLen) {
            return false;
        }
        UsbInstructionMessage::head head;
        memcpy(&head, data, headLen);
        totalLen = head.content.len+headLen;
    }
    else
    {
        int headLen = sizeof(UsbMediaMessage::head);
        if (len < headLen) {
            return false;
        }
        UsbMediaMessage::head head;
        memcpy(&head, data, headLen);
        totalLen = head.content.len+headLen;
    }
    
    if (len < totalLen) {
        return false;
    }
    
    return true;
}

bool UsbControlCoder::canParse(BYTE* data, int len)
{
    if (len < 2)
        return false;
    
    if (!(CHECK_HEAD_CODE(data, BL_HEAD_CODE_SEND)
          || CHECK_HEAD_CODE(data, BL_HEAD_CODE_RECV))) {
        return false;
    }
    
    return true;
}

void UsbControlCoder::getMessageText(const UsbMessage* message, char* szText, int size)
{
    const int txtlen = MAX_INFO_LEN;
    char messageTxt[txtlen];
    memset(messageTxt, 0, txtlen);
    snprintf(messageTxt, txtlen-1, "%s", "unknown usb message");
    if (message->messageType() == ZYUMTInstructionStar) {
        snprintf(messageTxt, txtlen-1, "%s", "USB协议Star指令");
    } else if (message->messageType() == ZYUMTInstructionBl) {
        BlMessage* blMessage = ((UsbInstructionBlMessage*)message)->getBlMessage();
        char blMessageTxt[txtlen];
        memset(blMessageTxt, 0, txtlen);
        BlControlCoder::getMessageText(blMessage, blMessageTxt, txtlen);
        snprintf(messageTxt, txtlen-1, "%s:%s", "USB协议指令", blMessageTxt);
    } else if (message->messageType() == ZYUMTInstructionMS) {
        snprintf(messageTxt, txtlen-1, "%s", "USB协议媒体流指令");
    } else if (message->messageType() == ZYUMTInstructionHB) {
        snprintf(messageTxt, txtlen-1, "%s", "USB协议心跳指令");
    } else if (message->messageType() == ZYUMTMedia) {
        snprintf(messageTxt, txtlen-1, "%s", "USB协议媒体数据");
    }
    snprintf(szText, size-1, "%s", messageTxt);
}

UsbMessage* UsbControlCoder::buildUsbMessage(const UsbMessage::headCode& headCode, BYTE* data, int len)
{
    UsbMessage* message = NULL;
    BYTE* body = NULL;
    int bodyLen = 0;
    if (headCode.type == UsbMessageTypeInstruction)
    {
        UsbInstructionMessage::head msgHead;
        memcpy(&msgHead, data, sizeof(msgHead));
        int totalLen = msgHead.content.len+sizeof(msgHead);
        this->resetData(data, totalLen);
        
        this->readData((BYTE*)&msgHead, sizeof(UsbInstructionMessage::head));
        bodyLen = msgHead.content.len;
        body = (BYTE*)malloc(bodyLen);
        this->readData(body, bodyLen);
        
        UsbInstructionMessage* usbInstructionMessage = NULL;
        uint8 cmdType = body[0];
        if (cmdType == UsbMessageCodeStar){
            usbInstructionMessage = new UsbInstructionStarMessage();
        } else if (cmdType == UsbMessageCodeZybl) {
            usbInstructionMessage = new UsbInstructionBlMessage();
        } else if (cmdType == UsbMessageCodeMediaStream){
            usbInstructionMessage = new UsbInstructionMediaStreamMessage();
        } else if (cmdType == UsbMessageCodeHeartBeat){
            usbInstructionMessage = new UsbInstructionHeartBeatMessage();
        } else {
            usbInstructionMessage = new UsbInstructionMessage();
        }
        usbInstructionMessage->setHead(msgHead);
        message = usbInstructionMessage;
    }
    else
    {
        //TODO 未完成
        UsbMediaMessage* usbMediaMessage = new UsbMediaMessage();        
        message = usbMediaMessage;
    }
    message->buildResponse(body, bodyLen);
    return message;
}

NAMESPACE_ZY_END
