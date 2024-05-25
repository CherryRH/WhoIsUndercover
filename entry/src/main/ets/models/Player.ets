import deviceManager from '@ohos.distributedDeviceManager';
import {AvatarUrls} from '../utils/Common'

const tag: string = 'TestTag [Player]:';

/*
 * 玩家类
 * 储存玩家的设备ID和个人信息
 * */
export default class Player {
  // 设备信息
  private deviceInfo: deviceManager.DeviceBasicInfo | null;
  // 玩家名称
  private playerName: string;
  // 玩家头像
  private avatar: number;
  // 角色类型
  private role: RoleType;
  // 玩家状态
  private inGameStatus: InGameStatus;
  // 是否是主机
  private isHost: boolean;
  // 被投票数（一轮游戏中）
  private votes: number;
  // 被投总票数
  private allVotes: number;
  // 玩家描述
  private remark: string;
  // 玩家词语
  private word: string;

  constructor(deviceInfo?: deviceManager.DeviceBasicInfo, playerName?: string, avatar?: number) {
    this.deviceInfo = deviceInfo ?? null;
    this.playerName = playerName ?? "";
    this.avatar = avatar ?? 0;
    this.role = RoleType.Undercover;
    this.inGameStatus = InGameStatus.WaitForWord;
    this.isHost = false;
    this.votes = 0;
    this.allVotes = 0;
    this.remark = '';
    this.word = '';
  }

  public getDeviceInfo(): deviceManager.DeviceBasicInfo | null {
    return this.deviceInfo;
  }

  public setDeviceInfo(deviceInfo: deviceManager.DeviceBasicInfo): void {
    if (!deviceInfo) {
      console.error(tag, '玩家设备信息不能为空');
      return;
    }
    this.deviceInfo = deviceInfo;
  }

  public getPlayerName(): string {
    return this.playerName;
  }

  public setPlayerName(playerName: string): void {
    if (playerName === "") {
      console.error(tag, '玩家名称不能为空');
      return;
    }
    this.playerName = playerName;
  }

  public getAvatar(): number {
    return this.avatar;
  }

  public setAvatar(avatar: number): void {
    if (avatar < 0 || avatar > AvatarUrls.length) {
      console.error(tag, '玩家头像无效');
      avatar = 0;
    }
    this.avatar = avatar;
  }

  public getRole(): RoleType {
    return this.role;
  }

  public setRole(role: RoleType): void {
    this.role = role;
  }

  public getInGameStatus(): InGameStatus {
    return this.inGameStatus;
  }

  public setInGameStatus(inGameStatus: InGameStatus): void {
    this.inGameStatus = inGameStatus;
  }

  public getIsHost(): boolean {
    return this.isHost;
  }

  public setIsHost(isHost: boolean): void {
    this.isHost = isHost;
  }

  public getVotes(): number {
    return this.votes;
  }

  public setVotes(votes: number) {
    this.votes = votes;
  }

  public getAllVotes(): number {
    return this.allVotes;
  }

  public setAllVotes(allVotes: number) {
    this.allVotes = allVotes;
  }

  public getRemark(): string {
    return this.remark;
  }

  public setRemark(remark: string) {
    this.remark = remark;
  }

  public getWord(): string {
    return this.word;
  }

  public setWord(word: string) {
    return this.word;
  }
}

/*
 * 角色类型枚举
 * 目前分为两类：卧底和平民
 * */
enum RoleType {
  Undercover,
  Civilian
}

/*
 * 玩家状态枚举
 * 分为等待分配词语、等待发言、发言中、等待投票、已投票、出局、获胜
 * */
enum InGameStatus {
  WaitForWord,
  WaitForSpeaking,
  Speaking,
  WaitForVote,
  Voted,
  Out,
  Win
}