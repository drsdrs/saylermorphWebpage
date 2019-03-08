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
