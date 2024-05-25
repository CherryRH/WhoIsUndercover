import distributedKVStore from '@ohos.data.distributedKVStore';
import { BusinessError, Callback } from '@ohos.base';

const tag: string = 'TestTag [DistributedKVStore]:';
export const BUNDLE_NAME: string = 'com.ohapp.whoisundercover'

export default class DistributedKVStore {
  // 分布式键值数据库管理器
  static kvManager: distributedKVStore.KVManager;
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

  // 获取全部数据库ID
  static async getAllKVStoreId() {
    try {
      console.info(tag, 'GetAllKVStoreId');
      await DistributedKVStore.kvManager.getAllKVStoreId(BUNDLE_NAME).then((data: string[]) => {
        console.info(tag, 'Succeeded in getting AllKVStoreId');
        console.info(tag, `GetAllKVStoreId size = ${data.length}`);
        for (let id of data) {
          console.info(tag, `KVStoreId: ${id}`);
        }
      }).catch((err: BusinessError) => {
        console.error(tag, `Failed to get AllKVStoreId.code is ${err.code},message is ${err.message}`);
      });
    } catch (e) {
      let error = e as BusinessError;
      console.error(tag, `Failed to get AllKVStoreId.code is ${error.code},message is ${error.message}`);
    }
  }

  static createKVStore(context: Context, callback: Callback<void>) {
    if (DistributedKVStore.singleKVStore != null) {
      callback();
      return;
    }
    const kvManagerConfig: distributedKVStore.KVManagerConfig = {
      context: context,
      bundleName: BUNDLE_NAME,
    }
    try {
      DistributedKVStore.kvManager = distributedKVStore.createKVManager(kvManagerConfig);
      console.info(tag, "Succeeded in creating KVManager");

      const options: distributedKVStore.Options = {
        createIfMissing: true,
        encrypt: false,
        backup: false,
        autoSync: true,
        kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
        securityLevel: distributedKVStore.SecurityLevel.S2,
      };

      DistributedKVStore.kvManager.getKVStore<distributedKVStore.SingleKVStore>(DistributedKVStore.singleKVStoreID, options).then((store: distributedKVStore.SingleKVStore) => {
        console.info(tag, "Succeeded in getting SingleKVStore");
        DistributedKVStore.singleKVStore = store;
        callback();
      }).catch((err: BusinessError) => {
        console.error(tag, `Failed to get SingleKVStore.code is ${err.code},message is ${err.message}`);
      });
    } catch (e) {
      let error = e as BusinessError;
      console.error(tag, `Failed to create KVManager.code is ${error.code},message is ${error.message}`);
    }
  }

  static setListener(context: Context, callback: Callback<distributedKVStore.ChangeNotification>) {
    DistributedKVStore.createKVStore(context, () => {
      DistributedKVStore.onDataChange(callback);
    });
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

  // 初始化值
  static async initData() {
    // 游戏信息
    let entries: distributedKVStore.Entry[] = [
      {
        key: 'GameMessage',
        value: {
          type: distributedKVStore.ValueType.STRING,
          value: ''
        }
      },
    ];
    await DistributedKVStore.putBatchInSKV(entries);
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
  static async putInSKV(key: string, value: string | number | boolean) {
    try {
      if (DistributedKVStore.singleKVStore == null) {
        console.error(tag, 'SingleKVStore is null');
        return;
      }
      DistributedKVStore.singleKVStore.put(key, value).then(() => {
        console.info(tag, `Succeeded in putting data: ${key} => ${value}`);
      }).catch((err: BusinessError) => {
        console.error(tag, `Failed to put.code is ${err.code},message is ${err.message}`);
      });
    } catch (e) {
      let error = e as BusinessError;
      console.error(tag, `An unexpected error occurred.code is ${error.code},message is ${error.message}`);
    }
  }

  // 批量添加键值
  static async putBatchInSKV(entries: distributedKVStore.Entry[]) {
    try {
      if (entries.length === 0) {
        console.error(tag, 'Entries is empty');
        return;
      }
      if (DistributedKVStore.singleKVStore == null) {
        console.error(tag, 'SingleKVStore is null');
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
  static async deleteInSKV(key: string) {
    try {
      if (DistributedKVStore.singleKVStore == null) {
        console.error(tag, 'SingleKVStore is null');
        return;
      }
      await DistributedKVStore.singleKVStore.delete(key).then(() => {
        console.info(tag, 'Succeeded in deleting');
      }).catch((err: BusinessError) => {
        console.error(tag, `Failed to delete.code is ${err.code},message is ${err.message}`);
      });
    } catch (e) {
      let error = e as BusinessError;
      console.error(tag, `An unexpected error occurred.code is ${error.code},message is ${error.message}`);
    }
  }

  // 批量删除键值
  static async deleteBatchInSKV(keys: string[]) {
    try {
      if (DistributedKVStore.singleKVStore == null) {
        console.error(tag, 'SingleKVStore is null');
        return;
      }
      await DistributedKVStore.singleKVStore.deleteBatch(keys).then(() => {
        console.info(tag, 'Succeeded in deleting Batch');
      }).catch((err: BusinessError) => {
        console.error(tag, `Failed to delete Batch.code is ${err.code},message is ${err.message}`);
      });
    } catch (e) {
      let error = e as BusinessError;
      console.error(tag, `An unexpected error occurred.code is ${error.code},message is ${error.message}`);
    }
  }

  // 获取指定键值
  static async getInSKV(key: string) {
    try {
      if (DistributedKVStore.singleKVStore == null) {
        console.error(tag, 'SingleKVStore is null');
        return;
      }
      await DistributedKVStore.singleKVStore.get(key).then((data: string | number | boolean | Uint8Array) => {
        console.info(tag, `Succeeded in getting ${key} => ${data}`);
      }).catch((err: BusinessError) => {
        console.error(tag, `Failed to get.code is ${err.code},message is ${err.message}`);
      });
    } catch (e) {
      let error = e as BusinessError;
      console.error(tag, `Failed to get.code is ${error.code},message is ${error.message}`);
    }
  }

  // 获取相同前缀的所有键值
  static async getEntriesByKeyPrefix(keyPrefix: string) {
    try {
      if (DistributedKVStore.singleKVStore == null) {
        console.error(tag, 'SingleKVStore is null');
        return;
      }
      await DistributedKVStore.singleKVStore.getEntries(keyPrefix).then((entries: distributedKVStore.Entry[]) => {
        console.info(tag, 'Succeeded in getting Entries');
        console.info(tag, `Get Entries ${entries}`);
      }).catch((err: BusinessError) => {
        console.error(tag, `Failed to get Entries.code is ${err.code},message is ${err.message}`);
      });
    } catch (e) {
      let error = e as BusinessError;
      console.error(tag, `An unexpected error occurred.code is ${error.code},message is ${error.message} `);
    }
  }

  // 手动触发同步
  static sync(networkIds: string[]) {
    try {
      if (DistributedKVStore.singleKVStore == null) {
        console.error(tag, 'SingleKVStore is null');
        return;
      }
      DistributedKVStore.singleKVStore.sync(networkIds, distributedKVStore.SyncMode.PUSH_PULL, 1000);
      console.info(tag, 'Succeeded in sync');
    } catch (e) {
      let error = e as BusinessError;
      console.error(tag, `An unexpected error occurred.code is ${error.code},message is ${error.message} `);
    }
  }

  // 订阅数据变更通知
  static onDataChange(callback: Callback<distributedKVStore.ChangeNotification>) {
    try {
      if (DistributedKVStore.singleKVStore == null) {
        console.error(tag, 'SingleKVStore is null');
        return;
      }
      DistributedKVStore.singleKVStore.on('dataChange', distributedKVStore.SubscribeType.SUBSCRIBE_TYPE_ALL, (data: distributedKVStore.ChangeNotification) => {
        console.info(tag, `dataChange on callback call data: ${data}`);
        callback(data);
      });
    } catch (e) {
      let error = e as BusinessError;
      console.error(tag, `An unexpected error occurred.code is ${error.code},message is ${error.message}`);
    }
  }

  // 取消订阅数据变更通知
  static offDataChange(callback: Callback<distributedKVStore.ChangeNotification>) {
    try {
      if (DistributedKVStore.singleKVStore == null) {
        console.error(tag, 'SingleKVStore is null');
        return;
      }
      DistributedKVStore.singleKVStore.off('dataChange', (data: distributedKVStore.ChangeNotification) => {
        console.info(tag, `dataChange off callback call data: ${data}`);
        callback(data);
      });
    } catch (err) {
      let error = err as BusinessError;
      console.error(tag, `Failed to unsubscribe DataChange.code is ${error.code},message is ${error.message}`);
    }
  }

  // 订阅同步完成事件
  static onSyncComplete(callback: Callback<[string, number][]>) {
    try {
      if (DistributedKVStore.singleKVStore == null) {
        console.error(tag, 'SingleKVStore is null');
        return;
      }
      DistributedKVStore.singleKVStore.on('syncComplete', (data: [string, number][]) => {
        console.info(tag, `syncComplete ${data}`);
        callback(data);
      });
    } catch (e) {
      let error = e as BusinessError;
      console.error(tag, `Failed to subscribe syncComplete.code is ${error.code},message is ${error.message}`);
    }
  }

  // 取消订阅同步完成事件
  static offSyncComplete(callback: Callback<[string, number][]>) {
    try {
      if (DistributedKVStore.singleKVStore == null) {
        console.error(tag, 'SingleKVStore is null');
        return;
      }
      DistributedKVStore.singleKVStore.off('syncComplete', (data: [string, number][]) => {
        console.info(tag, `syncComplete callback call data: ${data}`);
        callback(data);
      });
    } catch (err) {
      let error = err as BusinessError;
      console.error(tag, `Failed to unsubscribe syncComplete.code is ${error.code},message is ${error.message}`);
    }
  }
}