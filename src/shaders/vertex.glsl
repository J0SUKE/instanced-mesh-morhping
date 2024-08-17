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
        
    
    vec3 instancePosition = (instanceMatrix * vec4(position,1.)).xyz;    

    vec4 text = texture2D(uTexture,aInstanceUV);
    float scale = text.g;
    //scale*=step(0.5,scale);

    vec3 scaledPosition = scale*position;

    
    vec4 modelPosition = modelMatrix*instanceMatrix * vec4(scaledPosition, 1.0);

    float elevation =0.;

    
    
    modelPosition.y+=step(0.,position.y)*elevation;
    
    
    
    vec4 viewPosition =  viewMatrix * modelPosition;
    vec4 projectedPosition = projectionMatrix * viewPosition;
    gl_Position = projectedPosition;    


    //varying
    vInstancePosition=aInstancePosition;
    vPosition=modelPosition.xyz;
    vElevation=elevation;
    vScale=scale;
}