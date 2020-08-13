#version 460

//precision highp float;
//precision highp int;

//uniform mat4 modelViewMatrix;
//uniform mat4 projectionMatrix;
uniform float uTime;
uniform float uZDepth;

attribute vec3 position;
attribute vec3 normal;

varying vec3 vPosition;
varying vec3 vPositionRefrac;
varying vec3 vNormal;
varying vec3 vSurface;
varying vec3 nSurface;
varying float vAngle;

const float refracIdxAir = 1.000277;
const float refracIdxWater = 1.333;

/* https://www.shadertoy.com/view/XsX3zB
 *
 * The MIT License
 * Copyright © 2013 Nikita Miropolskiy
 *
 * ( license has been changed from CCA-NC-SA 3.0 to MIT
 *
 *   but thanks for attributing your source code when deriving from this sample
 *   with a following link: https://www.shadertoy.com/view/XsX3zB )
 *
 * ~
 * ~ if you're looking for procedural noise implementation examples you might
 * ~ also want to look at the following shaders:
 * ~
 * ~ Noise Lab shader by candycat: https://www.shadertoy.com/view/4sc3z2
 * ~
 * ~ Noise shaders by iq:
 * ~     Value    Noise 2D, Derivatives: https://www.shadertoy.com/view/4dXBRH
 * ~     Gradient Noise 2D, Derivatives: https://www.shadertoy.com/view/XdXBRH
 * ~     Value    Noise 3D, Derivatives: https://www.shadertoy.com/view/XsXfRH
 * ~     Gradient Noise 3D, Derivatives: https://www.shadertoy.com/view/4dffRH
 * ~     Value    Noise 2D             : https://www.shadertoy.com/view/lsf3WH
 * ~     Value    Noise 3D             : https://www.shadertoy.com/view/4sfGzS
 * ~     Gradient Noise 2D             : https://www.shadertoy.com/view/XdXGW8
 * ~     Gradient Noise 3D             : https://www.shadertoy.com/view/Xsl3Dl
 * ~     Simplex  Noise 2D             : https://www.shadertoy.com/view/Msf3WH
 * ~     Voronoise: https://www.shadertoy.com/view/Xd23Dh
 * ~
 *
 */

/* discontinuous pseudorandom uniformly distributed in [-0.5, +0.5]^3 */
vec3 random3(vec3 c) {
	float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));
	vec3 r;
	r.z = fract(512.0*j);
	j *= .125;
	r.x = fract(512.0*j);
	j *= .125;
	r.y = fract(512.0*j);
	return r-0.5;
}

/* skew constants for 3d simplex functions */
const float F3 =  0.3333333;
const float G3 =  0.1666667;

/* 3d simplex noise */
float simplex3d(vec3 p) {
	 /* 1. find current tetrahedron T and it's four vertices */
	 /* s, s+i1, s+i2, s+1.0 - absolute skewed (integer) coordinates of T vertices */
	 /* x, x1, x2, x3 - unskewed coordinates of p relative to each of T vertices*/

	 /* calculate s and x */
	 vec3 s = floor(p + dot(p, vec3(F3)));
	 vec3 x = p - s + dot(s, vec3(G3));

	 /* calculate i1 and i2 */
	 vec3 e = step(vec3(0.0), x - x.yzx);
	 vec3 i1 = e*(1.0 - e.zxy);
	 vec3 i2 = 1.0 - e.zxy*(1.0 - e);

	 /* x1, x2, x3 */
	 vec3 x1 = x - i1 + G3;
	 vec3 x2 = x - i2 + 2.0*G3;
	 vec3 x3 = x - 1.0 + 3.0*G3;

	 /* 2. find four surflets and store them in d */
	 vec4 w, d;

	 /* calculate surflet weights */
	 w.x = dot(x, x);
	 w.y = dot(x1, x1);
	 w.z = dot(x2, x2);
	 w.w = dot(x3, x3);

	 /* w fades from 0.6 at the center of the surflet to 0.0 at the margin */
	 w = max(0.6 - w, 0.0);

	 /* calculate surflet components */
	 d.x = dot(random3(s), x);
	 d.y = dot(random3(s + i1), x1);
	 d.z = dot(random3(s + i2), x2);
	 d.w = dot(random3(s + 1.0), x3);

	 /* multiply d by w^4 */
	 w *= w;
	 w *= w;
	 d *= w;

	 /* 3. return the sum of the four surflets */
	 return dot(d, vec4(52.0));
}

float xPartZSine(in float x) {
    float z = 0;
    for(int i = 1; i < 4; ++i) {
        z += 0.5 * (sin(4.0 * i * x * 3.14 + uTime) + 1.0) / 2.0 / (2.0 * pow(i,2));
    }
    return(z);
}

float yPartZSine(in float y) {
    float z = 0;
    for(int i = 1; i < 4; i++) {
        z += 0.5 * (sin(4.0 * float(i) * y * 3.14 + uTime) + 1.0) / 2.0 / (10.0 * pow(i,3));
    }
    //float z = 0.5 * (sin(4.0 * y * 3.14 + 2.0 * uTime) + 1.0)/2.0;
    z = 0.0;
    return(z);
}

void main() {

    vec3 vIn = normalize(vec3(0.0, 0.0, 1.0));

    // Arbitrary transformation on input plane model
    vPosition = position;//vec3(position.x, position.y, 0.00);
    vNormal = normal;


    float xStep = 0.001;
    float yStep = 0.001;
    //float zAmp = 0.1;

    // SINE WAVS
    //vSurface = vec3(vPosition.xy, xPartZ(vPosition.x) + yPartZ(vPosition.y));
    //vec3 dX = vec3(xStep, 0.0, xPartZ(vPosition.x) - xPartZ(vPosition.x + xStep));
    //vec3 dY = vec3(0.0, yStep, yPartZ(vPosition.y) - yPartZ(vPosition.y + yStep));

    // SIMPLEX NOISE
    float scale = 1/2.0;
    float t_incr = uTime/5.0;
    vSurface = vec3(vPosition.xy, scale * simplex3d(vec3(vPosition.xy, t_incr)));
    vec3 dX = vec3(xStep, 0.0, scale * simplex3d(vec3(vPosition.xy, t_incr)) - scale * simplex3d(vec3(vPosition.x + xStep, vPosition.y, t_incr)));
    vec3 dY = vec3(0.0, yStep, scale * simplex3d(vec3(vPosition.xy, t_incr)) - scale * simplex3d(vec3(vPosition.x, vPosition.y + yStep, t_incr)));

    // Calculate surface normals
    nSurface = -vec3(normalize(cross(dX, dY)));

    // Calculate direction of ray after refraction on interface
    vec3 refracDir = refract(vIn, nSurface, refracIdxAir/refracIdxWater);

    // Calculate intersection of ray and ground plane
    //float d = 1.0; // distance of plane
    //float d = -mod(uTime/10, 10);
    float t = -(dot(vSurface, vNormal) + uZDepth) / (dot(refracDir, vNormal)); // length of refracted vector to plane
    vPositionRefrac = vSurface + t * refracDir;

    vec3 groundPlane = vec3(vPosition.xy, -uZDepth);
    vec3 unitGround = normalize(groundPlane);

    //gl_Position = projectionMatrix * modelViewMatrix * vec4( vPosition.xyz, 1.0 );
    gl_Position = <transform>;

}