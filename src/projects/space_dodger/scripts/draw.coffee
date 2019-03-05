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
  ctx.font = fontSize+'px monospace';
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
