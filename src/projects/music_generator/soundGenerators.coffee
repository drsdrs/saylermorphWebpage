d = document
c = console
c.l = c.log
instruments = null

ac = new (window.AudioContext || window.webkitAudioContext)()
analyser = ac.createAnalyser()

Kick = ->
  osc = ac.createOscillator()
  gain = ac.createGain()
  filter = ac.createBiquadFilter()

  osc.type = 'square'
  osc.frequency.value = 0

  filter.type = 'lowpass'
  filter.frequency.value = 0
  filter.Q.value = 0
  gain.gain.value = 0

  osc.connect(filter)
  filter.connect(gain)
  gain.connect(analyser)
  analyser.connect(ac.destination)
  osc.start()
  instrument =
    frequency:
      start: 400
      end: 0
      length: .43
    filterFrequency:
      start: 1000
      end: 50
      length: .5
    filterQ:
      start: 22
      end: .1
      length: .3
    trigger: ->
      gain.gain.value = 0.2

      osc.frequency.value = @frequency.start
      filter.frequency.value = @filterFrequency.start
      filter.Q.value = @filterQ.start
      osc.frequency.exponentialRampToValueAtTime(@frequency.end+0.001, ac.currentTime+@frequency.length)
      filter.frequency.exponentialRampToValueAtTime(@filterFrequency.end+0.001, ac.currentTime+@filterFrequency.length)
      filter.Q.exponentialRampToValueAtTime(@filterQ.end+0.001, ac.currentTime+@filterQ.length)

Fm = ->
  sinea = ac.createOscillator() # frequ-modulator
  osc = ac.createOscillator() # carrier

  sinea.frequency.value = 0
  sinea.type = "sine"
  sineagain = ac.createGain()
  sineagain.gain.value = 0
  sinea.connect(sineagain);

  osc = ac.createOscillator()
  osc.type = "sine"
  osc.frequency.value = 0
  oscgain = ac.createGain()
  oscgain.gain.value = 0

  osc.connect(oscgain)
  sineagain.connect(osc.frequency)
  oscgain.connect(analyser)
  analyser.connect(ac.destination)

  sinea.start()
  osc.start()

  instrument =
    osc:
      frequency: 520
    modulator:
      frequency: 455
    envelopeCarrierVolume:
      start: .4
      end: 0
      length: 1.75
    envelopeModulatorVolume:
      start: 1220
      end: 5
      length: 6
    trigger: ->
      sinea.frequency.value = @modulator.frequency
      osc.frequency.value = @osc.frequency
      oscgain.gain.value = @envelopeCarrierVolume.start
      sineagain.gain.value = @envelopeModulatorVolume.start
      oscgain.gain.exponentialRampToValueAtTime(@envelopeCarrierVolume.end+0.001, ac.currentTime+@envelopeCarrierVolume.length)
      sineagain.gain.exponentialRampToValueAtTime(@envelopeModulatorVolume.end+0.001, ac.currentTime+@envelopeModulatorVolume.length)

startDrums = ->
  instruments =
    kick: Kick()
    fm: Fm()

  intrumentConfigGenerator 'kick'
  intrumentConfigGenerator 'fm'

  setInterval (->
    instruments.fm.trigger()
    #kick.filterFrequency.start = Math.random()*4000
    #instruments.fm.modulator.frequency = Math.random()*400
    #instruments.fm.osc.frequency = Math.random()*4400
  ), 1000*.3333334

  setInterval (->
    #instruments.kick.trigger()
    #kick.filterFrequency.start = Math.random()*4000
    #kick.filterFrequency.end = Math.random()*400
  ), 1000*1

intrumentConfigGenerator = (instrName)->
  instr = instruments[instrName]
  cEl = d.createElement 'div'
  cEl.className = 'instrumentConfig'
  h1El = d.createElement 'h1'
  h1El.innerText = instrName

  d.body.appendChild h1El
  d.body.appendChild cEl


  Object.keys(instr).forEach (groupName)->
    groupValues = instr[groupName]

    return if typeof groupValues=='function'
    hEl = d.createElement 'h4'
    hEl.innerText = groupName
    cEl.appendChild hEl
    Object.keys(groupValues).forEach (name)->
      val = instr[groupName][name]
      lEl = d.createElement 'label'
      lEl.innerText = name+': '
      iEl = d.createElement 'input'

      iEl.type = 'number'
      iEl.value = val
      iEl.step = .1
      iEl.min = 0.01
      iEl.oninput = (e)->
        val = Math.max e.target.value, 0#0.01
        e.target.value = val
        instruments[instrName][groupName][name] = parseFloat val

      lEl.appendChild iEl
      cEl.appendChild lEl
