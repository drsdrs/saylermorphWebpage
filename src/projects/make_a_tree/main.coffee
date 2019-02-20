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

  ctx.strokeStyle = 'rgba(0, 0, 0, 1)'
  ctx.lineWidth = config.width

  ctx.shadowBlur = 0
  ctx.shadowColor = '#00ff00'
      
config =
  width: 2
  length: 1.5
  branchAngle: 120
  branchAmount: 8
  branchLengthShrink: .4
  maxIterations: 10
  randomAngle: 2
  

configControls =
  trgContainerId: 'configControls'
  content:
    'Branch Length':
      funct: (val)-> config.length = val
      type: 'range', min: 0.01, max: .75, step: .01
      value: config.length
      
    Reset:
      funct: initCanvas
      type: 'button'
      



draw = (startPos, lastAngle, lastLength, iteration)->
  if iteration > config.maxIterations then return false  
  
  if iteration == 0
    branchAmount = 0
    branchAngle = 0
    startAngle = lastAngle
  else
    branchAmount = config.branchAmount-1
    branchAngle = config.branchAngle/branchAmount
    startAngle = lastAngle - config.branchAngle/2
    branchAngle += ((config.randomAngle/2)-(Math.random()*config.randomAngle))
    
  
  for branchNr in [0..branchAmount]
    ctx.lineWidth = config.width/(iteration+1)

    ctx.beginPath(branchNr)
    angle = (startAngle+branchAngle*branchNr)
    radian = convAngleRadian angle
    trgLength = lastLength*config.branchLengthShrink
    trgPos = convDeg2d trgLength, radian, startPos
    ctx.moveTo startPos.x, startPos.y
    ctx.lineTo trgPos.x, trgPos.y
    ctx.stroke()
    doNext = (trgPos, angle, trgLength, iteration)->
      setTimeout (->
        draw trgPos, angle, trgLength, iteration
      ), 0#.1*branchNr*iteration
    
    doNext trgPos, angle, trgLength, iteration+2

initCanvas()
configGenerator configControls


startPos = x: W/2, y: H
draw startPos, -90 , config.length*H , 0

