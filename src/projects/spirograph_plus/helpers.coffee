convDeg2d = (l, deg, centre)->
  x: (l*Math.cos(deg))+centre.x
  y: (l*Math.sin(deg))+centre.y
  
convAngleRadian = (angle)->
  angle * (Math.PI / 180)


configGenerator = (config)->
  trgContainer = d.getElementById config.trgContainerId 
  trgContainer.innerHTML = ''
  createInput = (name,cc)->
    iEl = d.createElement 'input'
    if cc.type=='range'
      iEl.type = 'range'
      iEl.min = cc.min
      iEl.max = cc.max
      iEl.step = cc.step
      iEl.value = cc.value
      iEl.onchange = (e)->
        cc.funct parseFloat e.target.value
      labelEl = d.createElement 'label'
      labelEl.innerText = name+': '
      trgContainer.appendChild labelEl
      trgContainer.appendChild iEl
      trgContainer.appendChild d.createElement 'br'
    else if cc.type=='button'
      iEl.type = 'button'
      iEl.onclick = -> cc.funct()
      iEl.value = name
      trgContainer.appendChild iEl
    else c.l 'UNKNOWN CONFIG: ', name, cc
      
  for name, cc of config.content then createInput name, cc
