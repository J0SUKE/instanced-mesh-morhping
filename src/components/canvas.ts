import * as THREE from 'three'
import { Dimensions, Size } from '../types/types'
import { OrbitControls } from 'three/addons/controls/OrbitControls.js'
import GUI from 'lil-gui'
import Cubes from './cubes'
import GeometryRenderer from '../utilities/geometry-renderer'

export default class Canvas {
  element: HTMLCanvasElement
  scene: THREE.Scene
  camera: THREE.PerspectiveCamera
  renderer: THREE.WebGLRenderer
  sizes: Size
  dimensions: Dimensions
  time: number
  clock: THREE.Clock
  raycaster: THREE.Raycaster
  mouse: THREE.Vector2
  orbitControls: OrbitControls
  debug: GUI
  cubes: Cubes
  geometryRenderer: GeometryRenderer

  constructor() {
    this.element = document.getElementById('webgl') as HTMLCanvasElement
    this.time = 0
    this.createClock()
    this.createScene()
    this.createCamera()
    this.createRenderer()
    this.setSizes()
    this.createRayCaster()
    this.createOrbitControls()
    this.addEventListeners()
    this.createDebug()
    //this.createHelpers()
    this.createCubes()
    this.createGeometryRenderer()
    this.render()

    //this.debug.add(this.camera.position, 'x').min(-10).max(15).step(1).name('camera x').step(0.1).listen()
    //this.debug.add(this.camera.position, 'y').min(-10).max(15).step(1).name('camera y').step(0.1).listen()
    //this.debug.add(this.camera.position, 'z').min(-10).max(15).step(1).name('camera z').step(0.1).listen()
  }

  createScene() {
    this.scene = new THREE.Scene()
  }

  createCamera() {
    this.camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 100)
    this.scene.add(this.camera)

    this.camera.position.z = 7
    this.camera.position.y = 7
    this.camera.position.x = -7
  }

  createOrbitControls() {
    this.orbitControls = new OrbitControls(this.camera, this.renderer.domElement)
  }

  createRenderer() {
    this.dimensions = {
      width: window.innerWidth,
      height: window.innerHeight,
      pixelRatio: Math.min(2, window.devicePixelRatio),
    }

    this.renderer = new THREE.WebGLRenderer({ canvas: this.element, alpha: true })
    this.renderer.setSize(this.dimensions.width, this.dimensions.height)
    this.renderer.render(this.scene, this.camera)
    //this.renderer.toneMapping = THREE.ACESFilmicToneMapping
    this.renderer.setPixelRatio(this.dimensions.pixelRatio)
  }

  createDebug() {
    this.debug = new GUI()
  }

  setSizes() {
    let fov = this.camera.fov * (Math.PI / 180)
    let height = this.camera.position.z * Math.tan(fov / 2) * 2
    let width = height * this.camera.aspect

    this.sizes = {
      width: width,
      height: height,
    }
  }

  createClock() {
    this.clock = new THREE.Clock()
  }

  createRayCaster() {
    this.raycaster = new THREE.Raycaster()
    this.mouse = new THREE.Vector2()
  }

  onMouseMove(event: MouseEvent) {
    this.mouse.x = (event.clientX / window.innerWidth) * 2 - 1
    this.mouse.y = -(event.clientY / window.innerHeight) * 2 + 1

    this.raycaster.setFromCamera(this.mouse, this.camera)
    const intersects = this.raycaster.intersectObjects(this.scene.children)
    const target = intersects[0]
    if (target && 'material' in target.object) {
      const targetMesh = intersects[0].object as THREE.Mesh
    }
  }

  addEventListeners() {
    window.addEventListener('mousemove', this.onMouseMove.bind(this))
    window.addEventListener('resize', this.onResize.bind(this))
  }

  onResize() {
    this.dimensions = {
      width: window.innerWidth,
      height: window.innerHeight,
      pixelRatio: Math.min(2, window.devicePixelRatio),
    }

    this.camera.aspect = window.innerWidth / window.innerHeight
    this.camera.updateProjectionMatrix()
    this.setSizes()

    this.renderer.setPixelRatio(this.dimensions.pixelRatio)
    this.renderer.setSize(this.dimensions.width, this.dimensions.height)
  }

  createCubes() {
    this.cubes = new Cubes({ scene: this.scene, sizes: this.sizes, debug: this.debug })
  }

  createGeometryRenderer() {
    const size = this.cubes.getSize()

    this.geometryRenderer = new GeometryRenderer({
      size,
      renderer: this.renderer,
      scene: this.scene,
      debug: this.debug,
      camera: this.camera,
    })
  }

  createHelpers() {
    this.scene.add(new THREE.AxesHelper(1))
  }

  render() {
    this.time = this.clock.getElapsedTime()

    this.orbitControls.update()

    this.geometryRenderer.render(this.time)
    const texture = this.geometryRenderer.getTexture()
    this.cubes.updateTexture(texture)
    this.cubes.render(this.time)

    this.renderer.render(this.scene, this.camera)
  }
}
