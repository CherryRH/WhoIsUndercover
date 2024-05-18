import { DistributedDeviceManager } from '../distributed_abilities/DistributedDeviceManager';
import Player from '../models/player';

let indexProp: Record<string, Player> = {
  'LocalPlayer': new Player()
};
let localStorage: LocalStorage = new LocalStorage(indexProp);

@Entry(localStorage)
@Component
struct Index {
  @State message: string = '谁是卧底';
  // 本机玩家设为全局变量
  @LocalStorageLink('LocalPlayer') localPlayer: Player = new Player();

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