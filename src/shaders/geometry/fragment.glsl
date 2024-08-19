
uniform sampler2D uWorldTexture;
uniform sampler2D uDisplacementTexture;
uniform sampler2D uMaskTexture;
uniform vec2 uTextureRes;
varying vec2 vUv;

uniform float uMaskToMapProgress;


void main()
{    
    
    vec4 mapTexture = texture2D(uWorldTexture,vUv);
    vec4 maskTexture = texture2D(uMaskTexture,vUv);
    vec3 color = vec3(1.);    

    vec4 maskToMapTexture = mix(maskTexture,mapTexture,uMaskToMapProgress);

    //gl_FragColor = maskToMapTexture;

    // float maskStart = 0.35;
    // float maskEnd = 0.45;
    float maskEnd = 1.-uMaskToMapProgress;
    float maskStart = maskEnd-0.1;    

    //max is maskEnd=0
    
    float mask = smoothstep(maskStart,maskEnd,vUv.x)
                *(1.-smoothstep(1.-maskEnd,1.-maskStart,vUv.x))
                *smoothstep(maskStart,maskEnd,vUv.y)
                *(1.-smoothstep(1.-maskEnd,1.-maskStart,vUv.y));

    vec3 maskedMap = mapTexture.rgb * vec3(mask);

    vec3 final = max(maskedMap,maskTexture.rgb);

    gl_FragColor = vec4(final,1.);
}
