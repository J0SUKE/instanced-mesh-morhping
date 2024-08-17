
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

    gl_FragColor = maskToMapTexture;
}
