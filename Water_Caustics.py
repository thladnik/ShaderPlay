from glumpy import app, gl, glm, gloo
import numpy as np
from glumpy.transforms import Trackball, Position
import time
from scipy.stats import multivariate_normal

window = app.Window(width=2000, height=1500)

with open('Water_Caustics.vert', 'r') as f:
    vert_caustic = f.read()

with open('Water_Caustics_Ground.frag', 'r') as f:
    frag_caustic = f.read()

with open('Water_Caustics_Surface.frag', 'r') as f:
    frag_surface = f.read()

def draw_ground_for_depth(depth):
    ground['uZDepth'] = depth
    ground.draw(gl.GL_TRIANGLES, indices=I)

@window.event
def on_draw(dt):
    window.clear(color=(0,0,0,1))
    t = 5 * (time.time() - t_start)
    surface['uTime'] = t
    ground['uTime'] = t

    surface.draw(gl.GL_TRIANGLES, indices=I)

    if False:
        for depth in np.arange(0, 2.0, 0.05):
            draw_ground_for_depth(depth)
    else:
        draw_ground_for_depth(0.45)
    #program.draw(gl.GL_LINES, indices=I)
    #gl.glPointSize(10)
    #gl.glEnable(gl.GL_POINT_SMOOTH)
    #gl.glEnable(gl.GL_BLEND)
    #program.draw(gl.GL_POINTS)


### Create vertex mesh
#z_depth = 1.0
lim = 3  # units?
step = 0.01
x = np.arange(-lim, lim, step)
y = np.arange(-lim, lim, step)
count = int(x.shape[0] *y.shape[0])

X,Y = np.meshgrid(x,y)
X = X.flatten()
Y = Y.flatten()

### Set indices
indices = list()
sr = x.shape[0]
for i in range(sr-1):
    for j in np.arange(sr-1):
        indices.append([i * sr + j, i * sr + j + 1, (i + 1) * sr + j + 1])
        indices.append([i * sr + j, (i + 1) * sr + j, (i + 1) * sr + j + 1])
indices = np.array(indices).flatten().astype(np.uint32)
I = indices.view(gloo.IndexBuffer)

### Create surface
surface = gloo.Program(vertex=vert_caustic, fragment=frag_surface, count=count)
surface['position'] = np.array([X, Y, np.zeros(count)]).T
surface['normal'] = np.array(count * [[0.0, 0.0, 1.0]])

surface['transform'] = Trackball(Position('vSurface'), znear=0.01, zfar=20000, theta=0, phi=0)

### Create ground
ground = gloo.Program(vertex=vert_caustic, fragment=frag_caustic, count=count)
ground['position'] = np.array([X, Y, np.zeros(count)]).T
ground['normal'] = np.array(count * [[0.0, 0.0, 1.0]])


ground['transform'] = Trackball(Position('vPositionRefrac'), znear=0.01, zfar=20000, theta=0, phi=0)
#program['transform'] = Trackball(Position('vSurface'), znear=0.01, zfar=20000)
#program['transform'] = Trackball(Position('vPosition'), znear=0.01, zfar=20000)
#program['transform'] = Trackball(Position('groundPlane'), znear=0.01, zfar=20000, theta=0)

window.attach(ground['transform'])
window.attach(surface['transform'])

t_start = time.time()

app.run()