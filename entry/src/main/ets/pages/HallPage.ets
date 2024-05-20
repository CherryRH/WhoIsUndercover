import HallHeader from '../components/HallHeader'
import MoreButton from '../components/MoreButton'
import SideBar from '../components/SideBar'
import { DistributedDeviceManager } from '../distributed_abilities/DistributedDeviceManager'
import localStorage from '../utils/MyStorage'
import deviceManager from '@ohos.distributedDeviceManager'
import DeviceInfoCard from '../components/DeviceInfoCard'
import Player from '../models/Player'

@Entry(localStorage)
@Component
struct HallPage {
  @LocalStorageLink('LocalPlayer') localPlayer: Player = new Player();
  // 设备列表
  @State deviceInfoList: deviceManager.DeviceBasicInfo[] = DistributedDeviceManager.deviceInfoList;
  // 是否正在搜索设备
  @State isDiscovering: boolean = false;

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
                  this.deviceInfoList = deviceInfoList;
                })
                DistributedDeviceManager.startDiscovering();
                this.deviceInfoList = Array.from(new Set([...DistributedDeviceManager.deviceInfoList,...DistributedDeviceManager.availableDeviceList]));
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
          .onClick(() => {
            // 如果已认证设备少于2个，则停止创建房间
            if (DistributedDeviceManager.availableDeviceList.length < 2) {
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
            // 拉起已上线的设备

          })
      }
      .full()
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