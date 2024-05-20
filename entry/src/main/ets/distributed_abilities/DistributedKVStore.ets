import distributedKVStore from '@ohos.data.distributedKVStore';
import { BusinessError } from '@ohos.base';

const tag: string = 'TestTag [DistributedKVStore]:';
export const BUNDLE_NAME: string = 'com.ohapp.whoisundercover'

export default class DistributedKVStore {
  // 分布式键值数据库管理器
  static kvManager: distributedKVStore.KVManager;
  // 设备级键值数据库
  static deviceKVStore: distributedKVStore.DeviceKVStore | null;
  static deviceKVStoreID: string = 'WhoIsUndercoverDeviceKVStore';
  // 单版本键值数据库
  static singleKVStore: distributedKVStore.SingleKVStore | null;
  static singleKVStoreID: string = 'WhoIsUndercoverSingleKVStore';

  // 创建管理器
  static createKVManager(context: Context) {
    const kvManagerConfig: distributedKVStore.KVManagerConfig = {
      context: context,
      bundleName: BUNDLE_NAME,
    }
    try {
      DistributedKVStore.kvManager = distributedKVStore.createKVManager(kvManagerConfig);
      console.info(tag, "Succeeded in creating KVManager");
    } catch (e) {
      let error = e as BusinessError;
      console.error(tag, `Failed to create KVManager.code is ${error.code},message is ${error.message}`);
    }
  }

  /*
   * 单版本键值数据库
   * 以下为单版本键值数据库的函数
   * */

  // 获取单版本键值数据库
  static async getSingleKVStore() {
    try {
      const options: distributedKVStore.Options = {
        createIfMissing: true,
        encrypt: false,
        backup: false,
        autoSync: true,
        kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
        securityLevel: distributedKVStore.SecurityLevel.S2,
      };
      await DistributedKVStore.kvManager.getKVStore<distributedKVStore.SingleKVStore>(DistributedKVStore.singleKVStoreID, options).then((store: distributedKVStore.SingleKVStore) => {
        console.info(tag, "Succeeded in getting SingleKVStore");
        DistributedKVStore.singleKVStore = store;
      }).catch((err: BusinessError) => {
        console.error(tag, `Failed to get SingleKVStore.code is ${err.code},message is ${err.message}`);
      });
    } catch (e) {
      let error = e as BusinessError;
      console.error(tag, `An unexpected error occurred.code is ${error.code},message is ${error.message}`);
    }
  }

  // 关闭单版本数据库
  static async closeSingleKVStore() {
    try {
      const options: distributedKVStore.Options = {
        createIfMissing: true,
        encrypt: false,
        backup: false,
        autoSync: true,
        kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
        schema: undefined,
        securityLevel: distributedKVStore.SecurityLevel.S2,
      }
      await DistributedKVStore.kvManager.getKVStore<distributedKVStore.SingleKVStore>(DistributedKVStore.singleKVStoreID, options).then(async (store: distributedKVStore.SingleKVStore | null) => {
        DistributedKVStore.singleKVStore = store;
        DistributedKVStore.singleKVStore = null;
        store = null;
        await DistributedKVStore.kvManager.closeKVStore(BUNDLE_NAME, DistributedKVStore.singleKVStoreID).then(() => {
          console.info(tag, 'Succeeded in closing SingleKVStore');
        }).catch((err: BusinessError) => {
          console.error(tag, `Failed to close SingleKVStore.code is ${err.code},message is ${err.message}`);
        });
      }).catch((err: BusinessError) => {
        console.error(tag, `Failed to get SingleKVStore.code is ${err.code},message is ${err.message}`);
      });
    } catch (e) {
      let error = e as BusinessError;
      console.error(tag, `Failed to close SingleKVStore.code is ${error.code},message is ${error.message}`);
    }
  }

  // 删除单版本数据库
  static async deleteSingleKVStore() {
    const options: distributedKVStore.Options = {
      createIfMissing: true,
      encrypt: false,
      backup: false,
      autoSync: true,
      kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
      schema: undefined,
      securityLevel: distributedKVStore.SecurityLevel.S2,
    }
    try {
      await DistributedKVStore.kvManager.getKVStore<distributedKVStore.SingleKVStore>(DistributedKVStore.singleKVStoreID, options).then(async (store: distributedKVStore.SingleKVStore | null) => {
        DistributedKVStore.singleKVStore = store;
        DistributedKVStore.singleKVStore = null;
        store = null;
        await DistributedKVStore.kvManager.deleteKVStore(BUNDLE_NAME, DistributedKVStore.singleKVStoreID).then(() => {
          console.info(tag, 'Succeeded in deleting SingleKVStore');
        }).catch((err: BusinessError) => {
          console.error(tag, `Failed to delete SingleKVStore.code is ${err.code},message is ${err.message}`);
        });
      }).catch((err: BusinessError) => {
        console.error(tag, `Failed to get SingleKVStore.code is ${err.code},message is ${err.message}`);
      });
    } catch (e) {
      let error = e as BusinessError;
      console.error(tag, `Failed to delete SingleKVStore.code is ${error.code},message is ${error.message}`);
    }
  }

  // 添加键值
  static async putSingleKVStore(key: string, value: distributedKVStore.ValueType) {
    try {
      if (DistributedKVStore.singleKVStore == null) {
        console.error(tag, 'SingleKVStore is null');
        return;
      }
      DistributedKVStore.singleKVStore.put(key, value).then(() => {
        console.info(tag, `Succeeded in putting data:` + key + ' => ' + value.toString());
      }).catch((err: BusinessError) => {
        console.error(tag, `Failed to put.code is ${err.code},message is ${err.message}`);
      });
    } catch (e) {
      let error = e as BusinessError;
      console.error(tag, `An unexpected error occurred.code is ${error.code},message is ${error.message}`);
    }
  }

  // 批量添加键值
  static async putBatchSingleKVStore(entries: distributedKVStore.Entry[]) {
    try {
      if (entries.length === 0) {
        console.error(tag, 'Entries is empty');
        return;
      }
      console.info(tag, `entries: ${entries}`);
      await DistributedKVStore.singleKVStore.putBatch(entries).then(async () => {
        console.info(tag, 'Succeeded in putting Batch');
      }).catch((err: BusinessError) => {
        console.error(tag, `Failed to put Batch.code is ${err.code},message is ${err.message}`);
      });
    } catch (e) {
      let error = e as BusinessError;
      console.error(tag, `An unexpected error occurred.code is ${error.code},message is ${error.message} `);
    }
  }

  // 删除指定键值
  //static async

  /*
   * 设备级键值数据库
   * 以下为设备级键值数据库的函数
   * */

  // 获取设备级键值数据库
  static async getDeviceKVStore() {
    try {
      const options: distributedKVStore.Options = {
        createIfMissing: true,
        encrypt: false,
        backup: false,
        autoSync: true,
        kvStoreType: distributedKVStore.KVStoreType.DEVICE_COLLABORATION,
        securityLevel: distributedKVStore.SecurityLevel.S2,
      };
      await DistributedKVStore.kvManager.getKVStore<distributedKVStore.DeviceKVStore>(DistributedKVStore.deviceKVStoreID, options).then((store: distributedKVStore.DeviceKVStore) => {
        console.info(tag, "Succeeded in getting DeviceKVStore");
        DistributedKVStore.deviceKVStore = store;
      }).catch((err: BusinessError) => {
        console.error(tag, `Failed to get DeviceKVStore.code is ${err.code},message is ${err.message}`);
      });
    } catch (e) {
      let error = e as BusinessError;
      console.error(tag, `An unexpected error occurred.code is ${error.code},message is ${error.message}`);
    }
  }

  // 关闭设备级数据库
  static async closeDeviceKVStore() {
    try {
      const options: distributedKVStore.Options = {
        createIfMissing: true,
        encrypt: false,
        backup: false,
        autoSync: true,
        kvStoreType: distributedKVStore.KVStoreType.DEVICE_COLLABORATION,
        schema: undefined,
        securityLevel: distributedKVStore.SecurityLevel.S2,
      }
      await DistributedKVStore.kvManager.getKVStore<distributedKVStore.DeviceKVStore>(DistributedKVStore.deviceKVStoreID, options).then(async (store: distributedKVStore.DeviceKVStore | null) => {
        DistributedKVStore.deviceKVStore = store;
        DistributedKVStore.deviceKVStore = null;
        store = null;
        await DistributedKVStore.kvManager.closeKVStore(BUNDLE_NAME, DistributedKVStore.deviceKVStoreID).then(() => {
          console.info(tag, 'Succeeded in closing DeviceKVStore');
        }).catch((err: BusinessError) => {
          console.error(tag, `Failed to close DeviceKVStore.code is ${err.code},message is ${err.message}`);
        });
      }).catch((err: BusinessError) => {
        console.error(tag, `Failed to get DeviceKVStore.code is ${err.code},message is ${err.message}`);
      });
    } catch (e) {
      let error = e as BusinessError;
      console.error(tag, `Failed to close DeviceKVStore.code is ${error.code},message is ${error.message}`);
    }
  }

  // 删除设备级数据库
  static async deleteDeviceKVStore() {
    const options: distributedKVStore.Options = {
      createIfMissing: true,
      encrypt: false,
      backup: false,
      autoSync: true,
      kvStoreType: distributedKVStore.KVStoreType.DEVICE_COLLABORATION,
      schema: undefined,
      securityLevel: distributedKVStore.SecurityLevel.S2,
    }
    try {
      await DistributedKVStore.kvManager.getKVStore<distributedKVStore.DeviceKVStore>(DistributedKVStore.deviceKVStoreID, options).then(async (store: distributedKVStore.DeviceKVStore | null) => {
        DistributedKVStore.deviceKVStore = store;
        DistributedKVStore.deviceKVStore = null;
        store = null;
        await DistributedKVStore.kvManager.deleteKVStore(BUNDLE_NAME, DistributedKVStore.deviceKVStoreID).then(() => {
          console.info(tag, 'Succeeded in deleting DeviceKVStore');
        }).catch((err: BusinessError) => {
          console.error(tag, `Failed to delete DeviceKVStore.code is ${err.code},message is ${err.message}`);
        });
      }).catch((err: BusinessError) => {
        console.error(tag, `Failed to get DeviceKVStore.code is ${err.code},message is ${err.message}`);
      });
    } catch (e) {
      let error = e as BusinessError;
      console.error(tag, `Failed to delete DeviceKVStore.code is ${error.code},message is ${error.message}`);
    }
  }

  // 获取全部数据库ID
  static async getAllKVStoreId() {
    try {
      console.info(tag, 'GetAllKVStoreId');
      await DistributedKVStore.kvManager.getAllKVStoreId(BUNDLE_NAME).then((data: string[]) => {
        console.info(tag, 'Succeeded in getting AllKVStoreId');
        console.info(tag, `GetAllKVStoreId size = ${data.length}`);
      }).catch((err: BusinessError) => {
        console.error(tag, `Failed to get AllKVStoreId.code is ${err.code},message is ${err.message}`);
      });
    } catch (e) {
      let error = e as BusinessError;
      console.error(tag, `Failed to get AllKVStoreId.code is ${error.code},message is ${error.message}`);
    }
  }
}