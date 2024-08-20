
uniform sampler2D uMapTexture;
uniform sampler2D uDisplacementTexture;
uniform sampler2D uMaskTexture;
uniform sampler2D uCityTexture;

uniform vec2 uTextureRes;
varying vec2 vUv;

uniform float uMaskToMapProgress;
uniform float uMapToCityProgress;
uniform float uTime;

uniform float uAmplitude;
uniform float uCityAmplitude;


#include ../utils/drawsmoothstep.glsl


float mixTexturesRed(float a,float b,float progress)
{
    float maskEnd = 1.-(progress*0.5 + 0.5);
    float maskStart = maskEnd-0.1;    
    
    float mask = smoothstep(maskStart,maskEnd,vUv.x)
                *(1.-smoothstep(1.-maskEnd,1.-maskStart,vUv.x))
                *smoothstep(maskStart,maskEnd,vUv.y)
                *(1.-smoothstep(1.-maskEnd,1.-maskStart,vUv.y));

    float maskedTexture = b * mask;

    float maskToMapTexture = max(maskedTexture,a);
    
    return maskToMapTexture;
}


void main()
{    
    
    vec4 color = vec4(0.);


    //textures
    vec4 mapTexture = texture2D(uMapTexture,vUv);
    vec4 maskTexture = texture2D(uMaskTexture,vUv);
    vec4 cityTexture = texture2D(uCityTexture,vUv);
    cityTexture.r = 1.;


    color.a = uAmplitude;
    
    float totalProgress = uMaskToMapProgress + uMapToCityProgress;

    color.r+= mixTexturesRed(maskTexture.r,mapTexture.r,uMaskToMapProgress)*(1.-step(1.,totalProgress));
    color.r+= mixTexturesRed(mapTexture.r,cityTexture.r,uMapToCityProgress)*(step(1.,totalProgress));

    
    //transition elevation
    float elevation = 0.;
    float dist = 1.-distance(vec2(0.5),vUv);

    float normalizedProgress = mod(totalProgress,1.);

    float decayStart = pow(normalizedProgress,2.);
    float decayEnd = decayStart+0.1;

    elevation = sin(dist*40.+normalizedProgress*15.);
    
    elevation*=(smoothstep(decayStart,decayEnd,1.-dist));

    elevation*=smoothstep(0.,0.1,normalizedProgress);
    
    color.g = elevation;    
        

    gl_FragColor = color;
}
