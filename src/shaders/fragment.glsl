varying vec3 vPosition;
varying float vElevation;
varying float vScale;
varying float vShadows;
varying vec3 vPos;

uniform float uBlockSize;
uniform float uAmplitude;
varying float vHeight;

uniform vec3 uTopColor;
uniform vec3 uSidesColorBottom;
uniform vec3 uSidesColorTop;

void main()
{
    vec3 whiteBlue = uTopColor;

    vec3 topColor = whiteBlue;
        
    float yProgress = vPos.y/(uBlockSize/2.);//0 at the bottom of the block, 1 at the top
    
    vec3 sidesColor = mix(uSidesColorBottom,uSidesColorTop,yProgress);
    

    float isTop = step(uBlockSize/2.,vPos.y);//1 if it's the top, 0 if it's not

    vec3 color = mix(sidesColor,topColor,isTop);
    
    color.rgb+=vShadows*isTop;//apply shadows only on the top face

    if(vPos.x==uBlockSize/2. && vHeight>0.)
    {
        color*=0.7;
    }
    if(vPos.z==uBlockSize/2.&& vHeight>0.)
    {
        color*=0.8;
    }


    //vPos.y goes from 0 to uBlockSize/2.

    //gl_FragColor = vec4(vec3(0.,0.,step(uBlockSize/2.,vPos.y)),1.);
    gl_FragColor = vec4(color,1.);

    #include <tonemapping_fragment>
    //#include <colorspace_fragment>
}