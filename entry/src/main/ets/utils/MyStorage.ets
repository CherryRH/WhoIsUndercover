import Player from '../models/Player';

let indexProp: Record<string, Player> = {
  'LocalPlayer': new Player()
};
let localStorage: LocalStorage = new LocalStorage(indexProp);

export default localStorage;