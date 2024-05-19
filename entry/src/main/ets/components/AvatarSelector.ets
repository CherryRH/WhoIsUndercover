import { AvatarUrls } from '../utils/Common';

@Component
export default struct AvatarSelector {
  // 头像编号
  @Link avatar: number;

  build() {
    Column() {
      Text('头像选择')
        .width('50%')
        .fontSize(24)
        .fontWeight(FontWeight.Bolder)
        .fontStyle(FontStyle.Italic)
        .textAlign(TextAlign.Center)
      List({space: 10}) {
        ForEach(
          AvatarUrls,
          (item: Resource, index: number) => {
            ListItem() {
              Image(item)
                .width(60)
                .borderRadius(10)
                .borderWidth(3)
                .borderColor((index === this.avatar) ? Color.Yellow : Color.Transparent)
                .clickEffect({level: ClickEffectLevel.HEAVY, scale: 0.7})
                .onClick(() => {
                  //更改头像
                  this.avatar = index;
                })
            }
          }
        )
      }
      .height(80)
      .alignListItem(ListItemAlign.Center)
      .listDirection(Axis.Horizontal)
    }
  }
}