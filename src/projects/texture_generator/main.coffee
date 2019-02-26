###
# TODO:
  only render on button press

###

d = document
c = console
c.l = c.log

W = H = canvas = ctx = null;

configControls_element = d.getElementById('configControls')

d.getElementById('openCloseConfig').onclick = ->
  if configControls_element.style.display == 'none'
    configControls_element.style.display = 'block'
  else
    configControls_element.style.display = 'none'

initCanvas = ->
  if canvas != null then d.body.removeChild canvas
  W = config.canvasWidth
  H = config.canvasHeight
  canvas = d.createElement 'canvas'
  c.l W,H
  canvas.height = H
  canvas.width = W
  ctx = canvas.getContext '2d'
  d.body.appendChild canvas

  ctx.fillStyle = '#ffffff'
  ctx.fillRect 0, 0, W, H
  #ctx.rect 0, 0, W, H
  ctx.stroke()

  ctx.strokeStyle = 'rgba(0, 0, 0, 1)'
  ctx.lineWidth = config.width

  ctx.shadowBlur = 0
  ctx.shadowColor = '#00ff00'

clearCanvas = ->
  ctx.fillStyle = '#ffffff'
  ctx.fillRect 0, 0, W, H


config =
  canvasWidth: 1800
  canvasHeight: 1800
  startX1: 0
  startY1: 0
  startX2: 0
  startY2: 0
  incX1: 3
  incY1: 165
  incX2: 217
  incY2: 4
  rndX1: 0
  lineWidth: .1
  startRed: 0
  startBlue: 0
  startGreen: 0
  incRed: 255
  incBlue: 255
  incGreen: 255
  iterations: 7255

position =
  x1: config.startX1
  y1: config.startY1
  x2: config.startX2
  y2: config.startY2

color =
  red: config.startRed
  green: config.startGreen
  blue: config.startBlue

isPlaying = true
# incX incY incX2 incY2 canvasWidth canvasHeight

configControls =
  trgContainerId: 'configControls'
  content:
    'Increase X1':
      funct: (val)-> config.incX1 = val
      type: 'range', min: -config.canvasWidth/8, max: config.canvasWidth/8, step: .001
      value: config.incX1
    'Increase X2':
      funct: (val)-> config.incX2 = val
      type: 'range', min: -config.canvasWidth/8, max: config.canvasWidth/8, step: .001
      value: config.incX1
    'Increase Y1':
      funct: (val)-> config.incX1 = val
      type: 'range', min: -config.canvasHeight/8, max: config.canvasHeight/8, step: .001
      value: config.incX2
    'Increase Y2':
      funct: (val)-> config.incX1 = val
      type: 'range', min: -config.canvasHeight/8, max: config.canvasHeight/8, step: .001
      value: config.incY2

    'Increase Red':
      funct: (val)-> config.incRed = val
      type: 'range', min: 0, max: 255, step: 1
      value: config.incRed
    'Increase Green':
      funct: (val)-> config.incGreen = val
      type: 'range', min: 0, max: 255, step: 1
      value: config.incGreen
    'Increase Blue':
      funct: (val)-> config.incBlue = val
      type: 'range', min: 0, max: 255, step: 1
      value: config.incBlue

    'Line Width':
      funct: (val)-> config.lineWidth = val
      type: 'range', min: 0.001, max: 2, step: 0.001
      value: config.lineWidth

    'Iterations':
      funct: (val)-> config.iterations = val
      type: 'range', min: 0, max: 10000, step: 1
      value: config.iterations

    ResetColors:
      funct: ->
        color = red: 0, green: 0, blue: 0
      type: 'button'

    Render:
      funct: -> draw()
      type: 'button'

    Clear:
      funct: ->
        position = x1: config.startX1, y1: config.startY1, x2: config.startX2, y2: config.startY2
        clearCanvas()
      type: 'button'

draw = ()->
  ctx.strokeStyle = 'rgba('+color.red+', '+color.green+', '+color.blue+', 1)'
  ctx.lineWidth = config.lineWidth
  len = config.iterations

  ctx.beginPath()
  while len--
    ctx.moveTo position.x1, position.y1
    ctx.lineTo position.x2, position.y2

    position.x1 += config.incX1
    position.y1 += config.incY1
    position.x2 += config.incX2
    position.y2 += config.incY2

    if position.x1 > W*2 then position.x1 = -W
    else if position.x1 < -W then position.x1 = W*2

    if position.x2 > W*2 then position.x2 = -W
    else if position.x2 < -W then position.x2 = W*2

    if position.y1 > H*2 then position.y1 = -H
    else if position.y1 < -H then position.y1 = H*2

    if position.y2 > H*2 then position.y2 = -H
    else if position.y2 < -H then position.y2 = H*2

  ctx.stroke()
  color.red += config.incRed
  color.green += config.incGreen
  color.blue += config.incBlue

  if color.red>255 then color.red = 0
  if color.green>255 then color.green = 0
  if color.blue>255 then color.blue = 0

  # color.red %= 255
  # color.blue %= 255
  # color.green %= 255


initCanvas()
configGenerator configControls

draw()
