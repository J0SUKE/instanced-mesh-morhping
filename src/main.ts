import './style.css'
import Canvas from './components/canvas'
import Scroll from './components/scroll'

class App {
  canvas: Canvas
  scroll: Scroll

  constructor() {
    this.canvas = new Canvas()
    this.scroll = new Scroll()

    this.render()
  }

  render() {
    this.canvas.render()
    requestAnimationFrame(this.render.bind(this))
  }
}

export default new App()
