
uniform sampler2D uMapTexture;
uniform sampler2D uDisplacementTexture;
uniform sampler2D uMaskTexture;
uniform sampler2D uCityTexture;
uniform sampler2D uCityShadowsTexture;

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
    float dist = distance(vec2(0.5),vUv);
        
    float maskStart = progress;
    float maskEnd = maskStart+0.3;
    

    //square mask
    
    // float mask = smoothstep(maskStart,maskEnd,dist)
    //             *(1.-smoothstep(1.-maskEnd,1.-maskStart,dist))
    //             *smoothstep(maskStart,maskEnd,dist)
    //             *(1.-smoothstep(1.-maskEnd,1.-maskStart,dist));

    //circle mask
    float mask = 1.-smoothstep(progress,progress+0.1,dist);


    float maskedTexture = b * (mask);

    float maskToMapTexture = max(maskedTexture,a);
    
    return maskToMapTexture;
}


void main()
{    
    
    vec4 color = vec4(0.);
    float dist = 1.-distance(vec2(0.5),vUv);    

    //textures
    vec4 mapTexture = texture2D(uMapTexture,vUv);
    vec4 maskTexture = texture2D(uMaskTexture,vUv);
    vec4 cityShadowsTexture = texture2D(uCityShadowsTexture,vUv);
    vec4 cityTexture = texture2D(uCityTexture,vUv);
    cityTexture.r = 1.;    
    
    float totalProgress = uMaskToMapProgress + uMapToCityProgress;

    float maskToMap = 1.-step(1.,totalProgress);
    float mapToCity = step(1.,totalProgress);

    //color.a += smoothstep(0.2,0.,1.-dist)*0.6;
    //scales
    float mapRed = mixTexturesRed(maskTexture.r,mapTexture.r,(pow(uMaskToMapProgress,2.)))*maskToMap;        

    color.r+= mapRed;        
    
    float cityRed = mixTexturesRed(mapTexture.r,cityTexture.r,uMapToCityProgress)*mapToCity;
    color.r+= cityRed;    

    //amplitudes
    float elevationStrenght = 0.;    
    elevationStrenght += uAmplitude*maskToMap;
    elevationStrenght += uAmplitude*mapToCity*pow(dist,2.);
    
    
    //transition elevation
    float elevation = 0.;    

    float normalizedProgress = mod(totalProgress,1.);

    float decayStart = pow(normalizedProgress,2.);
    float decayEnd = decayStart+0.1;

    elevation = sin(dist*40.+normalizedProgress*15.);
    
    elevation*=(smoothstep(decayStart,decayEnd,1.-dist));
    elevation*=(1.-smoothstep(decayEnd,decayEnd+0.1,1.-dist));

    elevation*=smoothstep(0.,0.1,normalizedProgress);
    
    color.g = elevation*elevationStrenght;    
    
    float lightStrenght = 0.;
    lightStrenght+=smoothstep(0.5,elevationStrenght,color.g)*0.2;
    
    color.a += lightStrenght;
    
    //color.b = drawSmoothstep(color.rgb,decayStart,decayEnd).b;


    //height
    float heightProgress = pow(uMapToCityProgress,2.);
    float cityProgress = smoothstep(heightProgress,heightProgress-0.1,1.-dist);

    color.b=cityRed*cityTexture.b*uCityAmplitude*cityProgress;

    float a1 = smoothstep(0.2,0.,1.-dist)*(uMaskToMapProgress*0.5+0.5)*0.5;
    float a2 = smoothstep(0.5,0.,1.-dist)*(uMapToCityProgress)*0.7;
    
    color.a += max(a1,a2);

    color.a -= cityShadowsTexture.r*cityProgress*0.5;
        

    gl_FragColor = color;
    
}
