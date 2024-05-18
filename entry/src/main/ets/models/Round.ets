import Player from './player'
import Remark from './remark';

const tag: string = 'TestTag [Round]:';

/*
 * 游戏内的一轮
 * 所有玩家全部完成评论，并完成投票后，系统产生判定结果，该轮即结束
 * */
export default class Round {
  // 本轮参与的玩家
  private players: Player[];
  // 卧底词
  private undercoverWord: string;
  // 平民词
  private civilianWord: string;
  // 本轮的所有发言
  private remarks: Remark[];

  constructor() {
    this.undercoverWord = "";
    this.civilianWord = "";
  }

  // 本轮是否结束（投票结束）
  public isOver(): boolean {
    // 确保发言已结束
    if (!this.isRemarkOver()) {
      console.error(tag, '本轮发言尚未结束');
      return false;
    }
    let roundVotes: number = 0;
    for (let player of this.players) {
      roundVotes += player.getVotes();
    }
    if (roundVotes > this.players.length) {
      console.error(tag, '本轮投票数超过玩家数，错误');
      return false;
    }
    return roundVotes === this.players.length;
  }

  // 本轮发言是否结束
  public isRemarkOver(): boolean {
    if (this.players.length === 0) {
      console.error(tag, '本轮玩家为空，无法判断');
      return false;
    }
    if (this.players.length < this.remarks.length) {
      console.error(tag, '本轮评论数超过玩家数，错误');
      return false;
    }
    return this.remarks.length === this.players.length;
  }

  public setPlayers(players: Player[]): void {
    if (players.length === 0) {
      console.error(tag, '玩家为空，无法设置');
      return;
    }
    this.players = players;
  }

  public getPlayers(): Player[] {
    return this.players;
  }

  public setUndercoverWord(undercoverWord: string): void {
    this.undercoverWord = undercoverWord;
  }

  public getUndercoverWord(): string {
    return this.undercoverWord;
  }

  public setCivilianWord(civilianWord: string): void {
    this.civilianWord = civilianWord;
  }

  public getCivilianWord(): string {
    return this.civilianWord;
  }

  public setRemarks(remarks: Remark[]): void {
    this.remarks = remarks;
  }

  public addRemark(remark: Remark): void {
    if (!remark) {
      console.warn(tag, '评论不能为空');
      return;
    }
    this.remarks.push(remark);
  }

  public getRemarks(): Remark[] {
    return this.remarks;
  }
}