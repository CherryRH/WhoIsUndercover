import router from '@ohos.router'

const tag: string = 'TestTag [Router]:';

//路由函数的封装
export default function routerIndexPage() {
  router.pushUrl(
    {
      url: 'pages/Index',
      params: new PageInfo(0)
    },
    router.RouterMode.Single,
    Error => {
      if (Error) {
        console.error(tag, 'Rout to ' + '/pages/Index' + ' failed.');
      }
    }
  )
}

/*
 * 页面路由传参对象
 * */
export class PageInfo {
  id: number
  name: string
  constructor(id?: number, name?: string) {
    this.id = id ?? 0;
    this.name = name ?? '';
  }
}