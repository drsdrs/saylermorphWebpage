convDeg2d = (l, deg, centre)->
  x: (l*Math.cos(deg))+centre.x
  y: (l*Math.sin(deg))+centre.y

convAngleRadian = (angle)->
  angle * (Math.PI / 180)

conv3d2d = (x, y, z, center, zoom)->
  zoom = zoom||1
  x: x/z*zoom+center.x, y: y/z*zoom+center.y
