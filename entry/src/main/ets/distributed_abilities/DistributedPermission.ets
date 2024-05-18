import abilityAccessCtrl , {Permissions}from '@ohos.abilityAccessCtrl';
import bundleManager from '@ohos.bundle.bundleManager';
import common from '@ohos.app.ability.common';

const TAG = '[DistributedPermissionTestTag]';

let atManager = abilityAccessCtrl.createAtManager();

export async function getAccessTokenID(permission: Array<Permissions>) {
  let tokenID: number;
  let grantStatus: Array<abilityAccessCtrl.GrantStatus> = [];
  let bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
  let appInfo : bundleManager.ApplicationInfo = bundleInfo.appInfo;
  tokenID = appInfo.accessTokenId;
  let length: number = permission.length;
  for (let i = 0 ; i < length ; i++) {
    try {
      grantStatus.push(await atManager.checkAccessToken(tokenID,permission[i]));
    }
    catch (err) {
      console.error(TAG, `checkAccessToken failed, code is ${err.code}, message is ${err.message}`);
    }
  }
  return grantStatus ;
}

export async function checkPermission(context: common.UIAbilityContext ,permissions: Array<Permissions>) {
  let grantStatus: Array<abilityAccessCtrl.GrantStatus> = await getAccessTokenID(permissions);
  let length = permissions.length;
  for (let i = 0; i < length; i++) {
    if (grantStatus[i] == abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      console.info(TAG, `${ permissions[i].toString() } has granted`);
    }
    else {
      console.info(TAG, `${ permissions[i].toString() } hasn't granted , request now`);
      requestPermission(context,permissions);
    }
  }
}

export async function requestPermission(context: common.UIAbilityContext, permissions: Array<Permissions>) {
  atManager.requestPermissionsFromUser(context , permissions)
    .then ((data)=> {
      let permissionStatus: Array<number> = data.authResults;
      let length: number = permissionStatus.length;
      for (let i = 0; i < length; i++) {
        if (permissionStatus[i] === 0) {
          console.info(TAG, `REQUEST ${permissions[i].toString()} Success`) ;
        }
        else {
          console.info(TAG, `REQUEST ${permissions[i].toString()} Rejected!`)
        }
      }
    })
}