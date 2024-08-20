import HallHeader from '../components/HallHeader'
import MoreButton from '../components/MoreButton'
import SideBar from '../components/SideBar'
import { DistributedDeviceManager } from '../distributed_abilities/DistributedDeviceManager'
import localStorage from '../utils/MyStorage'
import deviceManager from '@ohos.distributedDeviceManager'
import DeviceInfoCard from '../components/DeviceInfoCard'
import Player from '../models/Player'
import { toGamePage } from '../utils/Routers'
import distributedKVStore from '@ohos.data.distributedKVStore'
import DistributedKVStore from '../distributed_abilities/DistributedKVStore'
import MessageSender from '../distributed_abilities/MessageSender'
import MessageReceiver, { Message, PlayerInfoMessage } from '../distributed_abilities/MessageReceiver'

const tag: string = 'TestTag [HallPage]:';

@Entry(localStorage)
@Component
struct HallPage {
  @LocalStorageLink('LocalPlayer') localPlayer: Player = new Player();
  // 设备列表
  @State deviceInfoList: deviceManager.DeviceBasicInfo[] = DistributedDeviceManager.deviceInfoList;
  // 是否正在搜索设备
  @State isDiscovering: boolean = false;
  // 是否有加入房间的邀请
  @State ifInvited: boolean = false;
  // 房主的networkId
  @State hostNetworkId: string = '';

  async onPageShow() {
    DistributedDeviceManager.getAvailableDeviceListSync();

    this.deviceInfoList = DistributedDeviceManager.availableDeviceList;
    // 注册接收信息的回调
    MessageReceiver.onReceiveMessage('GameMessage', (message: Message | PlayerInfoMessage) => {
      // 房主发送开始游戏的邀请
      if ((message as Message).message === 'GameStart') {
        this.ifInvited = true;
        this.hostNetworkId = message.sender;
      }
    })
  }

  onPageHide() {
    MessageReceiver.offReceiveMessage('GameMessage');
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
        HallHeader({localPlayer: this.localPlayer})
        Divider()
        Row() {
          Text('已发现设备 ' + this.deviceInfoList.length + ' 个')
            .width('50%')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontStyle(FontStyle.Italic)
            .maxLines(1)
            .textAlign(TextAlign.Start)
          Blank()
          if (this.isDiscovering) {
            Button('停止搜索设备')
              .fontSize(12)
              .backgroundColor(Color.Red)
              .clickEffect({level: ClickEffectLevel.HEAVY, scale: 0.7})
              .onClick(() => {
                this.isDiscovering = false;
                DistributedDeviceManager.stopDiscovering();
                DistributedDeviceManager.offDiscoverSuccess();
              })
          }
          else {
            Button('开始搜索设备')
              .fontSize(12)
              .backgroundColor(Color.Green)
              .clickEffect({level: ClickEffectLevel.HEAVY, scale: 0.7})
              .onClick(() => {
                DistributedDeviceManager.getAvailableDeviceListSync();
                this.isDiscovering = true;
                DistributedDeviceManager.onDiscoverSuccess((deviceInfoList: deviceManager.DeviceBasicInfo[]) => {
                  this.deviceInfoList = Array.from(new Set([...deviceInfoList,...DistributedDeviceManager.availableDeviceList]));
                })
                DistributedDeviceManager.startDiscovering();
              })
          }
        }
        .width('100%')
        .padding(10)
        .justifyContent(FlexAlign.Start)

        Divider()
        // 设备列表
        List({space: 6}) {
          ForEach(
            this.deviceInfoList,
            (item: deviceManager.DeviceBasicInfo) => {
              ListItem() {
                DeviceInfoCard({device: item});
              }
            }
          )
        }
        Blank()
        Text('创建房间')
          .width('60%')
          .padding(20)
          .fontSize(40)
          .fontWeight(FontWeight.Bolder)
          .fontColor(Color.White)
          .fontStyle(FontStyle.Italic)
          .textAlign(TextAlign.Center)
          .clickEffect({level: ClickEffectLevel.HEAVY, scale: 0.7})
          .onClick(async () => {
            // 如果已认证设备少于2个，则停止创建房间
            if (DistributedDeviceManager.availableDeviceList.length < 1) {
              AlertDialog.show(
                {
                  message: '已上线设备不能少于2个',
                  autoCancel: true,
                  alignment: DialogAlignment.Bottom,
                  gridCount: 3
                }
              )
              return;
            }
            // 本机玩家成为房主
            this.localPlayer.setIsHost(true);
            // 向所有已上线的设备发送信息
            DistributedDeviceManager.getAvailableDeviceListSync();
            for (let device of DistributedDeviceManager.availableDeviceList) {
              MessageSender.sendGameMessage(device.networkId, 'GameStart');
            }
            toGamePage(DistributedDeviceManager.localDeviceInfo.networkId, DistributedDeviceManager.availableDeviceList.length + 1);
          })
      }
      .full()

      if (this.ifInvited) {
        Column({space: 50}) {
          Text('有玩家邀请您进入游戏，是否进入？')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontStyle(FontStyle.Italic)
          Row() {
            Text('否')
              .width('30%')
              .height('10%')
              .fontColor(Color.Red)
              .fontSize(30)
              .fontWeight(FontWeight.Bolder)
              .fontStyle(FontStyle.Italic)
              .textAlign(TextAlign.Center)
              .onClick(() => {
                this.ifInvited = false;
              })
            Text('是')
              .width('30%')
              .height('10%')
              .fontColor(Color.Blue)
              .fontSize(30)
              .fontWeight(FontWeight.Bolder)
              .fontStyle(FontStyle.Italic)
              .textAlign(TextAlign.Center)
              .onClick(() => {
                this.localPlayer.setIsHost(false);
                this.ifInvited = false;
                toGamePage(this.hostNetworkId);
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
        }
        .full()
        .justifyContent(FlexAlign.Center)
        .backgroundBlurStyle(BlurStyle.Thin)
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