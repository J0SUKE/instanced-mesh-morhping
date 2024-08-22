import { Color } from 'three'

export const getRgbColor = (r: number, g: number, b: number) => {
  return new Color().setRGB(r / 255, g / 255, b / 255)
}
