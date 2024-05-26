import Player, { InGameStatus } from '../models/Player';
import { AvatarUrls } from '../utils/Common';
import { toIndexPage } from '../utils/Routers';
import IconButton from './IconButton';

@Component
export default struct GameHeader {
  @Prop localPlayer: Player;

  build() {
    Column() {
      Row() {
        Row({space: 10}) {
          Image(AvatarUrls[this.localPlayer.getAvatar()])
            .width(50)
            .borderRadius(10)
            .margin({left: 10})
          Text(this.localPlayer.getPlayerName().length === 0 ? '玩家' : this.localPlayer.getPlayerName())
            .width('100%')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontStyle(FontStyle.Italic)
            .maxLines(1)
            .textOverflow({overflow: TextOverflow.Ellipsis})
        }
        .width("50%")
        .height("100%")
        .justifyContent(FlexAlign.Start)
        if (this.localPlayer.getInGameStatus() === InGameStatus.WaitForStart) {
          Text('等待玩家进入')
            .titleFont()
            .fontColor(Color.Green)
        }
        else if (this.localPlayer.getInGameStatus() === InGameStatus.WaitForWord) {
          Text('等待词语发放')
            .titleFont()
            .fontColor(Color.Green)
        }
        else if (this.localPlayer.getInGameStatus() === InGameStatus.WaitForSpeaking) {
          Text('等待发言')
            .titleFont()
            .fontColor(Color.Green)
        }
        else if (this.localPlayer.getInGameStatus() === InGameStatus.Speaking) {
          Text('正在发言')
            .titleFont()
            .fontColor(Color.Orange)
        }
        else if (this.localPlayer.getInGameStatus() === InGameStatus.WaitForVote) {
          Text('等待投票')
            .titleFont()
            .fontColor(Color.Green)
        }
        else if (this.localPlayer.getInGameStatus() === InGameStatus.Voted) {
          Text('投票完成')
            .titleFont()
            .fontColor(Color.Orange)
        }
        else if (this.localPlayer.getInGameStatus() === InGameStatus.Out) {
          Text('您已出局')
            .titleFont()
            .fontColor(Color.Red)
        }
        else if (this.localPlayer.getInGameStatus() === InGameStatus.Win) {
          Text('您已获胜！')
            .titleFont()
            .fontColor(Color.Yellow)
        }

      }
      .width("100%")
      .height("100%")
      .backgroundColor(Color.Transparent)
      .justifyContent(FlexAlign.SpaceBetween)
      Divider()
    }
    .width("100%")
    .height("70")
    .backgroundColor(Color.Transparent)
  }
}

@Extend(Text)
function titleFont() {
  .width('50%')
  .fontSize(20)
  .fontWeight(FontWeight.Bolder)
  .fontStyle(FontStyle.Italic)
  .textAlign(TextAlign.End)
  .padding(10)
}