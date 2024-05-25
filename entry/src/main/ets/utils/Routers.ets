import router from '@ohos.router'

const tag: string = 'TestTag [Router]:';

//路由函数的封装
export function toIndexPage() {
  router.pushUrl(
    {
      url: 'pages/Index',
      params: new PageInfo(0)
    },
    router.RouterMode.Single,
    Error => {
      if (Error) {
        console.error(tag, 'Rout to ' + 'pages/Index' + ' failed.');
      }
    }
  )
}

export function toHallPage() {
  router.pushUrl(
    {
      url: 'pages/HallPage',
      params: new PageInfo(0)
    },
    router.RouterMode.Single,
    Error => {
      if (Error) {
        console.error(tag, 'Rout to ' + 'pages/HallPage' + ' failed.');
      }
    }
  )
}

export function toGamePage(hostNetworkId: string, playerNum?: number) {
  router.pushUrl(
    {
      url: 'pages/GamePage',
      params: new PageInfo(playerNum ?? 0, hostNetworkId)
    },
    router.RouterMode.Single,
    Error => {
      if (Error) {
        console.error(tag, 'Rout to ' + 'pages/GamePage' + ' failed.');
      }
    }
  )
}

export function toResultPage() {
  router.pushUrl(
    {
      url: 'pages/ResultPage',
      params: new PageInfo(0)
    },
    router.RouterMode.Single,
    Error => {
      if (Error) {
        console.error(tag, 'Rout to ' + 'pages/ResultPage' + ' failed.');
      }
    }
  )
}

/*
 * 页面路由传参对象
 * */
export class PageInfo {
  id: number;
  name: string;
  constructor(id?: number, name?: string) {
    this.id = id ?? 0;
    this.name = name ?? '';
  }
}