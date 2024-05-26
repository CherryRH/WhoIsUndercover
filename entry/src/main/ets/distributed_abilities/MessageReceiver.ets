import Queue from '@ohos.util.Queue';
import { Callback } from '@ohos.base';
import MessageSender from './MessageSender';

const tag: string = 'TestTag [MessageReceiver]:';

export class Message {
  message: string;
  sender: string;
  tag: string;

  constructor(message: string, sender: string, tag: string) {
    this.message = message;
    this.sender = sender;
    this.tag = tag;
  }
}

export class PlayerInfoMessage {
  playerName: string;
  avatar: number;
  networkId: string;
  sender: string;
  tag: string;

  constructor(playerName: string, avatar: number, networkId: string, sender: string, tag: string) {
    this.playerName = playerName;
    this.avatar = avatar;
    this.networkId = networkId;
    this.sender = sender;
    this.tag = tag;
  }
}

export default class MessageReceiver {

  static dealMessage(message: Message) {
    if (MessageSender.context) {
      MessageSender.context.eventHub.emit(message.tag, message);
      console.log(tag, 'Deal with new Message successful');
    }
  }

  static dealPlayerInfoMessage(playerInfoMessage: PlayerInfoMessage) {
    if (MessageSender.context) {
      MessageSender.context.eventHub.emit(playerInfoMessage.tag, playerInfoMessage);
      console.log(tag, 'Deal with new PlayerInfoMessage successful');
    }
  }

  static onReceiveMessage(tag: string, callback: Callback<Message | PlayerInfoMessage>) {
    try {
      if (MessageSender.context) {
        MessageSender.context.eventHub.on(tag, callback);
      }
    }
    catch(error){
      console.error(tag , `Error when on ReceiveMessage , error information:${error}`);
    }
  }

  static offReceiveMessage(tag: string) {
    try {
      if (MessageSender.context) {
        MessageSender.context.eventHub.off(tag);
      }
    }
    catch(error){
      console.error(tag , `Error when off ReceiveMessage , error information:${error}`);
    }
  }
}