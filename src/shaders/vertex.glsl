uniform float uTime;
uniform float uAmplitude;

attribute vec3 aInstancePosition;
attribute vec2 aInstanceUV;


varying vec3 vInstancePosition;
varying vec3 vPosition;
varying float vElevation;
varying float vScale;

uniform sampler2D uTexture;

void main()
{                            
    vec4 texel = texture2D(uTexture,aInstanceUV);


    //cube scale
    float scale = texel.r;
    vec3 scaledPosition = scale*position;    
    vec4 modelPosition = modelMatrix*instanceMatrix * vec4(scaledPosition, 1.0);

    //cube elevation
    float elevation =texel.g*uAmplitude;        
    //modelPosition.y+=step(0.,position.y)*elevation;
    modelPosition.y+=elevation;
    
    
    
    vec4 viewPosition =  viewMatrix * modelPosition;
    vec4 projectedPosition = projectionMatrix * viewPosition;
    gl_Position = projectedPosition;    


    //varyings
    vInstancePosition=aInstancePosition;
    vPosition=modelPosition.xyz;
    vElevation=elevation;
    vScale=scale;
}