//
//  BluePrinterManager.h
//  BluePrinter
//
//  Created by feng on 15/12/14.
//  Copyright © 2015年 feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef NS_ENUM(NSInteger,BluePrinterState)
{
    BluePrinterStateInitialize, //初始化
    BluePrinterStateSetLanage, //设置语言指令集 ,此处为中文
    BluePrinterStateSetDefultLineSpace, //默认行间距
    BluePrinterStateSetLineSpace, //设置行间距
    BluePrinterStateSetFontSizeBig, //设置字体大小
    BluePrinterStateSetFontDefult, //设置默认字体
    BluePrinterStateSetFontHeightBig, //设置字体高度变大
    BluePrinterStateAlignmentCenter, //居中
    BluePrinterStateAlignmentLift,//左对齐
};


typedef void (^eventHardwareBlock)(CBCentralManagerState state);

@protocol BluePrinterDelegate <NSObject>
@required
/**
 *  扫描到蓝牙设备
 *
 *  @param central    中心设备管理器
 *  @param peripheral 蓝牙设备
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral;
/**
 *  连接设备失败
 *
 *  @param central   中心设备管理
 *  @param peripheral 蓝牙设备
 *  @param error      错误
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error;
/**
 *  设备连接成功
 *
 *  @param central    中心设备
 *  @param peripheral 蓝牙设备
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;

@end

@interface BluePrinterManager : NSObject

@property (nonatomic, readonly, strong) CBCentralManager* centralManager; //蓝牙中心管理
@property (nonatomic, strong)NSMutableArray* peripheralArray;
@property (nonatomic, weak) id<BluePrinterDelegate> delegate;

@property (nonatomic,readonly, assign)BOOL isConnect;
/**
 *  扫描外设
 *
 *  @return 返回外设数组
 */
- (void)scanPeripherals;

/**
 *  取消扫描外设
 */
- (void)cancelScan;

/**
 *  连接外设
 *
 *  @param peripheral 外设
 */
- (void)connectPeripheral:(nonnull CBPeripheral *)peripheral;

/**
 *  打印数据
 *
 *  @param writeData 可打印数据
 */
- (void)startPrint:(nonnull NSData *)writeData;

/**
 *  设置打印机状态
 *
 *  @param state 
 */
- (void)setupPrinterState:(BluePrinterState)state;

- (void)handleLEHardwareState:(nonnull eventHardwareBlock)handel;


+ (instancetype)shareInstance;

@end
