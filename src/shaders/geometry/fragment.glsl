
uniform sampler2D uMapTexture;
uniform sampler2D uDisplacementTexture;
uniform sampler2D uMaskTexture;
uniform vec2 uTextureRes;
varying vec2 vUv;

uniform float uMaskToMapProgress;
uniform float uTime;

uniform float uStart;
uniform float uEnd;


vec3 drawSmoothstep(vec3 color,float start,float end)
{
    vec3 clr = color;
    
    float dist = distance(vec2(0.5),vUv);
    
    float startPct =  smoothstep( start-0.02, start, dist) -
          smoothstep( start, start+0.02, dist);

    clr = (1.0-startPct)*clr+startPct*vec3(0.0,0.0,1.0);

    float endPct =  smoothstep( end-0.02, end, dist) -
          smoothstep( end, end+0.02, dist);

    clr = (1.0-endPct)*clr+endPct*vec3(0.0,0.0,1.0);

    return clr;
}


void main()
{    
    
    vec3 color = vec3(0.);

    //morphing    
    vec4 mapTexture = texture2D(uMapTexture,vUv);
    vec4 maskTexture = texture2D(uMaskTexture,vUv);

    float maskEnd = 1.-(uMaskToMapProgress*0.5 + 0.5);
    float maskStart = maskEnd-0.1;    
    
    float mapMask = smoothstep(maskStart,maskEnd,vUv.x)
                *(1.-smoothstep(1.-maskEnd,1.-maskStart,vUv.x))
                *smoothstep(maskStart,maskEnd,vUv.y)
                *(1.-smoothstep(1.-maskEnd,1.-maskStart,vUv.y));

    vec3 maskedMap = mapTexture.rgb * vec3(mapMask);

    vec3 maskToMapTexture = max(maskedMap,maskTexture.rgb);
    
    color.r = maskToMapTexture.r;

    //elevation
    float elevation = 0.;
    float dist = 1.-distance(vec2(0.5),vUv);

    float ampl = 1.;

    float decayStart = pow(uMaskToMapProgress,2.);
    float decayEnd = decayStart+0.1;

    elevation = sin(dist*40.+uMaskToMapProgress*15.)*ampl;
    
    elevation*=(smoothstep(decayStart,decayEnd,1.-dist))*smoothstep(0.,0.1,uMaskToMapProgress);

    //draw smoothstep limits
    //color = drawSmoothstep(color,decayStart,decayEnd);
    
    color.g = elevation;    


    gl_FragColor = vec4(color,1.);
}
