import Player from './player';

/*
 * 评论
 * 一个玩家对他的词语做出的评论
 * */
export default class Remark {
  // 作出评论的玩家
  private player: Player;
  // 拿到的词语
  private word: string;
  // 内容
  private content: string;
  // 是否完成
  private ifFinished: boolean;

  constructor(player: Player, word: string) {
    this.player = player;
    this.word = word;
    this.content = "";
    this.ifFinished = false;
  }

  public getPlayer(): Player {
    return this.player;
  }

  public setPlayer(player: Player): void {
    this.player = player;
  }

  public getWord(): string {
    return this.word;
  }

  public setWord(word: string): void {
    this.word = word;
  }

  public getContent(): string {
    return this.content;
  }

  public setContent(content: string): void {
    this.content = content;
  }

  public getIfFinished(): boolean {
    return this.ifFinished;
  }

  public setIfFinished(ifFinished: boolean): void {
    this.ifFinished = ifFinished;
  }
}