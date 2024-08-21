varying vec3 vPosition;
varying float vElevation;
varying float vScale;
varying float vShadows;
varying vec3 vPos;

uniform float uBlockSize;
uniform float uAmplitude;

void main()
{
    vec3 basicBlue = vec3(0.1,0.1,0.8);
    vec3 whiteBlue = vec3(0.5,0.5,1.);

    vec3 topColor = whiteBlue;
    
    vec3 sidesColor = mix(vec3(0.,0.,0.4),vec3(0.,0.,0.55),vPosition.y);
    

    vec3 color = mix(sidesColor,topColor,step(vElevation+uBlockSize*vScale,vPosition.y));
    

    color.rgb-=vShadows*0.5;
    //color*=vPos*2.;
    if(vPos.x==uBlockSize/2.)
    {
        color*=0.7;
    }
    if(vPos.z==uBlockSize/2.)
    {
        color*=0.9;
    }

    gl_FragColor = vec4(color,1.);
}