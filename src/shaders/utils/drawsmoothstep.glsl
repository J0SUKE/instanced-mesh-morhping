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