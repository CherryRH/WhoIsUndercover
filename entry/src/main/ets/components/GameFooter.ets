import Player, { RoleType } from '../models/Player';
import { AvatarUrls } from '../utils/Common';
import { toIndexPage } from '../utils/Routers';
import IconButton from './IconButton';

@Component
export default struct GameFooter {
  @Prop localPlayer: Player;

  build() {
    Column() {
      Divider()
      Row({space: 10}) {
        if (this.localPlayer.getRole() === RoleType.Unknown) {
          Text('等待职业分配')
            .titleFont()
            .fontSize(12)
            .fontColor(Color.Blue)
        }
        else if (this.localPlayer.getRole() === RoleType.Undercover) {
          Text('卧底')
            .titleFont()
            .fontSize(24)
            .fontColor(Color.White)
        }
        else if (this.localPlayer.getRole() === RoleType.Civilian) {
          Text('平民')
            .titleFont()
            .fontSize(24)
            .fontColor(Color.Black)
        }
        Text('被投票数：' + this.localPlayer.getVotes())
          .width('30%')
          .height('70%')
          .fontSize(20)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bolder)
          .fontStyle(FontStyle.Italic)
          .backgroundColor(Color.Gray)
          .borderRadius(10)
          .shadow({color: Color.White, radius: 5, offsetX: 10, offsetY: 5})
        Text('你的词语：' + this.localPlayer.getWord())
          .width('40%')
          .height('70%')
          .fontSize(20)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bolder)
          .fontStyle(FontStyle.Italic)
          .backgroundColor(Color.Gray)
          .borderRadius(10)
          .shadow({color: Color.White, radius: 5, offsetX: 10, offsetY: 5})
      }
      .width("100%")
      .height('100%')
      .padding(10)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width("100%")
    .height("70")
    .backgroundColor(Color.Transparent)
  }
}

@Extend(Text)
function titleFont() {
  .width('20%')
  .fontWeight(FontWeight.Bolder)
  .fontStyle(FontStyle.Italic)
}