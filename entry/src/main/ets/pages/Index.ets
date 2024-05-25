import distributedKVStore from '@ohos.data.distributedKVStore';
import AvatarSelector from '../components/AvatarSelector';
import GameRule from '../components/GameRule';
import GameTitle from '../components/GameTitle';
import { DistributedDeviceManager } from '../distributed_abilities/DistributedDeviceManager';
import DistributedKVStore from '../distributed_abilities/DistributedKVStore';
import Player from '../models/Player';
import { AvatarUrls, userPrefName } from '../utils/Common';
import localStorage from '../utils/MyStorage';
import { toHallPage } from '../utils/Routers';
import preferenceUtil from '../utils/UserPreferenceUtil';
import WordProvider from '../utils/WordProvider';

const tag: string = 'TestTag [Index]:';

@Entry(localStorage)
@Component
struct Index {
  // 玩家名称
  @State playerName: string = 'Player';
  // 玩家头像
  @State avatar: number = 0;
  // 累计获胜次数
  @State winNum: number = 0;
  // 累计失败次数
  @State failNum: number = 0;
  // 是否编辑玩家信息
  @State ifEdit: boolean = false;
  // 是否显示游戏规则
  @State ifShowGameRule: boolean = false;
  // 本机玩家设为全局变量
  @LocalStorageLink('LocalPlayer') localPlayer: Player = new Player();

  async onPageShow() {
    // 读取用户首选项
    let playerName = await preferenceUtil.getPereferenceValue(userPrefName, 'playerName', this.playerName);
    let avatar = await preferenceUtil.getPereferenceValue(userPrefName, 'avatar', this.avatar);
    let winNum = await preferenceUtil.getPereferenceValue(userPrefName, 'winNum', this.winNum);
    let failNum = await preferenceUtil.getPereferenceValue(userPrefName, 'failNum', this.failNum);
    this.localPlayer.setPlayerName(playerName as string);
    this.localPlayer.setAvatar(avatar as number);
    this.playerName = playerName as string;
    this.avatar = avatar as number;
    this.winNum = winNum as number;
    this.failNum = failNum as number;

  }

  // 保存玩家信息
  async savePlayer() {
    this.localPlayer.setPlayerName(this.playerName);
    this.localPlayer.setAvatar(this.avatar);
    await preferenceUtil.putPereferenceValue(userPrefName, 'playerName', this.playerName);
    await preferenceUtil.putPereferenceValue(userPrefName, 'avatar', this.avatar);
  }

  build() {
    Stack() {
      Column() {
        GameTitle()
          .clickEffect({level: ClickEffectLevel.HEAVY, scale: 0.7})
          .onClick(() => {
            animateTo({duration: 500, curve: Curve.EaseInOut}, () => {
              this.ifShowGameRule = true;
            })
          })
        if (this.ifEdit) {
          Column({space: 30}) {
            Column({space: 10}) {
              Text('玩家名称')
                .width('50%')
                .fontSize(24)
                .fontWeight(FontWeight.Bolder)
                .fontStyle(FontStyle.Italic)
                .textAlign(TextAlign.Center)
              TextInput({ text: this.playerName, placeholder: '玩家'})
                .maxLength(20)
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
              .onClick(async () => {
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
                await this.savePlayer();
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
            Text('获胜 ' + this.winNum + ' 次  失败 ' + this.failNum + ' 次')
              .width('100%')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontStyle(FontStyle.Italic)
              .textAlign(TextAlign.Center)
              .fontColor(Color.Blue)
            Image(AvatarUrls[this.localPlayer.getAvatar()])
              .width(100)
              .borderRadius(20)
            Text(this.playerName.length === 0 ? '点击编辑玩家信息' : this.localPlayer.getPlayerName())
              .width('100%')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontStyle(FontStyle.Italic)
              .textAlign(TextAlign.Center)
          }
          .height('40%')
          .justifyContent(FlexAlign.Center)
          .clickEffect({level: ClickEffectLevel.HEAVY, scale: 0.7})
          .onClick(() => {
            // 进入编辑玩家信息
            animateTo({duration: 500, curve: Curve.EaseInOut}, () => {
              this.ifEdit = true;
            })
          })
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
            .onClick(async () => {
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
              await this.savePlayer();
              // 获取本地设备信息
              DistributedDeviceManager.getLocalDeviceInfo();
              toHallPage();
            })
        }
      }
      .full()
      .backgroundColor($r('app.color.page_background'))
      .justifyContent(FlexAlign.SpaceAround)
      .alignItems(HorizontalAlign.Center)

      // 是否显示游戏规则
      if (this.ifShowGameRule) {
        GameRule({ifShowGameRule: this.ifShowGameRule})
      }
    }
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