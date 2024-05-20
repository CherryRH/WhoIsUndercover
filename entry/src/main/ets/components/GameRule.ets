
@Component
export default struct GameRule {
  @Link ifShowGameRule: boolean;
  gameRuleText: string = '在场n(n大于等于3)个人中(n-x)(x就是卧底人数，暂定为1)个人拿到相同的一个词语，剩下的x个拿到与之相关的另一个词语。每人每轮只能说一句话描述自己拿到的词语（不能直接说出那个词语），既不能让卧底发现，也要给同伴以暗示。每轮描述完毕，n人投票选出怀疑是卧底的那个人，得票数最多的人出局；平票则进入下一轮描述。若最后仅剩两人（包含卧底），则卧底获胜；反之，则其他人获胜。';

  build() {
    Column({space: 20}) {
      Text(this.gameRuleText)
        .width('80%')
        .height('80%')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontStyle(FontStyle.Italic)
        .lineHeight(35)
        .letterSpacing(2)

      Text('我知道了')
        .width('50%')
        .fontSize(30)
        .fontWeight(FontWeight.Bolder)
        .fontStyle(FontStyle.Italic)
        .textAlign(TextAlign.Center)
        .clickEffect({level: ClickEffectLevel.HEAVY, scale: 0.7})
        .onClick(() => {
          animateTo({duration: 500, curve: Curve.EaseInOut}, () => {
            this.ifShowGameRule = false;
          })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundBlurStyle(BlurStyle.Thin)
  }
}