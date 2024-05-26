import Player, { InGameStatus } from '../models/Player';

@Component
export default struct RemarkWidget {
  @Link localPlayer: Player;
  @Prop hostNetworkId: string;
  // 倒计时
  @State time: number = 60;
  @State intervalId: number = 0;

  aboutToAppear() {
    this.time = 60;
    this.intervalId = setInterval(() => {
      if (this.time <= 0) {
        this.sendRemarkToHost();
        clearInterval(this.intervalId);
        return;
      }
      this.time--;
    }, 1000);
  }

  // 发送评论
  sendRemarkToHost() {

    this.localPlayer.setInGameStatus(InGameStatus.WaitForVote);
  }

  build() {
    Column({space: 30}) {
      Text(`你的词语：${this.localPlayer.getWord()}  倒计时${this.time}秒`)
        .width('100%')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .fontStyle(FontStyle.Italic)

      TextArea({text: this.localPlayer.getRemark(), placeholder: '请对你的词语进行不超过100字的发言，限时1分钟'})
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontStyle(FontStyle.Italic)
        .width('80%')
        .height('70%')
        .onChange((value: string) => {
          this.localPlayer.setRemark(value);
        })

      Text('提交')
        .width('50%')
        .fontSize(30)
        .fontWeight(FontWeight.Bolder)
        .fontStyle(FontStyle.Italic)
        .textAlign(TextAlign.Center)
        .clickEffect({level: ClickEffectLevel.HEAVY, scale: 0.7})
        .onClick(() => {
          this.sendRemarkToHost();
          clearInterval(this.intervalId);
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundBlurStyle(BlurStyle.Thin)
  }
}