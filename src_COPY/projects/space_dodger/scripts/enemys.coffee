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
