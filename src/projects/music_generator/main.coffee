W = H = canvas = ctx = center = null;


analyser.fftSize = 1<<15
bufferLength = analyser.frequencyBinCount
dataArray = new Uint8Array(bufferLength)
analyser.getByteTimeDomainData dataArray


initCanvas = ->
  if canvas != null then d.body.removeChild canvas
  W = window.innerWidth
  H = window.innerHeight*.5
  canvas = d.createElement 'canvas'
  canvas.height = H
  canvas.width = W
  ctx = canvas.getContext '2d'
  d.body.appendChild canvas


drawWave = ->
  requestAnimationFrame drawWave
  analyser.getByteTimeDomainData dataArray
  ctx.fillStyle = 'rgba(200, 200, 200, .75)'
  ctx.fillRect 0, 0, W, H/2
  ctx.lineWidth = 2
  ctx.strokeStyle = 'rgba(0, 0, 0, .75)'
  ctx.beginPath()
  sliceWidth = canvas.width * 1.0 / bufferLength
  x = 0
  i = 0
  while i < bufferLength
    v = dataArray[i] / 128.0
    y = v * canvas.height / 2
    if i == 0
      ctx.moveTo x, y
    else
      ctx.lineTo x, y/2
    x += sliceWidth
    i++
  ctx.lineTo canvas.width, canvas.height / 2
  ctx.stroke()

drawFft = ->
  drawVisual = requestAnimationFrame(drawFft)
  analyser.getByteFrequencyData dataArray
  ctx.fillStyle = 'rgba(0, 0, 0, .25)'
  ctx.fillRect 0, H/2, W, H/2
  barWidth = W / bufferLength * 2.5
  barHeight = undefined
  x = 0
  i = 0
  while i < bufferLength
    barHeight = dataArray[i] / 2
    ctx.fillStyle = 'rgba('+((H/2)-barHeight*2)+',250,250, .25)'
    ctx.fillRect x, H - (barHeight / 2), barWidth+1, barHeight
    x += barWidth + 1
    i++

window.onload = ->

  d.getElementById('unmute').onclick = (e)->
    d.body.removeChild e.target


    startDrums()
    initCanvas()
    drawWave()
    drawFft()

  d.getElementById('unmute').click()
