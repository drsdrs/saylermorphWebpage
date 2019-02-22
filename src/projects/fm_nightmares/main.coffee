c = console
c.l = c.log

res = 255
w = window.innerWidth
h = window.innerHeight

hiddenCanvas = document.createElement 'canvas'
hiddenCanvas.width = res
hiddenCanvas.height = res

hiddenCtx = hiddenCanvas.getContext '2d'
hiddenCtx.fillStyle = 'black'

hiddenCtx.font = '30px monospace'
hiddenCtx.fillText 'Saylermorph', res/8, res*.4
hiddenCtx.font = '12px monospace'
hiddenCtx.fillText 'Fear not | You are hellcome', res/7.5, res*.5

imgData = hiddenCtx.getImageData(0, 0, res, res)


dispCanvas = document.createElement 'canvas'
dispCtx = dispCanvas.getContext '2d'
dispCanvas.width = w
dispCanvas.height = h

dispCtx.webkitImageSmoothingEnabled = dispCtx.mozImageSmoothingEnabled = dispCtx.imageSmoothingEnabled = true

dispCanvas.style.background = 'grey'
document.body.appendChild dispCanvas

y = 0
x = 0

loopit = ()->
  i = imgData.data.length
  data = imgData.data


  while i
    if data[i-1]<127
      data[i-0] = (t^t>>8)&255
      data[i-1] = (data[i-2] + Math.random()*8)&255
      data[i-3] = ((t&t>>6)^t>>4)%64
      #data[i-3] = 0
      data[i-4] = (t^t>>9)&128
    i -= 4

  imgData.data = data
  hiddenCtx.putImageData imgData, 0,0
  dispCtx.drawImage hiddenCanvas, x, y, w, h
  if Math.random()<.5
    y += Math.random()-.5
    x += Math.random()-.5
    x %= res
    y %= res


  sinea.frequency.value = 50+((t&t>>6)^t>>4)%444
  osc.frequency.value = 50+((t&t>>16)&t>>3)%1200
  sineagain.gain.value = (t^t>>8)&255
  if oscgain.gain.value < .25 then oscgain.gain.value += .0005
  t += 3



# FM SYNTH

audioCtx = new (window.AudioContext || window.webkitAudioContext)()
sinea = audioCtx.createOscillator()

sinea.frequency.value = 25.5
sinea.type = "sine"
sineagain = audioCtx.createGain()
sineagain.gain.value = 100
sinea.connect(sineagain);
sinea.start()

osc = audioCtx.createOscillator()
osc.type = "sine"
osc.frequency.value = 440
oscgain = audioCtx.createGain()
oscgain.gain.value = 0
osc.connect(oscgain)

sineagain.connect(osc.frequency)

oscgain.connect(audioCtx.destination)

osc.start()

t = 1


loopit()
setInterval loopit, 1000/20
