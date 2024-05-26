/*
 * 组件：立体轮播图
 * */
import MessageSender from '../distributed_abilities/MessageSender';
import Player, { InGameStatus } from '../models/Player';
import { AvatarUrls } from '../utils/Common';

@Component
export default struct Carousel {
  // 主角度
  @State @Watch('onSwipe') Angle: number = 0;
  // 圆柱半径
  private radius: number = 25;
  // 视角距离
  private horizon: number = 50;
  // 当前最前方图片ID
  @State frontID: number = 0;
  // 图片中心坐标
  @State positionX: number[] = [];
  // 图片深度
  @State depth: number[] = []
  // 图片长宽
  private baseWidth: number = 70;
  private baseHeight: number = 90;
  @State Width: number[] = [];
  @State Height: number[] = [];
  // 图片灰度
  @State Grayscale: number[] = [];
  // 图片数量
  @State Size: number = 0;
  @State ID: number[] = [];
  @Prop @Watch('onItemsChange') players: Player[] = [];
  // 是否显示投票
  @Link startVoteFlag: boolean;
  // 主机的networkId
  @Prop hostNetworkId: string;
  @Link localPlayer: Player;

  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Left | PanDirection.Right });

  // 初始化变量
  aboutToAppear() {
    this.Size = this.players.length;
    for (let i = 0; i < this.Size; i++) {
      this.ID.push(i);
      this.Width.push(this.baseWidth);
      this.Height.push(this.baseHeight);
      this.positionX.push(0);
      this.depth.push(0);
      this.Grayscale.push(0);
      this.onSwipe();
    }
  }

  onItemsChange() {
    this.Size = this.players.length;
    this.ID = [];
    this.Width = [];
    this.Height = [];
    this.positionX = [];
    this.depth = [];
    this.Grayscale = [];
    for (let i = 0; i < this.Size; i++) {
      this.ID.push(i);
      this.Width.push(this.baseWidth);
      this.Height.push(this.baseHeight);
      this.positionX.push(0);
      this.depth.push(0);
      this.Grayscale.push(0);
      this.onSwipe();
    }
    this.Angle = 0;
    this.frontID = 0;
  }

  // 根据主角度计算所有变量
  onSwipe() {
    // 先计算每个图片的具体角度
    let everyAngle: number[] = [];
    // 主角度分割
    let partAngle: number = 360 / this.Size;
    for (let i: number = 0; i < this.Size; i++) {
      everyAngle.push(i * partAngle - this.Angle);
      let x = everyAngle[i] / 180 * Math.PI;
      // 计算深度
      this.depth[i] = this.radius - this.radius * Math.cos(x);
      // 计算尺寸
      this.Width[i] = (this.baseWidth * this.horizon) / (this.depth[i] + this.horizon);
      this.Height[i] = (this.baseHeight * this.horizon) / (this.depth[i] + this.horizon);
      // 计算坐标，如果存在重叠情况，则增加位移
      this.positionX[i] = this.radius * Math.sin(x);
      // 计算灰度
      this.Grayscale[i] = (this.depth[i] / (2 * this.radius)) * 0.7;
    }
  }

  build() {
    Column() {
      if (this.startVoteFlag) {
        Button('投票')
          .backgroundColor($r('app.color.button_background'))
          .onClick(() => {
            this.localPlayer.setInGameStatus(InGameStatus.Voted);
            // 向主机发送投票信息
            MessageSender.sendVoteMessage(this.hostNetworkId, this.players[this.frontID].getNetworkId());
            this.startVoteFlag = false;
          })
      }
      Row() {
        this.buildGraphList()
      }
      .width('100%')
      .height('100%')
      .gesture(
        PanGesture(this.panOption)
          .onActionStart((event: GestureEvent) => {
          })
          .onActionUpdate((event: GestureEvent) => {
            this.Angle -= event.offsetX / 4;
          })
          .onActionEnd(() => {
            // 找到最近的角度，进行自动复位
            let turnTo: number = Math.round(this.Angle / (360 / this.Size)) % this.Size;
            turnTo += (turnTo < 0) ? this.Size : 0;
            this.frontID = turnTo;
            animateTo({
              duration: 300,
              curve: Curve.Rhythm
            }, () => {
              this.Angle = (360 / this.Size) * turnTo;
            })
          })
      )
      Row() {
        Button('向左')
          .backgroundColor($r('app.color.button_background'))
          .onClick(() => {
            this.frontID = (this.frontID + 1 == this.Size ? 0 : this.frontID + 1);
            animateTo({
              duration: 500,
              curve: Curve.Rhythm
            }, () => {
              this.Angle += 360 / this.Size;
            })
          })
        Text((this.frontID + 1) + '/' + this.Size)
          .width('20%')
          .fontSize(20)
          .fontWeight(FontWeight.Bolder)
          .fontStyle(FontStyle.Italic)
          .textAlign(TextAlign.Center)
        Button('向右')
          .backgroundColor($r('app.color.button_background'))
          .onClick(() => {
            let preID = this.frontID;
            this.frontID = (preID - 1 == -1 ? this.Size - 1 : preID - 1);
            animateTo({
              duration: 500,
              curve: Curve.Rhythm
            }, () => {
              this.Angle -= 360 / this.Size;
            })
          })
      }
      .width('100%')
      .height('10%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildGraphList() {
    Row() {
      ForEach(
        this.ID,
        (id: number) => {
          Graph({player: this.players[id], ID: id})
            .borderRadius(10)
            .borderWidth(2)
            .borderColor((id === this.frontID) ? '#ffffe600' : Color.Black)
            .backgroundColor(Color.White)
            .width(this.Width[id].toString() + '%')
            .height(this.Height[id].toString() + '%')
            .position({x: (50 + this.positionX[id] - this.Width[id] / 2).toString() + '%', y: (50 - this.Height[id] / 2) + '%'})
            .opacity(1 - this.Grayscale[id])
            .zIndex(this.getZIndex(id))
            .onClick(() => {
              console.log('testtag', id)
            })
        }
      )
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }

  // 计算覆盖优先级
  getZIndex(id: number): number {
    return 50 - this.depth[id];
  }

  // 判断是否会造成重叠
  haveOverlap(): boolean {
    return this.radius * Math.sin(180 / this.Size) * 2 < this.baseWidth;
  }
}

/*
 * 组件：模拟一张图片
 * */
@Component
struct Graph {
  @Prop ID: number;
  @Prop player: Player;

  build() {
    Column() {
      Row({space: 10}) {
        Image(AvatarUrls[this.player.getAvatar()])
          .width(30)
          .borderRadius(5)
          .margin({left: 5})
        Text(this.player.getPlayerName().length === 0 ? '玩家' : this.player.getPlayerName())
          .width('100%')
          .fontSize(16)
          .fontWeight(FontWeight.Bolder)
          .fontStyle(FontStyle.Italic)
          .maxLines(1)
          .textOverflow({overflow: TextOverflow.Ellipsis})
      }
      .width("100%")
      .height("15%")
      .justifyContent(FlexAlign.Start)
      Divider()
      if (this.player.getRemark().length === 0) {
        Text('等待发言')
          .width('100%')
          .height('100%')
          .fontSize(24)
          .fontWeight(FontWeight.Bolder)
          .fontStyle(FontStyle.Italic)
          .textAlign(TextAlign.Center)
      }
      else {
        Text(this.player.getRemark())
          .width('100%')
          .fontSize(16)
          .padding(5)
          .fontWeight(FontWeight.Bold)
          .fontStyle(FontStyle.Italic)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
  }
}