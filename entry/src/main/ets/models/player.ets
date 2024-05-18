
/*
 * 玩家类
 * 储存玩家的设备ID和个人信息
 * */
export default class Player {
  // 设备ID
  private deviceId: String;
  // 玩家名称
  private playerName: String;
  // 玩家头像
  private avatar: number;
  // 角色类型
  private role: RoleType;
  // 玩家状态

}

/*
 * 角色类型枚举
 * 目前分为两类：卧底和平民
 * */
enum RoleType {
  Undercover,
  Civilian
}