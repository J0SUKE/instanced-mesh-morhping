uniform float uTime;

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

    //texel.r contain the scale
    //texel.g contain the elevation
    //
    //texel.a contain the amplitude of the elevation


    //cube scale
    float scale = texel.r;
    vec3 scaledPosition = scale*position;    
    vec4 modelPosition = modelMatrix*instanceMatrix * vec4(scaledPosition, 1.0);

    //cube elevation
    float elevation =texel.g*texel.a;
    modelPosition.y+=elevation;

    //cube height

    float height =texel.b;
    modelPosition.y+=step(0.,position.y)*texel.b;

    
    
    
    vec4 viewPosition =  viewMatrix * modelPosition;
    vec4 projectedPosition = projectionMatrix * viewPosition;
    gl_Position = projectedPosition;    


    //varyings
    vInstancePosition=aInstancePosition;
    vPosition=modelPosition.xyz;
    vElevation=elevation+height;
    //vElevation=elevation;
    vScale=scale;
}