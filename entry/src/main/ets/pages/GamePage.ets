import router from '@ohos.router';
import Carousel from '../components/Carousel';
import { DistributedDeviceManager } from '../distributed_abilities/DistributedDeviceManager';
import MessageReceiver, { Message, PlayerInfoMessage } from '../distributed_abilities/MessageReceiver';
import MessageSender from '../distributed_abilities/MessageSender';
import Player from '../models/Player'
import localStorage from '../utils/MyStorage';
import { PageInfo } from '../utils/Routers';

const tag: string = 'TestTag [GamePage]:';
//获取路由传参
const params: PageInfo = router.getParams() as PageInfo;

@Entry(localStorage)
@Component
struct GamePage {
  @LocalStorageLink('LocalPlayer') localPlayer: Player = new Player();
  @State players: Player[] = [];
  // 当前轮数
  @State round: number = 1;
  // 房主networkId
  @State hostNetworkId: string = '';

  aboutToAppear() {
    this.hostNetworkId = params.name;
    this.players.push(this.localPlayer);
    // 注册接收游戏信息回调
    MessageReceiver.onReceiveMessage('GameMessage', (message: Message | PlayerInfoMessage) => {
      // 显示提醒框

    })
    // 注册接收玩家信息回调
    MessageReceiver.onReceiveMessage('PlayerInfoMessage', (message: Message | PlayerInfoMessage) => {
      console.log(tag, 'Receive player info')
      let player: Player = new Player();
      for (let it of this.players) {
        if (it.getPlayerName() === (message as PlayerInfoMessage).playerName) {
          return;
        }
      }
      player.setPlayerName((message as PlayerInfoMessage).playerName);
      player.setAvatar((message as PlayerInfoMessage).avatar);
      for (let device of DistributedDeviceManager.availableDeviceList) {
        if (device.networkId === message.sender) {
          player.setDeviceInfo(device);
        }
      }
      this.players.push(player);
      // 如果是主机，则将玩家信息分发给其他人
      if (this.localPlayer.getIsHost()) {
        for (let device of DistributedDeviceManager.availableDeviceList) {
          MessageSender.sendPlayerInfoMessage(device.networkId!, this.localPlayer);
          if (device.networkId === message.sender) {
            continue;
          }
          MessageSender.sendPlayerInfoMessage(device.networkId!, player);
        }
      }
      // 如果玩家数量足够，则开始游戏
      if (this.players.length === params.id) {

      }
    })
    // 向房主发送玩家信息
    if (!this.localPlayer.getIsHost()) {
      MessageSender.sendPlayerInfoMessage(this.hostNetworkId, this.localPlayer);
    }
  }

  build() {
    Stack() {
      Text('谁是卧底')
        .width('100%')
        .fontSize(70)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bolder)
        .fontStyle(FontStyle.Italic)
        .textAlign(TextAlign.Center)
        .textShadow({color: Color.Gray, radius: 0, offsetX: 20, offsetY: 10})
      Column({space: 10}) {
        Button('加')
          .onClick(() => {
            this.players.push(this.localPlayer);
          })
        Carousel({players: this.players})
          .width('100%')
          .height('50%')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .full()
    .backgroundColor($r('app.color.page_background'))
  }
}

/*
 * 样式表：占满空间
 * */
@Styles
function full() {
  .width('100%')
  .height('100%')
}