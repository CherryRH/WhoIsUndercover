import deviceManager from '@ohos.distributedDeviceManager'
import { DistributedDeviceManager } from '../distributed_abilities/DistributedDeviceManager'
import DeviceInfoCard from './DeviceInfoCard'
import IconButton from './IconButton';

/*
 * 组件：侧边栏
 * */
@Component
export default struct SideBar {
  // 设备列表
  @State deviceInfoList: deviceManager.DeviceBasicInfo[] = DistributedDeviceManager.deviceInfoList;

  build() {
    Column() {
      Text('已发现设备')
        .width('90%')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontStyle(FontStyle.Italic)
        .textAlign(TextAlign.Start)
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
      Row() {
        Button('开始搜索设备')
          .fontSize(12)
          .onClick(() => {
            this.deviceInfoList = DistributedDeviceManager.deviceInfoList;
            DistributedDeviceManager.onDiscoverSuccess((deviceInfoList: deviceManager.DeviceBasicInfo[]) => {
              this.deviceInfoList = deviceInfoList;
            })
            DistributedDeviceManager.startDiscovering();
          })
        Button('停止搜索设备')
          .fontSize(12)
          .onClick(() => {
            DistributedDeviceManager.stopDiscovering();
            DistributedDeviceManager.offDiscoverSuccess();
          })
      }
      .width('90%')
    }
    .bar_card()
    .padding(20)
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}

@Styles
function bar_card() {
  .width('90%')
  .height('100%')
  .borderRadius(20)
  .backgroundColor(Color.White)
  .shadow({ radius: 20, color: Color.Gray, offsetX: 15, offsetY: 10 })
}
