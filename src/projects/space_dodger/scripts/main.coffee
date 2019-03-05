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
  shipPos = x:0, y:20
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

  clearCanvas()
  drawDots()
  drawBorder()
  drawShip(dir)
  moveEnemy()
  checkLevel()
  drawStats()
  checkCollision()

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
