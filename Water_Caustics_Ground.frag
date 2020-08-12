#version 460

//precision highp float;
//precision highp int;

uniform sampler2D texture;
varying vec3 vPosition;
varying vec3 vPositionRefrac;
varying vec3 vSurface;
varying vec3 nSurface;

void main() {


    //gl_FragColor = vec4(vec3(vPosition.z), 1.0);
    //gl_FragColor = vec4(vPositionRefrac, 1.0);
    //gl_FragColor = vec4(nSurface, 1.0);
    //gl_FragColor = vec4(vec3(1.0), 0.05);
    //gl_FragColor = vec4(vec3(vAngle), 1.0);
    float oldArea = length(dFdx(vPosition)) * length(dFdy(vPosition));
    float newArea = length(dFdx(vPositionRefrac)) * length(dFdy(vPositionRefrac));
    float ratio = oldArea / newArea * 2.0;

    gl_FragColor = vec4(ratio);
    //gl_FragColor = texture2D(texture, vPositionRefrac.xy);

    //gl_FragColor = vec4( vec3( 0.5 ), 1.0 );

}
