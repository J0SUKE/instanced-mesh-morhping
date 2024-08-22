import * as THREE from 'three'
import { Size } from '../types/types'

import vertexShader from '../shaders/vertex.glsl'
import fragmentShader from '../shaders/fragment.glsl'
import GUI from 'lil-gui'
import { getRgbColor } from '../utilities/get-rgb-color'

interface Props {
  scene: THREE.Scene
  sizes: Size
  debug: GUI
}

export default class Cubes {
  scene: THREE.Scene
  sizes: Size
  material: THREE.ShaderMaterial
  geometry: THREE.BoxGeometry
  mesh: THREE.InstancedMesh
  size: number
  debug: GUI
  blockSize: number
  colors: Record<string, THREE.Color>

  constructor({ scene, sizes, debug }: Props) {
    this.scene = scene
    this.sizes = sizes
    this.size = 128
    this.blockSize = 0.25
    this.debug = debug

    this.colors = {
      uTopColor: getRgbColor(46, 46, 255),
      uSidesColorBottom: getRgbColor(0, 0, 133),
      uSidesColorTop: getRgbColor(0, 0, 209),
    }

    this.createGeometry()
    this.createMaterial()
    this.createInstancedMesh()
    this.positionMeshes()
    //this.setupDebug()
  }

  createMaterial() {
    this.material = new THREE.ShaderMaterial({
      vertexShader,
      fragmentShader,
      uniforms: {
        uTime: new THREE.Uniform(0),
        uBlockSize: new THREE.Uniform(this.blockSize),
        uTexture: new THREE.Uniform(new THREE.Vector4()),
        uTopColor: new THREE.Uniform(
          new THREE.Color().setRGB(this.colors.uTopColor.r, this.colors.uTopColor.g, this.colors.uTopColor.b)
        ),
        uSidesColorBottom: new THREE.Uniform(
          new THREE.Color().setRGB(
            this.colors.uSidesColorBottom.r,
            this.colors.uSidesColorBottom.g,
            this.colors.uSidesColorBottom.b
          )
        ),
        uSidesColorTop: new THREE.Uniform(
          new THREE.Color().setRGB(
            this.colors.uSidesColorTop.r,
            this.colors.uSidesColorTop.g,
            this.colors.uSidesColorTop.b
          )
        ),
      },
    })
  }

  createGeometry() {
    this.geometry = new THREE.BoxGeometry(this.blockSize, this.blockSize, this.blockSize)
  }

  createInstancedMesh() {
    this.mesh = new THREE.InstancedMesh(this.geometry, this.material, this.size * this.size)
    this.scene.add(this.mesh)
  }

  setupDebug() {
    this.debug
      .addColor(this.colors, 'uTopColor')
      .name('uTopColor')
      .onChange((color: THREE.Color) => {
        this.material.uniforms.uTopColor.value.setRGB(color.r, color.g, color.b)
      })
    this.debug
      .addColor(this.colors, 'uSidesColorBottom')
      .name('uSidesColorBottom')
      .onChange((color: THREE.Color) => {
        this.material.uniforms.uSidesColorBottom.value.setRGB(color.r, color.g, color.b)
      })
    this.debug
      .addColor(this.colors, 'uSidesColorTop')
      .name('uSidesColorTop')
      .onChange((color: THREE.Color) => {
        this.material.uniforms.uSidesColorTop.value.setRGB(color.r, color.g, color.b)
      })
  }

  positionMeshes() {
    let dummy = new THREE.Object3D()

    const { width, height } = this.geometry.parameters
    const halfSize = (this.size - 1) / 2

    const instancePositions = new Float32Array(this.size * this.size * 3)
    const uvPositions = new Float32Array(this.size * this.size * 2)

    const gap = width / 4

    let count = 0

    for (let i = 0; i < this.size; i++) {
      for (let j = 0; j < this.size; j++) {
        const position = new THREE.Vector3((i - halfSize) * (width + gap), height / 2, (j - halfSize) * (height + gap))

        instancePositions[count * 3] = position.x
        instancePositions[count * 3 + 1] = position.y
        instancePositions[count * 3 + 2] = position.z

        const u = i / (this.size - 1)
        const v = 1 - j / (this.size - 1) // Flip the v coordinate
        uvPositions[count * 2] = u
        uvPositions[count * 2 + 1] = v

        dummy.position.set(position.x, position.y, position.z)
        dummy.updateMatrix()
        this.mesh.setMatrixAt(count++, dummy.matrix)
      }
    }

    this.mesh.geometry.setAttribute('aInstancePosition', new THREE.InstancedBufferAttribute(instancePositions, 3))
    this.mesh.geometry.setAttribute('aInstanceUV', new THREE.InstancedBufferAttribute(uvPositions, 2))

    this.mesh.instanceMatrix.needsUpdate = true
    this.mesh.computeBoundingSphere()
  }

  getSize() {
    return this.size
  }

  updateTexture(texture: THREE.Texture) {
    this.material.uniforms.uTexture.value = texture
  }

  render(time: number) {
    this.material.uniforms.uTime.value = time
  }
}
