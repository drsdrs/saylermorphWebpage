d = document
c = console; c.l = c.log

canvas = ctx = null

W = Math.round Math.min(window.innerWidth-75, window.innerHeight-75)
H = W

initCanvas = ->
  canvas = d.createElement 'canvas'
  canvas.height = H
  canvas.width = W
  ctx = canvas.getContext '2d'
  d.getElementById('canvasContainer').appendChild canvas

  ctx.fillStyle = '#ffffff'
  ctx.fillRect 0, 0, W, H
  ctx.rect 0, 0, W, H
  ctx.stroke()
  ctx

clearCanvas = ->
  ctx.fillStyle = '#000'
  ctx.fillRect 0, 0, W, H
