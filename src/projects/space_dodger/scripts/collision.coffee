checkCollision = ->
  # check collision with dot
  for sp in shipDirDots[dir]
    dot = getDot(sp[0]+shipPos.x, sp[1]+shipPos.y)
    if dot>0
      if dot==10
        score += 100*(level+1)
        setDot(sp[0]+shipPos.x, sp[1]+shipPos.y, 0)
        placeRandomDots(1, 1)
      else killed--

  # check collision with wall

  if shipPos.x >= worldEdge.x
    shipPos.x = -worldEdge.x
  else if shipPos.x < -worldEdge.x
    shipPos.x = worldEdge.x-1

  if shipPos.y >= worldEdge.y
    shipPos.y = -worldEdge.x
  else if shipPos.y < -worldEdge.y
    shipPos.y = worldEdge.x-1
