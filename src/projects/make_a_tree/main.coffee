d = document
c = console
c.l = c.log

W = H = canvas = ctx = null;

maxBranches = 29000
branchCnt = 0
branchDrawn = 0
isDrawing = false

configGen = ->
  startWidth: 25*(.5+Math.random())
  startLength: window.innerHeight*.3
  branchAngle: 50*(.5+Math.random())
  maxBranchAmount: 3*(2+Math.random()*4)
  maxBranchWidth: .025+(Math.random()*1.5)
  maxBranchChanges: 5+(Math.random()*10)
  branchShrinkrate: .85+(Math.random()*.1)
  randomBranchSpread: .2+(Math.random()*.8)

config = configGen()

configControls_element = d.getElementById('configControls')
isDrawing_element = d.getElementById('isDrawing')

d.getElementById('newtree').onclick = ->
  startDrawing() if isDrawing == false

initCanvas = ->
  if canvas != null then d.body.removeChild canvas
  W = Math.min(window.innerWidth-75, window.innerHeight-75)
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
  ctx.lineCap = "round"
  ctx.shadowBlur = 0
  ctx.shadowColor = '#00ff00'


drawBranchPositions = (startPos, length, branchChanges, startAngle, branchWidth)->
  if isDrawing == false
    isDrawing_element.innerText = 'Working...'
    isDrawing = true
  branchCnt++

  newBranches = []

  branchDrawn++

  if branchCnt>maxBranches || branchWidth < config.maxBranchWidth
    return doneDrawBranches()


  branchChangePositions = for i in [0...branchChanges]
    Math.random()*(length/branchChanges*1.5)

  for nxtLength, i in branchChangePositions
    randomDeg = startAngle+(22-(Math.random()*44))
    ctx.lineWidth = branchWidth

    red = Math.round Math.random()*32
    green = Math.round Math.random()*32
    blue = Math.round Math.random()*16

    red += 100
    green += 50

    ctx.strokeStyle = 'rgba('+(red)+', '+green+', '+blue+', 1)'

    ctx.beginPath()
    ctx.moveTo startPos.x, startPos.y
    startPos = convDeg2d nxtLength, convAngleRadian(randomDeg), startPos
    ctx.lineTo startPos.x, startPos.y
    ctx.stroke()

    branchWidth *= config.branchShrinkrate

    if Math.random() < config.randomBranchSpread
      newBranches.push startPos

  branchAmount = Math.random()*config.maxBranchAmount

  if branchCnt < maxBranches+branchAmount
    for i in [0..branchAmount] then newBranches.push startPos

  for newStartPos in newBranches
    #setTimeout (->
      newAngle = 1-(Math.random()*2)
      newAngle *= config.branchAngle
      drawBranchPositions newStartPos, length*.75 , config.maxBranchChanges, startAngle+newAngle, branchWidth*config.branchShrinkrate
    #), -1

  branchDrawn--


doneDrawBranches = ->
  setTimeout (->
    branchDrawn--
    if branchDrawn == 0
      c.l 'done: ', branchCnt, branchDrawn
      isDrawing_element.innerText = 'Done!'
      isDrawing = false
      branchCnt = 0
      config = configGen()
  ), 250




clearCanvas = ->
  ctx.fillStyle = '#ffffff'
  ctx.fillRect 0, 0, W, H

initCanvas()
#configGenerator configControls

startPos = x: W/2, y: H


startDrawing = ->
  clearCanvas()
  drawBranchPositions startPos, config.startLength , config.maxBranchChanges, -90, config.startWidth


startDrawing()
