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
  W = Math.min(window.innerWidth, window.innerHeight)
  H = W
  canvas = d.createElement 'canvas'
  canvas.height = H
  canvas.width = W
  ctx = canvas.getContext '2d'
  d.body.appendChild canvas

  ctx.fillStyle = '#ffffff'
  ctx.fillRect 0, 0, W, H
  ctx.rect 0, 0, W, H
  ctx.stroke()

  ctx.strokeStyle = 'rgba(0, 0, 0, 0.1)'
  ctx.lineWidth = spiroConfig.lineAttr.width

  ctx.shadowBlur = spiroConfig.lineAttr.blur
  ctx.shadowColor = '#ffffff'
      
spiroConfig =
  length: [.1, .3, .1]
  speed: [.02, .002, .2]
  lineAttr:
    width: .3
    blur: 0
    color: 0x000000
    blurColor: 0xffffff

spiroConfigControls =
  trgContainerId: 'configControls'
  mainObject: 'spiroConfig'
  content:
    Length_0:
      funct: (val)-> spiroConfig.length[0] = val
      type: 'range', min: 0.001, max: .75, step: 0.01
      value: spiroConfig.length[0]
      
    Length_1:
      funct: (val)-> spiroConfig.length[1] = val
      type: 'range', min: 0.001, max: .75, step: 0.01
      value: spiroConfig.length[1]

    Length_2:
      funct: (val)-> spiroConfig.length[2] = val
      type: 'range', min: 0.001, max: .75, step: 0.01
      value: spiroConfig.length[2]
      
    Speed_0:
      funct: (val)-> spiroConfig.speed[0] = val
      type: 'range', min: 0.001, max: Math.PI/8, step: 0.001
      value: spiroConfig.speed[0]

    Speed_1:
      funct: (val)-> spiroConfig.speed[1] = val
      type: 'range', min: 0.001, max: Math.PI/8, step: 0.001
      value: spiroConfig.speed[1]
      
    Speed_2:
      funct: (val)-> spiroConfig.speed[2] = val
      type: 'range', min: 0.001, max: Math.PI/8, step: 0.001
      value: spiroConfig.speed[2]
    
    Line_Width:
      funct: (val)-> ctx.lineWidth = spiroConfig.lineAttr.width = val
      type: 'range', min: .1, max: 2, step: 0.01
      value: spiroConfig.lineAttr.width

    Blur_Width:
      funct: (val)-> ctx.shadowBlur = spiroConfig.lineAttr.blur = val
      type: 'range', min: 0, max: 3, step: 0.001
      value: spiroConfig.lineAttr.blur

    Reset:
      funct: initCanvas
      type: 'button'
      
    SaveImage:
      funct: ->
        img = canvas.toDataURL('image/png').replace('image/png', 'image/octet-stream')
        window.location.href = img
      type: 'button'

playing = true
spiroPos = [0, 0, 0]
oldXY = x: W/2, y: H/2

draw = ->
  ctx.beginPath()
  center = x: W/2, y: H/2
  ctx.moveTo oldXY.x, oldXY.y
  for circleNr in [0..2]
    center = convDeg2d(W*spiroConfig.length[circleNr], spiroPos[circleNr], center)
    spiroPos[circleNr] += spiroConfig.speed[circleNr]
    
    ctx.lineTo center.x, center.y
  ctx.stroke()
  oldXY = center

initCanvas()
configGenerator spiroConfigControls

setInterval (->
  draw()
), -1
