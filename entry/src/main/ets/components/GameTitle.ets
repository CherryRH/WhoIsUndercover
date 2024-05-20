
@Component
export default struct GameTitle {

  build() {
    Column({space: 5}) {
      Text('谁是卧底')
        .width('100%')
        .fontSize(70)
        .fontWeight(FontWeight.Bolder)
        .fontStyle(FontStyle.Italic)
        .textAlign(TextAlign.Center)
        .textShadow({color: Color.White, radius: 0, offsetX: 20, offsetY: 10})
      Row({space: 5}) {
        Text('游戏规则')
          .width('35%')
          .fontSize(20)
          .fontWeight(FontWeight.Bolder)
          .fontStyle(FontStyle.Italic)
          .textAlign(TextAlign.Center)
          .fontColor('#ff3686ff')
        Image($r('app.media.ic_public_search'))
          .width(20)
          .backgroundColor(Color.Transparent)
      }
      .width('70%')
      .justifyContent(FlexAlign.End)
    }
  }
}