init = ->
  canvasEl = document.getElementById 'canvas'

  nxtBtnEl = document.getElementById 'nextFrame'
  startBtnEl = document.getElementById 'start'
  stopBtnEl = document.getElementById 'stop'

  textEl = document.getElementById 'textarea'
  textOriginalEl = document.getElementById 'textOriginal'

  cpufreqRangeEL = document.getElementById 'cpufreq_range'
  cpufreqNumberEL = document.getElementById 'cpufreq_number'

  audioVolumeEL = document.getElementById 'audio_volume'

  canvasEl.width = 256
  canvasEl.height = 256
  ctx = canvasEl.getContext '2d'
  imageData = ctx.getImageData 0, 0, canvasEl.width, canvasEl.height
  data = imageData.data

  audioData = new Uint8Array(canvasEl.width*canvasEl.height)

  refreshAutomatic = true

  audioVolume = audioVolumeEL.value

  wwCanvas = new Worker "./coffee/worker.js"

  setBuffer = ->
    sr = Pico.sampleRate
    bs = Pico.bufferSize
    bufferCnt = 0

    (e) ->
      out = e.buffers
      i = 0
      while i < e.bufferSize
        pos = bs*bufferCnt
        out[0][i] = audioData[pos+i] / 255 / 255 * audioVolume
        out[1][i] = out[0][i]
        i++
      if (bufferCnt+1)*bs>audioData.length then bufferCnt = 0
      else bufferCnt++


  cycle = ->
    wwCanvas.postMessage "G" # get image data array
    if refreshAutomatic then requestAnimationFrame cycle

  wwCanvas.onmessage = (n)->
    len = n.data.length
    while len--
      audioData[len] = n.data[len]
      pos = len*4
      wwData = n.data[len]
      data[pos]  = wwData
      data[pos+1] = wwData
      data[pos+2] = wwData
      data[pos+3] = 255
    ctx.putImageData imageData, 0, 0

  prevTextValue = ""

  keyyy = (e)->
    char = ""
    for charOrig in textOriginalEl.value
      if charOrig=="a" then char += "&#8592;"
      else if charOrig=="d" then char += "&#8594;"
      else if charOrig=="w" then char += "&#8593;"
      else if charOrig=="s" then char += "&#8595;"

      else if charOrig=="r" then char += "&#10595;"
      else if charOrig=="f" then char += "&#10597;"

      else if charOrig=="y" then char += "Y"
      else if charOrig=="x" then char += "X"

      else if charOrig=="c" then char += "&#8630;"
      else if charOrig=="v" then char += "&#8631;"

      else if charOrig=="\n" then char += "<br/>"
      else char += charOrig
    textEl.innerHTML = char

    instrRaw = textOriginalEl.value
    instrRaw = instrRaw.replace(/[^23456789wasdrfyxcv\+\-\|\&\^]/g, "")
    return if instrRaw.length==0 || prevTextValue == e.target.value
    prevTextValue = e.target.value
    wwCanvas.postMessage "S"
    wwCanvas.postMessage instrRaw


  changeVolume = (e)->
    audioVolume = e.target.value
    if Pico.isPlaying == false
      Pico.play setBuffer()

  changeCpuFrequ = (e)->
    cpufreqRangeEL.value = e.target.value
    cpufreqNumberEL.value = e.target.value
    wwCanvas.postMessage "C"
    wwCanvas.postMessage e.target.value

  textOriginalEl.addEventListener "keyup", keyyy
  cpufreqRangeEL.addEventListener "change", changeCpuFrequ
  cpufreqNumberEL.addEventListener "change", changeCpuFrequ
  audioVolumeEL.addEventListener "change", changeVolume



  nxtBtnEl.addEventListener "click", ->
    refreshAutomatic = false
    cycle()

  startBtnEl.addEventListener "click", ->
    if refreshAutomatic then return false
    refreshAutomatic = true
    cycle()

  stopBtnEl.addEventListener "click", ->
    refreshAutomatic = false

  keyyy {target:textEl}
  cycle()

  Pico.play setBuffer()

window.onload = init
