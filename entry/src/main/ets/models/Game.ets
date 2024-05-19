import Player from './Player'
import Round from './Round';

const tag: string = 'TestTag [Game]:';

/*
 * 游戏类
 * 表示一局游戏
 * */
export default class Game {
  // 参与的玩家
  private players: Player[];
  // 本局游戏的轮
  private rounds: Round[];

  constructor(players: Player[]) {
    if (players.length === 0) {
      console.error(tag, '玩家为空，无法设置游戏');
      return;
    }
    this.players = players;
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

  public setRounds(rounds: Round[]): void {
    if (rounds.length === 0) {
      console.error(tag, '轮数为零，无法设置');
      return;
    }
    this.rounds = rounds;
  }

  public getRounds(): Round[] {
    return this.rounds;
  }
}