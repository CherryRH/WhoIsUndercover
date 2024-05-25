import deviceManager from '@ohos.distributedDeviceManager';
import { BusinessError, Callback } from '@ohos.base';

const TAG: string = 'TestTag [DistributedDeviceManager]:';
export const BUNDLE_NAME: string = 'com.ohapp.whoisundercover'

// 本地设备信息
export class LocalDeviceInfo {
  deviceName?: string;
  networkId?: string;
  deviceType?: number;
  deviceId?: string;
}

export class DistributedDeviceManager {
  static dmInstance: deviceManager.DeviceManager;

  static deviceInfoList: Array<deviceManager.DeviceBasicInfo> = [];

  static availableDeviceList: Array<deviceManager.DeviceBasicInfo> = [];

  static localDeviceInfo: LocalDeviceInfo;

  static subscribeID: number = 100;

  static publishID: number;

  // 初始化
  static init() {
    // 创建分布式设备管理器实例
    try {
      DistributedDeviceManager.dmInstance = deviceManager.createDeviceManager('com.ohapp.whoisundercover');
      DistributedDeviceManager.localDeviceInfo = new LocalDeviceInfo();
      console.log(TAG, '创建分布式设备管理器成功');
    } catch(err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG, 'createDeviceManager errCode:' + e.code + ',errMessage:' + e.message);
    }
  }

  // 同步所有可信设备信息列表
  static getAvailableDeviceListSync() {
    try {
      DistributedDeviceManager.availableDeviceList = DistributedDeviceManager.dmInstance.getAvailableDeviceListSync();
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

  // 获取可信设备的networkIDs
  static getAvailableDeviceNetworkIDs(): string[] {
    DistributedDeviceManager.getAvailableDeviceListSync();
    let networkIDs: string[] = [];
    for (let device of DistributedDeviceManager.availableDeviceList) {
      if (device.networkId != '') {
        networkIDs.push(device.networkId!);
      }
    }
    return networkIDs;
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
      DistributedDeviceManager.localDeviceInfo.deviceType = deviceType;
      DistributedDeviceManager.localDeviceInfo.deviceId = deviceId;
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
    // 如果已经认证过，则跳过
    for (let it of DistributedDeviceManager.availableDeviceList) {
      if (device.deviceId === it.deviceId) {
        return false;
      }
    }
    try {
      if (!DistributedDeviceManager.dmInstance) {
        console.error(TAG, '设备管理器失效');
        return false;
      }
      if (!device || !device.deviceId) {
        console.error(TAG, '认证设备信息错误');
        return false;
      }
      // 认证的设备信息可以从发现的结果中获取
      DistributedDeviceManager.dmInstance.bindTarget(
        device.deviceId,
        {
          bindLevel: 3,
          bindType: 1,
          targetPkgName: BUNDLE_NAME,
          appName: 'WhoIsUndercover',

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

  // 认证所有设备
  static bindAllTarget() {
    for (let i = 0; i < DistributedDeviceManager.deviceInfoList.length; i++) {
      let ifBind = DistributedDeviceManager.bindTarget(DistributedDeviceManager.deviceInfoList[i]);
      if (ifBind) {
        DistributedDeviceManager.deviceInfoList.splice(i, 1);
      }
    }
    DistributedDeviceManager.getAvailableDeviceListSync();
  }

  // 判断某设备是否已认证
  static ifDeviceBinded(device: deviceManager.DeviceBasicInfo): boolean {
    DistributedDeviceManager.getAvailableDeviceList();
    for (let device of DistributedDeviceManager.availableDeviceList) {
      if (device.deviceId === device.deviceId) return true;
    }
    return false;
  }

  // 取消认证设备
  static unbindTarget(deviceId: string) {
    try {
      DistributedDeviceManager.dmInstance.unbindTarget(deviceId);
      // 从可信列表中删除，放入发现列表中
      for (let device of DistributedDeviceManager.availableDeviceList) {
        if (deviceId === device.deviceId) {
          let index = DistributedDeviceManager.availableDeviceList.indexOf(device);
          DistributedDeviceManager.deviceInfoList.push(device);
          DistributedDeviceManager.availableDeviceList.splice(index, 1);
        }
      }
      console.log(TAG, '已取消认证设备' + deviceId);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG, 'unbindTarget errCode:' + e.code + ',errMessage:' + e.message);
    }
  }

  // 取消认证所有已认证的设备
  static unBindAllTarget() {
    for (let i = 0; i < DistributedDeviceManager.availableDeviceList.length; i++) {
      DistributedDeviceManager.unbindTarget(DistributedDeviceManager.availableDeviceList[i].deviceId);
    }
  }

  // 注册设备状态回调
  static onDeviceStateChange(callback: Callback<number>) {
    try {
      DistributedDeviceManager.dmInstance.on('deviceStateChange', (data) => {
        console.info(TAG, 'deviceStateChange on:' + JSON.stringify(data));
        callback(data.action);
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

  // 注册发现设备成功回调
  static onDiscoverSuccess(callback: Callback<deviceManager.DeviceBasicInfo[]>) {
    try {
      DistributedDeviceManager.dmInstance.on('discoverSuccess', (data) => {
        // 如果已经搜索到，则跳过
        for (let device of DistributedDeviceManager.deviceInfoList) {
          if (device.deviceId === data.device.deviceId) {
            return;
          }
        }
        DistributedDeviceManager.deviceInfoList.push(data.device);
        callback(DistributedDeviceManager.deviceInfoList);
        console.info(TAG, "discoverSuccess:" + JSON.stringify(data));
      });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG, "discoverSuccess errCode:" + e.code + ",errMessage:" + e.message);
    }
  }

  // 取消注册发现设备成功回调
  static offDiscoverSuccess() {
    try {
      DistributedDeviceManager.dmInstance.off('discoverSuccess', (data) => {
        let index = DistributedDeviceManager.availableDeviceList.indexOf(data.device);
        DistributedDeviceManager.availableDeviceList.splice(index, 1);
        console.info(TAG,'discoverSuccess' + JSON.stringify(data));
      });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG, "discoverSuccess errCode:" + e.code + ",errMessage:" + e.message);
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
      DistributedDeviceManager.offDeviceStateChange();
      DistributedDeviceManager.offDiscoverSuccess();
      console.log(TAG, '释放分布式设备管理器成功');
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG, 'release device manager errCode:' + e.code + ',errMessage:' + e.message);
    }
  }
}