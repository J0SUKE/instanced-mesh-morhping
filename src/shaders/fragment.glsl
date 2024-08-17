varying vec3 vInstancePosition;
varying vec3 vPosition;
varying float vElevation;
varying float vScale;

uniform float uBlockSize;
uniform float uAmplitude;

void main()
{
    vec3 basicBlue = vec3(0.1,0.1,1.);
    vec3 whiteBlue = vec3(1.,1.,1.);
    
    vec3 color = mix(basicBlue,whiteBlue,step(vElevation+uBlockSize*vScale,vPosition.y));
    
    gl_FragColor = vec4(color,1.);
}