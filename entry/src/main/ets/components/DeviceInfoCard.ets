import deviceManager from '@ohos.distributedDeviceManager'
import Device from '@system.device';
import { DistributedDeviceManager } from '../distributed_abilities/DistributedDeviceManager';

@Component
export default struct DeviceInfoCard {
  @Prop device: deviceManager.DeviceBasicInfo;
  // 设备状态
  @State deviceState: number = 2;

  aboutToAppear() {
    if (DistributedDeviceManager.ifDeviceBinded(this.device)) {
      this.deviceState = 1;
    }
    DistributedDeviceManager.onDeviceStateChange((state: number) => {
      this.deviceState = state;
    })
  }

  build() {
    Row({space: 15}) {
      Text(this.device.deviceName)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({overflow: TextOverflow.Ellipsis })
      if (this.deviceState === 2) {
        Text('未上线')
          .fontSize(16)
          .fontColor(Color.Red)
          .fontWeight(FontWeight.Bold)
        Button('认证')
          .backgroundColor(Color.Green)
          .clickEffect({level: ClickEffectLevel.HEAVY, scale: 0.7})
          .onClick(() => {
            DistributedDeviceManager.bindTarget(this.device);
          })
      }
      else if (this.deviceState === 0) {
        Text('等待连接')
          .fontSize(16)
          .fontColor(Color.Gray)
          .fontWeight(FontWeight.Bold)
        Button('重新认证')
          .clickEffect({level: ClickEffectLevel.HEAVY, scale: 0.7})
          .onClick(() => {
            DistributedDeviceManager.unbindTarget(this.device.deviceId);
            DistributedDeviceManager.bindTarget(this.device);
          })
      }
      else {
        Text('已上线')
          .fontSize(16)
          .fontColor(Color.Green)
          .fontWeight(FontWeight.Bold)
        Button('取消认证')
          .backgroundColor(Color.Red)
          .clickEffect({level: ClickEffectLevel.HEAVY, scale: 0.7})
          .onClick(() => {
            DistributedDeviceManager.unbindTarget(this.device.deviceId);
            this.deviceState = 0;
          })
      }
    }
    .width('100%')
    .height(80)
    .padding(15)
    .borderRadius(10)
    .backgroundColor($r('app.color.card_background'))
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .alignSelf(ItemAlign.Center)
  }
}