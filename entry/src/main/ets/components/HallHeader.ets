import Player from '../models/Player';
import { AvatarUrls } from '../utils/Common';
import { toIndexPage } from '../utils/Routers';
import IconButton from './IconButton';

@Component
export default struct HallHeader {
  @Prop localPlayer: Player;

  build() {
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
      .width("70%")
      .height("100%")
      .justifyContent(FlexAlign.Start)
      .clickEffect({level: ClickEffectLevel.HEAVY, scale: 0.7})
      .onClick(() => {
        toIndexPage();
      })
    }
    .width("100%")
    .height("70")
    .backgroundColor(Color.Transparent)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}