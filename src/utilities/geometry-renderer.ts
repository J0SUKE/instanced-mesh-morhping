import * as THREE from 'three'
import vertexShader from '../shaders/geometry/vertex.glsl'
import fragmentShader from '../shaders/geometry/fragment.glsl'
import GUI from 'lil-gui'

interface Props {
  size: number
  renderer: THREE.WebGLRenderer
  scene: THREE.Scene
  debug: GUI
}

export default class GeometryRenderer {
  renderTarget: THREE.WebGLRenderTarget
  camera: THREE.OrthographicCamera
  size: number
  material: THREE.ShaderMaterial
  plane: THREE.Mesh
  renderer: THREE.WebGLRenderer
  debugPlane: THREE.Mesh
  scene: THREE.Scene
  debug: GUI

  constructor({ size, scene, renderer, debug }: Props) {
    this.size = size
    this.renderer = renderer
    this.scene = scene
    this.debug = debug

    this.createRenderTarget()
    this.createMaterial()
    this.createOrthographicCamera()
    this.createPlane()
    this.createDebugPlane()
    this.setupDebug()
  }

  createRenderTarget() {
    this.renderTarget = new THREE.WebGLRenderTarget(this.size, this.size, {
      format: THREE.RGBAFormat,
      type: THREE.FloatType,
    })
  }

  createMaterial() {
    this.material = new THREE.ShaderMaterial({
      vertexShader,
      fragmentShader,
      uniforms: {
        uTime: new THREE.Uniform(0),
        uWorldTexture: new THREE.Uniform(
          new THREE.TextureLoader().load('./usa.png', (texture) => {
            const { naturalWidth, naturalHeight } = texture.image
            this.material.uniforms.uTextureRes.value = new THREE.Vector2(naturalWidth, naturalHeight)
          })
        ),
        uMaskTexture: new THREE.Uniform(
          new THREE.TextureLoader().load('./texture-mask-graph.png', (texture) => {
            texture.magFilter = THREE.NearestFilter
          })
        ),
        uTextureRes: new THREE.Uniform(new THREE.Vector2(1)),
        uMaskToMapProgress: new THREE.Uniform(0),
      },
    })
  }

  createOrthographicCamera() {
    this.camera = new THREE.OrthographicCamera(
      -this.size / 2,
      this.size / 2,
      this.size / 2,
      -this.size / 2,
      0,
      this.size / 2
    )
    this.camera.position.set(0, this.size / 4, 0) // Position the camera above the plane
    this.camera.lookAt(0, 0, 0)
  }

  createPlane() {
    this.plane = new THREE.Mesh(new THREE.PlaneGeometry(this.size, this.size), this.material)
    this.plane.rotateX(-Math.PI / 2)
  }

  createDebugPlane() {
    this.debugPlane = new THREE.Mesh(
      new THREE.PlaneGeometry(2, 2),
      new THREE.ShaderMaterial({
        vertexShader: `        
      
      varying vec2 vUv;
      
      void main()
      {
          
          vec4 modelPosition = modelMatrix * vec4(position, 1.0);        
          vec4 viewPosition = viewMatrix * modelPosition;
          vec4 projectedPosition = projectionMatrix * viewPosition;
          gl_Position = projectedPosition;  
          
          vUv=uv;
      }
      `,
        fragmentShader: `
       uniform sampler2D uTexture;
       varying vec2 vUv;
       
       void main()
       {
         gl_FragColor = texture2D(uTexture,vUv);
       } 
      `,
        uniforms: {
          uTexture: new THREE.Uniform(new THREE.Vector4()),
        },
      })
    )

    this.debugPlane.position.y = 2

    this.scene.add(this.debugPlane)
  }

  setupDebug() {
    this.debug.add(this.material.uniforms.uMaskToMapProgress, 'value').min(0).max(1).step(0.001)
  }

  updateDebugPlaneTexture() {
    const debugMaterial = this.debugPlane.material as THREE.ShaderMaterial
    debugMaterial.uniforms.uTexture.value = this.renderTarget.texture
  }

  readRenderTargetPixels() {
    const buffer = new Float32Array(this.size * this.size * 4)
    this.renderer.readRenderTargetPixels(this.renderTarget, 0, 0, this.size, this.size, buffer)
    return buffer
  }

  getTexture() {
    return this.renderTarget.texture
  }

  render(time: number) {
    this.material.uniforms.uTime.value = time

    this.renderer.setRenderTarget(this.renderTarget)
    this.renderer.render(this.plane, this.camera)

    //const pixelData = this.readRenderTargetPixels()
    this.updateDebugPlaneTexture()

    this.renderer.setRenderTarget(null)
  }
}
