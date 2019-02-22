convDeg2d = (l, deg, centre)->
  x: (l*Math.cos(deg))+centre.x
  y: (l*Math.sin(deg))+centre.y

convAngleRadian = (angle)->
  angle * (Math.PI / 180)

conv3d2d = (x, y, z, center, zoom)->
  zoom = zoom||1
  x: x/z*zoom+center.x, y: y/z*zoom+center.y

configGenerator = (config)->
  trgContainer = d.getElementById config.trgContainerId
  trgContainer.innerHTML = ''
  createInput = (name,cc)->
    iEl = d.createElement 'input'
    if cc.type=='range'
      nEl = d.createElement 'input'
      nEl.type = 'text'
      nEl.disabled = true
      nEl.value = cc.value
      iEl.type = 'range'
      iEl.min = cc.min
      iEl.max = cc.max
      iEl.step = cc.step
      iEl.value = cc.value
      iEl.onchange = (e)->
        val = parseFloat e.target.value
        cc.funct val
        nEl.value = val
      labelEl = d.createElement 'label'
      labelEl.innerText = name+': '
      trgContainer.appendChild labelEl
      trgContainer.appendChild iEl
      trgContainer.appendChild nEl
      trgContainer.appendChild d.createElement 'br'
    else if cc.type=='button'
      iEl.type = 'button'
      iEl.onclick = -> cc.funct()
      iEl.value = name
      trgContainer.appendChild iEl
    else c.l 'UNKNOWN CONFIG: ', name, cc

  for name, cc of config.content then createInput name, cc
