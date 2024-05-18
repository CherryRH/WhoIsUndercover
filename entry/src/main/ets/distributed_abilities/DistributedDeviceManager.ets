import deviceManager from '@ohos.distributedDeviceManager';
import { BusinessError } from '@ohos.base';

const TAG: string = '[DistributedDeviceManagerTestTag]';
export const BUNDLE_NAME: string = 'com.ohapp.whoisundercover'

export class DistributedDeviceManager {
  static dmInstance: deviceManager.DeviceManager;

  static deviceInfoList: Array<deviceManager.DeviceBasicInfo> = [];

  static availableDeviceList: Array<deviceManager.DeviceBasicInfo> = [];

  static bindDeviceList: Array<deviceManager.DeviceBasicInfo> = [];

  static localDeviceInfo: deviceManager.DeviceBasicInfo;

  static subscribeID: number;

  static publishID: number;

  // 初始化
  static init() {
    // 创建分布式设备管理器实例
    try {
      DistributedDeviceManager.dmInstance = deviceManager.createDeviceManager('com.ohapp.whoisundercover');
      console.log(TAG, '创建分布式设备管理器成功');
    } catch(err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG, 'createDeviceManager errCode:' + e.code + ',errMessage:' + e.message);
    }
  }

  // 同步所有可信设备信息列表
  static getDeviceInfoList() {
    try {
      DistributedDeviceManager.deviceInfoList = DistributedDeviceManager.dmInstance.getAvailableDeviceListSync();
      console.log(TAG, '获取可信设备信息列表成功');
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG, 'getAvailableDeviceListSync errCode:' + e.code + ',errMessage:' + e.message);
    }
  }

  // 获取可信设备列表
  static getAvailableDeviceList() {
    try {
      DistributedDeviceManager.dmInstance.getAvailableDeviceList((err: BusinessError, data: Array<deviceManager.DeviceBasicInfo>) => {
        if (err) {
          console.error(TAG, 'getAvailableDeviceList errCode:' + err.code + ',errMessage:' + err.message);
          return;
        }
        DistributedDeviceManager.availableDeviceList = data;
        console.log(TAG, 'get available device info: ' + JSON.stringify(data));
      });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG, 'getAvailableDeviceList errCode:' + e.code + ',errMessage:' + e.message);
    }
  }

  // 获取本地设备信息
  static getLocalDeviceInfo() {
    try {
      let deviceName: string = DistributedDeviceManager.dmInstance.getLocalDeviceName();
      console.log(TAG, 'local device name: ' + JSON.stringify(deviceName));
      let deviceNetworkId: string = DistributedDeviceManager.dmInstance.getLocalDeviceNetworkId();
      console.log(TAG, 'local device networkId: ' + JSON.stringify(deviceNetworkId));
      let deviceType: number = DistributedDeviceManager.dmInstance.getLocalDeviceType();
      console.log(TAG, 'local device type: ' + JSON.stringify(deviceType));
      let deviceId: string = DistributedDeviceManager.dmInstance.getLocalDeviceId();
      console.log(TAG, 'local device id: ' + JSON.stringify(deviceId));
      DistributedDeviceManager.localDeviceInfo.deviceName = deviceName;
      DistributedDeviceManager.localDeviceInfo.networkId = deviceNetworkId;
      DistributedDeviceManager.localDeviceInfo.deviceId = deviceId;
      DistributedDeviceManager.localDeviceInfo.deviceType = deviceType.toString();
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG, 'getLocalDeviceInfo errCode:' + e.code + ',errMessage:' + e.message);
    }
  }

  // 开始发现周边设备，返回值：0-正常开始；11600104-服务正在进行，不能重复开始
  static startDiscovering(): number {
    try {
      let discoverParam: Record<string, number> = {
        'discoverTargetType': 1
      };
      let filterOptions: Record<string, number> = {
        'availableStatus': 0
      };
      DistributedDeviceManager.dmInstance.startDiscovering(discoverParam, filterOptions);
      console.log(TAG, '开始发现周边设备');
      return 0;
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG, 'startDiscovering errCode:' + e.code + ',errMessage:' + e.message);
      return e.code;
    }
  }

  // 停止发现周边设备，返回值：0-正常停止；11600101-已停止，不能重复停止
  static stopDiscovering(): number {
    try {
      DistributedDeviceManager.dmInstance.stopDiscovering();
      console.log(TAG, '周边设备发现已停止');
      return 0;
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG, 'stopDiscovering errCode:' + e.code + ',errMessage:' + e.message);
      return e.code;
    }
  }

  // 认证设备，返回true则为认证成功
  static bindTarget(device: deviceManager.DeviceBasicInfo): boolean {
    try {
      // 认证的设备信息可以从发现的结果中获取
      DistributedDeviceManager.dmInstance.bindTarget(
        device.deviceId,
        {
          // bindType: 1,
          // targetPkgName: BUNDLE_NAME,
          // appName: 'WhoIsUndercover'
        },
        (err, data) => {
          if (err) {
            console.error(TAG, 'bindTarget errCode:' + err.code + ',errMessage:' + err.message);
            return false;
          }
          console.info(TAG, 'bindTarget result:' + JSON.stringify(data));
          return true;
        }
      );
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG, 'bindTarget errCode:' + e.code + ',errMessage:' + e.message);
      return false;
    }
    return false;
  }

  // 认证所有可信设备
  static bindAllTarget() {
    for (let i = 0; i < DistributedDeviceManager.availableDeviceList.length; i++) {
      let ifBind = DistributedDeviceManager.bindTarget(DistributedDeviceManager.availableDeviceList[i]);
      if (ifBind) {
        // 认证成功，加入认证设备列表
        DistributedDeviceManager.bindDeviceList.push(DistributedDeviceManager.availableDeviceList[i]);
      }
    }
  }

  // 取消认证设备
  static unbindTarget(deviceId: string) {
    try {
      DistributedDeviceManager.dmInstance.unbindTarget(deviceId);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG, 'unbindTarget errCode:' + e.code + ',errMessage:' + e.message);
    }
  }

  // 注册设备状态回调
  static onDeviceStateChange() {
    try {
      DistributedDeviceManager.dmInstance.on('deviceStateChange', (data) => {
        console.info(TAG, 'deviceStateChange on:' + JSON.stringify(data));
      });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG, 'deviceStateChange errCode:' + e.code + ',errMessage:' + e.message);
    }
  }

  // 取消注册设备状态回调
  static offDeviceStateChange() {
    try {
      DistributedDeviceManager.dmInstance.off('deviceStateChange', (data) => {
        console.info('deviceStateChange' + JSON.stringify(data));
      });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG, 'deviceStateChange errCode:' + e.code + ',errMessage:' + e.message);
    }
  }

  // 获取设备名称
  static getDeviceName(networkId: string): string {
    try {
      // 设备网络标识可以从可信设备列表中获取
      let deviceName: string = DistributedDeviceManager.dmInstance.getDeviceName(networkId);
      console.log(TAG, 'device name: ' + JSON.stringify(deviceName));
      return deviceName;
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG, 'getDeviceName errCode:' + e.code + ',errMessage:' + e.message);
      return '';
    }
  }

  // 获取设备类型
  static getDeviceType(networkId: string): number {
    try {
      // 设备网络标识可以从可信设备列表中获取
      let deviceType: number = DistributedDeviceManager.dmInstance.getDeviceType(networkId);
      console.log(TAG, 'device type: ' + JSON.stringify(deviceType));
      return deviceType;
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG, 'getDeviceType errCode:' + e.code + ',errMessage:' + e.message);
      return -1;
    }
  }

  // 释放资源
  static release() {
    try {
      DistributedDeviceManager.dmInstance = deviceManager.createDeviceManager('com.ohapp.whoisundercover');
      deviceManager.releaseDeviceManager(DistributedDeviceManager.dmInstance);
      console.log(TAG, '释放分布式设备管理器成功');
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG, 'release device manager errCode:' + e.code + ',errMessage:' + e.message);
    }
  }
}