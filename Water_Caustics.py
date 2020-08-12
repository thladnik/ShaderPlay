from glumpy import app, gl, glm, gloo
import numpy as np
from glumpy.transforms import Trackball, Position
import time
from scipy.stats import multivariate_normal

window = app.Window(width=2000, height=1500)

with open('Water_caustics.vert', 'r') as f:
    vertex = f.read()

with open('Water_caustics.frag', 'r') as f:
    fragment = f.read()


@window.event
def on_draw(dt):
    window.clear(color=(0,0,0,1))
    program['uTime'] = 0.0#5 * (time.time() - t_start)

    for depth in np.arange(0, 10.0, 0.05):
        program['uZDepth'] = depth
        program.draw(gl.GL_TRIANGLES, indices=I)
    #program.draw(gl.GL_LINES, indices=I)
    #gl.glPointSize(10)
    #gl.glEnable(gl.GL_POINT_SMOOTH)
    #gl.glEnable(gl.GL_BLEND)
    #program.draw(gl.GL_POINTS)


### Create vertex mesh
#z_depth = 1.0
lim = 1  # units?
step = 0.01
x = np.arange(-lim, lim, step)
y = np.arange(-lim, lim, step)
count = int(x.shape[0] *y.shape[0])

X,Y = np.meshgrid(x,y)
X = X.flatten()
Y = Y.flatten()

if True:
    ### Set indices
    indices = list()
    sr = x.shape[0]
    for i in range(sr-1):
        for j in np.arange(sr-1):
            indices.append([i * sr + j, i * sr + j + 1, (i + 1) * sr + j + 1])
            indices.append([i * sr + j, (i + 1) * sr + j, (i + 1) * sr + j + 1])
    indices = np.array(indices).flatten().astype(np.uint32)
    I = indices.view(gloo.IndexBuffer)

program = gloo.Program(vertex=vertex, fragment=fragment, count=count)
program['position'] = np.array([X, Y, np.zeros(count)]).T
program['normal'] = np.array(count * [[0.0, 0.0, 1.0]])

xtex,ytex = np.mgrid[-2:2:.1, -2:2:.1]
pos = np.dstack((xtex, ytex))

z = multivariate_normal([0,0], [[1, 0], [0, 1]]).pdf(pos)
z_rep = np.hstack(10 * [z])
z_rep = np.vstack(10 * [z_rep])


program['texture'] = z_rep
program['transform'] = Trackball(Position('vPositionRefrac'), znear=0.01, zfar=20000, theta=0, phi=0)
#program['transform'] = Trackball(Position('vSurface'), znear=0.01, zfar=20000)
#program['transform'] = Trackball(Position('vPosition'), znear=0.01, zfar=20000)
#program['transform'] = Trackball(Position('groundPlane'), znear=0.01, zfar=20000, theta=0)
window.attach(program['transform'])
#program['uProjection'] = glm.ortho(-1.0, 1.0, -1.0, 1.0, 0.0, 4.0)

t_start = time.time()

app.run()