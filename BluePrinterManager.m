//
//  BluePrinterManager.m
//  BluePrinter
//
//  Created by feng on 15/12/14.
//  Copyright © 2015年 feng. All rights reserved.
//

#import "BluePrinterManager.h"
#import "BluePrinterFormat.h"

@interface BluePrinterManager ()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic, strong, readwrite)CBCentralManager* centralManager;
@property (nonatomic, strong) NSTimer* conectTimer;
@property (nonatomic, strong) BluePrinterFormat* printerFomat;

//连接的peripheral
@property (nonatomic, strong) CBPeripheral* connectPeripheral;
//可连接的服务
@property (nonatomic, strong) CBService* connectService;
/**
 *  可连接的特征
 */
@property (nonatomic, strong) CBCharacteristic* connectCharacteristic;

@property (nonatomic, copy) eventHardwareBlock harwareBlock;

@property (nonatomic, assign,readwrite) BOOL isConnect;
@end

@implementation BluePrinterManager

#pragma mark - 生命周期

- (instancetype)init
{
    self = [super init];
    if (self) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.peripheralArray = [[NSMutableArray alloc] init];
        self.printerFomat = [[BluePrinterFormat alloc] init];
    }
    return self;
}

+ (instancetype)shareInstance
{
    static dispatch_once_t dpOnce;
    static BluePrinterManager* instance;
    dispatch_once(&dpOnce, ^{
        instance = [[BluePrinterManager alloc] init];
    });
    return instance;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (self.harwareBlock) {
        self.harwareBlock(central.state);
    }
}

/**
 *  扫描到新的外设
 *
 *  @param central           中心设备
 *  @param peripheral        外设
 *  @param advertisementData
 *  @param RSSI
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    if ([self.delegate respondsToSelector:@selector(centralManager:didDiscoverPeripheral:)]) {
        [self.delegate centralManager:central didDiscoverPeripheral:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"连接成功:%@",peripheral);
    [self.conectTimer invalidate];
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    if (error) {
        NSLog(@"连接%@失败，错误码是:%@",peripheral.name,[error localizedDescription]);
    }
    
    [self clearConnectData];
}

#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"didDicoverService");
    if (error) {
        NSLog(@"连接服务:%@ 发生错误:%@",peripheral.name,[error localizedDescription]);
        return;
    }
    
    for (CBService* service in  peripheral.services) {
        NSLog(@"扫描到的serviceUUID:%@",service.UUID);
        //这里其实三个服务都可以做打印，但是我只选择了其中一个
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"49535343-FE7D-4AE5-8FA9-9FAFD205E455"]]) {
            //扫描特征
            self.connectService = service;
            [peripheral discoverCharacteristics:nil forService:service];
            break;
        }
    }
}

//扫描出特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"扫描特征:%@错误描述:%@",service.UUID,[error localizedDescription]);
        return;
    }
    
    for (CBCharacteristic * characteristic in service.characteristics)
    {
        if (characteristic.properties & CBCharacteristicPropertyWrite ) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            self.connectPeripheral = peripheral;
            self.connectService = service;
            self.connectCharacteristic = characteristic;
            self.isConnect = YES;
            [self cancelScan];
            if ([self.delegate respondsToSelector:@selector(centralManager:didConnectPeripheral:)]) {
                [self.delegate centralManager:self.centralManager didConnectPeripheral:peripheral];
            }
            return;
        }
    }
}

/*
 Invoked upon completion of a -[setNotifyValue:forCharacteristic:] request.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error updating notification state for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
        return;
    }
    
    NSLog(@"Updated notification state for characteristic %@ (newState:%@)", characteristic.UUID, [characteristic isNotifying] ? @"Notifying" : @"Not Notifying");
    
    
}

#pragma mark - 共有方法
- (void)scanPeripherals
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerOptionShowPowerAlertKey, nil];
    [self.centralManager scanForPeripheralsWithServices:nil options:options];
}

- (void)cancelScan
{
    [self.centralManager stopScan];
}

- (void)connectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"开始连接");
    [self.centralManager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    self.conectTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(connectTimeOut:) userInfo:peripheral repeats:NO];
}



- (void)setupPrinterState:(BluePrinterState)state
{
    unsigned char* cData = (unsigned char *)calloc(100, sizeof(unsigned char));
    NSData* sendData = nil;
    switch (state) {
        case BluePrinterStateInitialize:
            cData[0] = 0x1B;
            cData[1] = 0x40;
            sendData = [NSData dataWithBytes:cData length:2];
            break;
        case BluePrinterStateSetLanage:
        {
            //选中中文指令集
            cData[0] = 0x1B;
            cData[1] = 0x55;
            cData[2] = 15;
            sendData = [NSData dataWithBytes:cData length:3];
        }
            break;
        case BluePrinterStateSetDefultLineSpace:
        {
            cData[0] = 0x1B;
            cData[1] = 0x32;
            sendData = [NSData dataWithBytes:cData length:2];
        }
            break;
        case BluePrinterStateSetFontSizeBig:
        {
            cData[0] = 0x1D;
            cData[1] = 0x21;
            cData[2] = 0x11;
            sendData = [NSData dataWithBytes:cData length:3];
        }
            break;
        case BluePrinterStateSetFontDefult:
        {
            cData[0] = 0x1D;
            cData[1] = 0x21;
            cData[2] = 0x00;
            sendData = [NSData dataWithBytes:cData length:3];
        }
            break;
        case BluePrinterStateAlignmentCenter:
        {
            cData[0] = 0x1B;
            cData[1] = 0x61;
            cData[2] = 1;
            sendData = [NSData dataWithBytes:cData length:3];
        }
            break;
        case BluePrinterStateAlignmentLift:
        {
            cData[0] = 0x1B;
            cData[1] = 0x61;
            cData[2] = 0;
            sendData = [NSData dataWithBytes:cData length:3];
        }
            break;
        case BluePrinterStateSetLineSpace:
        {
            cData[0] = 0x1B;
            cData[1] = 0x33;
            cData[2] = 15 * 8;
            sendData = [NSData dataWithBytes:cData length:3];
        }
            break;
        case BluePrinterStateSetFontHeightBig:
        {
            cData[0] = 0x1B;
            cData[1] = 0x21;
            cData[2] = 16;
            sendData = [NSData dataWithBytes:cData length:3];
        }
        default:
            break;
    }
    free(cData);
    [self startPrint:sendData];
}

- (void)startPrint:(NSData *)writeData
{
    if (self.connectPeripheral && self.connectCharacteristic) {
        [self startPrint:self.connectPeripheral writeValue:writeData forCharacteristic:self.connectCharacteristic type:CBCharacteristicWriteWithResponse];
        return;
    }
}

- (void)handleLEHardwareState:(eventHardwareBlock)handel
{
    self.harwareBlock = handel;
}

#pragma mark - 私有方法

/**
 *  写数据
 *
 *  @param peripheral
 *  @param valData
 *  @param characteristic
 *  @param type
 */
- (void)startPrint:(CBPeripheral *)peripheral writeValue:(NSData *)valData forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type
{
    [peripheral writeValue:valData forCharacteristic:characteristic type:type];
}

- (void)connectTimeOut:(CBPeripheral *)peripheral
{
    NSLog(@"连接超时%@",peripheral);
    [self centralManager:self.centralManager didFailToConnectPeripheral:peripheral error:nil];
}

//清除连接数据
- (void)clearConnectData
{
    [self cancelScan];
    self.connectPeripheral = nil;
    self.connectCharacteristic = nil;
    self.connectService = nil;
    [self.conectTimer invalidate];
    self.conectTimer = nil;
    self.isConnect = NO;
}


@end
