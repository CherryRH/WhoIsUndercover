import { DistributedDeviceManager } from '../distributed_abilities/DistributedDeviceManager';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';


  build() {
    Column({space: 10}) {

    }
    .full()
    .justifyContent(FlexAlign.Center)
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