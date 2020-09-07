//
//  ZYBleDeviceDispacther.m
//  ZYCamera
//
//  Created by Frost Zhang on 2017/3/31.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBleDeviceDispacther.h"
#import "ZYStablizerDefineENUM.h"
#import "BabyBluetooth.h"

@interface ZYBleDeviceDispacther ()

@property (nonatomic, readwrite) BOOL isReady;
@property (nonatomic, readwrite, strong) NSMutableDictionary<NSString*, CBPeripheral*>* peripheralDict;
@property (nonatomic, readwrite, strong) NSMutableDictionary<NSString*, ZYBleDeviceCallBack*>* channelCallBackDict;
@property (nonatomic, readwrite, strong) NSMutableDictionary<NSString*, CBPeripheral*>* characteristicToPeripheral;

@end

@implementation ZYBleDeviceDispacther

-(instancetype) init
{
    self = [super init];
    if (self) {
        self.peripheralDict = [NSMutableDictionary dictionary];
        self.channelCallBackDict = [NSMutableDictionary dictionary];
        self.characteristicToPeripheral = [NSMutableDictionary dictionary];
    }
    return self;
}

-(NSArray<ZYBleDeviceCallBack*>*) findPeripheralCallBacks:(CBPeripheral*)peripheral
{
    NSMutableArray<ZYBleDeviceCallBack*>* callBacks = [NSMutableArray array];
    @weakify(self)
    [self.peripheralDict enumerateKeysAndObjectsUsingBlock:^(NSString* channel, CBPeripheral* aPeripheral, BOOL *stop) {
        @strongify(self)
        if (peripheral == aPeripheral
            || [aPeripheral isKindOfClass:[NSString class]]) {
            ZYBleDeviceCallBack* callBack = [self.channelCallBackDict objectForKey:channel];
            if (callBack) {
                [callBacks addObject:callBack];
            }
        }
        *stop = NO;
    }];
    return callBacks;
}

-(ZYBleDeviceCallBack*) findPeripheralCallBack:(CBPeripheral*)peripheral atChannel:(NSString*)channel
{
    __block ZYBleDeviceCallBack* callBack = nil;
    @weakify(self)
    [self.peripheralDict enumerateKeysAndObjectsUsingBlock:^(NSString* aChannel, CBPeripheral* aPeripheral, BOOL *stop) {
        @strongify(self)
        if ((aPeripheral == peripheral) && [aChannel isEqualToString:channel]) {
            callBack = [self.channelCallBackDict objectForKey:channel];
            *stop = YES;
        }
    }];
    if (!callBack) {
        if (!peripheral) {
            [self.peripheralDict setObject:(CBPeripheral*)@"NULL" forKey:channel];
        } else {
            [self.peripheralDict setObject:peripheral forKey:channel];
        }
        
        callBack = [[ZYBleDeviceCallBack alloc] init];
        [self.channelCallBackDict setObject:callBack forKey:channel];
    }
    return callBack;
}

-(BOOL) isPeripheralRecord:(CBPeripheral*)peripheral
{
    for (CBPeripheral* aPeripheral in self.channelCallBackDict.allValues) {
        if (aPeripheral == peripheral) {
            return YES;
        }
    }
    return NO;
}


-(void) setConnectedPeripheralBlock:(CBPeripheral*)peripheral atChannel:(NSString*)channel withBlock:(ZYBleConnectedPeripheralBlock)block
{
    [self findPeripheralCallBack:peripheral atChannel:channel].connectedPeripheralBlock = block;
}

-(void) setFailToConnectBlock:(CBPeripheral*)peripheral atChannel:(NSString*)channel withBlock:(ZYBleFailToConnectBlock)block
{
    [self findPeripheralCallBack:peripheral atChannel:channel].failToConnectBlock = block;
}

-(void) setDisconnectBlock:(CBPeripheral*)peripheral atChannel:(NSString*)channel withBlock:(ZYBleDisconnectBlock)block
{
    [self findPeripheralCallBack:peripheral atChannel:channel].disconnectBlock = block;
}

-(void) setDiscoverCharacteristicsBlock:(CBPeripheral*)peripheral atChannel:(NSString*)channel withBlock:(ZYBleDiscoverCharacteristicsBlock)block
{
    [self findPeripheralCallBack:peripheral atChannel:channel].discoverCharacteristicsBlock = block;
}

-(void) setReadValueForCharacteristicBlock:(CBPeripheral*)peripheral atChannel:channel withBlock:(ZYBleReadValueForCharacteristicBlock)block
{
    [self findPeripheralCallBack:peripheral atChannel:channel].readValueForCharacteristicBlock = block;
}

-(void) setDidWriteValueForCharacteristicBlock:(CBPeripheral*)peripheral atChannel:channel withBlock:(ZYBleDidWriteValueForCharacteristicBlock)block
{
    [self findPeripheralCallBack:peripheral atChannel:channel].didWriteValueForCharacteristicBlock = block;
}

-(void) setDidUpdateNotificationStateForCharacteristicBlock:(CBPeripheral*)peripheral atChannel:channel withBlock:(ZYBleDidUpdateNotificationStateForCharacteristicBlock)block
{
    [self findPeripheralCallBack:peripheral atChannel:channel].didUpdateNotificationStateForCharacteristicBlock = block;
}

-(void)setDidDiscoverDescriptorsForCharacteristicBlock:(CBPeripheral *)peripheral atChannel:(NSString *)channel withBlock:(ZYDiscoverDescriptorsForCharacteristicBlock)block{
    [self findPeripheralCallBack:peripheral atChannel:channel].didDiscoverDescriptorsForCharacteristicBlock = block;
}

-(void)setDidDiscoverDescriptorsOnReadValueForDescriptorsBlock:(CBPeripheral *)peripheral atChannel:(NSString *)channel withBlock:(ZYDiscoverDescriptorsOnReadValueForDescriptorsBlcok)block{
    [self findPeripheralCallBack:peripheral atChannel:channel].didDiscoverDescriptorsOnReadValueForDescriptorsBlock = block;

}

-(void) prepare
{
    if (self.isReady) {
        return;
    }
    
    @weakify(self)
    BabyBluetooth* baby = [BabyBluetooth shareBabyBluetooth];
    
    //设置设备连接成功的委托
    [baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        @strongify(self)
        NSLog(@"设备成功连接 %@", peripheral);
        NSArray<ZYBleDeviceCallBack*>* callBacks = [self findPeripheralCallBacks:peripheral];
        for (ZYBleDeviceCallBack* callBack in callBacks) {
            BLOCK_EXEC_ON_MAINQUEUE(callBack.connectedPeripheralBlock, central);
        }
    }];
    
    //设置设备连接失败的委托
    [baby setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        @strongify(self)
        NSLog(@"设备连接失败 %@", peripheral);
        NSArray<ZYBleDeviceCallBack*>* callBacks = [self findPeripheralCallBacks:peripheral];
        for (ZYBleDeviceCallBack* callBack in callBacks) {
            BLOCK_EXEC_ON_MAINQUEUE(callBack.failToConnectBlock, central, error);
        }
        
        [self removeChannelForPeripheral:peripheral];
    }];
    
    //设置设备断开连接的委托
    [baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        @strongify(self)
        NSLog(@"设备断开连接 %@", peripheral);
        NSArray<ZYBleDeviceCallBack*>* callBacks = [self findPeripheralCallBacks:peripheral];
        for (ZYBleDeviceCallBack* callBack in callBacks) {
            BLOCK_EXEC_ON_MAINQUEUE(callBack.disconnectBlock, central, error);
        }
        
    }];
    
    [baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        @strongify(self)
        if ([self isPeripheralRecord:peripheral]) {
            for (CBCharacteristic* characteristic in service.characteristics) {
                [self.characteristicToPeripheral setObject:peripheral forKey:[self makeCharacteristiIdentifier:characteristic]];
            }
        }
        NSArray<ZYBleDeviceCallBack*>* callBacks = [self findPeripheralCallBacks:peripheral];
        for (ZYBleDeviceCallBack* callBack in callBacks) {
            BLOCK_EXEC_ON_MAINQUEUE(callBack.discoverCharacteristicsBlock, service, error);
        }
    }];
    
    [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        @strongify(self)
        //NSLog(@"设备%@ 读取数据 %@", peripheral, characteristic.value);
        NSArray<ZYBleDeviceCallBack*>* callBacks = [self findPeripheralCallBacks:peripheral];
        for (ZYBleDeviceCallBack* callBack in callBacks) {
            BLOCK_EXEC_ON_MAINQUEUE(callBack.readValueForCharacteristicBlock, characteristic, error);
        }
    }];
    
    [baby setBlockOnDidWriteValueForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        @strongify(self)
        CBPeripheral *peripheral = [self findPeripheral:characteristic];;
        NSArray<ZYBleDeviceCallBack*>* callBacks = [self findPeripheralCallBacks:peripheral];
        for (ZYBleDeviceCallBack* callBack in callBacks) {
            BLOCK_EXEC_ON_MAINQUEUE(callBack.didWriteValueForCharacteristicBlock, characteristic, error);
        }
    }];
    
    [baby setBlockOnDidUpdateNotificationStateForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        @strongify(self)
        CBPeripheral *peripheral = [self findPeripheral:characteristic];
        NSArray<ZYBleDeviceCallBack*>* callBacks = [self findPeripheralCallBacks:peripheral];
        for (ZYBleDeviceCallBack* callBack in callBacks) {
            BLOCK_EXEC_ON_MAINQUEUE(callBack.didUpdateNotificationStateForCharacteristicBlock, characteristic, error);
        }
    }];
    
    [baby setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        @strongify(self)
        NSArray<ZYBleDeviceCallBack*>* callBacks = [self findPeripheralCallBacks:peripheral];
        for (ZYBleDeviceCallBack* callBack in callBacks) {
            BLOCK_EXEC_ON_MAINQUEUE(callBack.didDiscoverDescriptorsForCharacteristicBlock,peripheral, characteristic, error);
        }
    }];
    
    [baby setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        @strongify(self)
        NSArray<ZYBleDeviceCallBack*>* callBacks = [self findPeripheralCallBacks:peripheral];
        for (ZYBleDeviceCallBack* callBack in callBacks) {
            BLOCK_EXEC_ON_MAINQUEUE(callBack.didDiscoverDescriptorsOnReadValueForDescriptorsBlock,peripheral, descriptor, error);
        }
    }];
    
    self.isReady = YES;
}

-(void) recordCharacteristicForPeripheral:(CBPeripheral*)peripheral withCharacteristic:(CBCharacteristic*)characteristic
{
    [self.characteristicToPeripheral setObject:peripheral forKey:[self makeCharacteristiIdentifier:characteristic]];
}

-(NSString*) makeCharacteristiIdentifier:(CBCharacteristic*)characteristic
{
    return [NSString stringWithFormat:@"%@.%x", characteristic.UUID.UUIDString, (unsigned int)characteristic];
}

-(BOOL) isCharacteristEqual:(CBCharacteristic*)characteristic withIdentifier:(NSString*)identifier
{
    return [identifier isEqualToString:[self makeCharacteristiIdentifier:characteristic]];
}
     
-(CBPeripheral*) findPeripheral:(CBCharacteristic*)characteristic
{
    return [self.characteristicToPeripheral objectForKey:[self makeCharacteristiIdentifier:characteristic]];
}

-(void) removeChannelForPeripheral:(CBPeripheral*)peripheral
{
    NSMutableArray* removeKeys = [NSMutableArray array];
    
    [self.peripheralDict enumerateKeysAndObjectsUsingBlock:^(NSString* identifier, CBPeripheral* aPeripheral, BOOL *stop) {
        if (aPeripheral == peripheral) {
            [removeKeys addObject:identifier];
            *stop = NO;
        }
    }];
    
    [self.peripheralDict removeObjectsForKeys:removeKeys];
    [self.channelCallBackDict removeObjectsForKeys:removeKeys];
    
    [self removeCharacteristicForPeripheral:peripheral];
}

-(void) removeCharacteristicForPeripheral:(CBPeripheral*)peripheral
{
    NSMutableArray* removeKeys = [NSMutableArray array];
    
    [self.characteristicToPeripheral enumerateKeysAndObjectsUsingBlock:^(NSString* identifier, CBPeripheral* aPeripheral, BOOL *stop) {
        if (aPeripheral == peripheral) {
            [removeKeys addObject:identifier];
            *stop = NO;
        }
    }];
    
    [self.characteristicToPeripheral removeObjectsForKeys:removeKeys];
}

@end
