d = document
c = console
c.l = c.log

W = H = canvas = ctx = center = null;

initCanvas = ->
  if canvas != null then d.body.removeChild canvas
  W = window.innerWidth
  H = window.innerHeight
  center = x: W/2, y: H/2
  canvas = d.createElement 'canvas'
  canvas.height = H
  canvas.width = W
  ctx = canvas.getContext '2d'
  d.body.appendChild canvas

  canvas.onmousemove = (e)->
    center = x: W-e.clientX, y: H-e.clientY

  ctx.strokeStyle = '#adadad'
  ctx.fillStyle = '#000000'
  ctx.lineWidth = 1.5

  ctx.beginPath()
  ctx.fillRect 0, 0, W, H
  ctx.stroke()


stars = []


getStar = ->
  x = (W)-Math.random()*W*2
  y = (H)- Math.random()*H*2
  z = 25+(Math.random()*75)
  x:x*z, y:y*z, z:z

drawStar = (star)->
  ctx.beginPath()

  #ctx.moveTo center.x-28, center.y
  #ctx.lineTo center.x+28, center.y
  #ctx.moveTo center.x, center.y-28
  #ctx.lineTo center.x, center.y+28

  starPos3d = conv3d2d star.x, star.y, star.z, center, 1
  size = 64/star.z
  ctx.rect starPos3d.x-size/2, starPos3d.y-size/2, size, size
  ctx.stroke()

draw = ->
  ctx.fillStyle = 'rgba(0,0,0,.15)'
  ctx.fillRect 0, 0, W, H
  while stars.length<255 then stars.push getStar()
  for star,i in stars
    drawStar star
    star.z -= .75
    if star.z<1 then stars[i] = getStar()

initCanvas()


setInterval (->
  draw()
), 1000/60
