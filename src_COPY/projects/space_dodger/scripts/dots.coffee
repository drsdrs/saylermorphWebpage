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
