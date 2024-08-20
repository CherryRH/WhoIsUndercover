import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import hilog from '@ohos.hilog';
import UIAbility from '@ohos.app.ability.UIAbility';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import { Permissions } from '@ohos.abilityAccessCtrl';
import { checkPermission, requestPermission } from '../distributed_abilities/DistributedPermission';
import { DistributedDeviceManager } from '../distributed_abilities/DistributedDeviceManager';
import preferenceUtil from '../utils/UserPreferenceUtil';
import { userPrefName } from '../utils/Common';
import WordProvider from '../utils/WordProvider';
import DistributedKVStore from '../distributed_abilities/DistributedKVStore';
import distributedKVStore from '@ohos.data.distributedKVStore';
import MessageSender from '../distributed_abilities/MessageSender';
import MessageReceiver, { Message, PlayerInfoMessage } from '../distributed_abilities/MessageReceiver';

// 要用到的权限
const PERMISSIONS: Array<Permissions> = [
  'ohos.permission.DISTRIBUTED_DATASYNC'
];

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');

    // 设置屏幕常亮
    let thisWindow = await window.getLastWindow(this.context);
    thisWindow.setWindowKeepScreenOn(true);

    // 加载用户首选项
    await preferenceUtil.loadPreference(this.context, userPrefName);

    // 申请权限
    await requestPermission(this.context, PERMISSIONS)
      .then(()=> {
        checkPermission(this.context, PERMISSIONS);
      })
    MessageSender.init(this.context);
    // 初始化分布式设备管理器
    DistributedDeviceManager.init();
  }

  onNewWant(want: Want): void {
    if (want.parameters) {
      if (want.parameters.tag === 'GameMessage') {
        let newMessage: Message = new Message(
          want.parameters.message.toString(),
          want.parameters.sender.toString(),
          want.parameters.tag.toString()
        );
        MessageReceiver.dealMessage(newMessage);
        console.log('testTag', `Receive message ${want.parameters.message.toString()} from ${want.parameters.sender.toString()}`);
      }
      else if (want.parameters.tag === 'WordMessage') {
        let newMessage: Message = new Message(
          want.parameters.message.toString(),
          want.parameters.sender.toString(),
          want.parameters.tag.toString()
        );
        MessageReceiver.dealMessage(newMessage);
        console.log('testTag', `Receive message ${want.parameters.message.toString()} from ${want.parameters.sender.toString()}`);
      }
      else if (want.parameters.tag === 'RemarkMessage') {
        let newMessage: Message = new Message(
          want.parameters.message.toString(),
          want.parameters.sender.toString(),
          want.parameters.tag.toString()
        );
        MessageReceiver.dealMessage(newMessage);
        console.log('testTag', `Receive message ${want.parameters.message.toString()} from ${want.parameters.sender.toString()}`);
      }
      else if (want.parameters.tag === 'VoteMessage') {
        let newMessage: Message = new Message(
          want.parameters.message.toString(),
          want.parameters.sender.toString(),
          want.parameters.tag.toString()
        );
        MessageReceiver.dealMessage(newMessage);
        console.log('testTag', `Receive message ${want.parameters.message.toString()} from ${want.parameters.sender.toString()}`);
      }
      else if (want.parameters.tag === 'PlayerInfoMessage') {
        let playerInfoMessage: PlayerInfoMessage = new PlayerInfoMessage(
          want.parameters.playerName.toString(),
          Number(want.parameters.avatar.toString()),
          want.parameters.networkId.toString(),
          want.parameters.sender.toString(),
          want.parameters.tag.toString()
        );
        MessageReceiver.dealPlayerInfoMessage(playerInfoMessage);
        console.log('testTag', `Receive playerInfoMessage ${want.parameters.playerName.toString()} from ${want.parameters.sender.toString()}`);
      }
    }
    else {
      hilog.error(0x0000, 'testTag', 'Dont Received Parameter from the want');
    }
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');

    DistributedKVStore.closeSingleKVStore();
    DistributedDeviceManager.release();
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
