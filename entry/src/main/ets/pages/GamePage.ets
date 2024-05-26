import router from '@ohos.router';
import Carousel from '../components/Carousel';
import GameFooter from '../components/GameFooter';
import GameHeader from '../components/GameHeader';
import RemarkWidget from '../components/RemarkWidget';
import { DistributedDeviceManager } from '../distributed_abilities/DistributedDeviceManager';
import MessageReceiver, { Message, PlayerInfoMessage } from '../distributed_abilities/MessageReceiver';
import MessageSender from '../distributed_abilities/MessageSender';
import Player, { InGameStatus, RoleType } from '../models/Player'
import localStorage from '../utils/MyStorage';
import { PageInfo } from '../utils/Routers';
import WordProvider, { Word } from '../utils/WordProvider';

const tag: string = 'TestTag [GamePage]:';
//获取路由传参
const params: PageInfo = router.getParams() as PageInfo;

@Entry(localStorage)
@Component
struct GamePage {
  @LocalStorageLink('LocalPlayer') localPlayer: Player = new Player();
  // 全体玩家
  @State players: Player[] = [];
  // 剩余的玩家
  @State leftPlayers: Player[] = [];
  // 当前轮数
  @State round: number = 0;
  // 房主networkId
  @State hostNetworkId: string = '';
  // 新一轮是否可以开启
  @State canNewRoundStartFlag: boolean = false;

  onPageShow() {
    this.hostNetworkId = params.name;
    this.players.push(this.localPlayer);
    this.leftPlayers.push(this.localPlayer);
    // 注册接收游戏信息回调
    MessageReceiver.onReceiveMessage('GameMessage', (message: Message | PlayerInfoMessage) => {
      // 显示提醒框
      console.log(tag, 'Receive Game Message');
      let str = (message as Message).message;
      if (str.length === 0) {
        console.warn(tag, 'Receive empty message');
      }
      if (str === 'Start') {
        // 人数已满，游戏正式开始
        AlertDialog.show(
          {
            message: '玩家已到齐，游戏正式开始！',
            autoCancel: true,
            alignment: DialogAlignment.Bottom,
            gridCount: 3
          }
        )
        // 改变玩家状态
        this.localPlayer.setInGameStatus(InGameStatus.WaitForWord);
      }
      else if (str === 'SetUndercover') {
        // 设置为卧底
        AlertDialog.show(
          {
            message: '你的职业是【卧底】',
            autoCancel: true,
            alignment: DialogAlignment.Bottom,
            gridCount: 3
          }
        )
        // 改变玩家状态
        this.localPlayer.setRole(RoleType.Undercover);
      }
      else if (str === 'SetCivilian') {
        // 设置为平民
        AlertDialog.show(
          {
            message: '你的职业是【平民】',
            autoCancel: true,
            alignment: DialogAlignment.Bottom,
            gridCount: 3
          }
        )
        // 改变玩家状态
        this.localPlayer.setRole(RoleType.Civilian);
      }
      else if (str === 'StartSpeaking') {
        // 一名玩家开始发言
        AlertDialog.show(
          {
            message: `开始发言!`,
            autoCancel: true,
            alignment: DialogAlignment.Bottom,
            gridCount: 3
          }
        )
        this.localPlayer.setInGameStatus(InGameStatus.Speaking);
      }
    })
    // 注册接收玩家信息回调
    MessageReceiver.onReceiveMessage('PlayerInfoMessage', (message: Message | PlayerInfoMessage) => {
      console.log(tag, 'Receive player info');
      let player: Player = new Player();
      for (let it of this.players) {
        if (it.getPlayerName() === (message as PlayerInfoMessage).playerName) {
          return;
        }
      }
      player.setPlayerName((message as PlayerInfoMessage).playerName);
      player.setAvatar((message as PlayerInfoMessage).avatar);
      player.setNetworkId((message as PlayerInfoMessage).networkId);
      this.players.push(player);
      this.leftPlayers.push(player);
      // 如果是主机，则将玩家信息分发给其他人
      if (this.localPlayer.getIsHost()) {
        for (let device of DistributedDeviceManager.availableDeviceList) {
          MessageSender.sendPlayerInfoMessage(device.networkId!, this.localPlayer);
          if (device.networkId === message.sender) {
            continue;
          }
          MessageSender.sendPlayerInfoMessage(device.networkId!, player);
        }
        // 如果玩家数量足够，则开始游戏
        if (this.players.length === params.id) {
          setTimeout(() => {
            for (let player of this.players) {
              MessageSender.sendGameMessage(player.getNetworkId(), 'Start');
              player.setInGameStatus(InGameStatus.WaitForWord);
            }
            this.canNewRoundStartFlag = true;
          }, 1000);

          // 分配职业
          setTimeout(() => {
            let index = Math.floor(this.leftPlayers.length * Math.random());
            for (let player of this.leftPlayers) {
              if (index === this.leftPlayers.indexOf(player)) {
                MessageSender.sendGameMessage(player.getNetworkId(), 'SetUndercover');
                player.setRole(RoleType.Undercover);
              }
              else {
                MessageSender.sendGameMessage(player.getNetworkId(), 'SetCivilian');
                player.setRole(RoleType.Civilian);
              }
            }
          }, 5000);
        }
      }
    })
    // 注册接收词语回调
    MessageReceiver.onReceiveMessage('WordMessage', (message: Message | PlayerInfoMessage) => {
      console.log(tag, 'Receive Word Message');
      let word = (message as Message).message;
      if (word.length === 0) {
        console.warn(tag, 'Receive empty word message');
      }
      AlertDialog.show(
        {
          message: `你的词语是【${word}】，开始发言后请在1分钟内完成发言并点击发送`,
          autoCancel: true,
          alignment: DialogAlignment.Bottom,
          gridCount: 3
        }
      )
      this.localPlayer.setWord(word);
      this.localPlayer.setInGameStatus(InGameStatus.WaitForSpeaking);
      this.round++;

    })
    // 向房主发送玩家信息
    if (!this.localPlayer.getIsHost()) {
      MessageSender.sendPlayerInfoMessage(this.hostNetworkId, this.localPlayer);
    }
  }

  onPageHide() {
    // 取消注册游戏信息回调
    MessageReceiver.offReceiveMessage('GameMessage');
    MessageReceiver.offReceiveMessage('PlayerInfoMessage');
    MessageReceiver.offReceiveMessage('WordMessage');
    // 重置玩家状态
    this.localPlayer.reset();
  }

  // 每一轮是否可以开启
  canNewRoundStart() {
    let flag: boolean = true;
    for (let player of this.leftPlayers) {
      if (player.getInGameStatus() != InGameStatus.WaitForWord) flag = false;
    }
    return flag;
  }

  build() {
    Stack() {
      Column() {
        Text(this.round < 1 ? '等待开始' : 'Round' + this.round)
          .width('100%')
          .fontSize(70)
          .fontColor(Color.Yellow)
          .fontWeight(FontWeight.Bolder)
          .fontStyle(FontStyle.Italic)
          .textAlign(TextAlign.Center)
          .textShadow({color: Color.Gray, radius: 0, offsetX: 10, offsetY: 5})

        Text('谁是卧底')
          .width('100%')
          .fontSize(70)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bolder)
          .fontStyle(FontStyle.Italic)
          .textAlign(TextAlign.Center)
          .textShadow({color: Color.Gray, radius: 0, offsetX: 20, offsetY: 10})
      }
      .width('100%')
      .height('80%')
      .justifyContent(FlexAlign.SpaceBetween)
      Column({space: 10}) {
        Column() {
          GameHeader({localPlayer: this.localPlayer})

          if (this.localPlayer.getIsHost() && this.canNewRoundStartFlag) {
            Button(`开始第${this.round + 1}轮`)
              .width('40%')
              .fontSize(20)
              .backgroundColor($r('app.color.button_background'))
              .fontWeight(FontWeight.Bolder)
              .fontStyle(FontStyle.Italic)
              .clickEffect({level: ClickEffectLevel.HEAVY, scale: 0.7})
              .onClick(() => {
                // 开始新的一轮
                this.canNewRoundStartFlag = false;
                // 获取随机词语
                let word: Word = WordProvider.getRandomWord();
                for (let player of this.leftPlayers) {
                  if (player.getRole() === RoleType.Undercover) {
                    MessageSender.sendWordMessage(player.getNetworkId(), word.undercoverWord);
                  }
                  else if (player.getRole() === RoleType.Civilian) {
                    MessageSender.sendWordMessage(player.getNetworkId(), word.civilianWord);
                  }
                  player.setInGameStatus(InGameStatus.WaitForSpeaking);
                }
                // 5s后随机选择一名玩家发言
                setTimeout(() => {
                  let index = Math.floor(this.leftPlayers.length * Math.random());
                  this.leftPlayers[index].setInGameStatus(InGameStatus.Speaking);
                  MessageSender.sendGameMessage(this.leftPlayers[index].getNetworkId(), 'StartSpeaking');
                }, 5000);
              })
          }
        }

        Carousel({players: this.leftPlayers})
          .width('100%')
          .height('50%')
        GameFooter({localPlayer: this.localPlayer})
      }
      .full()
      .justifyContent(FlexAlign.SpaceBetween)

      if (this.localPlayer.getInGameStatus() === InGameStatus.Speaking) {
        RemarkWidget({localPlayer: this.localPlayer, hostNetworkId: this.hostNetworkId})
      }
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