import distributedKVStore from '@ohos.data.distributedKVStore';
import Want from '@ohos.app.ability.Want';
import DistributedKVStore from './DistributedKVStore'
import { DistributedDeviceManager } from './DistributedDeviceManager';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import Player from '../models/Player';

const tag: string = 'TestTag [MessageSender]:';
export const BUNDLE_NAME: string = 'com.ohapp.whoisundercover'

export default class MessageSender {
  static context: common.UIAbilityContext;
  static init(context: common.UIAbilityContext) {
    MessageSender.context = context ;
  }

  // 发送want
  static sendWant(want: Want) {
    try {
      MessageSender.context.startAbility(want,
        (err: BusinessError) => {
          if (err.code) {
            console.error(tag, `startAbility failed, code is ${err.code}, message is ${err.message}`);
            return;
          }
        }
      )
    }
    catch(err) {
      let code = (err as BusinessError).code;
      let message = (err as BusinessError).message;
      console.error(tag, `Start Service Ability Failed , code:${code},message:${message}`) ;
    }
  }

  // 发送游戏通知信息
  static sendGameMessage(networkId: string, gameMessage: string) {
    let want: Want = {
      deviceId: networkId,
      bundleName: BUNDLE_NAME,
      abilityName: 'EntryAbility',
      parameters: {
        tag: 'GameMessage',
        message: gameMessage,
        sender: DistributedDeviceManager.localDeviceInfo.networkId!
      }
    }
    MessageSender.sendWant(want);
  }

  // 发送玩家信息
  static sendPlayerInfoMessage(networkId: string, player: Player) {
    let want: Want = {
      deviceId: networkId,
      bundleName: BUNDLE_NAME,
      abilityName: 'EntryAbility',
      parameters: {
        tag: 'PlayerInfoMessage',
        playerName: player.getPlayerName(),
        avatar: player.getAvatar(),
        networkId: player.getDeviceInfo() ? player.getDeviceInfo()!.networkId! : DistributedDeviceManager.localDeviceInfo.networkId!,
        sender: DistributedDeviceManager.localDeviceInfo.networkId!
      }
    }
    MessageSender.sendWant(want);
  }
}
