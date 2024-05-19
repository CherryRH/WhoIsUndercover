import AvatarSelector from '../components/AvatarSelector';
import { DistributedDeviceManager } from '../distributed_abilities/DistributedDeviceManager';
import Player from '../models/Player';
import { AvatarUrls } from '../utils/Common';
import { toHallPage } from '../utils/Routers';
import WordProvider from '../utils/WordProvider';

const tag: string = 'TestTag [Index]:';

let indexProp: Record<string, Player> = {
  'LocalPlayer': new Player()
};
let localStorage: LocalStorage = new LocalStorage(indexProp);

@Entry(localStorage)
@Component
struct Index {
  // 玩家名称
  @State playerName: string = '';
  // 玩家头像
  @State avatar: number = 0;
  // 是否编辑玩家信息
  @State ifEdit: boolean = false;
  // 本机玩家设为全局变量
  @LocalStorageLink('LocalPlayer') localPlayer: Player = new Player();

  onPageShow() {

  }

  build() {
    Column() {
      Text('谁是卧底')
        .width('100%')
        .fontSize(70)
        .fontWeight(FontWeight.Bolder)
        .fontStyle(FontStyle.Italic)
        .textAlign(TextAlign.Center)
      if (this.ifEdit) {
        Column({space: 30}) {
          Column({space: 10}) {
            Text('玩家名称')
              .width('50%')
              .fontSize(24)
              .fontWeight(FontWeight.Bolder)
              .fontStyle(FontStyle.Italic)
              .textAlign(TextAlign.Center)
            TextInput({ text: this.playerName, placeholder: '老玩家'})
              .maxLength(15)
              .onChange((val: string) => {
                this.playerName = val;
              })
          }
          AvatarSelector({avatar: this.avatar})
          Text('确定')
            .width('60%')
            .fontSize(30)
            .fontWeight(FontWeight.Bolder)
            .fontColor(Color.White)
            .fontStyle(FontStyle.Italic)
            .textAlign(TextAlign.Center)
            .clickEffect({level: ClickEffectLevel.HEAVY, scale: 0.7})
            .onClick(() => {
              // 判断玩家名称是否为空
              if (this.playerName.length === 0) {
                AlertDialog.show(
                  {
                    message: '玩家名称不能为空',
                    autoCancel: true,
                    alignment: DialogAlignment.Bottom,
                    gridCount: 3
                  }
                )
                return;
              }
              animateTo({duration: 500, curve: Curve.EaseInOut}, () => {
                this.ifEdit = false;
              })
            })
        }
        .width('80%')
        .height('40%')
      }
      else {
        Column({space: 10}) {
          Image(AvatarUrls[this.avatar])
            .width(100)
            .borderRadius(20)
            .clickEffect({level: ClickEffectLevel.HEAVY, scale: 0.7})
            .onClick(() => {
              // 进入编辑玩家信息
              animateTo({duration: 500, curve: Curve.EaseInOut}, () => {
                this.ifEdit = true;
              })
            })
          Text(this.playerName.length === 0 ? '点击编辑玩家信息' : this.playerName)
            .width('100%')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontStyle(FontStyle.Italic)
            .textAlign(TextAlign.Center)
        }
        .height('40%')
        .justifyContent(FlexAlign.Center)
      }

      if (!this.ifEdit) {
        Text('进入游戏！')
          .width('60%')
          .fontSize(40)
          .fontWeight(FontWeight.Bolder)
          .fontColor(Color.White)
          .fontStyle(FontStyle.Italic)
          .textAlign(TextAlign.Center)
          .clickEffect({level: ClickEffectLevel.HEAVY, scale: 0.7})
          .onClick(() => {
            // 判断玩家名称是否为空
            if (this.playerName.length === 0) {
              AlertDialog.show(
                {
                  message: '玩家名称不能为空',
                  autoCancel: true,
                  alignment: DialogAlignment.Bottom,
                  gridCount: 3
                }
              )
              return;
            }
            // 获取本地设备信息
            DistributedDeviceManager.getLocalDeviceInfo();

            toHallPage();
          })
      }
    }
    .full()
    .backgroundColor('#ffd4e4ef')
    .justifyContent(FlexAlign.SpaceAround)
    .alignItems(HorizontalAlign.Center)
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