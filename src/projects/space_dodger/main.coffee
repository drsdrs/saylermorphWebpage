pieceSizeW = W / gameRes
pieceSizeH = H / gameRes

killed = false

cx = (gameRes/2)
cy = (gameRes/2)

shipPos = x:0, y:0
shipVel = x:0, y:0
dir = 0
keysPressed = ["w"]
score = 0
highscore = 0
gameRes = 0
aniSpeed = 666
level = 0

gameTick = 0

startRes = 60

worldEdge = x: 127, y: 127
dots = new Uint8Array worldEdge.x*2*worldEdge.y*2
shipDirDots = null

shipColor = 'b0ec51'
shipTrailColor = '598e07'

enemyColor = '8333a5'
enemyBodyColor = 'ac61cc'
enemyTrailColor = '3e49d2'

bonusPointsColor = 'e4cc1f'

wallColor = '20363e'

shipDirDots = [
  [
    [-1, 0], [0, 0], [+1, 0], [0, -1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0+1, 0]
  ], [
    [0-1, 0], [0, 0], [0+1, 0], [0, 0+1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0-1, 0]
  ]
]

killPlayer = (i)->
  i = i||0

  clearCanvas()
  drawDots()
  drawBorder()

  if i<Math.sqrt(gameRes*gameRes+gameRes*gameRes)/2
    drawDot 0+i, 0+i, shipColor
    drawDot 0-i, 0-i, shipColor
    drawDot 0+i, 0-i, shipColor
    drawDot 0-i, 0+i, shipColor
    i++
    requestAnimationFrame (-> killPlayer(i))
  else
    highscore = Math.max score, highscore
    score = 0
    startGame()

startGame = ->
  shipPos = x:0, y:19
  shipVel = x:0, y:0
  dir = 0
  keysPressed = ['w']

  dots = new Uint8Array worldEdge.x*2*worldEdge.y*2

  killed = false

  worldEdge.x = 31 # must be uneven
  worldEdge.y = 31 # must be uneven
  gameRes = 5
  aniSpeed = 14
  level = 0
  lasers = 10

  getEnemys(4)
  moveEnemy()
  setGameRes()
  placeRandomDots(10)
  nextFrame()


setGameRes = ->
  pieceSizeW = W / gameRes
  pieceSizeH = H / gameRes

  cx = gameRes/2
  cy = gameRes/2


checkKeysPressed = ()->
  k = keysPressed.shift()
  if k
    if k=='w'
      shipVel = x:0, y:-1
      dir = 0
    else if k=='d'
      shipVel = x:1, y:0
      dir = 1
    else if k=='s'
      shipVel = x:0, y:1
      dir = 2
    else if k=='a'
      shipVel = x:-1, y:0
      dir = 3

aniCnt = aniSpeed

nextFrame = ->
  if aniCnt<aniSpeed
    aniCnt++
    return requestAnimationFrame nextFrame
  else aniCnt = 0

  aniSpeed -= 1 if aniSpeed>5

  if gameRes < startRes && level==0
    gameRes += 4
    setGameRes()

  checkKeysPressed()

  shipPos.x += shipVel.x
  shipPos.y += shipVel.y


  checkCollision()
  checkBorderCollision()

  moveEnemy()
  checkCollision()


  checkLevel()

  clearCanvas()

  drawDots()
  drawBorder()
  drawShip(dir)

  drawStats()



  #setDot shipPos.x, shipPos.y, 1

  if Math.random()<.05 then placeRandomDots(1, 1)

  score += 1+level
  gameTick++

  if killed==false
    requestAnimationFrame nextFrame
  else
    killPlayer()


addEventListeners = ->
  d.body.addEventListener 'keydown', (e)->
    if (e.key=='w' || e.key=='d' || e.key=='s' || e.key=='a') && e.key != keysPressed[keysPressed.length-1]
      keysPressed.push e.key

enemys = []

getEnemys = (cnt)->
  enemys = []
  # for i in [0..cnt]
  #   m = if Math.random()>.5 then 1 else -1
  #   if Math.random()>.5
  #     mx = m
  #     my = 0
  #   else
  #     mx = 0
  #     my = m
  #   pos = getRandomDot(worldEdge.x/10)
  enemys.push pos:{x: -worldEdge.x+2, y: -6 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: -3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 0 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 6 }, mx: 1, my:0

moveEnemy = ->
  for enemy, ei in enemys
    e = enemy.pos
    setDot e.x, e.y, 0
    setDot e.x-1, e.y, 0
    setDot e.x+1, e.y, 0
    setDot e.x, e.y+1, 0
    setDot e.x, e.y-1, 0


    if Math.abs(e.x) > worldEdge.x
      e.x = -e.x
    if Math.abs(e.y) > worldEdge.y
      e.y = -e.y

    if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        x = enemy.mx
        enemy.mx = enemy.my
        enemy.my = x
    else if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        enemy.mx *= -1
        enemy.my *= -1

    e.x += enemy.mx
    e.y += enemy.my

    setDot e.x, e.y, 8
    setDot e.x-1, e.y, 6
    setDot e.x+1, e.y, 6
    setDot e.x, e.y+1, 6
    setDot e.x, e.y-1, 6

    if gameTick%41 == 40 && level>=1
      setDot e.x-enemy.mx*2, e.y-enemy.my*2, 7

drawDot = (x, y, col)->
  canvasX = (x+cx)*pieceSizeW
  canvasY = (y+cy)*pieceSizeH
  if canvasX<-pieceSizeW || canvasX > W || canvasY<-pieceSizeH || canvasY > H then return# c.l 'DRAW_DOT ERROR', canvasX, canvasY, x, y
  ctx.fillStyle = '#'+col
  ctx.fillRect .25+canvasX, .25+canvasY, pieceSizeW-.5, pieceSizeH-.5

drawShip = (dir)->
  for xy in shipDirDots[dir]
    drawDot xy[0], xy[1], shipColor

drawBorder = ->
  if shipPos.x+cx > worldEdge.x
    borderStartX = W-(shipPos.x+cx-worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect borderStartX, 0, W, H
  if shipPos.x-cx < -worldEdge.x
    borderStartX = -(shipPos.x-cx+worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, borderStartX, H
  if shipPos.y+cy > worldEdge.y
    borderStartY = W-(shipPos.y+cy-worldEdge.y)*pieceSizeH
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, borderStartY, W, H
  if shipPos.y-cy < -worldEdge.y
    borderStartY = -(shipPos.y-cy+worldEdge.y)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, W, borderStartY

drawStats = ->
  fontSize = (W/35)
  ctx.fillStyle = '#fff'
  ctx.font = fontSize+'px c64';
  ctx.fillText('HIGHSCORE: '+highscore, 6, 4+fontSize)
  ctx.fillText('SCORE: '+score, 6, 4+fontSize*2)
  ctx.fillText('LEVEL: '+level, 6, 4+fontSize*3)

drawDots = -> # Draw visible dots
  if worldEdge.x*2<gameRes
    maxX = worldEdge.x
    startX = -worldEdge.x-shipPos.x
    endX = worldEdge.x-shipPos.x
    startY = -worldEdge.y-shipPos.y
    endY = worldEdge.y-shipPos.y
  else
    maxX = (Math.round gameRes/2)
    startX = startY = -maxX
    endX = endY = maxX

  for x in [startX...endX]#[Math.floor(-(gameRes/2))...(gameRes/2)]
    posX = x+shipPos.x
    for y in [startY...endY] # [Math.floor(-(gameRes/2))...(gameRes/2)]
      posY = shipPos.y+y
      dot = getDot posX, posY
      if dot>0
        col =
          if dot==1 then shipTrailColor
          else if dot==6 then enemyColor
          else if dot==7 then enemyTrailColor
          else if dot==8 then enemyBodyColor
          else if dot==10 then bonusPointsColor
          else if dot==25 then 'f00'
          else if dot>=50 && dot<64
            dot += 1
            setDot posX, posY, dot
            col = (0xfff-((dot-50)*0x111)).toString(16)

          else if dot>=64
            setDot posX, posY, 0
            '000'
          else 'fff'
        drawDot x, y, col

getDot = (x, y)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  #if x<0 || x>=gameRes || y<0 || y>=gameRes then return# c.l 'getDot Out of bound',x,y
  dots[ x+(y*worldEdge.x*2) ]

setDot = (x, y, type)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  if x<0 || x >= worldEdge.x*2 || y<0 || y >= worldEdge.x*2 then return false# c.l 'setDot Out of bound',x,y
  dots[ x+(y*(worldEdge.x)*2) ] = type

getRandomDot = (saveArea)->
  x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
  y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
  maxTries = 128
  saveArea = saveArea||0
  tries = 0
  while x > -saveArea && x < saveArea && y > -saveArea && y < saveArea && getDot(x,y)==0
    tries++
    x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
    y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
    if tries > maxTries then return c.l 'getRandomDot overload'
  x:x, y:y

placeRandomDots = (amount, saveArea, id)->
  amount = amount||100
  saveArea = saveArea||worldEdge.x*.6
  while amount--
    dot = getRandomDot saveArea
    setDot dot.x, dot.y, id||10

checkCollision = ->
  # check collision with dot
  for sp in shipDirDots[dir]
    dot = getDot(sp[0]+shipPos.x, sp[1]+shipPos.y)
    if dot>0
      c.l dot
      if dot==10
        score += 100*(level+1)
        setDot(sp[0]+shipPos.x, sp[1]+shipPos.y, 0)
        placeRandomDots(1, 1)
      else killed--

  # check collision with wall
checkBorderCollision = ->
  if shipPos.x >= worldEdge.x
    shipPos.x = -worldEdge.x
  else if shipPos.x < -worldEdge.x
    shipPos.x = worldEdge.x-1

  if shipPos.y >= worldEdge.y
    shipPos.y = -worldEdge.x
  else if shipPos.y < -worldEdge.y
    shipPos.y = worldEdge.x-1

checkLevel = ->
  if score>1000 && level==0
    level++
    aniSpeed -= 2
  else if score>2500 && level==1
    level++
    gameRes -= 8
    setGameRes()
  else if score>5000 && level==2
    level++
    gameRes -= 8
    setGameRes()
  else if score>10000 && level==3
    level++
    gameRes -= 4
    setGameRes()
  else if score>20000 && level==4
    level++
    gameRes -= 2
    setGameRes()
  else if score>30000 && level==5
    level++
    gameRes -= 2
    setGameRes()
  else if score>45000 && level==6
    level++
    gameRes -= 2
    setGameRes()
  else if score>65000 && level==7
    level++
    gameRes -= 2
    setGameRes()
  else if score>80000 && level==8
    level++
    gameRes -= 2
    setGameRes()
  else if score>10000 && level==9
    level++
    aniSpeed -= 1

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

# requestAnimationFrame polyfill by Erik Möller. fixes from Paul Irish and Tino Zijdel
# MIT license

do ->
  lastTime = 0
  vendors = [ 'ms', 'moz', 'webkit', 'o' ]
  x = 0
  while x < vendors.length and !window.requestAnimationFrame
    window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame']
    window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] or window[vendors[x] + 'CancelRequestAnimationFrame']
    ++x
  if !window.requestAnimationFrame

    window.requestAnimationFrame = (callback, element) ->
      currTime = (new Date).getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      id = window.setTimeout((->
        callback currTime + timeToCall
        return
      ), timeToCall)
      lastTime = currTime + timeToCall
      id

  if !window.cancelAnimationFrame

    window.cancelAnimationFrame = (id) ->
      clearTimeout id
      return
  return


window.onload = ->
  addEventListeners()
  initCanvas()
  startGame()

pieceSizeW = W / gameRes
pieceSizeH = H / gameRes

killed = false

cx = (gameRes/2)
cy = (gameRes/2)

shipPos = x:0, y:0
shipVel = x:0, y:0
dir = 0
keysPressed = ["w"]
score = 0
highscore = 0
gameRes = 0
aniSpeed = 666
level = 0

gameTick = 0

startRes = 60

worldEdge = x: 127, y: 127
dots = new Uint8Array worldEdge.x*2*worldEdge.y*2
shipDirDots = null

shipColor = 'b0ec51'
shipTrailColor = '598e07'

enemyColor = '8333a5'
enemyBodyColor = 'ac61cc'
enemyTrailColor = '3e49d2'

bonusPointsColor = 'e4cc1f'

wallColor = '20363e'

shipDirDots = [
  [
    [-1, 0], [0, 0], [+1, 0], [0, -1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0+1, 0]
  ], [
    [0-1, 0], [0, 0], [0+1, 0], [0, 0+1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0-1, 0]
  ]
]

killPlayer = (i)->
  i = i||0

  clearCanvas()
  drawDots()
  drawBorder()

  if i<Math.sqrt(gameRes*gameRes+gameRes*gameRes)/2
    drawDot 0+i, 0+i, shipColor
    drawDot 0-i, 0-i, shipColor
    drawDot 0+i, 0-i, shipColor
    drawDot 0-i, 0+i, shipColor
    i++
    requestAnimationFrame (-> killPlayer(i))
  else
    highscore = Math.max score, highscore
    score = 0
    startGame()

startGame = ->
  shipPos = x:0, y:19
  shipVel = x:0, y:0
  dir = 0
  keysPressed = ['w']

  dots = new Uint8Array worldEdge.x*2*worldEdge.y*2

  killed = false

  worldEdge.x = 31 # must be uneven
  worldEdge.y = 31 # must be uneven
  gameRes = 5
  aniSpeed = 14
  level = 0
  lasers = 10

  getEnemys(4)
  moveEnemy()
  setGameRes()
  placeRandomDots(10)
  nextFrame()


setGameRes = ->
  pieceSizeW = W / gameRes
  pieceSizeH = H / gameRes

  cx = gameRes/2
  cy = gameRes/2


checkKeysPressed = ()->
  k = keysPressed.shift()
  if k
    if k=='w'
      shipVel = x:0, y:-1
      dir = 0
    else if k=='d'
      shipVel = x:1, y:0
      dir = 1
    else if k=='s'
      shipVel = x:0, y:1
      dir = 2
    else if k=='a'
      shipVel = x:-1, y:0
      dir = 3

aniCnt = aniSpeed

nextFrame = ->
  if aniCnt<aniSpeed
    aniCnt++
    return requestAnimationFrame nextFrame
  else aniCnt = 0

  aniSpeed -= 1 if aniSpeed>5

  if gameRes < startRes && level==0
    gameRes += 4
    setGameRes()

  checkKeysPressed()

  shipPos.x += shipVel.x
  shipPos.y += shipVel.y


  checkCollision()
  checkBorderCollision()

  moveEnemy()
  checkCollision()


  checkLevel()

  clearCanvas()

  drawDots()
  drawBorder()
  drawShip(dir)

  drawStats()



  #setDot shipPos.x, shipPos.y, 1

  if Math.random()<.05 then placeRandomDots(1, 1)

  score += 1+level
  gameTick++

  if killed==false
    requestAnimationFrame nextFrame
  else
    killPlayer()


addEventListeners = ->
  d.body.addEventListener 'keydown', (e)->
    if (e.key=='w' || e.key=='d' || e.key=='s' || e.key=='a') && e.key != keysPressed[keysPressed.length-1]
      keysPressed.push e.key

enemys = []

getEnemys = (cnt)->
  enemys = []
  # for i in [0..cnt]
  #   m = if Math.random()>.5 then 1 else -1
  #   if Math.random()>.5
  #     mx = m
  #     my = 0
  #   else
  #     mx = 0
  #     my = m
  #   pos = getRandomDot(worldEdge.x/10)
  enemys.push pos:{x: -worldEdge.x+2, y: -6 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: -3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 0 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 6 }, mx: 1, my:0

moveEnemy = ->
  for enemy, ei in enemys
    e = enemy.pos
    setDot e.x, e.y, 0
    setDot e.x-1, e.y, 0
    setDot e.x+1, e.y, 0
    setDot e.x, e.y+1, 0
    setDot e.x, e.y-1, 0


    if Math.abs(e.x) > worldEdge.x
      e.x = -e.x
    if Math.abs(e.y) > worldEdge.y
      e.y = -e.y

    if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        x = enemy.mx
        enemy.mx = enemy.my
        enemy.my = x
    else if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        enemy.mx *= -1
        enemy.my *= -1

    e.x += enemy.mx
    e.y += enemy.my

    setDot e.x, e.y, 8
    setDot e.x-1, e.y, 6
    setDot e.x+1, e.y, 6
    setDot e.x, e.y+1, 6
    setDot e.x, e.y-1, 6

    if gameTick%41 == 40 && level>=1
      setDot e.x-enemy.mx*2, e.y-enemy.my*2, 7

drawDot = (x, y, col)->
  canvasX = (x+cx)*pieceSizeW
  canvasY = (y+cy)*pieceSizeH
  if canvasX<-pieceSizeW || canvasX > W || canvasY<-pieceSizeH || canvasY > H then return# c.l 'DRAW_DOT ERROR', canvasX, canvasY, x, y
  ctx.fillStyle = '#'+col
  ctx.fillRect .25+canvasX, .25+canvasY, pieceSizeW-.5, pieceSizeH-.5

drawShip = (dir)->
  for xy in shipDirDots[dir]
    drawDot xy[0], xy[1], shipColor

drawBorder = ->
  if shipPos.x+cx > worldEdge.x
    borderStartX = W-(shipPos.x+cx-worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect borderStartX, 0, W, H
  if shipPos.x-cx < -worldEdge.x
    borderStartX = -(shipPos.x-cx+worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, borderStartX, H
  if shipPos.y+cy > worldEdge.y
    borderStartY = W-(shipPos.y+cy-worldEdge.y)*pieceSizeH
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, borderStartY, W, H
  if shipPos.y-cy < -worldEdge.y
    borderStartY = -(shipPos.y-cy+worldEdge.y)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, W, borderStartY

drawStats = ->
  fontSize = (W/35)
  ctx.fillStyle = '#fff'
  ctx.font = fontSize+'px c64';
  ctx.fillText('HIGHSCORE: '+highscore, 6, 4+fontSize)
  ctx.fillText('SCORE: '+score, 6, 4+fontSize*2)
  ctx.fillText('LEVEL: '+level, 6, 4+fontSize*3)

drawDots = -> # Draw visible dots
  if worldEdge.x*2<gameRes
    maxX = worldEdge.x
    startX = -worldEdge.x-shipPos.x
    endX = worldEdge.x-shipPos.x
    startY = -worldEdge.y-shipPos.y
    endY = worldEdge.y-shipPos.y
  else
    maxX = (Math.round gameRes/2)
    startX = startY = -maxX
    endX = endY = maxX

  for x in [startX...endX]#[Math.floor(-(gameRes/2))...(gameRes/2)]
    posX = x+shipPos.x
    for y in [startY...endY] # [Math.floor(-(gameRes/2))...(gameRes/2)]
      posY = shipPos.y+y
      dot = getDot posX, posY
      if dot>0
        col =
          if dot==1 then shipTrailColor
          else if dot==6 then enemyColor
          else if dot==7 then enemyTrailColor
          else if dot==8 then enemyBodyColor
          else if dot==10 then bonusPointsColor
          else if dot==25 then 'f00'
          else if dot>=50 && dot<64
            dot += 1
            setDot posX, posY, dot
            col = (0xfff-((dot-50)*0x111)).toString(16)

          else if dot>=64
            setDot posX, posY, 0
            '000'
          else 'fff'
        drawDot x, y, col

getDot = (x, y)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  #if x<0 || x>=gameRes || y<0 || y>=gameRes then return# c.l 'getDot Out of bound',x,y
  dots[ x+(y*worldEdge.x*2) ]

setDot = (x, y, type)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  if x<0 || x >= worldEdge.x*2 || y<0 || y >= worldEdge.x*2 then return false# c.l 'setDot Out of bound',x,y
  dots[ x+(y*(worldEdge.x)*2) ] = type

getRandomDot = (saveArea)->
  x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
  y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
  maxTries = 128
  saveArea = saveArea||0
  tries = 0
  while x > -saveArea && x < saveArea && y > -saveArea && y < saveArea && getDot(x,y)==0
    tries++
    x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
    y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
    if tries > maxTries then return c.l 'getRandomDot overload'
  x:x, y:y

placeRandomDots = (amount, saveArea, id)->
  amount = amount||100
  saveArea = saveArea||worldEdge.x*.6
  while amount--
    dot = getRandomDot saveArea
    setDot dot.x, dot.y, id||10

checkCollision = ->
  # check collision with dot
  for sp in shipDirDots[dir]
    dot = getDot(sp[0]+shipPos.x, sp[1]+shipPos.y)
    if dot>0
      c.l dot
      if dot==10
        score += 100*(level+1)
        setDot(sp[0]+shipPos.x, sp[1]+shipPos.y, 0)
        placeRandomDots(1, 1)
      else killed--

  # check collision with wall
checkBorderCollision = ->
  if shipPos.x >= worldEdge.x
    shipPos.x = -worldEdge.x
  else if shipPos.x < -worldEdge.x
    shipPos.x = worldEdge.x-1

  if shipPos.y >= worldEdge.y
    shipPos.y = -worldEdge.x
  else if shipPos.y < -worldEdge.y
    shipPos.y = worldEdge.x-1

checkLevel = ->
  if score>1000 && level==0
    level++
    aniSpeed -= 2
  else if score>2500 && level==1
    level++
    gameRes -= 8
    setGameRes()
  else if score>5000 && level==2
    level++
    gameRes -= 8
    setGameRes()
  else if score>10000 && level==3
    level++
    gameRes -= 4
    setGameRes()
  else if score>20000 && level==4
    level++
    gameRes -= 2
    setGameRes()
  else if score>30000 && level==5
    level++
    gameRes -= 2
    setGameRes()
  else if score>45000 && level==6
    level++
    gameRes -= 2
    setGameRes()
  else if score>65000 && level==7
    level++
    gameRes -= 2
    setGameRes()
  else if score>80000 && level==8
    level++
    gameRes -= 2
    setGameRes()
  else if score>10000 && level==9
    level++
    aniSpeed -= 1

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

# requestAnimationFrame polyfill by Erik Möller. fixes from Paul Irish and Tino Zijdel
# MIT license

do ->
  lastTime = 0
  vendors = [ 'ms', 'moz', 'webkit', 'o' ]
  x = 0
  while x < vendors.length and !window.requestAnimationFrame
    window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame']
    window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] or window[vendors[x] + 'CancelRequestAnimationFrame']
    ++x
  if !window.requestAnimationFrame

    window.requestAnimationFrame = (callback, element) ->
      currTime = (new Date).getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      id = window.setTimeout((->
        callback currTime + timeToCall
        return
      ), timeToCall)
      lastTime = currTime + timeToCall
      id

  if !window.cancelAnimationFrame

    window.cancelAnimationFrame = (id) ->
      clearTimeout id
      return
  return


window.onload = ->
  addEventListeners()
  initCanvas()
  startGame()

pieceSizeW = W / gameRes
pieceSizeH = H / gameRes

killed = false

cx = (gameRes/2)
cy = (gameRes/2)

shipPos = x:0, y:0
shipVel = x:0, y:0
dir = 0
keysPressed = ["w"]
score = 0
highscore = 0
gameRes = 0
aniSpeed = 666
level = 0

gameTick = 0

startRes = 60

worldEdge = x: 127, y: 127
dots = new Uint8Array worldEdge.x*2*worldEdge.y*2
shipDirDots = null

shipColor = 'b0ec51'
shipTrailColor = '598e07'

enemyColor = '8333a5'
enemyBodyColor = 'ac61cc'
enemyTrailColor = '3e49d2'

bonusPointsColor = 'e4cc1f'

wallColor = '20363e'

shipDirDots = [
  [
    [-1, 0], [0, 0], [+1, 0], [0, -1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0+1, 0]
  ], [
    [0-1, 0], [0, 0], [0+1, 0], [0, 0+1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0-1, 0]
  ]
]

killPlayer = (i)->
  i = i||0

  clearCanvas()
  drawDots()
  drawBorder()

  if i<Math.sqrt(gameRes*gameRes+gameRes*gameRes)/2
    drawDot 0+i, 0+i, shipColor
    drawDot 0-i, 0-i, shipColor
    drawDot 0+i, 0-i, shipColor
    drawDot 0-i, 0+i, shipColor
    i++
    requestAnimationFrame (-> killPlayer(i))
  else
    highscore = Math.max score, highscore
    score = 0
    startGame()

startGame = ->
  shipPos = x:0, y:19
  shipVel = x:0, y:0
  dir = 0
  keysPressed = ['w']

  dots = new Uint8Array worldEdge.x*2*worldEdge.y*2

  killed = false

  worldEdge.x = 31 # must be uneven
  worldEdge.y = 31 # must be uneven
  gameRes = 5
  aniSpeed = 14
  level = 0
  lasers = 10

  getEnemys(4)
  moveEnemy()
  setGameRes()
  placeRandomDots(10)
  nextFrame()


setGameRes = ->
  pieceSizeW = W / gameRes
  pieceSizeH = H / gameRes

  cx = gameRes/2
  cy = gameRes/2


checkKeysPressed = ()->
  k = keysPressed.shift()
  if k
    if k=='w'
      shipVel = x:0, y:-1
      dir = 0
    else if k=='d'
      shipVel = x:1, y:0
      dir = 1
    else if k=='s'
      shipVel = x:0, y:1
      dir = 2
    else if k=='a'
      shipVel = x:-1, y:0
      dir = 3

aniCnt = aniSpeed

nextFrame = ->
  if aniCnt<aniSpeed
    aniCnt++
    return requestAnimationFrame nextFrame
  else aniCnt = 0

  aniSpeed -= 1 if aniSpeed>5

  if gameRes < startRes && level==0
    gameRes += 4
    setGameRes()

  checkKeysPressed()

  shipPos.x += shipVel.x
  shipPos.y += shipVel.y


  checkCollision()
  checkBorderCollision()

  moveEnemy()
  checkCollision()


  checkLevel()

  clearCanvas()

  drawDots()
  drawBorder()
  drawShip(dir)

  drawStats()



  #setDot shipPos.x, shipPos.y, 1

  if Math.random()<.05 then placeRandomDots(1, 1)

  score += 1+level
  gameTick++

  if killed==false
    requestAnimationFrame nextFrame
  else
    killPlayer()


addEventListeners = ->
  d.body.addEventListener 'keydown', (e)->
    if (e.key=='w' || e.key=='d' || e.key=='s' || e.key=='a') && e.key != keysPressed[keysPressed.length-1]
      keysPressed.push e.key

enemys = []

getEnemys = (cnt)->
  enemys = []
  # for i in [0..cnt]
  #   m = if Math.random()>.5 then 1 else -1
  #   if Math.random()>.5
  #     mx = m
  #     my = 0
  #   else
  #     mx = 0
  #     my = m
  #   pos = getRandomDot(worldEdge.x/10)
  enemys.push pos:{x: -worldEdge.x+2, y: -6 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: -3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 0 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 6 }, mx: 1, my:0

moveEnemy = ->
  for enemy, ei in enemys
    e = enemy.pos
    setDot e.x, e.y, 0
    setDot e.x-1, e.y, 0
    setDot e.x+1, e.y, 0
    setDot e.x, e.y+1, 0
    setDot e.x, e.y-1, 0


    if Math.abs(e.x) > worldEdge.x
      e.x = -e.x
    if Math.abs(e.y) > worldEdge.y
      e.y = -e.y

    if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        x = enemy.mx
        enemy.mx = enemy.my
        enemy.my = x
    else if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        enemy.mx *= -1
        enemy.my *= -1

    e.x += enemy.mx
    e.y += enemy.my

    setDot e.x, e.y, 8
    setDot e.x-1, e.y, 6
    setDot e.x+1, e.y, 6
    setDot e.x, e.y+1, 6
    setDot e.x, e.y-1, 6

    if gameTick%41 == 40 && level>=1
      setDot e.x-enemy.mx*2, e.y-enemy.my*2, 7

drawDot = (x, y, col)->
  canvasX = (x+cx)*pieceSizeW
  canvasY = (y+cy)*pieceSizeH
  if canvasX<-pieceSizeW || canvasX > W || canvasY<-pieceSizeH || canvasY > H then return# c.l 'DRAW_DOT ERROR', canvasX, canvasY, x, y
  ctx.fillStyle = '#'+col
  ctx.fillRect .25+canvasX, .25+canvasY, pieceSizeW-.5, pieceSizeH-.5

drawShip = (dir)->
  for xy in shipDirDots[dir]
    drawDot xy[0], xy[1], shipColor

drawBorder = ->
  if shipPos.x+cx > worldEdge.x
    borderStartX = W-(shipPos.x+cx-worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect borderStartX, 0, W, H
  if shipPos.x-cx < -worldEdge.x
    borderStartX = -(shipPos.x-cx+worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, borderStartX, H
  if shipPos.y+cy > worldEdge.y
    borderStartY = W-(shipPos.y+cy-worldEdge.y)*pieceSizeH
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, borderStartY, W, H
  if shipPos.y-cy < -worldEdge.y
    borderStartY = -(shipPos.y-cy+worldEdge.y)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, W, borderStartY

drawStats = ->
  fontSize = (W/35)
  ctx.fillStyle = '#fff'
  ctx.font = fontSize+'px c64';
  ctx.fillText('HIGHSCORE: '+highscore, 6, 4+fontSize)
  ctx.fillText('SCORE: '+score, 6, 4+fontSize*2)
  ctx.fillText('LEVEL: '+level, 6, 4+fontSize*3)

drawDots = -> # Draw visible dots
  if worldEdge.x*2<gameRes
    maxX = worldEdge.x
    startX = -worldEdge.x-shipPos.x
    endX = worldEdge.x-shipPos.x
    startY = -worldEdge.y-shipPos.y
    endY = worldEdge.y-shipPos.y
  else
    maxX = (Math.round gameRes/2)
    startX = startY = -maxX
    endX = endY = maxX

  for x in [startX...endX]#[Math.floor(-(gameRes/2))...(gameRes/2)]
    posX = x+shipPos.x
    for y in [startY...endY] # [Math.floor(-(gameRes/2))...(gameRes/2)]
      posY = shipPos.y+y
      dot = getDot posX, posY
      if dot>0
        col =
          if dot==1 then shipTrailColor
          else if dot==6 then enemyColor
          else if dot==7 then enemyTrailColor
          else if dot==8 then enemyBodyColor
          else if dot==10 then bonusPointsColor
          else if dot==25 then 'f00'
          else if dot>=50 && dot<64
            dot += 1
            setDot posX, posY, dot
            col = (0xfff-((dot-50)*0x111)).toString(16)

          else if dot>=64
            setDot posX, posY, 0
            '000'
          else 'fff'
        drawDot x, y, col

getDot = (x, y)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  #if x<0 || x>=gameRes || y<0 || y>=gameRes then return# c.l 'getDot Out of bound',x,y
  dots[ x+(y*worldEdge.x*2) ]

setDot = (x, y, type)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  if x<0 || x >= worldEdge.x*2 || y<0 || y >= worldEdge.x*2 then return false# c.l 'setDot Out of bound',x,y
  dots[ x+(y*(worldEdge.x)*2) ] = type

getRandomDot = (saveArea)->
  x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
  y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
  maxTries = 128
  saveArea = saveArea||0
  tries = 0
  while x > -saveArea && x < saveArea && y > -saveArea && y < saveArea && getDot(x,y)==0
    tries++
    x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
    y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
    if tries > maxTries then return c.l 'getRandomDot overload'
  x:x, y:y

placeRandomDots = (amount, saveArea, id)->
  amount = amount||100
  saveArea = saveArea||worldEdge.x*.6
  while amount--
    dot = getRandomDot saveArea
    setDot dot.x, dot.y, id||10

checkCollision = ->
  # check collision with dot
  for sp in shipDirDots[dir]
    dot = getDot(sp[0]+shipPos.x, sp[1]+shipPos.y)
    if dot>0
      c.l dot
      if dot==10
        score += 100*(level+1)
        setDot(sp[0]+shipPos.x, sp[1]+shipPos.y, 0)
        placeRandomDots(1, 1)
      else killed--

  # check collision with wall
checkBorderCollision = ->
  if shipPos.x >= worldEdge.x
    shipPos.x = -worldEdge.x
  else if shipPos.x < -worldEdge.x
    shipPos.x = worldEdge.x-1

  if shipPos.y >= worldEdge.y
    shipPos.y = -worldEdge.x
  else if shipPos.y < -worldEdge.y
    shipPos.y = worldEdge.x-1

checkLevel = ->
  if score>1000 && level==0
    level++
    aniSpeed -= 2
  else if score>2500 && level==1
    level++
    gameRes -= 8
    setGameRes()
  else if score>5000 && level==2
    level++
    gameRes -= 8
    setGameRes()
  else if score>10000 && level==3
    level++
    gameRes -= 4
    setGameRes()
  else if score>20000 && level==4
    level++
    gameRes -= 2
    setGameRes()
  else if score>30000 && level==5
    level++
    gameRes -= 2
    setGameRes()
  else if score>45000 && level==6
    level++
    gameRes -= 2
    setGameRes()
  else if score>65000 && level==7
    level++
    gameRes -= 2
    setGameRes()
  else if score>80000 && level==8
    level++
    gameRes -= 2
    setGameRes()
  else if score>10000 && level==9
    level++
    aniSpeed -= 1

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

# requestAnimationFrame polyfill by Erik Möller. fixes from Paul Irish and Tino Zijdel
# MIT license

do ->
  lastTime = 0
  vendors = [ 'ms', 'moz', 'webkit', 'o' ]
  x = 0
  while x < vendors.length and !window.requestAnimationFrame
    window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame']
    window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] or window[vendors[x] + 'CancelRequestAnimationFrame']
    ++x
  if !window.requestAnimationFrame

    window.requestAnimationFrame = (callback, element) ->
      currTime = (new Date).getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      id = window.setTimeout((->
        callback currTime + timeToCall
        return
      ), timeToCall)
      lastTime = currTime + timeToCall
      id

  if !window.cancelAnimationFrame

    window.cancelAnimationFrame = (id) ->
      clearTimeout id
      return
  return


window.onload = ->
  addEventListeners()
  initCanvas()
  startGame()

pieceSizeW = W / gameRes
pieceSizeH = H / gameRes

killed = false

cx = (gameRes/2)
cy = (gameRes/2)

shipPos = x:0, y:0
shipVel = x:0, y:0
dir = 0
keysPressed = ["w"]
score = 0
highscore = 0
gameRes = 0
aniSpeed = 666
level = 0

gameTick = 0

startRes = 60

worldEdge = x: 127, y: 127
dots = new Uint8Array worldEdge.x*2*worldEdge.y*2
shipDirDots = null

shipColor = 'b0ec51'
shipTrailColor = '598e07'

enemyColor = '8333a5'
enemyBodyColor = 'ac61cc'
enemyTrailColor = '3e49d2'

bonusPointsColor = 'e4cc1f'

wallColor = '20363e'

shipDirDots = [
  [
    [-1, 0], [0, 0], [+1, 0], [0, -1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0+1, 0]
  ], [
    [0-1, 0], [0, 0], [0+1, 0], [0, 0+1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0-1, 0]
  ]
]

killPlayer = (i)->
  i = i||0

  clearCanvas()
  drawDots()
  drawBorder()

  if i<Math.sqrt(gameRes*gameRes+gameRes*gameRes)/2
    drawDot 0+i, 0+i, shipColor
    drawDot 0-i, 0-i, shipColor
    drawDot 0+i, 0-i, shipColor
    drawDot 0-i, 0+i, shipColor
    i++
    requestAnimationFrame (-> killPlayer(i))
  else
    highscore = Math.max score, highscore
    score = 0
    startGame()

startGame = ->
  shipPos = x:0, y:19
  shipVel = x:0, y:0
  dir = 0
  keysPressed = ['w']

  dots = new Uint8Array worldEdge.x*2*worldEdge.y*2

  killed = false

  worldEdge.x = 31 # must be uneven
  worldEdge.y = 31 # must be uneven
  gameRes = 5
  aniSpeed = 14
  level = 0
  lasers = 10

  getEnemys(4)
  moveEnemy()
  setGameRes()
  placeRandomDots(10)
  nextFrame()


setGameRes = ->
  pieceSizeW = W / gameRes
  pieceSizeH = H / gameRes

  cx = gameRes/2
  cy = gameRes/2


checkKeysPressed = ()->
  k = keysPressed.shift()
  if k
    if k=='w'
      shipVel = x:0, y:-1
      dir = 0
    else if k=='d'
      shipVel = x:1, y:0
      dir = 1
    else if k=='s'
      shipVel = x:0, y:1
      dir = 2
    else if k=='a'
      shipVel = x:-1, y:0
      dir = 3

aniCnt = aniSpeed

nextFrame = ->
  if aniCnt<aniSpeed
    aniCnt++
    return requestAnimationFrame nextFrame
  else aniCnt = 0

  aniSpeed -= 1 if aniSpeed>5

  if gameRes < startRes && level==0
    gameRes += 4
    setGameRes()

  checkKeysPressed()

  shipPos.x += shipVel.x
  shipPos.y += shipVel.y


  checkCollision()
  checkBorderCollision()

  moveEnemy()
  checkCollision()


  checkLevel()

  clearCanvas()

  drawDots()
  drawBorder()
  drawShip(dir)

  drawStats()



  #setDot shipPos.x, shipPos.y, 1

  if Math.random()<.05 then placeRandomDots(1, 1)

  score += 1+level
  gameTick++

  if killed==false
    requestAnimationFrame nextFrame
  else
    killPlayer()


addEventListeners = ->
  d.body.addEventListener 'keydown', (e)->
    if (e.key=='w' || e.key=='d' || e.key=='s' || e.key=='a') && e.key != keysPressed[keysPressed.length-1]
      keysPressed.push e.key

enemys = []

getEnemys = (cnt)->
  enemys = []
  # for i in [0..cnt]
  #   m = if Math.random()>.5 then 1 else -1
  #   if Math.random()>.5
  #     mx = m
  #     my = 0
  #   else
  #     mx = 0
  #     my = m
  #   pos = getRandomDot(worldEdge.x/10)
  enemys.push pos:{x: -worldEdge.x+2, y: -6 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: -3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 0 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 6 }, mx: 1, my:0

moveEnemy = ->
  for enemy, ei in enemys
    e = enemy.pos
    setDot e.x, e.y, 0
    setDot e.x-1, e.y, 0
    setDot e.x+1, e.y, 0
    setDot e.x, e.y+1, 0
    setDot e.x, e.y-1, 0


    if Math.abs(e.x) > worldEdge.x
      e.x = -e.x
    if Math.abs(e.y) > worldEdge.y
      e.y = -e.y

    if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        x = enemy.mx
        enemy.mx = enemy.my
        enemy.my = x
    else if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        enemy.mx *= -1
        enemy.my *= -1

    e.x += enemy.mx
    e.y += enemy.my

    setDot e.x, e.y, 8
    setDot e.x-1, e.y, 6
    setDot e.x+1, e.y, 6
    setDot e.x, e.y+1, 6
    setDot e.x, e.y-1, 6

    if gameTick%41 == 40 && level>=1
      setDot e.x-enemy.mx*2, e.y-enemy.my*2, 7

drawDot = (x, y, col)->
  canvasX = (x+cx)*pieceSizeW
  canvasY = (y+cy)*pieceSizeH
  if canvasX<-pieceSizeW || canvasX > W || canvasY<-pieceSizeH || canvasY > H then return# c.l 'DRAW_DOT ERROR', canvasX, canvasY, x, y
  ctx.fillStyle = '#'+col
  ctx.fillRect .25+canvasX, .25+canvasY, pieceSizeW-.5, pieceSizeH-.5

drawShip = (dir)->
  for xy in shipDirDots[dir]
    drawDot xy[0], xy[1], shipColor

drawBorder = ->
  if shipPos.x+cx > worldEdge.x
    borderStartX = W-(shipPos.x+cx-worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect borderStartX, 0, W, H
  if shipPos.x-cx < -worldEdge.x
    borderStartX = -(shipPos.x-cx+worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, borderStartX, H
  if shipPos.y+cy > worldEdge.y
    borderStartY = W-(shipPos.y+cy-worldEdge.y)*pieceSizeH
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, borderStartY, W, H
  if shipPos.y-cy < -worldEdge.y
    borderStartY = -(shipPos.y-cy+worldEdge.y)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, W, borderStartY

drawStats = ->
  fontSize = (W/35)
  ctx.fillStyle = '#fff'
  ctx.font = fontSize+'px c64';
  ctx.fillText('HIGHSCORE: '+highscore, 6, 4+fontSize)
  ctx.fillText('SCORE: '+score, 6, 4+fontSize*2)
  ctx.fillText('LEVEL: '+level, 6, 4+fontSize*3)

drawDots = -> # Draw visible dots
  if worldEdge.x*2<gameRes
    maxX = worldEdge.x
    startX = -worldEdge.x-shipPos.x
    endX = worldEdge.x-shipPos.x
    startY = -worldEdge.y-shipPos.y
    endY = worldEdge.y-shipPos.y
  else
    maxX = (Math.round gameRes/2)
    startX = startY = -maxX
    endX = endY = maxX

  for x in [startX...endX]#[Math.floor(-(gameRes/2))...(gameRes/2)]
    posX = x+shipPos.x
    for y in [startY...endY] # [Math.floor(-(gameRes/2))...(gameRes/2)]
      posY = shipPos.y+y
      dot = getDot posX, posY
      if dot>0
        col =
          if dot==1 then shipTrailColor
          else if dot==6 then enemyColor
          else if dot==7 then enemyTrailColor
          else if dot==8 then enemyBodyColor
          else if dot==10 then bonusPointsColor
          else if dot==25 then 'f00'
          else if dot>=50 && dot<64
            dot += 1
            setDot posX, posY, dot
            col = (0xfff-((dot-50)*0x111)).toString(16)

          else if dot>=64
            setDot posX, posY, 0
            '000'
          else 'fff'
        drawDot x, y, col

getDot = (x, y)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  #if x<0 || x>=gameRes || y<0 || y>=gameRes then return# c.l 'getDot Out of bound',x,y
  dots[ x+(y*worldEdge.x*2) ]

setDot = (x, y, type)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  if x<0 || x >= worldEdge.x*2 || y<0 || y >= worldEdge.x*2 then return false# c.l 'setDot Out of bound',x,y
  dots[ x+(y*(worldEdge.x)*2) ] = type

getRandomDot = (saveArea)->
  x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
  y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
  maxTries = 128
  saveArea = saveArea||0
  tries = 0
  while x > -saveArea && x < saveArea && y > -saveArea && y < saveArea && getDot(x,y)==0
    tries++
    x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
    y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
    if tries > maxTries then return c.l 'getRandomDot overload'
  x:x, y:y

placeRandomDots = (amount, saveArea, id)->
  amount = amount||100
  saveArea = saveArea||worldEdge.x*.6
  while amount--
    dot = getRandomDot saveArea
    setDot dot.x, dot.y, id||10

checkCollision = ->
  # check collision with dot
  for sp in shipDirDots[dir]
    dot = getDot(sp[0]+shipPos.x, sp[1]+shipPos.y)
    if dot>0
      c.l dot
      if dot==10
        score += 100*(level+1)
        setDot(sp[0]+shipPos.x, sp[1]+shipPos.y, 0)
        placeRandomDots(1, 1)
      else killed--

  # check collision with wall
checkBorderCollision = ->
  if shipPos.x >= worldEdge.x
    shipPos.x = -worldEdge.x
  else if shipPos.x < -worldEdge.x
    shipPos.x = worldEdge.x-1

  if shipPos.y >= worldEdge.y
    shipPos.y = -worldEdge.x
  else if shipPos.y < -worldEdge.y
    shipPos.y = worldEdge.x-1

checkLevel = ->
  if score>1000 && level==0
    level++
    aniSpeed -= 2
  else if score>2500 && level==1
    level++
    gameRes -= 8
    setGameRes()
  else if score>5000 && level==2
    level++
    gameRes -= 8
    setGameRes()
  else if score>10000 && level==3
    level++
    gameRes -= 4
    setGameRes()
  else if score>20000 && level==4
    level++
    gameRes -= 2
    setGameRes()
  else if score>30000 && level==5
    level++
    gameRes -= 2
    setGameRes()
  else if score>45000 && level==6
    level++
    gameRes -= 2
    setGameRes()
  else if score>65000 && level==7
    level++
    gameRes -= 2
    setGameRes()
  else if score>80000 && level==8
    level++
    gameRes -= 2
    setGameRes()
  else if score>10000 && level==9
    level++
    aniSpeed -= 1

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

# requestAnimationFrame polyfill by Erik Möller. fixes from Paul Irish and Tino Zijdel
# MIT license

do ->
  lastTime = 0
  vendors = [ 'ms', 'moz', 'webkit', 'o' ]
  x = 0
  while x < vendors.length and !window.requestAnimationFrame
    window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame']
    window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] or window[vendors[x] + 'CancelRequestAnimationFrame']
    ++x
  if !window.requestAnimationFrame

    window.requestAnimationFrame = (callback, element) ->
      currTime = (new Date).getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      id = window.setTimeout((->
        callback currTime + timeToCall
        return
      ), timeToCall)
      lastTime = currTime + timeToCall
      id

  if !window.cancelAnimationFrame

    window.cancelAnimationFrame = (id) ->
      clearTimeout id
      return
  return


window.onload = ->
  addEventListeners()
  initCanvas()
  startGame()

pieceSizeW = W / gameRes
pieceSizeH = H / gameRes

killed = false

cx = (gameRes/2)
cy = (gameRes/2)

shipPos = x:0, y:0
shipVel = x:0, y:0
dir = 0
keysPressed = ["w"]
score = 0
highscore = 0
gameRes = 0
aniSpeed = 666
level = 0

gameTick = 0

startRes = 60

worldEdge = x: 127, y: 127
dots = new Uint8Array worldEdge.x*2*worldEdge.y*2
shipDirDots = null

shipColor = 'b0ec51'
shipTrailColor = '598e07'

enemyColor = '8333a5'
enemyBodyColor = 'ac61cc'
enemyTrailColor = '3e49d2'

bonusPointsColor = 'e4cc1f'

wallColor = '20363e'

shipDirDots = [
  [
    [-1, 0], [0, 0], [+1, 0], [0, -1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0+1, 0]
  ], [
    [0-1, 0], [0, 0], [0+1, 0], [0, 0+1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0-1, 0]
  ]
]

killPlayer = (i)->
  i = i||0

  clearCanvas()
  drawDots()
  drawBorder()

  if i<Math.sqrt(gameRes*gameRes+gameRes*gameRes)/2
    drawDot 0+i, 0+i, shipColor
    drawDot 0-i, 0-i, shipColor
    drawDot 0+i, 0-i, shipColor
    drawDot 0-i, 0+i, shipColor
    i++
    requestAnimationFrame (-> killPlayer(i))
  else
    highscore = Math.max score, highscore
    score = 0
    startGame()

startGame = ->
  shipPos = x:0, y:19
  shipVel = x:0, y:0
  dir = 0
  keysPressed = ['w']

  dots = new Uint8Array worldEdge.x*2*worldEdge.y*2

  killed = false

  worldEdge.x = 31 # must be uneven
  worldEdge.y = 31 # must be uneven
  gameRes = 5
  aniSpeed = 14
  level = 0
  lasers = 10

  getEnemys(4)
  moveEnemy()
  setGameRes()
  placeRandomDots(10)
  nextFrame()


setGameRes = ->
  pieceSizeW = W / gameRes
  pieceSizeH = H / gameRes

  cx = gameRes/2
  cy = gameRes/2


checkKeysPressed = ()->
  k = keysPressed.shift()
  if k
    if k=='w'
      shipVel = x:0, y:-1
      dir = 0
    else if k=='d'
      shipVel = x:1, y:0
      dir = 1
    else if k=='s'
      shipVel = x:0, y:1
      dir = 2
    else if k=='a'
      shipVel = x:-1, y:0
      dir = 3

aniCnt = aniSpeed

nextFrame = ->
  if aniCnt<aniSpeed
    aniCnt++
    return requestAnimationFrame nextFrame
  else aniCnt = 0

  aniSpeed -= 1 if aniSpeed>5

  if gameRes < startRes && level==0
    gameRes += 4
    setGameRes()

  checkKeysPressed()

  shipPos.x += shipVel.x
  shipPos.y += shipVel.y


  checkCollision()
  checkBorderCollision()

  moveEnemy()
  checkCollision()


  checkLevel()

  clearCanvas()

  drawDots()
  drawBorder()
  drawShip(dir)

  drawStats()



  #setDot shipPos.x, shipPos.y, 1

  if Math.random()<.05 then placeRandomDots(1, 1)

  score += 1+level
  gameTick++

  if killed==false
    requestAnimationFrame nextFrame
  else
    killPlayer()


addEventListeners = ->
  d.body.addEventListener 'keydown', (e)->
    if (e.key=='w' || e.key=='d' || e.key=='s' || e.key=='a') && e.key != keysPressed[keysPressed.length-1]
      keysPressed.push e.key

enemys = []

getEnemys = (cnt)->
  enemys = []
  # for i in [0..cnt]
  #   m = if Math.random()>.5 then 1 else -1
  #   if Math.random()>.5
  #     mx = m
  #     my = 0
  #   else
  #     mx = 0
  #     my = m
  #   pos = getRandomDot(worldEdge.x/10)
  enemys.push pos:{x: -worldEdge.x+2, y: -6 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: -3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 0 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 6 }, mx: 1, my:0

moveEnemy = ->
  for enemy, ei in enemys
    e = enemy.pos
    setDot e.x, e.y, 0
    setDot e.x-1, e.y, 0
    setDot e.x+1, e.y, 0
    setDot e.x, e.y+1, 0
    setDot e.x, e.y-1, 0


    if Math.abs(e.x) > worldEdge.x
      e.x = -e.x
    if Math.abs(e.y) > worldEdge.y
      e.y = -e.y

    if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        x = enemy.mx
        enemy.mx = enemy.my
        enemy.my = x
    else if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        enemy.mx *= -1
        enemy.my *= -1

    e.x += enemy.mx
    e.y += enemy.my

    setDot e.x, e.y, 8
    setDot e.x-1, e.y, 6
    setDot e.x+1, e.y, 6
    setDot e.x, e.y+1, 6
    setDot e.x, e.y-1, 6

    if gameTick%41 == 40 && level>=1
      setDot e.x-enemy.mx*2, e.y-enemy.my*2, 7

drawDot = (x, y, col)->
  canvasX = (x+cx)*pieceSizeW
  canvasY = (y+cy)*pieceSizeH
  if canvasX<-pieceSizeW || canvasX > W || canvasY<-pieceSizeH || canvasY > H then return# c.l 'DRAW_DOT ERROR', canvasX, canvasY, x, y
  ctx.fillStyle = '#'+col
  ctx.fillRect .25+canvasX, .25+canvasY, pieceSizeW-.5, pieceSizeH-.5

drawShip = (dir)->
  for xy in shipDirDots[dir]
    drawDot xy[0], xy[1], shipColor

drawBorder = ->
  if shipPos.x+cx > worldEdge.x
    borderStartX = W-(shipPos.x+cx-worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect borderStartX, 0, W, H
  if shipPos.x-cx < -worldEdge.x
    borderStartX = -(shipPos.x-cx+worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, borderStartX, H
  if shipPos.y+cy > worldEdge.y
    borderStartY = W-(shipPos.y+cy-worldEdge.y)*pieceSizeH
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, borderStartY, W, H
  if shipPos.y-cy < -worldEdge.y
    borderStartY = -(shipPos.y-cy+worldEdge.y)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, W, borderStartY

drawStats = ->
  fontSize = (W/35)
  ctx.fillStyle = '#fff'
  ctx.font = fontSize+'px c64';
  ctx.fillText('HIGHSCORE: '+highscore, 6, 4+fontSize)
  ctx.fillText('SCORE: '+score, 6, 4+fontSize*2)
  ctx.fillText('LEVEL: '+level, 6, 4+fontSize*3)

drawDots = -> # Draw visible dots
  if worldEdge.x*2<gameRes
    maxX = worldEdge.x
    startX = -worldEdge.x-shipPos.x
    endX = worldEdge.x-shipPos.x
    startY = -worldEdge.y-shipPos.y
    endY = worldEdge.y-shipPos.y
  else
    maxX = (Math.round gameRes/2)
    startX = startY = -maxX
    endX = endY = maxX

  for x in [startX...endX]#[Math.floor(-(gameRes/2))...(gameRes/2)]
    posX = x+shipPos.x
    for y in [startY...endY] # [Math.floor(-(gameRes/2))...(gameRes/2)]
      posY = shipPos.y+y
      dot = getDot posX, posY
      if dot>0
        col =
          if dot==1 then shipTrailColor
          else if dot==6 then enemyColor
          else if dot==7 then enemyTrailColor
          else if dot==8 then enemyBodyColor
          else if dot==10 then bonusPointsColor
          else if dot==25 then 'f00'
          else if dot>=50 && dot<64
            dot += 1
            setDot posX, posY, dot
            col = (0xfff-((dot-50)*0x111)).toString(16)

          else if dot>=64
            setDot posX, posY, 0
            '000'
          else 'fff'
        drawDot x, y, col

getDot = (x, y)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  #if x<0 || x>=gameRes || y<0 || y>=gameRes then return# c.l 'getDot Out of bound',x,y
  dots[ x+(y*worldEdge.x*2) ]

setDot = (x, y, type)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  if x<0 || x >= worldEdge.x*2 || y<0 || y >= worldEdge.x*2 then return false# c.l 'setDot Out of bound',x,y
  dots[ x+(y*(worldEdge.x)*2) ] = type

getRandomDot = (saveArea)->
  x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
  y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
  maxTries = 128
  saveArea = saveArea||0
  tries = 0
  while x > -saveArea && x < saveArea && y > -saveArea && y < saveArea && getDot(x,y)==0
    tries++
    x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
    y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
    if tries > maxTries then return c.l 'getRandomDot overload'
  x:x, y:y

placeRandomDots = (amount, saveArea, id)->
  amount = amount||100
  saveArea = saveArea||worldEdge.x*.6
  while amount--
    dot = getRandomDot saveArea
    setDot dot.x, dot.y, id||10

checkCollision = ->
  # check collision with dot
  for sp in shipDirDots[dir]
    dot = getDot(sp[0]+shipPos.x, sp[1]+shipPos.y)
    if dot>0
      c.l dot
      if dot==10
        score += 100*(level+1)
        setDot(sp[0]+shipPos.x, sp[1]+shipPos.y, 0)
        placeRandomDots(1, 1)
      else killed--

  # check collision with wall
checkBorderCollision = ->
  if shipPos.x >= worldEdge.x
    shipPos.x = -worldEdge.x
  else if shipPos.x < -worldEdge.x
    shipPos.x = worldEdge.x-1

  if shipPos.y >= worldEdge.y
    shipPos.y = -worldEdge.x
  else if shipPos.y < -worldEdge.y
    shipPos.y = worldEdge.x-1

checkLevel = ->
  if score>1000 && level==0
    level++
    aniSpeed -= 2
  else if score>2500 && level==1
    level++
    gameRes -= 8
    setGameRes()
  else if score>5000 && level==2
    level++
    gameRes -= 8
    setGameRes()
  else if score>10000 && level==3
    level++
    gameRes -= 4
    setGameRes()
  else if score>20000 && level==4
    level++
    gameRes -= 2
    setGameRes()
  else if score>30000 && level==5
    level++
    gameRes -= 2
    setGameRes()
  else if score>45000 && level==6
    level++
    gameRes -= 2
    setGameRes()
  else if score>65000 && level==7
    level++
    gameRes -= 2
    setGameRes()
  else if score>80000 && level==8
    level++
    gameRes -= 2
    setGameRes()
  else if score>10000 && level==9
    level++
    aniSpeed -= 1

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

# requestAnimationFrame polyfill by Erik Möller. fixes from Paul Irish and Tino Zijdel
# MIT license

do ->
  lastTime = 0
  vendors = [ 'ms', 'moz', 'webkit', 'o' ]
  x = 0
  while x < vendors.length and !window.requestAnimationFrame
    window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame']
    window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] or window[vendors[x] + 'CancelRequestAnimationFrame']
    ++x
  if !window.requestAnimationFrame

    window.requestAnimationFrame = (callback, element) ->
      currTime = (new Date).getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      id = window.setTimeout((->
        callback currTime + timeToCall
        return
      ), timeToCall)
      lastTime = currTime + timeToCall
      id

  if !window.cancelAnimationFrame

    window.cancelAnimationFrame = (id) ->
      clearTimeout id
      return
  return


window.onload = ->
  addEventListeners()
  initCanvas()
  startGame()

pieceSizeW = W / gameRes
pieceSizeH = H / gameRes

killed = false

cx = (gameRes/2)
cy = (gameRes/2)

shipPos = x:0, y:0
shipVel = x:0, y:0
dir = 0
keysPressed = ["w"]
score = 0
highscore = 0
gameRes = 0
aniSpeed = 666
level = 0

gameTick = 0

startRes = 60

worldEdge = x: 127, y: 127
dots = new Uint8Array worldEdge.x*2*worldEdge.y*2
shipDirDots = null

shipColor = 'b0ec51'
shipTrailColor = '598e07'

enemyColor = '8333a5'
enemyBodyColor = 'ac61cc'
enemyTrailColor = '3e49d2'

bonusPointsColor = 'e4cc1f'

wallColor = '20363e'

shipDirDots = [
  [
    [-1, 0], [0, 0], [+1, 0], [0, -1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0+1, 0]
  ], [
    [0-1, 0], [0, 0], [0+1, 0], [0, 0+1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0-1, 0]
  ]
]

killPlayer = (i)->
  i = i||0

  clearCanvas()
  drawDots()
  drawBorder()

  if i<Math.sqrt(gameRes*gameRes+gameRes*gameRes)/2
    drawDot 0+i, 0+i, shipColor
    drawDot 0-i, 0-i, shipColor
    drawDot 0+i, 0-i, shipColor
    drawDot 0-i, 0+i, shipColor
    i++
    requestAnimationFrame (-> killPlayer(i))
  else
    highscore = Math.max score, highscore
    score = 0
    startGame()

startGame = ->
  shipPos = x:0, y:19
  shipVel = x:0, y:0
  dir = 0
  keysPressed = ['w']

  dots = new Uint8Array worldEdge.x*2*worldEdge.y*2

  killed = false

  worldEdge.x = 31 # must be uneven
  worldEdge.y = 31 # must be uneven
  gameRes = 5
  aniSpeed = 14
  level = 0
  lasers = 10

  getEnemys(4)
  moveEnemy()
  setGameRes()
  placeRandomDots(10)
  nextFrame()


setGameRes = ->
  pieceSizeW = W / gameRes
  pieceSizeH = H / gameRes

  cx = gameRes/2
  cy = gameRes/2


checkKeysPressed = ()->
  k = keysPressed.shift()
  if k
    if k=='w'
      shipVel = x:0, y:-1
      dir = 0
    else if k=='d'
      shipVel = x:1, y:0
      dir = 1
    else if k=='s'
      shipVel = x:0, y:1
      dir = 2
    else if k=='a'
      shipVel = x:-1, y:0
      dir = 3

aniCnt = aniSpeed

nextFrame = ->
  if aniCnt<aniSpeed
    aniCnt++
    return requestAnimationFrame nextFrame
  else aniCnt = 0

  aniSpeed -= 1 if aniSpeed>5

  if gameRes < startRes && level==0
    gameRes += 4
    setGameRes()

  checkKeysPressed()

  shipPos.x += shipVel.x
  shipPos.y += shipVel.y


  checkCollision()
  checkBorderCollision()

  moveEnemy()
  checkCollision()


  checkLevel()

  clearCanvas()

  drawDots()
  drawBorder()
  drawShip(dir)

  drawStats()



  #setDot shipPos.x, shipPos.y, 1

  if Math.random()<.05 then placeRandomDots(1, 1)

  score += 1+level
  gameTick++

  if killed==false
    requestAnimationFrame nextFrame
  else
    killPlayer()


addEventListeners = ->
  d.body.addEventListener 'keydown', (e)->
    if (e.key=='w' || e.key=='d' || e.key=='s' || e.key=='a') && e.key != keysPressed[keysPressed.length-1]
      keysPressed.push e.key

enemys = []

getEnemys = (cnt)->
  enemys = []
  # for i in [0..cnt]
  #   m = if Math.random()>.5 then 1 else -1
  #   if Math.random()>.5
  #     mx = m
  #     my = 0
  #   else
  #     mx = 0
  #     my = m
  #   pos = getRandomDot(worldEdge.x/10)
  enemys.push pos:{x: -worldEdge.x+2, y: -6 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: -3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 0 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 6 }, mx: 1, my:0

moveEnemy = ->
  for enemy, ei in enemys
    e = enemy.pos
    setDot e.x, e.y, 0
    setDot e.x-1, e.y, 0
    setDot e.x+1, e.y, 0
    setDot e.x, e.y+1, 0
    setDot e.x, e.y-1, 0


    if Math.abs(e.x) > worldEdge.x
      e.x = -e.x
    if Math.abs(e.y) > worldEdge.y
      e.y = -e.y

    if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        x = enemy.mx
        enemy.mx = enemy.my
        enemy.my = x
    else if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        enemy.mx *= -1
        enemy.my *= -1

    e.x += enemy.mx
    e.y += enemy.my

    setDot e.x, e.y, 8
    setDot e.x-1, e.y, 6
    setDot e.x+1, e.y, 6
    setDot e.x, e.y+1, 6
    setDot e.x, e.y-1, 6

    if gameTick%41 == 40 && level>=1
      setDot e.x-enemy.mx*2, e.y-enemy.my*2, 7

drawDot = (x, y, col)->
  canvasX = (x+cx)*pieceSizeW
  canvasY = (y+cy)*pieceSizeH
  if canvasX<-pieceSizeW || canvasX > W || canvasY<-pieceSizeH || canvasY > H then return# c.l 'DRAW_DOT ERROR', canvasX, canvasY, x, y
  ctx.fillStyle = '#'+col
  ctx.fillRect .25+canvasX, .25+canvasY, pieceSizeW-.5, pieceSizeH-.5

drawShip = (dir)->
  for xy in shipDirDots[dir]
    drawDot xy[0], xy[1], shipColor

drawBorder = ->
  if shipPos.x+cx > worldEdge.x
    borderStartX = W-(shipPos.x+cx-worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect borderStartX, 0, W, H
  if shipPos.x-cx < -worldEdge.x
    borderStartX = -(shipPos.x-cx+worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, borderStartX, H
  if shipPos.y+cy > worldEdge.y
    borderStartY = W-(shipPos.y+cy-worldEdge.y)*pieceSizeH
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, borderStartY, W, H
  if shipPos.y-cy < -worldEdge.y
    borderStartY = -(shipPos.y-cy+worldEdge.y)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, W, borderStartY

drawStats = ->
  fontSize = (W/35)
  ctx.fillStyle = '#fff'
  ctx.font = fontSize+'px c64';
  ctx.fillText('HIGHSCORE: '+highscore, 6, 4+fontSize)
  ctx.fillText('SCORE: '+score, 6, 4+fontSize*2)
  ctx.fillText('LEVEL: '+level, 6, 4+fontSize*3)

drawDots = -> # Draw visible dots
  if worldEdge.x*2<gameRes
    maxX = worldEdge.x
    startX = -worldEdge.x-shipPos.x
    endX = worldEdge.x-shipPos.x
    startY = -worldEdge.y-shipPos.y
    endY = worldEdge.y-shipPos.y
  else
    maxX = (Math.round gameRes/2)
    startX = startY = -maxX
    endX = endY = maxX

  for x in [startX...endX]#[Math.floor(-(gameRes/2))...(gameRes/2)]
    posX = x+shipPos.x
    for y in [startY...endY] # [Math.floor(-(gameRes/2))...(gameRes/2)]
      posY = shipPos.y+y
      dot = getDot posX, posY
      if dot>0
        col =
          if dot==1 then shipTrailColor
          else if dot==6 then enemyColor
          else if dot==7 then enemyTrailColor
          else if dot==8 then enemyBodyColor
          else if dot==10 then bonusPointsColor
          else if dot==25 then 'f00'
          else if dot>=50 && dot<64
            dot += 1
            setDot posX, posY, dot
            col = (0xfff-((dot-50)*0x111)).toString(16)

          else if dot>=64
            setDot posX, posY, 0
            '000'
          else 'fff'
        drawDot x, y, col

getDot = (x, y)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  #if x<0 || x>=gameRes || y<0 || y>=gameRes then return# c.l 'getDot Out of bound',x,y
  dots[ x+(y*worldEdge.x*2) ]

setDot = (x, y, type)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  if x<0 || x >= worldEdge.x*2 || y<0 || y >= worldEdge.x*2 then return false# c.l 'setDot Out of bound',x,y
  dots[ x+(y*(worldEdge.x)*2) ] = type

getRandomDot = (saveArea)->
  x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
  y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
  maxTries = 128
  saveArea = saveArea||0
  tries = 0
  while x > -saveArea && x < saveArea && y > -saveArea && y < saveArea && getDot(x,y)==0
    tries++
    x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
    y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
    if tries > maxTries then return c.l 'getRandomDot overload'
  x:x, y:y

placeRandomDots = (amount, saveArea, id)->
  amount = amount||100
  saveArea = saveArea||worldEdge.x*.6
  while amount--
    dot = getRandomDot saveArea
    setDot dot.x, dot.y, id||10

checkCollision = ->
  # check collision with dot
  for sp in shipDirDots[dir]
    dot = getDot(sp[0]+shipPos.x, sp[1]+shipPos.y)
    if dot>0
      c.l dot
      if dot==10
        score += 100*(level+1)
        setDot(sp[0]+shipPos.x, sp[1]+shipPos.y, 0)
        placeRandomDots(1, 1)
      else killed--

  # check collision with wall
checkBorderCollision = ->
  if shipPos.x >= worldEdge.x
    shipPos.x = -worldEdge.x
  else if shipPos.x < -worldEdge.x
    shipPos.x = worldEdge.x-1

  if shipPos.y >= worldEdge.y
    shipPos.y = -worldEdge.x
  else if shipPos.y < -worldEdge.y
    shipPos.y = worldEdge.x-1

checkLevel = ->
  if score>1000 && level==0
    level++
    aniSpeed -= 2
  else if score>2500 && level==1
    level++
    gameRes -= 8
    setGameRes()
  else if score>5000 && level==2
    level++
    gameRes -= 8
    setGameRes()
  else if score>10000 && level==3
    level++
    gameRes -= 4
    setGameRes()
  else if score>20000 && level==4
    level++
    gameRes -= 2
    setGameRes()
  else if score>30000 && level==5
    level++
    gameRes -= 2
    setGameRes()
  else if score>45000 && level==6
    level++
    gameRes -= 2
    setGameRes()
  else if score>65000 && level==7
    level++
    gameRes -= 2
    setGameRes()
  else if score>80000 && level==8
    level++
    gameRes -= 2
    setGameRes()
  else if score>10000 && level==9
    level++
    aniSpeed -= 1

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

# requestAnimationFrame polyfill by Erik Möller. fixes from Paul Irish and Tino Zijdel
# MIT license

do ->
  lastTime = 0
  vendors = [ 'ms', 'moz', 'webkit', 'o' ]
  x = 0
  while x < vendors.length and !window.requestAnimationFrame
    window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame']
    window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] or window[vendors[x] + 'CancelRequestAnimationFrame']
    ++x
  if !window.requestAnimationFrame

    window.requestAnimationFrame = (callback, element) ->
      currTime = (new Date).getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      id = window.setTimeout((->
        callback currTime + timeToCall
        return
      ), timeToCall)
      lastTime = currTime + timeToCall
      id

  if !window.cancelAnimationFrame

    window.cancelAnimationFrame = (id) ->
      clearTimeout id
      return
  return


window.onload = ->
  addEventListeners()
  initCanvas()
  startGame()

pieceSizeW = W / gameRes
pieceSizeH = H / gameRes

killed = false

cx = (gameRes/2)
cy = (gameRes/2)

shipPos = x:0, y:0
shipVel = x:0, y:0
dir = 0
keysPressed = ["w"]
score = 0
highscore = 0
gameRes = 0
aniSpeed = 666
level = 0

gameTick = 0

startRes = 60

worldEdge = x: 127, y: 127
dots = new Uint8Array worldEdge.x*2*worldEdge.y*2
shipDirDots = null

shipColor = 'b0ec51'
shipTrailColor = '598e07'

enemyColor = '8333a5'
enemyBodyColor = 'ac61cc'
enemyTrailColor = '3e49d2'

bonusPointsColor = 'e4cc1f'

wallColor = '20363e'

shipDirDots = [
  [
    [-1, 0], [0, 0], [+1, 0], [0, -1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0+1, 0]
  ], [
    [0-1, 0], [0, 0], [0+1, 0], [0, 0+1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0-1, 0]
  ]
]

killPlayer = (i)->
  i = i||0

  clearCanvas()
  drawDots()
  drawBorder()

  if i<Math.sqrt(gameRes*gameRes+gameRes*gameRes)/2
    drawDot 0+i, 0+i, shipColor
    drawDot 0-i, 0-i, shipColor
    drawDot 0+i, 0-i, shipColor
    drawDot 0-i, 0+i, shipColor
    i++
    requestAnimationFrame (-> killPlayer(i))
  else
    highscore = Math.max score, highscore
    score = 0
    startGame()

startGame = ->
  shipPos = x:0, y:19
  shipVel = x:0, y:0
  dir = 0
  keysPressed = ['w']

  dots = new Uint8Array worldEdge.x*2*worldEdge.y*2

  killed = false

  worldEdge.x = 31 # must be uneven
  worldEdge.y = 31 # must be uneven
  gameRes = 5
  aniSpeed = 14
  level = 0
  lasers = 10

  getEnemys(4)
  moveEnemy()
  setGameRes()
  placeRandomDots(10)
  nextFrame()


setGameRes = ->
  pieceSizeW = W / gameRes
  pieceSizeH = H / gameRes

  cx = gameRes/2
  cy = gameRes/2


checkKeysPressed = ()->
  k = keysPressed.shift()
  if k
    if k=='w'
      shipVel = x:0, y:-1
      dir = 0
    else if k=='d'
      shipVel = x:1, y:0
      dir = 1
    else if k=='s'
      shipVel = x:0, y:1
      dir = 2
    else if k=='a'
      shipVel = x:-1, y:0
      dir = 3

aniCnt = aniSpeed

nextFrame = ->
  if aniCnt<aniSpeed
    aniCnt++
    return requestAnimationFrame nextFrame
  else aniCnt = 0

  aniSpeed -= 1 if aniSpeed>5

  if gameRes < startRes && level==0
    gameRes += 4
    setGameRes()

  checkKeysPressed()

  shipPos.x += shipVel.x
  shipPos.y += shipVel.y


  checkCollision()
  checkBorderCollision()

  moveEnemy()
  checkCollision()


  checkLevel()

  clearCanvas()

  drawDots()
  drawBorder()
  drawShip(dir)

  drawStats()



  #setDot shipPos.x, shipPos.y, 1

  if Math.random()<.05 then placeRandomDots(1, 1)

  score += 1+level
  gameTick++

  if killed==false
    requestAnimationFrame nextFrame
  else
    killPlayer()


addEventListeners = ->
  d.body.addEventListener 'keydown', (e)->
    if (e.key=='w' || e.key=='d' || e.key=='s' || e.key=='a') && e.key != keysPressed[keysPressed.length-1]
      keysPressed.push e.key

enemys = []

getEnemys = (cnt)->
  enemys = []
  # for i in [0..cnt]
  #   m = if Math.random()>.5 then 1 else -1
  #   if Math.random()>.5
  #     mx = m
  #     my = 0
  #   else
  #     mx = 0
  #     my = m
  #   pos = getRandomDot(worldEdge.x/10)
  enemys.push pos:{x: -worldEdge.x+2, y: -6 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: -3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 0 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 6 }, mx: 1, my:0

moveEnemy = ->
  for enemy, ei in enemys
    e = enemy.pos
    setDot e.x, e.y, 0
    setDot e.x-1, e.y, 0
    setDot e.x+1, e.y, 0
    setDot e.x, e.y+1, 0
    setDot e.x, e.y-1, 0


    if Math.abs(e.x) > worldEdge.x
      e.x = -e.x
    if Math.abs(e.y) > worldEdge.y
      e.y = -e.y

    if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        x = enemy.mx
        enemy.mx = enemy.my
        enemy.my = x
    else if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        enemy.mx *= -1
        enemy.my *= -1

    e.x += enemy.mx
    e.y += enemy.my

    setDot e.x, e.y, 8
    setDot e.x-1, e.y, 6
    setDot e.x+1, e.y, 6
    setDot e.x, e.y+1, 6
    setDot e.x, e.y-1, 6

    if gameTick%41 == 40 && level>=1
      setDot e.x-enemy.mx*2, e.y-enemy.my*2, 7

drawDot = (x, y, col)->
  canvasX = (x+cx)*pieceSizeW
  canvasY = (y+cy)*pieceSizeH
  if canvasX<-pieceSizeW || canvasX > W || canvasY<-pieceSizeH || canvasY > H then return# c.l 'DRAW_DOT ERROR', canvasX, canvasY, x, y
  ctx.fillStyle = '#'+col
  ctx.fillRect .25+canvasX, .25+canvasY, pieceSizeW-.5, pieceSizeH-.5

drawShip = (dir)->
  for xy in shipDirDots[dir]
    drawDot xy[0], xy[1], shipColor

drawBorder = ->
  if shipPos.x+cx > worldEdge.x
    borderStartX = W-(shipPos.x+cx-worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect borderStartX, 0, W, H
  if shipPos.x-cx < -worldEdge.x
    borderStartX = -(shipPos.x-cx+worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, borderStartX, H
  if shipPos.y+cy > worldEdge.y
    borderStartY = W-(shipPos.y+cy-worldEdge.y)*pieceSizeH
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, borderStartY, W, H
  if shipPos.y-cy < -worldEdge.y
    borderStartY = -(shipPos.y-cy+worldEdge.y)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, W, borderStartY

drawStats = ->
  fontSize = (W/35)
  ctx.fillStyle = '#fff'
  ctx.font = fontSize+'px c64';
  ctx.fillText('HIGHSCORE: '+highscore, 6, 4+fontSize)
  ctx.fillText('SCORE: '+score, 6, 4+fontSize*2)
  ctx.fillText('LEVEL: '+level, 6, 4+fontSize*3)

drawDots = -> # Draw visible dots
  if worldEdge.x*2<gameRes
    maxX = worldEdge.x
    startX = -worldEdge.x-shipPos.x
    endX = worldEdge.x-shipPos.x
    startY = -worldEdge.y-shipPos.y
    endY = worldEdge.y-shipPos.y
  else
    maxX = (Math.round gameRes/2)
    startX = startY = -maxX
    endX = endY = maxX

  for x in [startX...endX]#[Math.floor(-(gameRes/2))...(gameRes/2)]
    posX = x+shipPos.x
    for y in [startY...endY] # [Math.floor(-(gameRes/2))...(gameRes/2)]
      posY = shipPos.y+y
      dot = getDot posX, posY
      if dot>0
        col =
          if dot==1 then shipTrailColor
          else if dot==6 then enemyColor
          else if dot==7 then enemyTrailColor
          else if dot==8 then enemyBodyColor
          else if dot==10 then bonusPointsColor
          else if dot==25 then 'f00'
          else if dot>=50 && dot<64
            dot += 1
            setDot posX, posY, dot
            col = (0xfff-((dot-50)*0x111)).toString(16)

          else if dot>=64
            setDot posX, posY, 0
            '000'
          else 'fff'
        drawDot x, y, col

getDot = (x, y)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  #if x<0 || x>=gameRes || y<0 || y>=gameRes then return# c.l 'getDot Out of bound',x,y
  dots[ x+(y*worldEdge.x*2) ]

setDot = (x, y, type)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  if x<0 || x >= worldEdge.x*2 || y<0 || y >= worldEdge.x*2 then return false# c.l 'setDot Out of bound',x,y
  dots[ x+(y*(worldEdge.x)*2) ] = type

getRandomDot = (saveArea)->
  x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
  y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
  maxTries = 128
  saveArea = saveArea||0
  tries = 0
  while x > -saveArea && x < saveArea && y > -saveArea && y < saveArea && getDot(x,y)==0
    tries++
    x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
    y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
    if tries > maxTries then return c.l 'getRandomDot overload'
  x:x, y:y

placeRandomDots = (amount, saveArea, id)->
  amount = amount||100
  saveArea = saveArea||worldEdge.x*.6
  while amount--
    dot = getRandomDot saveArea
    setDot dot.x, dot.y, id||10

checkCollision = ->
  # check collision with dot
  for sp in shipDirDots[dir]
    dot = getDot(sp[0]+shipPos.x, sp[1]+shipPos.y)
    if dot>0
      c.l dot
      if dot==10
        score += 100*(level+1)
        setDot(sp[0]+shipPos.x, sp[1]+shipPos.y, 0)
        placeRandomDots(1, 1)
      else killed--

  # check collision with wall
checkBorderCollision = ->
  if shipPos.x >= worldEdge.x
    shipPos.x = -worldEdge.x
  else if shipPos.x < -worldEdge.x
    shipPos.x = worldEdge.x-1

  if shipPos.y >= worldEdge.y
    shipPos.y = -worldEdge.x
  else if shipPos.y < -worldEdge.y
    shipPos.y = worldEdge.x-1

checkLevel = ->
  if score>1000 && level==0
    level++
    aniSpeed -= 2
  else if score>2500 && level==1
    level++
    gameRes -= 8
    setGameRes()
  else if score>5000 && level==2
    level++
    gameRes -= 8
    setGameRes()
  else if score>10000 && level==3
    level++
    gameRes -= 4
    setGameRes()
  else if score>20000 && level==4
    level++
    gameRes -= 2
    setGameRes()
  else if score>30000 && level==5
    level++
    gameRes -= 2
    setGameRes()
  else if score>45000 && level==6
    level++
    gameRes -= 2
    setGameRes()
  else if score>65000 && level==7
    level++
    gameRes -= 2
    setGameRes()
  else if score>80000 && level==8
    level++
    gameRes -= 2
    setGameRes()
  else if score>10000 && level==9
    level++
    aniSpeed -= 1

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

# requestAnimationFrame polyfill by Erik Möller. fixes from Paul Irish and Tino Zijdel
# MIT license

do ->
  lastTime = 0
  vendors = [ 'ms', 'moz', 'webkit', 'o' ]
  x = 0
  while x < vendors.length and !window.requestAnimationFrame
    window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame']
    window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] or window[vendors[x] + 'CancelRequestAnimationFrame']
    ++x
  if !window.requestAnimationFrame

    window.requestAnimationFrame = (callback, element) ->
      currTime = (new Date).getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      id = window.setTimeout((->
        callback currTime + timeToCall
        return
      ), timeToCall)
      lastTime = currTime + timeToCall
      id

  if !window.cancelAnimationFrame

    window.cancelAnimationFrame = (id) ->
      clearTimeout id
      return
  return


window.onload = ->
  addEventListeners()
  initCanvas()
  startGame()

pieceSizeW = W / gameRes
pieceSizeH = H / gameRes

killed = false

cx = (gameRes/2)
cy = (gameRes/2)

shipPos = x:0, y:0
shipVel = x:0, y:0
dir = 0
keysPressed = ["w"]
score = 0
highscore = 0
gameRes = 0
aniSpeed = 666
level = 0

gameTick = 0

startRes = 60

worldEdge = x: 127, y: 127
dots = new Uint8Array worldEdge.x*2*worldEdge.y*2
shipDirDots = null

shipColor = 'b0ec51'
shipTrailColor = '598e07'

enemyColor = '8333a5'
enemyBodyColor = 'ac61cc'
enemyTrailColor = '3e49d2'

bonusPointsColor = 'e4cc1f'

wallColor = '20363e'

shipDirDots = [
  [
    [-1, 0], [0, 0], [+1, 0], [0, -1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0+1, 0]
  ], [
    [0-1, 0], [0, 0], [0+1, 0], [0, 0+1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0-1, 0]
  ]
]

killPlayer = (i)->
  i = i||0

  clearCanvas()
  drawDots()
  drawBorder()

  if i<Math.sqrt(gameRes*gameRes+gameRes*gameRes)/2
    drawDot 0+i, 0+i, shipColor
    drawDot 0-i, 0-i, shipColor
    drawDot 0+i, 0-i, shipColor
    drawDot 0-i, 0+i, shipColor
    i++
    requestAnimationFrame (-> killPlayer(i))
  else
    highscore = Math.max score, highscore
    score = 0
    startGame()

startGame = ->
  shipPos = x:0, y:19
  shipVel = x:0, y:0
  dir = 0
  keysPressed = ['w']

  dots = new Uint8Array worldEdge.x*2*worldEdge.y*2

  killed = false

  worldEdge.x = 31 # must be uneven
  worldEdge.y = 31 # must be uneven
  gameRes = 5
  aniSpeed = 14
  level = 0
  lasers = 10

  getEnemys(4)
  moveEnemy()
  setGameRes()
  placeRandomDots(10)
  nextFrame()


setGameRes = ->
  pieceSizeW = W / gameRes
  pieceSizeH = H / gameRes

  cx = gameRes/2
  cy = gameRes/2


checkKeysPressed = ()->
  k = keysPressed.shift()
  if k
    if k=='w'
      shipVel = x:0, y:-1
      dir = 0
    else if k=='d'
      shipVel = x:1, y:0
      dir = 1
    else if k=='s'
      shipVel = x:0, y:1
      dir = 2
    else if k=='a'
      shipVel = x:-1, y:0
      dir = 3

aniCnt = aniSpeed

nextFrame = ->
  if aniCnt<aniSpeed
    aniCnt++
    return requestAnimationFrame nextFrame
  else aniCnt = 0

  aniSpeed -= 1 if aniSpeed>5

  if gameRes < startRes && level==0
    gameRes += 4
    setGameRes()

  checkKeysPressed()

  shipPos.x += shipVel.x
  shipPos.y += shipVel.y


  checkCollision()
  checkBorderCollision()

  moveEnemy()
  checkCollision()


  checkLevel()

  clearCanvas()

  drawDots()
  drawBorder()
  drawShip(dir)

  drawStats()



  #setDot shipPos.x, shipPos.y, 1

  if Math.random()<.05 then placeRandomDots(1, 1)

  score += 1+level
  gameTick++

  if killed==false
    requestAnimationFrame nextFrame
  else
    killPlayer()


addEventListeners = ->
  d.body.addEventListener 'keydown', (e)->
    if (e.key=='w' || e.key=='d' || e.key=='s' || e.key=='a') && e.key != keysPressed[keysPressed.length-1]
      keysPressed.push e.key

enemys = []

getEnemys = (cnt)->
  enemys = []
  # for i in [0..cnt]
  #   m = if Math.random()>.5 then 1 else -1
  #   if Math.random()>.5
  #     mx = m
  #     my = 0
  #   else
  #     mx = 0
  #     my = m
  #   pos = getRandomDot(worldEdge.x/10)
  enemys.push pos:{x: -worldEdge.x+2, y: -6 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: -3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 0 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 6 }, mx: 1, my:0

moveEnemy = ->
  for enemy, ei in enemys
    e = enemy.pos
    setDot e.x, e.y, 0
    setDot e.x-1, e.y, 0
    setDot e.x+1, e.y, 0
    setDot e.x, e.y+1, 0
    setDot e.x, e.y-1, 0


    if Math.abs(e.x) > worldEdge.x
      e.x = -e.x
    if Math.abs(e.y) > worldEdge.y
      e.y = -e.y

    if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        x = enemy.mx
        enemy.mx = enemy.my
        enemy.my = x
    else if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        enemy.mx *= -1
        enemy.my *= -1

    e.x += enemy.mx
    e.y += enemy.my

    setDot e.x, e.y, 8
    setDot e.x-1, e.y, 6
    setDot e.x+1, e.y, 6
    setDot e.x, e.y+1, 6
    setDot e.x, e.y-1, 6

    if gameTick%41 == 40 && level>=1
      setDot e.x-enemy.mx*2, e.y-enemy.my*2, 7

drawDot = (x, y, col)->
  canvasX = (x+cx)*pieceSizeW
  canvasY = (y+cy)*pieceSizeH
  if canvasX<-pieceSizeW || canvasX > W || canvasY<-pieceSizeH || canvasY > H then return# c.l 'DRAW_DOT ERROR', canvasX, canvasY, x, y
  ctx.fillStyle = '#'+col
  ctx.fillRect .25+canvasX, .25+canvasY, pieceSizeW-.5, pieceSizeH-.5

drawShip = (dir)->
  for xy in shipDirDots[dir]
    drawDot xy[0], xy[1], shipColor

drawBorder = ->
  if shipPos.x+cx > worldEdge.x
    borderStartX = W-(shipPos.x+cx-worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect borderStartX, 0, W, H
  if shipPos.x-cx < -worldEdge.x
    borderStartX = -(shipPos.x-cx+worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, borderStartX, H
  if shipPos.y+cy > worldEdge.y
    borderStartY = W-(shipPos.y+cy-worldEdge.y)*pieceSizeH
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, borderStartY, W, H
  if shipPos.y-cy < -worldEdge.y
    borderStartY = -(shipPos.y-cy+worldEdge.y)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, W, borderStartY

drawStats = ->
  fontSize = (W/35)
  ctx.fillStyle = '#fff'
  ctx.font = fontSize+'px c64';
  ctx.fillText('HIGHSCORE: '+highscore, 6, 4+fontSize)
  ctx.fillText('SCORE: '+score, 6, 4+fontSize*2)
  ctx.fillText('LEVEL: '+level, 6, 4+fontSize*3)

drawDots = -> # Draw visible dots
  if worldEdge.x*2<gameRes
    maxX = worldEdge.x
    startX = -worldEdge.x-shipPos.x
    endX = worldEdge.x-shipPos.x
    startY = -worldEdge.y-shipPos.y
    endY = worldEdge.y-shipPos.y
  else
    maxX = (Math.round gameRes/2)
    startX = startY = -maxX
    endX = endY = maxX

  for x in [startX...endX]#[Math.floor(-(gameRes/2))...(gameRes/2)]
    posX = x+shipPos.x
    for y in [startY...endY] # [Math.floor(-(gameRes/2))...(gameRes/2)]
      posY = shipPos.y+y
      dot = getDot posX, posY
      if dot>0
        col =
          if dot==1 then shipTrailColor
          else if dot==6 then enemyColor
          else if dot==7 then enemyTrailColor
          else if dot==8 then enemyBodyColor
          else if dot==10 then bonusPointsColor
          else if dot==25 then 'f00'
          else if dot>=50 && dot<64
            dot += 1
            setDot posX, posY, dot
            col = (0xfff-((dot-50)*0x111)).toString(16)

          else if dot>=64
            setDot posX, posY, 0
            '000'
          else 'fff'
        drawDot x, y, col

getDot = (x, y)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  #if x<0 || x>=gameRes || y<0 || y>=gameRes then return# c.l 'getDot Out of bound',x,y
  dots[ x+(y*worldEdge.x*2) ]

setDot = (x, y, type)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  if x<0 || x >= worldEdge.x*2 || y<0 || y >= worldEdge.x*2 then return false# c.l 'setDot Out of bound',x,y
  dots[ x+(y*(worldEdge.x)*2) ] = type

getRandomDot = (saveArea)->
  x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
  y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
  maxTries = 128
  saveArea = saveArea||0
  tries = 0
  while x > -saveArea && x < saveArea && y > -saveArea && y < saveArea && getDot(x,y)==0
    tries++
    x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
    y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
    if tries > maxTries then return c.l 'getRandomDot overload'
  x:x, y:y

placeRandomDots = (amount, saveArea, id)->
  amount = amount||100
  saveArea = saveArea||worldEdge.x*.6
  while amount--
    dot = getRandomDot saveArea
    setDot dot.x, dot.y, id||10

checkCollision = ->
  # check collision with dot
  for sp in shipDirDots[dir]
    dot = getDot(sp[0]+shipPos.x, sp[1]+shipPos.y)
    if dot>0
      c.l dot
      if dot==10
        score += 100*(level+1)
        setDot(sp[0]+shipPos.x, sp[1]+shipPos.y, 0)
        placeRandomDots(1, 1)
      else killed--

  # check collision with wall
checkBorderCollision = ->
  if shipPos.x >= worldEdge.x
    shipPos.x = -worldEdge.x
  else if shipPos.x < -worldEdge.x
    shipPos.x = worldEdge.x-1

  if shipPos.y >= worldEdge.y
    shipPos.y = -worldEdge.x
  else if shipPos.y < -worldEdge.y
    shipPos.y = worldEdge.x-1

checkLevel = ->
  if score>1000 && level==0
    level++
    aniSpeed -= 2
  else if score>2500 && level==1
    level++
    gameRes -= 8
    setGameRes()
  else if score>5000 && level==2
    level++
    gameRes -= 8
    setGameRes()
  else if score>10000 && level==3
    level++
    gameRes -= 4
    setGameRes()
  else if score>20000 && level==4
    level++
    gameRes -= 2
    setGameRes()
  else if score>30000 && level==5
    level++
    gameRes -= 2
    setGameRes()
  else if score>45000 && level==6
    level++
    gameRes -= 2
    setGameRes()
  else if score>65000 && level==7
    level++
    gameRes -= 2
    setGameRes()
  else if score>80000 && level==8
    level++
    gameRes -= 2
    setGameRes()
  else if score>10000 && level==9
    level++
    aniSpeed -= 1

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

# requestAnimationFrame polyfill by Erik Möller. fixes from Paul Irish and Tino Zijdel
# MIT license

do ->
  lastTime = 0
  vendors = [ 'ms', 'moz', 'webkit', 'o' ]
  x = 0
  while x < vendors.length and !window.requestAnimationFrame
    window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame']
    window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] or window[vendors[x] + 'CancelRequestAnimationFrame']
    ++x
  if !window.requestAnimationFrame

    window.requestAnimationFrame = (callback, element) ->
      currTime = (new Date).getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      id = window.setTimeout((->
        callback currTime + timeToCall
        return
      ), timeToCall)
      lastTime = currTime + timeToCall
      id

  if !window.cancelAnimationFrame

    window.cancelAnimationFrame = (id) ->
      clearTimeout id
      return
  return


window.onload = ->
  addEventListeners()
  initCanvas()
  startGame()

pieceSizeW = W / gameRes
pieceSizeH = H / gameRes

killed = false

cx = (gameRes/2)
cy = (gameRes/2)

shipPos = x:0, y:0
shipVel = x:0, y:0
dir = 0
keysPressed = ["w"]
score = 0
highscore = 0
gameRes = 0
aniSpeed = 666
level = 0

gameTick = 0

startRes = 60

worldEdge = x: 127, y: 127
dots = new Uint8Array worldEdge.x*2*worldEdge.y*2
shipDirDots = null

shipColor = 'b0ec51'
shipTrailColor = '598e07'

enemyColor = '8333a5'
enemyBodyColor = 'ac61cc'
enemyTrailColor = '3e49d2'

bonusPointsColor = 'e4cc1f'

wallColor = '20363e'

shipDirDots = [
  [
    [-1, 0], [0, 0], [+1, 0], [0, -1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0+1, 0]
  ], [
    [0-1, 0], [0, 0], [0+1, 0], [0, 0+1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0-1, 0]
  ]
]

killPlayer = (i)->
  i = i||0

  clearCanvas()
  drawDots()
  drawBorder()

  if i<Math.sqrt(gameRes*gameRes+gameRes*gameRes)/2
    drawDot 0+i, 0+i, shipColor
    drawDot 0-i, 0-i, shipColor
    drawDot 0+i, 0-i, shipColor
    drawDot 0-i, 0+i, shipColor
    i++
    requestAnimationFrame (-> killPlayer(i))
  else
    highscore = Math.max score, highscore
    score = 0
    startGame()

startGame = ->
  shipPos = x:0, y:19
  shipVel = x:0, y:0
  dir = 0
  keysPressed = ['w']

  dots = new Uint8Array worldEdge.x*2*worldEdge.y*2

  killed = false

  worldEdge.x = 31 # must be uneven
  worldEdge.y = 31 # must be uneven
  gameRes = 5
  aniSpeed = 14
  level = 0
  lasers = 10

  getEnemys(4)
  moveEnemy()
  setGameRes()
  placeRandomDots(10)
  nextFrame()


setGameRes = ->
  pieceSizeW = W / gameRes
  pieceSizeH = H / gameRes

  cx = gameRes/2
  cy = gameRes/2


checkKeysPressed = ()->
  k = keysPressed.shift()
  if k
    if k=='w'
      shipVel = x:0, y:-1
      dir = 0
    else if k=='d'
      shipVel = x:1, y:0
      dir = 1
    else if k=='s'
      shipVel = x:0, y:1
      dir = 2
    else if k=='a'
      shipVel = x:-1, y:0
      dir = 3

aniCnt = aniSpeed

nextFrame = ->
  if aniCnt<aniSpeed
    aniCnt++
    return requestAnimationFrame nextFrame
  else aniCnt = 0

  aniSpeed -= 1 if aniSpeed>5

  if gameRes < startRes && level==0
    gameRes += 4
    setGameRes()

  checkKeysPressed()

  shipPos.x += shipVel.x
  shipPos.y += shipVel.y


  checkCollision()
  checkBorderCollision()

  moveEnemy()
  checkCollision()


  checkLevel()

  clearCanvas()

  drawDots()
  drawBorder()
  drawShip(dir)

  drawStats()



  #setDot shipPos.x, shipPos.y, 1

  if Math.random()<.05 then placeRandomDots(1, 1)

  score += 1+level
  gameTick++

  if killed==false
    requestAnimationFrame nextFrame
  else
    killPlayer()


addEventListeners = ->
  d.body.addEventListener 'keydown', (e)->
    if (e.key=='w' || e.key=='d' || e.key=='s' || e.key=='a') && e.key != keysPressed[keysPressed.length-1]
      keysPressed.push e.key

enemys = []

getEnemys = (cnt)->
  enemys = []
  # for i in [0..cnt]
  #   m = if Math.random()>.5 then 1 else -1
  #   if Math.random()>.5
  #     mx = m
  #     my = 0
  #   else
  #     mx = 0
  #     my = m
  #   pos = getRandomDot(worldEdge.x/10)
  enemys.push pos:{x: -worldEdge.x+2, y: -6 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: -3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 0 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 6 }, mx: 1, my:0

moveEnemy = ->
  for enemy, ei in enemys
    e = enemy.pos
    setDot e.x, e.y, 0
    setDot e.x-1, e.y, 0
    setDot e.x+1, e.y, 0
    setDot e.x, e.y+1, 0
    setDot e.x, e.y-1, 0


    if Math.abs(e.x) > worldEdge.x
      e.x = -e.x
    if Math.abs(e.y) > worldEdge.y
      e.y = -e.y

    if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        x = enemy.mx
        enemy.mx = enemy.my
        enemy.my = x
    else if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        enemy.mx *= -1
        enemy.my *= -1

    e.x += enemy.mx
    e.y += enemy.my

    setDot e.x, e.y, 8
    setDot e.x-1, e.y, 6
    setDot e.x+1, e.y, 6
    setDot e.x, e.y+1, 6
    setDot e.x, e.y-1, 6

    if gameTick%41 == 40 && level>=1
      setDot e.x-enemy.mx*2, e.y-enemy.my*2, 7

drawDot = (x, y, col)->
  canvasX = (x+cx)*pieceSizeW
  canvasY = (y+cy)*pieceSizeH
  if canvasX<-pieceSizeW || canvasX > W || canvasY<-pieceSizeH || canvasY > H then return# c.l 'DRAW_DOT ERROR', canvasX, canvasY, x, y
  ctx.fillStyle = '#'+col
  ctx.fillRect .25+canvasX, .25+canvasY, pieceSizeW-.5, pieceSizeH-.5

drawShip = (dir)->
  for xy in shipDirDots[dir]
    drawDot xy[0], xy[1], shipColor

drawBorder = ->
  if shipPos.x+cx > worldEdge.x
    borderStartX = W-(shipPos.x+cx-worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect borderStartX, 0, W, H
  if shipPos.x-cx < -worldEdge.x
    borderStartX = -(shipPos.x-cx+worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, borderStartX, H
  if shipPos.y+cy > worldEdge.y
    borderStartY = W-(shipPos.y+cy-worldEdge.y)*pieceSizeH
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, borderStartY, W, H
  if shipPos.y-cy < -worldEdge.y
    borderStartY = -(shipPos.y-cy+worldEdge.y)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, W, borderStartY

drawStats = ->
  fontSize = (W/35)
  ctx.fillStyle = '#fff'
  ctx.font = fontSize+'px c64';
  ctx.fillText('HIGHSCORE: '+highscore, 6, 4+fontSize)
  ctx.fillText('SCORE: '+score, 6, 4+fontSize*2)
  ctx.fillText('LEVEL: '+level, 6, 4+fontSize*3)

drawDots = -> # Draw visible dots
  if worldEdge.x*2<gameRes
    maxX = worldEdge.x
    startX = -worldEdge.x-shipPos.x
    endX = worldEdge.x-shipPos.x
    startY = -worldEdge.y-shipPos.y
    endY = worldEdge.y-shipPos.y
  else
    maxX = (Math.round gameRes/2)
    startX = startY = -maxX
    endX = endY = maxX

  for x in [startX...endX]#[Math.floor(-(gameRes/2))...(gameRes/2)]
    posX = x+shipPos.x
    for y in [startY...endY] # [Math.floor(-(gameRes/2))...(gameRes/2)]
      posY = shipPos.y+y
      dot = getDot posX, posY
      if dot>0
        col =
          if dot==1 then shipTrailColor
          else if dot==6 then enemyColor
          else if dot==7 then enemyTrailColor
          else if dot==8 then enemyBodyColor
          else if dot==10 then bonusPointsColor
          else if dot==25 then 'f00'
          else if dot>=50 && dot<64
            dot += 1
            setDot posX, posY, dot
            col = (0xfff-((dot-50)*0x111)).toString(16)

          else if dot>=64
            setDot posX, posY, 0
            '000'
          else 'fff'
        drawDot x, y, col

getDot = (x, y)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  #if x<0 || x>=gameRes || y<0 || y>=gameRes then return# c.l 'getDot Out of bound',x,y
  dots[ x+(y*worldEdge.x*2) ]

setDot = (x, y, type)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  if x<0 || x >= worldEdge.x*2 || y<0 || y >= worldEdge.x*2 then return false# c.l 'setDot Out of bound',x,y
  dots[ x+(y*(worldEdge.x)*2) ] = type

getRandomDot = (saveArea)->
  x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
  y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
  maxTries = 128
  saveArea = saveArea||0
  tries = 0
  while x > -saveArea && x < saveArea && y > -saveArea && y < saveArea && getDot(x,y)==0
    tries++
    x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
    y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
    if tries > maxTries then return c.l 'getRandomDot overload'
  x:x, y:y

placeRandomDots = (amount, saveArea, id)->
  amount = amount||100
  saveArea = saveArea||worldEdge.x*.6
  while amount--
    dot = getRandomDot saveArea
    setDot dot.x, dot.y, id||10

checkCollision = ->
  # check collision with dot
  for sp in shipDirDots[dir]
    dot = getDot(sp[0]+shipPos.x, sp[1]+shipPos.y)
    if dot>0
      c.l dot
      if dot==10
        score += 100*(level+1)
        setDot(sp[0]+shipPos.x, sp[1]+shipPos.y, 0)
        placeRandomDots(1, 1)
      else killed--

  # check collision with wall
checkBorderCollision = ->
  if shipPos.x >= worldEdge.x
    shipPos.x = -worldEdge.x
  else if shipPos.x < -worldEdge.x
    shipPos.x = worldEdge.x-1

  if shipPos.y >= worldEdge.y
    shipPos.y = -worldEdge.x
  else if shipPos.y < -worldEdge.y
    shipPos.y = worldEdge.x-1

checkLevel = ->
  if score>1000 && level==0
    level++
    aniSpeed -= 2
  else if score>2500 && level==1
    level++
    gameRes -= 8
    setGameRes()
  else if score>5000 && level==2
    level++
    gameRes -= 8
    setGameRes()
  else if score>10000 && level==3
    level++
    gameRes -= 4
    setGameRes()
  else if score>20000 && level==4
    level++
    gameRes -= 2
    setGameRes()
  else if score>30000 && level==5
    level++
    gameRes -= 2
    setGameRes()
  else if score>45000 && level==6
    level++
    gameRes -= 2
    setGameRes()
  else if score>65000 && level==7
    level++
    gameRes -= 2
    setGameRes()
  else if score>80000 && level==8
    level++
    gameRes -= 2
    setGameRes()
  else if score>10000 && level==9
    level++
    aniSpeed -= 1

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

# requestAnimationFrame polyfill by Erik Möller. fixes from Paul Irish and Tino Zijdel
# MIT license

do ->
  lastTime = 0
  vendors = [ 'ms', 'moz', 'webkit', 'o' ]
  x = 0
  while x < vendors.length and !window.requestAnimationFrame
    window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame']
    window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] or window[vendors[x] + 'CancelRequestAnimationFrame']
    ++x
  if !window.requestAnimationFrame

    window.requestAnimationFrame = (callback, element) ->
      currTime = (new Date).getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      id = window.setTimeout((->
        callback currTime + timeToCall
        return
      ), timeToCall)
      lastTime = currTime + timeToCall
      id

  if !window.cancelAnimationFrame

    window.cancelAnimationFrame = (id) ->
      clearTimeout id
      return
  return


window.onload = ->
  addEventListeners()
  initCanvas()
  startGame()

pieceSizeW = W / gameRes
pieceSizeH = H / gameRes

killed = false

cx = (gameRes/2)
cy = (gameRes/2)

shipPos = x:0, y:0
shipVel = x:0, y:0
dir = 0
keysPressed = ["w"]
score = 0
highscore = 0
gameRes = 0
aniSpeed = 666
level = 0

gameTick = 0

startRes = 60

worldEdge = x: 127, y: 127
dots = new Uint8Array worldEdge.x*2*worldEdge.y*2
shipDirDots = null

shipColor = 'b0ec51'
shipTrailColor = '598e07'

enemyColor = '8333a5'
enemyBodyColor = 'ac61cc'
enemyTrailColor = '3e49d2'

bonusPointsColor = 'e4cc1f'

wallColor = '20363e'

shipDirDots = [
  [
    [-1, 0], [0, 0], [+1, 0], [0, -1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0+1, 0]
  ], [
    [0-1, 0], [0, 0], [0+1, 0], [0, 0+1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0-1, 0]
  ]
]

killPlayer = (i)->
  i = i||0

  clearCanvas()
  drawDots()
  drawBorder()

  if i<Math.sqrt(gameRes*gameRes+gameRes*gameRes)/2
    drawDot 0+i, 0+i, shipColor
    drawDot 0-i, 0-i, shipColor
    drawDot 0+i, 0-i, shipColor
    drawDot 0-i, 0+i, shipColor
    i++
    requestAnimationFrame (-> killPlayer(i))
  else
    highscore = Math.max score, highscore
    score = 0
    startGame()

startGame = ->
  shipPos = x:0, y:19
  shipVel = x:0, y:0
  dir = 0
  keysPressed = ['w']

  dots = new Uint8Array worldEdge.x*2*worldEdge.y*2

  killed = false

  worldEdge.x = 31 # must be uneven
  worldEdge.y = 31 # must be uneven
  gameRes = 5
  aniSpeed = 14
  level = 0
  lasers = 10

  getEnemys(4)
  moveEnemy()
  setGameRes()
  placeRandomDots(10)
  nextFrame()


setGameRes = ->
  pieceSizeW = W / gameRes
  pieceSizeH = H / gameRes

  cx = gameRes/2
  cy = gameRes/2


checkKeysPressed = ()->
  k = keysPressed.shift()
  if k
    if k=='w'
      shipVel = x:0, y:-1
      dir = 0
    else if k=='d'
      shipVel = x:1, y:0
      dir = 1
    else if k=='s'
      shipVel = x:0, y:1
      dir = 2
    else if k=='a'
      shipVel = x:-1, y:0
      dir = 3

aniCnt = aniSpeed

nextFrame = ->
  if aniCnt<aniSpeed
    aniCnt++
    return requestAnimationFrame nextFrame
  else aniCnt = 0

  aniSpeed -= 1 if aniSpeed>5

  if gameRes < startRes && level==0
    gameRes += 4
    setGameRes()

  checkKeysPressed()

  shipPos.x += shipVel.x
  shipPos.y += shipVel.y


  checkCollision()
  checkBorderCollision()

  moveEnemy()
  checkCollision()


  checkLevel()

  clearCanvas()

  drawDots()
  drawBorder()
  drawShip(dir)

  drawStats()



  #setDot shipPos.x, shipPos.y, 1

  if Math.random()<.05 then placeRandomDots(1, 1)

  score += 1+level
  gameTick++

  if killed==false
    requestAnimationFrame nextFrame
  else
    killPlayer()


addEventListeners = ->
  d.body.addEventListener 'keydown', (e)->
    if (e.key=='w' || e.key=='d' || e.key=='s' || e.key=='a') && e.key != keysPressed[keysPressed.length-1]
      keysPressed.push e.key

enemys = []

getEnemys = (cnt)->
  enemys = []
  # for i in [0..cnt]
  #   m = if Math.random()>.5 then 1 else -1
  #   if Math.random()>.5
  #     mx = m
  #     my = 0
  #   else
  #     mx = 0
  #     my = m
  #   pos = getRandomDot(worldEdge.x/10)
  enemys.push pos:{x: -worldEdge.x+2, y: -6 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: -3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 0 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 6 }, mx: 1, my:0

moveEnemy = ->
  for enemy, ei in enemys
    e = enemy.pos
    setDot e.x, e.y, 0
    setDot e.x-1, e.y, 0
    setDot e.x+1, e.y, 0
    setDot e.x, e.y+1, 0
    setDot e.x, e.y-1, 0


    if Math.abs(e.x) > worldEdge.x
      e.x = -e.x
    if Math.abs(e.y) > worldEdge.y
      e.y = -e.y

    if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        x = enemy.mx
        enemy.mx = enemy.my
        enemy.my = x
    else if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        enemy.mx *= -1
        enemy.my *= -1

    e.x += enemy.mx
    e.y += enemy.my

    setDot e.x, e.y, 8
    setDot e.x-1, e.y, 6
    setDot e.x+1, e.y, 6
    setDot e.x, e.y+1, 6
    setDot e.x, e.y-1, 6

    if gameTick%41 == 40 && level>=1
      setDot e.x-enemy.mx*2, e.y-enemy.my*2, 7

drawDot = (x, y, col)->
  canvasX = (x+cx)*pieceSizeW
  canvasY = (y+cy)*pieceSizeH
  if canvasX<-pieceSizeW || canvasX > W || canvasY<-pieceSizeH || canvasY > H then return# c.l 'DRAW_DOT ERROR', canvasX, canvasY, x, y
  ctx.fillStyle = '#'+col
  ctx.fillRect .25+canvasX, .25+canvasY, pieceSizeW-.5, pieceSizeH-.5

drawShip = (dir)->
  for xy in shipDirDots[dir]
    drawDot xy[0], xy[1], shipColor

drawBorder = ->
  if shipPos.x+cx > worldEdge.x
    borderStartX = W-(shipPos.x+cx-worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect borderStartX, 0, W, H
  if shipPos.x-cx < -worldEdge.x
    borderStartX = -(shipPos.x-cx+worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, borderStartX, H
  if shipPos.y+cy > worldEdge.y
    borderStartY = W-(shipPos.y+cy-worldEdge.y)*pieceSizeH
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, borderStartY, W, H
  if shipPos.y-cy < -worldEdge.y
    borderStartY = -(shipPos.y-cy+worldEdge.y)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, W, borderStartY

drawStats = ->
  fontSize = (W/35)
  ctx.fillStyle = '#fff'
  ctx.font = fontSize+'px c64';
  ctx.fillText('HIGHSCORE: '+highscore, 6, 4+fontSize)
  ctx.fillText('SCORE: '+score, 6, 4+fontSize*2)
  ctx.fillText('LEVEL: '+level, 6, 4+fontSize*3)

drawDots = -> # Draw visible dots
  if worldEdge.x*2<gameRes
    maxX = worldEdge.x
    startX = -worldEdge.x-shipPos.x
    endX = worldEdge.x-shipPos.x
    startY = -worldEdge.y-shipPos.y
    endY = worldEdge.y-shipPos.y
  else
    maxX = (Math.round gameRes/2)
    startX = startY = -maxX
    endX = endY = maxX

  for x in [startX...endX]#[Math.floor(-(gameRes/2))...(gameRes/2)]
    posX = x+shipPos.x
    for y in [startY...endY] # [Math.floor(-(gameRes/2))...(gameRes/2)]
      posY = shipPos.y+y
      dot = getDot posX, posY
      if dot>0
        col =
          if dot==1 then shipTrailColor
          else if dot==6 then enemyColor
          else if dot==7 then enemyTrailColor
          else if dot==8 then enemyBodyColor
          else if dot==10 then bonusPointsColor
          else if dot==25 then 'f00'
          else if dot>=50 && dot<64
            dot += 1
            setDot posX, posY, dot
            col = (0xfff-((dot-50)*0x111)).toString(16)

          else if dot>=64
            setDot posX, posY, 0
            '000'
          else 'fff'
        drawDot x, y, col

getDot = (x, y)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  #if x<0 || x>=gameRes || y<0 || y>=gameRes then return# c.l 'getDot Out of bound',x,y
  dots[ x+(y*worldEdge.x*2) ]

setDot = (x, y, type)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  if x<0 || x >= worldEdge.x*2 || y<0 || y >= worldEdge.x*2 then return false# c.l 'setDot Out of bound',x,y
  dots[ x+(y*(worldEdge.x)*2) ] = type

getRandomDot = (saveArea)->
  x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
  y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
  maxTries = 128
  saveArea = saveArea||0
  tries = 0
  while x > -saveArea && x < saveArea && y > -saveArea && y < saveArea && getDot(x,y)==0
    tries++
    x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
    y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
    if tries > maxTries then return c.l 'getRandomDot overload'
  x:x, y:y

placeRandomDots = (amount, saveArea, id)->
  amount = amount||100
  saveArea = saveArea||worldEdge.x*.6
  while amount--
    dot = getRandomDot saveArea
    setDot dot.x, dot.y, id||10

checkCollision = ->
  # check collision with dot
  for sp in shipDirDots[dir]
    dot = getDot(sp[0]+shipPos.x, sp[1]+shipPos.y)
    if dot>0
      c.l dot
      if dot==10
        score += 100*(level+1)
        setDot(sp[0]+shipPos.x, sp[1]+shipPos.y, 0)
        placeRandomDots(1, 1)
      else killed--

  # check collision with wall
checkBorderCollision = ->
  if shipPos.x >= worldEdge.x
    shipPos.x = -worldEdge.x
  else if shipPos.x < -worldEdge.x
    shipPos.x = worldEdge.x-1

  if shipPos.y >= worldEdge.y
    shipPos.y = -worldEdge.x
  else if shipPos.y < -worldEdge.y
    shipPos.y = worldEdge.x-1

checkLevel = ->
  if score>1000 && level==0
    level++
    aniSpeed -= 2
  else if score>2500 && level==1
    level++
    gameRes -= 8
    setGameRes()
  else if score>5000 && level==2
    level++
    gameRes -= 8
    setGameRes()
  else if score>10000 && level==3
    level++
    gameRes -= 4
    setGameRes()
  else if score>20000 && level==4
    level++
    gameRes -= 2
    setGameRes()
  else if score>30000 && level==5
    level++
    gameRes -= 2
    setGameRes()
  else if score>45000 && level==6
    level++
    gameRes -= 2
    setGameRes()
  else if score>65000 && level==7
    level++
    gameRes -= 2
    setGameRes()
  else if score>80000 && level==8
    level++
    gameRes -= 2
    setGameRes()
  else if score>10000 && level==9
    level++
    aniSpeed -= 1

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

# requestAnimationFrame polyfill by Erik Möller. fixes from Paul Irish and Tino Zijdel
# MIT license

do ->
  lastTime = 0
  vendors = [ 'ms', 'moz', 'webkit', 'o' ]
  x = 0
  while x < vendors.length and !window.requestAnimationFrame
    window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame']
    window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] or window[vendors[x] + 'CancelRequestAnimationFrame']
    ++x
  if !window.requestAnimationFrame

    window.requestAnimationFrame = (callback, element) ->
      currTime = (new Date).getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      id = window.setTimeout((->
        callback currTime + timeToCall
        return
      ), timeToCall)
      lastTime = currTime + timeToCall
      id

  if !window.cancelAnimationFrame

    window.cancelAnimationFrame = (id) ->
      clearTimeout id
      return
  return


window.onload = ->
  addEventListeners()
  initCanvas()
  startGame()

pieceSizeW = W / gameRes
pieceSizeH = H / gameRes

killed = false

cx = (gameRes/2)
cy = (gameRes/2)

shipPos = x:0, y:0
shipVel = x:0, y:0
dir = 0
keysPressed = ["w"]
score = 0
highscore = 0
gameRes = 0
aniSpeed = 666
level = 0

gameTick = 0

startRes = 60

worldEdge = x: 127, y: 127
dots = new Uint8Array worldEdge.x*2*worldEdge.y*2
shipDirDots = null

shipColor = 'b0ec51'
shipTrailColor = '598e07'

enemyColor = '8333a5'
enemyBodyColor = 'ac61cc'
enemyTrailColor = '3e49d2'

bonusPointsColor = 'e4cc1f'

wallColor = '20363e'

shipDirDots = [
  [
    [-1, 0], [0, 0], [+1, 0], [0, -1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0+1, 0]
  ], [
    [0-1, 0], [0, 0], [0+1, 0], [0, 0+1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0-1, 0]
  ]
]

killPlayer = (i)->
  i = i||0

  clearCanvas()
  drawDots()
  drawBorder()

  if i<Math.sqrt(gameRes*gameRes+gameRes*gameRes)/2
    drawDot 0+i, 0+i, shipColor
    drawDot 0-i, 0-i, shipColor
    drawDot 0+i, 0-i, shipColor
    drawDot 0-i, 0+i, shipColor
    i++
    requestAnimationFrame (-> killPlayer(i))
  else
    highscore = Math.max score, highscore
    score = 0
    startGame()

startGame = ->
  shipPos = x:0, y:19
  shipVel = x:0, y:0
  dir = 0
  keysPressed = ['w']

  dots = new Uint8Array worldEdge.x*2*worldEdge.y*2

  killed = false

  worldEdge.x = 31 # must be uneven
  worldEdge.y = 31 # must be uneven
  gameRes = 5
  aniSpeed = 14
  level = 0
  lasers = 10

  getEnemys(4)
  moveEnemy()
  setGameRes()
  placeRandomDots(10)
  nextFrame()


setGameRes = ->
  pieceSizeW = W / gameRes
  pieceSizeH = H / gameRes

  cx = gameRes/2
  cy = gameRes/2


checkKeysPressed = ()->
  k = keysPressed.shift()
  if k
    if k=='w'
      shipVel = x:0, y:-1
      dir = 0
    else if k=='d'
      shipVel = x:1, y:0
      dir = 1
    else if k=='s'
      shipVel = x:0, y:1
      dir = 2
    else if k=='a'
      shipVel = x:-1, y:0
      dir = 3

aniCnt = aniSpeed

nextFrame = ->
  if aniCnt<aniSpeed
    aniCnt++
    return requestAnimationFrame nextFrame
  else aniCnt = 0

  aniSpeed -= 1 if aniSpeed>5

  if gameRes < startRes && level==0
    gameRes += 4
    setGameRes()

  checkKeysPressed()

  shipPos.x += shipVel.x
  shipPos.y += shipVel.y


  checkCollision()
  checkBorderCollision()

  moveEnemy()
  checkCollision()


  checkLevel()

  clearCanvas()

  drawDots()
  drawBorder()
  drawShip(dir)

  drawStats()



  #setDot shipPos.x, shipPos.y, 1

  if Math.random()<.05 then placeRandomDots(1, 1)

  score += 1+level
  gameTick++

  if killed==false
    requestAnimationFrame nextFrame
  else
    killPlayer()


addEventListeners = ->
  d.body.addEventListener 'keydown', (e)->
    if (e.key=='w' || e.key=='d' || e.key=='s' || e.key=='a') && e.key != keysPressed[keysPressed.length-1]
      keysPressed.push e.key

enemys = []

getEnemys = (cnt)->
  enemys = []
  # for i in [0..cnt]
  #   m = if Math.random()>.5 then 1 else -1
  #   if Math.random()>.5
  #     mx = m
  #     my = 0
  #   else
  #     mx = 0
  #     my = m
  #   pos = getRandomDot(worldEdge.x/10)
  enemys.push pos:{x: -worldEdge.x+2, y: -6 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: -3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 0 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 6 }, mx: 1, my:0

moveEnemy = ->
  for enemy, ei in enemys
    e = enemy.pos
    setDot e.x, e.y, 0
    setDot e.x-1, e.y, 0
    setDot e.x+1, e.y, 0
    setDot e.x, e.y+1, 0
    setDot e.x, e.y-1, 0


    if Math.abs(e.x) > worldEdge.x
      e.x = -e.x
    if Math.abs(e.y) > worldEdge.y
      e.y = -e.y

    if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        x = enemy.mx
        enemy.mx = enemy.my
        enemy.my = x
    else if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        enemy.mx *= -1
        enemy.my *= -1

    e.x += enemy.mx
    e.y += enemy.my

    setDot e.x, e.y, 8
    setDot e.x-1, e.y, 6
    setDot e.x+1, e.y, 6
    setDot e.x, e.y+1, 6
    setDot e.x, e.y-1, 6

    if gameTick%41 == 40 && level>=1
      setDot e.x-enemy.mx*2, e.y-enemy.my*2, 7

drawDot = (x, y, col)->
  canvasX = (x+cx)*pieceSizeW
  canvasY = (y+cy)*pieceSizeH
  if canvasX<-pieceSizeW || canvasX > W || canvasY<-pieceSizeH || canvasY > H then return# c.l 'DRAW_DOT ERROR', canvasX, canvasY, x, y
  ctx.fillStyle = '#'+col
  ctx.fillRect .25+canvasX, .25+canvasY, pieceSizeW-.5, pieceSizeH-.5

drawShip = (dir)->
  for xy in shipDirDots[dir]
    drawDot xy[0], xy[1], shipColor

drawBorder = ->
  if shipPos.x+cx > worldEdge.x
    borderStartX = W-(shipPos.x+cx-worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect borderStartX, 0, W, H
  if shipPos.x-cx < -worldEdge.x
    borderStartX = -(shipPos.x-cx+worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, borderStartX, H
  if shipPos.y+cy > worldEdge.y
    borderStartY = W-(shipPos.y+cy-worldEdge.y)*pieceSizeH
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, borderStartY, W, H
  if shipPos.y-cy < -worldEdge.y
    borderStartY = -(shipPos.y-cy+worldEdge.y)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, W, borderStartY

drawStats = ->
  fontSize = (W/35)
  ctx.fillStyle = '#fff'
  ctx.font = fontSize+'px c64';
  ctx.fillText('HIGHSCORE: '+highscore, 6, 4+fontSize)
  ctx.fillText('SCORE: '+score, 6, 4+fontSize*2)
  ctx.fillText('LEVEL: '+level, 6, 4+fontSize*3)

drawDots = -> # Draw visible dots
  if worldEdge.x*2<gameRes
    maxX = worldEdge.x
    startX = -worldEdge.x-shipPos.x
    endX = worldEdge.x-shipPos.x
    startY = -worldEdge.y-shipPos.y
    endY = worldEdge.y-shipPos.y
  else
    maxX = (Math.round gameRes/2)
    startX = startY = -maxX
    endX = endY = maxX

  for x in [startX...endX]#[Math.floor(-(gameRes/2))...(gameRes/2)]
    posX = x+shipPos.x
    for y in [startY...endY] # [Math.floor(-(gameRes/2))...(gameRes/2)]
      posY = shipPos.y+y
      dot = getDot posX, posY
      if dot>0
        col =
          if dot==1 then shipTrailColor
          else if dot==6 then enemyColor
          else if dot==7 then enemyTrailColor
          else if dot==8 then enemyBodyColor
          else if dot==10 then bonusPointsColor
          else if dot==25 then 'f00'
          else if dot>=50 && dot<64
            dot += 1
            setDot posX, posY, dot
            col = (0xfff-((dot-50)*0x111)).toString(16)

          else if dot>=64
            setDot posX, posY, 0
            '000'
          else 'fff'
        drawDot x, y, col

getDot = (x, y)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  #if x<0 || x>=gameRes || y<0 || y>=gameRes then return# c.l 'getDot Out of bound',x,y
  dots[ x+(y*worldEdge.x*2) ]

setDot = (x, y, type)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  if x<0 || x >= worldEdge.x*2 || y<0 || y >= worldEdge.x*2 then return false# c.l 'setDot Out of bound',x,y
  dots[ x+(y*(worldEdge.x)*2) ] = type

getRandomDot = (saveArea)->
  x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
  y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
  maxTries = 128
  saveArea = saveArea||0
  tries = 0
  while x > -saveArea && x < saveArea && y > -saveArea && y < saveArea && getDot(x,y)==0
    tries++
    x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
    y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
    if tries > maxTries then return c.l 'getRandomDot overload'
  x:x, y:y

placeRandomDots = (amount, saveArea, id)->
  amount = amount||100
  saveArea = saveArea||worldEdge.x*.6
  while amount--
    dot = getRandomDot saveArea
    setDot dot.x, dot.y, id||10

checkCollision = ->
  # check collision with dot
  for sp in shipDirDots[dir]
    dot = getDot(sp[0]+shipPos.x, sp[1]+shipPos.y)
    if dot>0
      c.l dot
      if dot==10
        score += 100*(level+1)
        setDot(sp[0]+shipPos.x, sp[1]+shipPos.y, 0)
        placeRandomDots(1, 1)
      else killed--

  # check collision with wall
checkBorderCollision = ->
  if shipPos.x >= worldEdge.x
    shipPos.x = -worldEdge.x
  else if shipPos.x < -worldEdge.x
    shipPos.x = worldEdge.x-1

  if shipPos.y >= worldEdge.y
    shipPos.y = -worldEdge.x
  else if shipPos.y < -worldEdge.y
    shipPos.y = worldEdge.x-1

checkLevel = ->
  if score>1000 && level==0
    level++
    aniSpeed -= 2
  else if score>2500 && level==1
    level++
    gameRes -= 8
    setGameRes()
  else if score>5000 && level==2
    level++
    gameRes -= 8
    setGameRes()
  else if score>10000 && level==3
    level++
    gameRes -= 4
    setGameRes()
  else if score>20000 && level==4
    level++
    gameRes -= 2
    setGameRes()
  else if score>30000 && level==5
    level++
    gameRes -= 2
    setGameRes()
  else if score>45000 && level==6
    level++
    gameRes -= 2
    setGameRes()
  else if score>65000 && level==7
    level++
    gameRes -= 2
    setGameRes()
  else if score>80000 && level==8
    level++
    gameRes -= 2
    setGameRes()
  else if score>10000 && level==9
    level++
    aniSpeed -= 1

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

# requestAnimationFrame polyfill by Erik Möller. fixes from Paul Irish and Tino Zijdel
# MIT license

do ->
  lastTime = 0
  vendors = [ 'ms', 'moz', 'webkit', 'o' ]
  x = 0
  while x < vendors.length and !window.requestAnimationFrame
    window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame']
    window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] or window[vendors[x] + 'CancelRequestAnimationFrame']
    ++x
  if !window.requestAnimationFrame

    window.requestAnimationFrame = (callback, element) ->
      currTime = (new Date).getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      id = window.setTimeout((->
        callback currTime + timeToCall
        return
      ), timeToCall)
      lastTime = currTime + timeToCall
      id

  if !window.cancelAnimationFrame

    window.cancelAnimationFrame = (id) ->
      clearTimeout id
      return
  return


window.onload = ->
  addEventListeners()
  initCanvas()
  startGame()

pieceSizeW = W / gameRes
pieceSizeH = H / gameRes

killed = false

cx = (gameRes/2)
cy = (gameRes/2)

shipPos = x:0, y:0
shipVel = x:0, y:0
dir = 0
keysPressed = ["w"]
score = 0
highscore = 0
gameRes = 0
aniSpeed = 666
level = 0

gameTick = 0

startRes = 60

worldEdge = x: 127, y: 127
dots = new Uint8Array worldEdge.x*2*worldEdge.y*2
shipDirDots = null

shipColor = 'b0ec51'
shipTrailColor = '598e07'

enemyColor = '8333a5'
enemyBodyColor = 'ac61cc'
enemyTrailColor = '3e49d2'

bonusPointsColor = 'e4cc1f'

wallColor = '20363e'

shipDirDots = [
  [
    [-1, 0], [0, 0], [+1, 0], [0, -1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0+1, 0]
  ], [
    [0-1, 0], [0, 0], [0+1, 0], [0, 0+1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0-1, 0]
  ]
]

killPlayer = (i)->
  i = i||0

  clearCanvas()
  drawDots()
  drawBorder()

  if i<Math.sqrt(gameRes*gameRes+gameRes*gameRes)/2
    drawDot 0+i, 0+i, shipColor
    drawDot 0-i, 0-i, shipColor
    drawDot 0+i, 0-i, shipColor
    drawDot 0-i, 0+i, shipColor
    i++
    requestAnimationFrame (-> killPlayer(i))
  else
    highscore = Math.max score, highscore
    score = 0
    startGame()

startGame = ->
  shipPos = x:0, y:19
  shipVel = x:0, y:0
  dir = 0
  keysPressed = ['w']

  dots = new Uint8Array worldEdge.x*2*worldEdge.y*2

  killed = false

  worldEdge.x = 31 # must be uneven
  worldEdge.y = 31 # must be uneven
  gameRes = 5
  aniSpeed = 14
  level = 0
  lasers = 10

  getEnemys(4)
  moveEnemy()
  setGameRes()
  placeRandomDots(10)
  nextFrame()


setGameRes = ->
  pieceSizeW = W / gameRes
  pieceSizeH = H / gameRes

  cx = gameRes/2
  cy = gameRes/2


checkKeysPressed = ()->
  k = keysPressed.shift()
  if k
    if k=='w'
      shipVel = x:0, y:-1
      dir = 0
    else if k=='d'
      shipVel = x:1, y:0
      dir = 1
    else if k=='s'
      shipVel = x:0, y:1
      dir = 2
    else if k=='a'
      shipVel = x:-1, y:0
      dir = 3

aniCnt = aniSpeed

nextFrame = ->
  if aniCnt<aniSpeed
    aniCnt++
    return requestAnimationFrame nextFrame
  else aniCnt = 0

  aniSpeed -= 1 if aniSpeed>5

  if gameRes < startRes && level==0
    gameRes += 4
    setGameRes()

  checkKeysPressed()

  shipPos.x += shipVel.x
  shipPos.y += shipVel.y


  checkCollision()
  checkBorderCollision()

  moveEnemy()
  checkCollision()


  checkLevel()

  clearCanvas()

  drawDots()
  drawBorder()
  drawShip(dir)

  drawStats()



  #setDot shipPos.x, shipPos.y, 1

  if Math.random()<.05 then placeRandomDots(1, 1)

  score += 1+level
  gameTick++

  if killed==false
    requestAnimationFrame nextFrame
  else
    killPlayer()


addEventListeners = ->
  d.body.addEventListener 'keydown', (e)->
    if (e.key=='w' || e.key=='d' || e.key=='s' || e.key=='a') && e.key != keysPressed[keysPressed.length-1]
      keysPressed.push e.key

enemys = []

getEnemys = (cnt)->
  enemys = []
  # for i in [0..cnt]
  #   m = if Math.random()>.5 then 1 else -1
  #   if Math.random()>.5
  #     mx = m
  #     my = 0
  #   else
  #     mx = 0
  #     my = m
  #   pos = getRandomDot(worldEdge.x/10)
  enemys.push pos:{x: -worldEdge.x+2, y: -6 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: -3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 0 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 6 }, mx: 1, my:0

moveEnemy = ->
  for enemy, ei in enemys
    e = enemy.pos
    setDot e.x, e.y, 0
    setDot e.x-1, e.y, 0
    setDot e.x+1, e.y, 0
    setDot e.x, e.y+1, 0
    setDot e.x, e.y-1, 0


    if Math.abs(e.x) > worldEdge.x
      e.x = -e.x
    if Math.abs(e.y) > worldEdge.y
      e.y = -e.y

    if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        x = enemy.mx
        enemy.mx = enemy.my
        enemy.my = x
    else if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        enemy.mx *= -1
        enemy.my *= -1

    e.x += enemy.mx
    e.y += enemy.my

    setDot e.x, e.y, 8
    setDot e.x-1, e.y, 6
    setDot e.x+1, e.y, 6
    setDot e.x, e.y+1, 6
    setDot e.x, e.y-1, 6

    if gameTick%41 == 40 && level>=1
      setDot e.x-enemy.mx*2, e.y-enemy.my*2, 7

drawDot = (x, y, col)->
  canvasX = (x+cx)*pieceSizeW
  canvasY = (y+cy)*pieceSizeH
  if canvasX<-pieceSizeW || canvasX > W || canvasY<-pieceSizeH || canvasY > H then return# c.l 'DRAW_DOT ERROR', canvasX, canvasY, x, y
  ctx.fillStyle = '#'+col
  ctx.fillRect .25+canvasX, .25+canvasY, pieceSizeW-.5, pieceSizeH-.5

drawShip = (dir)->
  for xy in shipDirDots[dir]
    drawDot xy[0], xy[1], shipColor

drawBorder = ->
  if shipPos.x+cx > worldEdge.x
    borderStartX = W-(shipPos.x+cx-worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect borderStartX, 0, W, H
  if shipPos.x-cx < -worldEdge.x
    borderStartX = -(shipPos.x-cx+worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, borderStartX, H
  if shipPos.y+cy > worldEdge.y
    borderStartY = W-(shipPos.y+cy-worldEdge.y)*pieceSizeH
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, borderStartY, W, H
  if shipPos.y-cy < -worldEdge.y
    borderStartY = -(shipPos.y-cy+worldEdge.y)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, W, borderStartY

drawStats = ->
  fontSize = (W/35)
  ctx.fillStyle = '#fff'
  ctx.font = fontSize+'px c64';
  ctx.fillText('HIGHSCORE: '+highscore, 6, 4+fontSize)
  ctx.fillText('SCORE: '+score, 6, 4+fontSize*2)
  ctx.fillText('LEVEL: '+level, 6, 4+fontSize*3)

drawDots = -> # Draw visible dots
  if worldEdge.x*2<gameRes
    maxX = worldEdge.x
    startX = -worldEdge.x-shipPos.x
    endX = worldEdge.x-shipPos.x
    startY = -worldEdge.y-shipPos.y
    endY = worldEdge.y-shipPos.y
  else
    maxX = (Math.round gameRes/2)
    startX = startY = -maxX
    endX = endY = maxX

  for x in [startX...endX]#[Math.floor(-(gameRes/2))...(gameRes/2)]
    posX = x+shipPos.x
    for y in [startY...endY] # [Math.floor(-(gameRes/2))...(gameRes/2)]
      posY = shipPos.y+y
      dot = getDot posX, posY
      if dot>0
        col =
          if dot==1 then shipTrailColor
          else if dot==6 then enemyColor
          else if dot==7 then enemyTrailColor
          else if dot==8 then enemyBodyColor
          else if dot==10 then bonusPointsColor
          else if dot==25 then 'f00'
          else if dot>=50 && dot<64
            dot += 1
            setDot posX, posY, dot
            col = (0xfff-((dot-50)*0x111)).toString(16)

          else if dot>=64
            setDot posX, posY, 0
            '000'
          else 'fff'
        drawDot x, y, col

getDot = (x, y)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  #if x<0 || x>=gameRes || y<0 || y>=gameRes then return# c.l 'getDot Out of bound',x,y
  dots[ x+(y*worldEdge.x*2) ]

setDot = (x, y, type)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  if x<0 || x >= worldEdge.x*2 || y<0 || y >= worldEdge.x*2 then return false# c.l 'setDot Out of bound',x,y
  dots[ x+(y*(worldEdge.x)*2) ] = type

getRandomDot = (saveArea)->
  x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
  y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
  maxTries = 128
  saveArea = saveArea||0
  tries = 0
  while x > -saveArea && x < saveArea && y > -saveArea && y < saveArea && getDot(x,y)==0
    tries++
    x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
    y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
    if tries > maxTries then return c.l 'getRandomDot overload'
  x:x, y:y

placeRandomDots = (amount, saveArea, id)->
  amount = amount||100
  saveArea = saveArea||worldEdge.x*.6
  while amount--
    dot = getRandomDot saveArea
    setDot dot.x, dot.y, id||10

checkCollision = ->
  # check collision with dot
  for sp in shipDirDots[dir]
    dot = getDot(sp[0]+shipPos.x, sp[1]+shipPos.y)
    if dot>0
      c.l dot
      if dot==10
        score += 100*(level+1)
        setDot(sp[0]+shipPos.x, sp[1]+shipPos.y, 0)
        placeRandomDots(1, 1)
      else killed--

  # check collision with wall
checkBorderCollision = ->
  if shipPos.x >= worldEdge.x
    shipPos.x = -worldEdge.x
  else if shipPos.x < -worldEdge.x
    shipPos.x = worldEdge.x-1

  if shipPos.y >= worldEdge.y
    shipPos.y = -worldEdge.x
  else if shipPos.y < -worldEdge.y
    shipPos.y = worldEdge.x-1

checkLevel = ->
  if score>1000 && level==0
    level++
    aniSpeed -= 2
  else if score>2500 && level==1
    level++
    gameRes -= 8
    setGameRes()
  else if score>5000 && level==2
    level++
    gameRes -= 8
    setGameRes()
  else if score>10000 && level==3
    level++
    gameRes -= 4
    setGameRes()
  else if score>20000 && level==4
    level++
    gameRes -= 2
    setGameRes()
  else if score>30000 && level==5
    level++
    gameRes -= 2
    setGameRes()
  else if score>45000 && level==6
    level++
    gameRes -= 2
    setGameRes()
  else if score>65000 && level==7
    level++
    gameRes -= 2
    setGameRes()
  else if score>80000 && level==8
    level++
    gameRes -= 2
    setGameRes()
  else if score>10000 && level==9
    level++
    aniSpeed -= 1

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

# requestAnimationFrame polyfill by Erik Möller. fixes from Paul Irish and Tino Zijdel
# MIT license

do ->
  lastTime = 0
  vendors = [ 'ms', 'moz', 'webkit', 'o' ]
  x = 0
  while x < vendors.length and !window.requestAnimationFrame
    window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame']
    window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] or window[vendors[x] + 'CancelRequestAnimationFrame']
    ++x
  if !window.requestAnimationFrame

    window.requestAnimationFrame = (callback, element) ->
      currTime = (new Date).getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      id = window.setTimeout((->
        callback currTime + timeToCall
        return
      ), timeToCall)
      lastTime = currTime + timeToCall
      id

  if !window.cancelAnimationFrame

    window.cancelAnimationFrame = (id) ->
      clearTimeout id
      return
  return


window.onload = ->
  addEventListeners()
  initCanvas()
  startGame()

pieceSizeW = W / gameRes
pieceSizeH = H / gameRes

killed = false

cx = (gameRes/2)
cy = (gameRes/2)

shipPos = x:0, y:0
shipVel = x:0, y:0
dir = 0
keysPressed = ["w"]
score = 0
highscore = 0
gameRes = 0
aniSpeed = 666
level = 0

gameTick = 0

startRes = 60

worldEdge = x: 127, y: 127
dots = new Uint8Array worldEdge.x*2*worldEdge.y*2
shipDirDots = null

shipColor = 'b0ec51'
shipTrailColor = '598e07'

enemyColor = '8333a5'
enemyBodyColor = 'ac61cc'
enemyTrailColor = '3e49d2'

bonusPointsColor = 'e4cc1f'

wallColor = '20363e'

shipDirDots = [
  [
    [-1, 0], [0, 0], [+1, 0], [0, -1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0+1, 0]
  ], [
    [0-1, 0], [0, 0], [0+1, 0], [0, 0+1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0-1, 0]
  ]
]

killPlayer = (i)->
  i = i||0

  clearCanvas()
  drawDots()
  drawBorder()

  if i<Math.sqrt(gameRes*gameRes+gameRes*gameRes)/2
    drawDot 0+i, 0+i, shipColor
    drawDot 0-i, 0-i, shipColor
    drawDot 0+i, 0-i, shipColor
    drawDot 0-i, 0+i, shipColor
    i++
    requestAnimationFrame (-> killPlayer(i))
  else
    highscore = Math.max score, highscore
    score = 0
    startGame()

startGame = ->
  shipPos = x:0, y:19
  shipVel = x:0, y:0
  dir = 0
  keysPressed = ['w']

  dots = new Uint8Array worldEdge.x*2*worldEdge.y*2

  killed = false

  worldEdge.x = 31 # must be uneven
  worldEdge.y = 31 # must be uneven
  gameRes = 5
  aniSpeed = 14
  level = 0
  lasers = 10

  getEnemys(4)
  moveEnemy()
  setGameRes()
  placeRandomDots(10)
  nextFrame()


setGameRes = ->
  pieceSizeW = W / gameRes
  pieceSizeH = H / gameRes

  cx = gameRes/2
  cy = gameRes/2


checkKeysPressed = ()->
  k = keysPressed.shift()
  if k
    if k=='w'
      shipVel = x:0, y:-1
      dir = 0
    else if k=='d'
      shipVel = x:1, y:0
      dir = 1
    else if k=='s'
      shipVel = x:0, y:1
      dir = 2
    else if k=='a'
      shipVel = x:-1, y:0
      dir = 3

aniCnt = aniSpeed

nextFrame = ->
  if aniCnt<aniSpeed
    aniCnt++
    return requestAnimationFrame nextFrame
  else aniCnt = 0

  aniSpeed -= 1 if aniSpeed>5

  if gameRes < startRes && level==0
    gameRes += 4
    setGameRes()

  checkKeysPressed()

  shipPos.x += shipVel.x
  shipPos.y += shipVel.y


  checkCollision()
  checkBorderCollision()

  moveEnemy()
  checkCollision()


  checkLevel()

  clearCanvas()

  drawDots()
  drawBorder()
  drawShip(dir)

  drawStats()



  #setDot shipPos.x, shipPos.y, 1

  if Math.random()<.05 then placeRandomDots(1, 1)

  score += 1+level
  gameTick++

  if killed==false
    requestAnimationFrame nextFrame
  else
    killPlayer()


addEventListeners = ->
  d.body.addEventListener 'keydown', (e)->
    if (e.key=='w' || e.key=='d' || e.key=='s' || e.key=='a') && e.key != keysPressed[keysPressed.length-1]
      keysPressed.push e.key

enemys = []

getEnemys = (cnt)->
  enemys = []
  # for i in [0..cnt]
  #   m = if Math.random()>.5 then 1 else -1
  #   if Math.random()>.5
  #     mx = m
  #     my = 0
  #   else
  #     mx = 0
  #     my = m
  #   pos = getRandomDot(worldEdge.x/10)
  enemys.push pos:{x: -worldEdge.x+2, y: -6 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: -3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 0 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 6 }, mx: 1, my:0

moveEnemy = ->
  for enemy, ei in enemys
    e = enemy.pos
    setDot e.x, e.y, 0
    setDot e.x-1, e.y, 0
    setDot e.x+1, e.y, 0
    setDot e.x, e.y+1, 0
    setDot e.x, e.y-1, 0


    if Math.abs(e.x) > worldEdge.x
      e.x = -e.x
    if Math.abs(e.y) > worldEdge.y
      e.y = -e.y

    if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        x = enemy.mx
        enemy.mx = enemy.my
        enemy.my = x
    else if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        enemy.mx *= -1
        enemy.my *= -1

    e.x += enemy.mx
    e.y += enemy.my

    setDot e.x, e.y, 8
    setDot e.x-1, e.y, 6
    setDot e.x+1, e.y, 6
    setDot e.x, e.y+1, 6
    setDot e.x, e.y-1, 6

    if gameTick%41 == 40 && level>=1
      setDot e.x-enemy.mx*2, e.y-enemy.my*2, 7

drawDot = (x, y, col)->
  canvasX = (x+cx)*pieceSizeW
  canvasY = (y+cy)*pieceSizeH
  if canvasX<-pieceSizeW || canvasX > W || canvasY<-pieceSizeH || canvasY > H then return# c.l 'DRAW_DOT ERROR', canvasX, canvasY, x, y
  ctx.fillStyle = '#'+col
  ctx.fillRect .25+canvasX, .25+canvasY, pieceSizeW-.5, pieceSizeH-.5

drawShip = (dir)->
  for xy in shipDirDots[dir]
    drawDot xy[0], xy[1], shipColor

drawBorder = ->
  if shipPos.x+cx > worldEdge.x
    borderStartX = W-(shipPos.x+cx-worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect borderStartX, 0, W, H
  if shipPos.x-cx < -worldEdge.x
    borderStartX = -(shipPos.x-cx+worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, borderStartX, H
  if shipPos.y+cy > worldEdge.y
    borderStartY = W-(shipPos.y+cy-worldEdge.y)*pieceSizeH
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, borderStartY, W, H
  if shipPos.y-cy < -worldEdge.y
    borderStartY = -(shipPos.y-cy+worldEdge.y)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, W, borderStartY

drawStats = ->
  fontSize = (W/35)
  ctx.fillStyle = '#fff'
  ctx.font = fontSize+'px c64';
  ctx.fillText('HIGHSCORE: '+highscore, 6, 4+fontSize)
  ctx.fillText('SCORE: '+score, 6, 4+fontSize*2)
  ctx.fillText('LEVEL: '+level, 6, 4+fontSize*3)

drawDots = -> # Draw visible dots
  if worldEdge.x*2<gameRes
    maxX = worldEdge.x
    startX = -worldEdge.x-shipPos.x
    endX = worldEdge.x-shipPos.x
    startY = -worldEdge.y-shipPos.y
    endY = worldEdge.y-shipPos.y
  else
    maxX = (Math.round gameRes/2)
    startX = startY = -maxX
    endX = endY = maxX

  for x in [startX...endX]#[Math.floor(-(gameRes/2))...(gameRes/2)]
    posX = x+shipPos.x
    for y in [startY...endY] # [Math.floor(-(gameRes/2))...(gameRes/2)]
      posY = shipPos.y+y
      dot = getDot posX, posY
      if dot>0
        col =
          if dot==1 then shipTrailColor
          else if dot==6 then enemyColor
          else if dot==7 then enemyTrailColor
          else if dot==8 then enemyBodyColor
          else if dot==10 then bonusPointsColor
          else if dot==25 then 'f00'
          else if dot>=50 && dot<64
            dot += 1
            setDot posX, posY, dot
            col = (0xfff-((dot-50)*0x111)).toString(16)

          else if dot>=64
            setDot posX, posY, 0
            '000'
          else 'fff'
        drawDot x, y, col

getDot = (x, y)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  #if x<0 || x>=gameRes || y<0 || y>=gameRes then return# c.l 'getDot Out of bound',x,y
  dots[ x+(y*worldEdge.x*2) ]

setDot = (x, y, type)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  if x<0 || x >= worldEdge.x*2 || y<0 || y >= worldEdge.x*2 then return false# c.l 'setDot Out of bound',x,y
  dots[ x+(y*(worldEdge.x)*2) ] = type

getRandomDot = (saveArea)->
  x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
  y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
  maxTries = 128
  saveArea = saveArea||0
  tries = 0
  while x > -saveArea && x < saveArea && y > -saveArea && y < saveArea && getDot(x,y)==0
    tries++
    x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
    y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
    if tries > maxTries then return c.l 'getRandomDot overload'
  x:x, y:y

placeRandomDots = (amount, saveArea, id)->
  amount = amount||100
  saveArea = saveArea||worldEdge.x*.6
  while amount--
    dot = getRandomDot saveArea
    setDot dot.x, dot.y, id||10

checkCollision = ->
  # check collision with dot
  for sp in shipDirDots[dir]
    dot = getDot(sp[0]+shipPos.x, sp[1]+shipPos.y)
    if dot>0
      c.l dot
      if dot==10
        score += 100*(level+1)
        setDot(sp[0]+shipPos.x, sp[1]+shipPos.y, 0)
        placeRandomDots(1, 1)
      else killed--

  # check collision with wall
checkBorderCollision = ->
  if shipPos.x >= worldEdge.x
    shipPos.x = -worldEdge.x
  else if shipPos.x < -worldEdge.x
    shipPos.x = worldEdge.x-1

  if shipPos.y >= worldEdge.y
    shipPos.y = -worldEdge.x
  else if shipPos.y < -worldEdge.y
    shipPos.y = worldEdge.x-1

checkLevel = ->
  if score>1000 && level==0
    level++
    aniSpeed -= 2
  else if score>2500 && level==1
    level++
    gameRes -= 8
    setGameRes()
  else if score>5000 && level==2
    level++
    gameRes -= 8
    setGameRes()
  else if score>10000 && level==3
    level++
    gameRes -= 4
    setGameRes()
  else if score>20000 && level==4
    level++
    gameRes -= 2
    setGameRes()
  else if score>30000 && level==5
    level++
    gameRes -= 2
    setGameRes()
  else if score>45000 && level==6
    level++
    gameRes -= 2
    setGameRes()
  else if score>65000 && level==7
    level++
    gameRes -= 2
    setGameRes()
  else if score>80000 && level==8
    level++
    gameRes -= 2
    setGameRes()
  else if score>10000 && level==9
    level++
    aniSpeed -= 1

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

# requestAnimationFrame polyfill by Erik Möller. fixes from Paul Irish and Tino Zijdel
# MIT license

do ->
  lastTime = 0
  vendors = [ 'ms', 'moz', 'webkit', 'o' ]
  x = 0
  while x < vendors.length and !window.requestAnimationFrame
    window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame']
    window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] or window[vendors[x] + 'CancelRequestAnimationFrame']
    ++x
  if !window.requestAnimationFrame

    window.requestAnimationFrame = (callback, element) ->
      currTime = (new Date).getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      id = window.setTimeout((->
        callback currTime + timeToCall
        return
      ), timeToCall)
      lastTime = currTime + timeToCall
      id

  if !window.cancelAnimationFrame

    window.cancelAnimationFrame = (id) ->
      clearTimeout id
      return
  return


window.onload = ->
  addEventListeners()
  initCanvas()
  startGame()

pieceSizeW = W / gameRes
pieceSizeH = H / gameRes

killed = false

cx = (gameRes/2)
cy = (gameRes/2)

shipPos = x:0, y:0
shipVel = x:0, y:0
dir = 0
keysPressed = ["w"]
score = 0
highscore = 0
gameRes = 0
aniSpeed = 666
level = 0

gameTick = 0

startRes = 60

worldEdge = x: 127, y: 127
dots = new Uint8Array worldEdge.x*2*worldEdge.y*2
shipDirDots = null

shipColor = 'b0ec51'
shipTrailColor = '598e07'

enemyColor = '8333a5'
enemyBodyColor = 'ac61cc'
enemyTrailColor = '3e49d2'

bonusPointsColor = 'e4cc1f'

wallColor = '20363e'

shipDirDots = [
  [
    [-1, 0], [0, 0], [+1, 0], [0, -1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0+1, 0]
  ], [
    [0-1, 0], [0, 0], [0+1, 0], [0, 0+1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0-1, 0]
  ]
]

killPlayer = (i)->
  i = i||0

  clearCanvas()
  drawDots()
  drawBorder()

  if i<Math.sqrt(gameRes*gameRes+gameRes*gameRes)/2
    drawDot 0+i, 0+i, shipColor
    drawDot 0-i, 0-i, shipColor
    drawDot 0+i, 0-i, shipColor
    drawDot 0-i, 0+i, shipColor
    i++
    requestAnimationFrame (-> killPlayer(i))
  else
    highscore = Math.max score, highscore
    score = 0
    startGame()

startGame = ->
  shipPos = x:0, y:19
  shipVel = x:0, y:0
  dir = 0
  keysPressed = ['w']

  dots = new Uint8Array worldEdge.x*2*worldEdge.y*2

  killed = false

  worldEdge.x = 31 # must be uneven
  worldEdge.y = 31 # must be uneven
  gameRes = 5
  aniSpeed = 14
  level = 0
  lasers = 10

  getEnemys(4)
  moveEnemy()
  setGameRes()
  placeRandomDots(10)
  nextFrame()


setGameRes = ->
  pieceSizeW = W / gameRes
  pieceSizeH = H / gameRes

  cx = gameRes/2
  cy = gameRes/2


checkKeysPressed = ()->
  k = keysPressed.shift()
  if k
    if k=='w'
      shipVel = x:0, y:-1
      dir = 0
    else if k=='d'
      shipVel = x:1, y:0
      dir = 1
    else if k=='s'
      shipVel = x:0, y:1
      dir = 2
    else if k=='a'
      shipVel = x:-1, y:0
      dir = 3

aniCnt = aniSpeed

nextFrame = ->
  if aniCnt<aniSpeed
    aniCnt++
    return requestAnimationFrame nextFrame
  else aniCnt = 0

  aniSpeed -= 1 if aniSpeed>5

  if gameRes < startRes && level==0
    gameRes += 4
    setGameRes()

  checkKeysPressed()

  shipPos.x += shipVel.x
  shipPos.y += shipVel.y


  checkCollision()
  checkBorderCollision()

  moveEnemy()
  checkCollision()


  checkLevel()

  clearCanvas()

  drawDots()
  drawBorder()
  drawShip(dir)

  drawStats()



  #setDot shipPos.x, shipPos.y, 1

  if Math.random()<.05 then placeRandomDots(1, 1)

  score += 1+level
  gameTick++

  if killed==false
    requestAnimationFrame nextFrame
  else
    killPlayer()


addEventListeners = ->
  d.body.addEventListener 'keydown', (e)->
    if (e.key=='w' || e.key=='d' || e.key=='s' || e.key=='a') && e.key != keysPressed[keysPressed.length-1]
      keysPressed.push e.key

enemys = []

getEnemys = (cnt)->
  enemys = []
  # for i in [0..cnt]
  #   m = if Math.random()>.5 then 1 else -1
  #   if Math.random()>.5
  #     mx = m
  #     my = 0
  #   else
  #     mx = 0
  #     my = m
  #   pos = getRandomDot(worldEdge.x/10)
  enemys.push pos:{x: -worldEdge.x+2, y: -6 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: -3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 0 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 6 }, mx: 1, my:0

moveEnemy = ->
  for enemy, ei in enemys
    e = enemy.pos
    setDot e.x, e.y, 0
    setDot e.x-1, e.y, 0
    setDot e.x+1, e.y, 0
    setDot e.x, e.y+1, 0
    setDot e.x, e.y-1, 0


    if Math.abs(e.x) > worldEdge.x
      e.x = -e.x
    if Math.abs(e.y) > worldEdge.y
      e.y = -e.y

    if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        x = enemy.mx
        enemy.mx = enemy.my
        enemy.my = x
    else if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        enemy.mx *= -1
        enemy.my *= -1

    e.x += enemy.mx
    e.y += enemy.my

    setDot e.x, e.y, 8
    setDot e.x-1, e.y, 6
    setDot e.x+1, e.y, 6
    setDot e.x, e.y+1, 6
    setDot e.x, e.y-1, 6

    if gameTick%41 == 40 && level>=1
      setDot e.x-enemy.mx*2, e.y-enemy.my*2, 7

drawDot = (x, y, col)->
  canvasX = (x+cx)*pieceSizeW
  canvasY = (y+cy)*pieceSizeH
  if canvasX<-pieceSizeW || canvasX > W || canvasY<-pieceSizeH || canvasY > H then return# c.l 'DRAW_DOT ERROR', canvasX, canvasY, x, y
  ctx.fillStyle = '#'+col
  ctx.fillRect .25+canvasX, .25+canvasY, pieceSizeW-.5, pieceSizeH-.5

drawShip = (dir)->
  for xy in shipDirDots[dir]
    drawDot xy[0], xy[1], shipColor

drawBorder = ->
  if shipPos.x+cx > worldEdge.x
    borderStartX = W-(shipPos.x+cx-worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect borderStartX, 0, W, H
  if shipPos.x-cx < -worldEdge.x
    borderStartX = -(shipPos.x-cx+worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, borderStartX, H
  if shipPos.y+cy > worldEdge.y
    borderStartY = W-(shipPos.y+cy-worldEdge.y)*pieceSizeH
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, borderStartY, W, H
  if shipPos.y-cy < -worldEdge.y
    borderStartY = -(shipPos.y-cy+worldEdge.y)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, W, borderStartY

drawStats = ->
  fontSize = (W/35)
  ctx.fillStyle = '#fff'
  ctx.font = fontSize+'px c64';
  ctx.fillText('HIGHSCORE: '+highscore, 6, 4+fontSize)
  ctx.fillText('SCORE: '+score, 6, 4+fontSize*2)
  ctx.fillText('LEVEL: '+level, 6, 4+fontSize*3)

drawDots = -> # Draw visible dots
  if worldEdge.x*2<gameRes
    maxX = worldEdge.x
    startX = -worldEdge.x-shipPos.x
    endX = worldEdge.x-shipPos.x
    startY = -worldEdge.y-shipPos.y
    endY = worldEdge.y-shipPos.y
  else
    maxX = (Math.round gameRes/2)
    startX = startY = -maxX
    endX = endY = maxX

  for x in [startX...endX]#[Math.floor(-(gameRes/2))...(gameRes/2)]
    posX = x+shipPos.x
    for y in [startY...endY] # [Math.floor(-(gameRes/2))...(gameRes/2)]
      posY = shipPos.y+y
      dot = getDot posX, posY
      if dot>0
        col =
          if dot==1 then shipTrailColor
          else if dot==6 then enemyColor
          else if dot==7 then enemyTrailColor
          else if dot==8 then enemyBodyColor
          else if dot==10 then bonusPointsColor
          else if dot==25 then 'f00'
          else if dot>=50 && dot<64
            dot += 1
            setDot posX, posY, dot
            col = (0xfff-((dot-50)*0x111)).toString(16)

          else if dot>=64
            setDot posX, posY, 0
            '000'
          else 'fff'
        drawDot x, y, col

getDot = (x, y)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  #if x<0 || x>=gameRes || y<0 || y>=gameRes then return# c.l 'getDot Out of bound',x,y
  dots[ x+(y*worldEdge.x*2) ]

setDot = (x, y, type)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  if x<0 || x >= worldEdge.x*2 || y<0 || y >= worldEdge.x*2 then return false# c.l 'setDot Out of bound',x,y
  dots[ x+(y*(worldEdge.x)*2) ] = type

getRandomDot = (saveArea)->
  x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
  y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
  maxTries = 128
  saveArea = saveArea||0
  tries = 0
  while x > -saveArea && x < saveArea && y > -saveArea && y < saveArea && getDot(x,y)==0
    tries++
    x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
    y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
    if tries > maxTries then return c.l 'getRandomDot overload'
  x:x, y:y

placeRandomDots = (amount, saveArea, id)->
  amount = amount||100
  saveArea = saveArea||worldEdge.x*.6
  while amount--
    dot = getRandomDot saveArea
    setDot dot.x, dot.y, id||10

checkCollision = ->
  # check collision with dot
  for sp in shipDirDots[dir]
    dot = getDot(sp[0]+shipPos.x, sp[1]+shipPos.y)
    if dot>0
      c.l dot
      if dot==10
        score += 100*(level+1)
        setDot(sp[0]+shipPos.x, sp[1]+shipPos.y, 0)
        placeRandomDots(1, 1)
      else killed--

  # check collision with wall
checkBorderCollision = ->
  if shipPos.x >= worldEdge.x
    shipPos.x = -worldEdge.x
  else if shipPos.x < -worldEdge.x
    shipPos.x = worldEdge.x-1

  if shipPos.y >= worldEdge.y
    shipPos.y = -worldEdge.x
  else if shipPos.y < -worldEdge.y
    shipPos.y = worldEdge.x-1

checkLevel = ->
  if score>1000 && level==0
    level++
    aniSpeed -= 2
  else if score>2500 && level==1
    level++
    gameRes -= 8
    setGameRes()
  else if score>5000 && level==2
    level++
    gameRes -= 8
    setGameRes()
  else if score>10000 && level==3
    level++
    gameRes -= 4
    setGameRes()
  else if score>20000 && level==4
    level++
    gameRes -= 2
    setGameRes()
  else if score>30000 && level==5
    level++
    gameRes -= 2
    setGameRes()
  else if score>45000 && level==6
    level++
    gameRes -= 2
    setGameRes()
  else if score>65000 && level==7
    level++
    gameRes -= 2
    setGameRes()
  else if score>80000 && level==8
    level++
    gameRes -= 2
    setGameRes()
  else if score>10000 && level==9
    level++
    aniSpeed -= 1

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

# requestAnimationFrame polyfill by Erik Möller. fixes from Paul Irish and Tino Zijdel
# MIT license

do ->
  lastTime = 0
  vendors = [ 'ms', 'moz', 'webkit', 'o' ]
  x = 0
  while x < vendors.length and !window.requestAnimationFrame
    window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame']
    window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] or window[vendors[x] + 'CancelRequestAnimationFrame']
    ++x
  if !window.requestAnimationFrame

    window.requestAnimationFrame = (callback, element) ->
      currTime = (new Date).getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      id = window.setTimeout((->
        callback currTime + timeToCall
        return
      ), timeToCall)
      lastTime = currTime + timeToCall
      id

  if !window.cancelAnimationFrame

    window.cancelAnimationFrame = (id) ->
      clearTimeout id
      return
  return


window.onload = ->
  addEventListeners()
  initCanvas()
  startGame()

pieceSizeW = W / gameRes
pieceSizeH = H / gameRes

killed = false

cx = (gameRes/2)
cy = (gameRes/2)

shipPos = x:0, y:0
shipVel = x:0, y:0
dir = 0
keysPressed = ["w"]
score = 0
highscore = 0
gameRes = 0
aniSpeed = 666
level = 0

gameTick = 0

startRes = 60

worldEdge = x: 127, y: 127
dots = new Uint8Array worldEdge.x*2*worldEdge.y*2
shipDirDots = null

shipColor = 'b0ec51'
shipTrailColor = '598e07'

enemyColor = '8333a5'
enemyBodyColor = 'ac61cc'
enemyTrailColor = '3e49d2'

bonusPointsColor = 'e4cc1f'

wallColor = '20363e'

shipDirDots = [
  [
    [-1, 0], [0, 0], [+1, 0], [0, -1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0+1, 0]
  ], [
    [0-1, 0], [0, 0], [0+1, 0], [0, 0+1]
  ], [
    [0, 0-1], [0, 0], [0, 0+1], [0-1, 0]
  ]
]

killPlayer = (i)->
  i = i||0

  clearCanvas()
  drawDots()
  drawBorder()

  if i<Math.sqrt(gameRes*gameRes+gameRes*gameRes)/2
    drawDot 0+i, 0+i, shipColor
    drawDot 0-i, 0-i, shipColor
    drawDot 0+i, 0-i, shipColor
    drawDot 0-i, 0+i, shipColor
    i++
    requestAnimationFrame (-> killPlayer(i))
  else
    highscore = Math.max score, highscore
    score = 0
    startGame()

startGame = ->
  shipPos = x:0, y:19
  shipVel = x:0, y:0
  dir = 0
  keysPressed = ['w']

  dots = new Uint8Array worldEdge.x*2*worldEdge.y*2

  killed = false

  worldEdge.x = 31 # must be uneven
  worldEdge.y = 31 # must be uneven
  gameRes = 5
  aniSpeed = 14
  level = 0
  lasers = 10

  getEnemys(4)
  moveEnemy()
  setGameRes()
  placeRandomDots(10)
  nextFrame()


setGameRes = ->
  pieceSizeW = W / gameRes
  pieceSizeH = H / gameRes

  cx = gameRes/2
  cy = gameRes/2


checkKeysPressed = ()->
  k = keysPressed.shift()
  if k
    if k=='w'
      shipVel = x:0, y:-1
      dir = 0
    else if k=='d'
      shipVel = x:1, y:0
      dir = 1
    else if k=='s'
      shipVel = x:0, y:1
      dir = 2
    else if k=='a'
      shipVel = x:-1, y:0
      dir = 3

aniCnt = aniSpeed

nextFrame = ->
  if aniCnt<aniSpeed
    aniCnt++
    return requestAnimationFrame nextFrame
  else aniCnt = 0

  aniSpeed -= 1 if aniSpeed>5

  if gameRes < startRes && level==0
    gameRes += 4
    setGameRes()

  checkKeysPressed()

  shipPos.x += shipVel.x
  shipPos.y += shipVel.y


  checkCollision()
  checkBorderCollision()

  moveEnemy()
  checkCollision()


  checkLevel()

  clearCanvas()

  drawDots()
  drawBorder()
  drawShip(dir)

  drawStats()



  #setDot shipPos.x, shipPos.y, 1

  if Math.random()<.05 then placeRandomDots(1, 1)

  score += 1+level
  gameTick++

  if killed==false
    requestAnimationFrame nextFrame
  else
    killPlayer()


addEventListeners = ->
  d.body.addEventListener 'keydown', (e)->
    if (e.key=='w' || e.key=='d' || e.key=='s' || e.key=='a') && e.key != keysPressed[keysPressed.length-1]
      keysPressed.push e.key

enemys = []

getEnemys = (cnt)->
  enemys = []
  # for i in [0..cnt]
  #   m = if Math.random()>.5 then 1 else -1
  #   if Math.random()>.5
  #     mx = m
  #     my = 0
  #   else
  #     mx = 0
  #     my = m
  #   pos = getRandomDot(worldEdge.x/10)
  enemys.push pos:{x: -worldEdge.x+2, y: -6 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: -3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 0 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 3 }, mx: 1, my:0
  enemys.push pos:{x: -worldEdge.x+2, y: 6 }, mx: 1, my:0

moveEnemy = ->
  for enemy, ei in enemys
    e = enemy.pos
    setDot e.x, e.y, 0
    setDot e.x-1, e.y, 0
    setDot e.x+1, e.y, 0
    setDot e.x, e.y+1, 0
    setDot e.x, e.y-1, 0


    if Math.abs(e.x) > worldEdge.x
      e.x = -e.x
    if Math.abs(e.y) > worldEdge.y
      e.y = -e.y

    if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        x = enemy.mx
        enemy.mx = enemy.my
        enemy.my = x
    else if Math.random()>.995
      if -worldEdge.x+2 < e.x && worldEdge.x-2 > e.x && -worldEdge.y+2 < e.y && worldEdge.y-2 > e.y
        enemy.mx *= -1
        enemy.my *= -1

    e.x += enemy.mx
    e.y += enemy.my

    setDot e.x, e.y, 8
    setDot e.x-1, e.y, 6
    setDot e.x+1, e.y, 6
    setDot e.x, e.y+1, 6
    setDot e.x, e.y-1, 6

    if gameTick%41 == 40 && level>=1
      setDot e.x-enemy.mx*2, e.y-enemy.my*2, 7

drawDot = (x, y, col)->
  canvasX = (x+cx)*pieceSizeW
  canvasY = (y+cy)*pieceSizeH
  if canvasX<-pieceSizeW || canvasX > W || canvasY<-pieceSizeH || canvasY > H then return# c.l 'DRAW_DOT ERROR', canvasX, canvasY, x, y
  ctx.fillStyle = '#'+col
  ctx.fillRect .25+canvasX, .25+canvasY, pieceSizeW-.5, pieceSizeH-.5

drawShip = (dir)->
  for xy in shipDirDots[dir]
    drawDot xy[0], xy[1], shipColor

drawBorder = ->
  if shipPos.x+cx > worldEdge.x
    borderStartX = W-(shipPos.x+cx-worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect borderStartX, 0, W, H
  if shipPos.x-cx < -worldEdge.x
    borderStartX = -(shipPos.x-cx+worldEdge.x)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, borderStartX, H
  if shipPos.y+cy > worldEdge.y
    borderStartY = W-(shipPos.y+cy-worldEdge.y)*pieceSizeH
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, borderStartY, W, H
  if shipPos.y-cy < -worldEdge.y
    borderStartY = -(shipPos.y-cy+worldEdge.y)*pieceSizeW
    ctx.fillStyle = '#'+wallColor
    ctx.fillRect 0, 0, W, borderStartY

drawStats = ->
  fontSize = (W/35)
  ctx.fillStyle = '#fff'
  ctx.font = fontSize+'px c64';
  ctx.fillText('HIGHSCORE: '+highscore, 6, 4+fontSize)
  ctx.fillText('SCORE: '+score, 6, 4+fontSize*2)
  ctx.fillText('LEVEL: '+level, 6, 4+fontSize*3)

drawDots = -> # Draw visible dots
  if worldEdge.x*2<gameRes
    maxX = worldEdge.x
    startX = -worldEdge.x-shipPos.x
    endX = worldEdge.x-shipPos.x
    startY = -worldEdge.y-shipPos.y
    endY = worldEdge.y-shipPos.y
  else
    maxX = (Math.round gameRes/2)
    startX = startY = -maxX
    endX = endY = maxX

  for x in [startX...endX]#[Math.floor(-(gameRes/2))...(gameRes/2)]
    posX = x+shipPos.x
    for y in [startY...endY] # [Math.floor(-(gameRes/2))...(gameRes/2)]
      posY = shipPos.y+y
      dot = getDot posX, posY
      if dot>0
        col =
          if dot==1 then shipTrailColor
          else if dot==6 then enemyColor
          else if dot==7 then enemyTrailColor
          else if dot==8 then enemyBodyColor
          else if dot==10 then bonusPointsColor
          else if dot==25 then 'f00'
          else if dot>=50 && dot<64
            dot += 1
            setDot posX, posY, dot
            col = (0xfff-((dot-50)*0x111)).toString(16)

          else if dot>=64
            setDot posX, posY, 0
            '000'
          else 'fff'
        drawDot x, y, col

getDot = (x, y)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  #if x<0 || x>=gameRes || y<0 || y>=gameRes then return# c.l 'getDot Out of bound',x,y
  dots[ x+(y*worldEdge.x*2) ]

setDot = (x, y, type)->
  x = x + worldEdge.x
  y = y + worldEdge.y
  if x<0 || x >= worldEdge.x*2 || y<0 || y >= worldEdge.x*2 then return false# c.l 'setDot Out of bound',x,y
  dots[ x+(y*(worldEdge.x)*2) ] = type

getRandomDot = (saveArea)->
  x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
  y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
  maxTries = 128
  saveArea = saveArea||0
  tries = 0
  while x > -saveArea && x < saveArea && y > -saveArea && y < saveArea && getDot(x,y)==0
    tries++
    x = Math.round (worldEdge.x)-((Math.random()*(worldEdge.x)*2))
    y = Math.round (worldEdge.y)-((Math.random()*(worldEdge.y)*2))
    if tries > maxTries then return c.l 'getRandomDot overload'
  x:x, y:y

placeRandomDots = (amount, saveArea, id)->
  amount = amount||100
  saveArea = saveArea||worldEdge.x*.6
  while amount--
    dot = getRandomDot saveArea
    setDot dot.x, dot.y, id||10

checkCollision = ->
  # check collision with dot
  for sp in shipDirDots[dir]
    dot = getDot(sp[0]+shipPos.x, sp[1]+shipPos.y)
    if dot>0
      c.l dot
      if dot==10
        score += 100*(level+1)
        setDot(sp[0]+shipPos.x, sp[1]+shipPos.y, 0)
        placeRandomDots(1, 1)
      else killed--

  # check collision with wall
checkBorderCollision = ->
  if shipPos.x >= worldEdge.x
    shipPos.x = -worldEdge.x
  else if shipPos.x < -worldEdge.x
    shipPos.x = worldEdge.x-1

  if shipPos.y >= worldEdge.y
    shipPos.y = -worldEdge.x
  else if shipPos.y < -worldEdge.y
    shipPos.y = worldEdge.x-1

checkLevel = ->
  if score>1000 && level==0
    level++
    aniSpeed -= 2
  else if score>2500 && level==1
    level++
    gameRes -= 8
    setGameRes()
  else if score>5000 && level==2
    level++
    gameRes -= 8
    setGameRes()
  else if score>10000 && level==3
    level++
    gameRes -= 4
    setGameRes()
  else if score>20000 && level==4
    level++
    gameRes -= 2
    setGameRes()
  else if score>30000 && level==5
    level++
    gameRes -= 2
    setGameRes()
  else if score>45000 && level==6
    level++
    gameRes -= 2
    setGameRes()
  else if score>65000 && level==7
    level++
    gameRes -= 2
    setGameRes()
  else if score>80000 && level==8
    level++
    gameRes -= 2
    setGameRes()
  else if score>10000 && level==9
    level++
    aniSpeed -= 1

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

# requestAnimationFrame polyfill by Erik Möller. fixes from Paul Irish and Tino Zijdel
# MIT license

do ->
  lastTime = 0
  vendors = [ 'ms', 'moz', 'webkit', 'o' ]
  x = 0
  while x < vendors.length and !window.requestAnimationFrame
    window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame']
    window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] or window[vendors[x] + 'CancelRequestAnimationFrame']
    ++x
  if !window.requestAnimationFrame

    window.requestAnimationFrame = (callback, element) ->
      currTime = (new Date).getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      id = window.setTimeout((->
        callback currTime + timeToCall
        return
      ), timeToCall)
      lastTime = currTime + timeToCall
      id

  if !window.cancelAnimationFrame

    window.cancelAnimationFrame = (id) ->
      clearTimeout id
      return
  return


window.onload = ->
  addEventListeners()
  initCanvas()
  startGame()






























