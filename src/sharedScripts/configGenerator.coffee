configGenerator = (config)->
  trgContainer = document.getElementById config.trgContainerId
  trgContainer.innerHTML = ''
  createInput = (name, cc)->
    iEl = document.createElement 'input'
    if cc.type=='range'
      nEl = document.createElement 'input'
      nEl.type = 'text'
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
      nEl.onchange = (e)->
        val = parseFloat e.target.value
        cc.funct val
        iEl.value = val

      labelEl = document.createElement 'label'
      labelEl.innerText = name+': '
      trgContainer.appendChild labelEl
      trgContainer.appendChild iEl
      trgContainer.appendChild nEl
      trgContainer.appendChild document.createElement 'br'
    else if cc.type=='button'
      iEl.type = 'button'
      iEl.onclick = -> cc.funct()
      iEl.value = name
      trgContainer.appendChild iEl
    else c.l 'UNKNOWN CONFIG: ', name, cc

  for name, cc of config.content then createInput name, cc
