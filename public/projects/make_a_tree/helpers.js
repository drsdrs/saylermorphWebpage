var configGenerator, convAngleRadian, convDeg2d;

convDeg2d = function(l, deg, centre) {
  return {
    x: (l * Math.cos(deg)) + centre.x,
    y: (l * Math.sin(deg)) + centre.y
  };
};

convAngleRadian = function(angle) {
  return angle * (Math.PI / 180);
};

configGenerator = function(config) {
  var cc, createInput, name, ref, results, trgContainer;
  trgContainer = d.getElementById(config.trgContainerId);
  trgContainer.innerHTML = '';
  createInput = function(name, cc) {
    var iEl, labelEl;
    iEl = d.createElement('input');
    if (cc.type === 'range') {
      iEl.type = 'range';
      iEl.min = cc.min;
      iEl.max = cc.max;
      iEl.step = cc.step;
      iEl.value = cc.value;
      iEl.onchange = function(e) {
        return cc.funct(parseFloat(e.target.value));
      };
      labelEl = d.createElement('label');
      labelEl.innerText = name + ': ';
      trgContainer.appendChild(labelEl);
      trgContainer.appendChild(iEl);
      return trgContainer.appendChild(d.createElement('br'));
    } else if (cc.type === 'button') {
      iEl.type = 'button';
      iEl.onclick = function() {
        return cc.funct();
      };
      iEl.value = name;
      return trgContainer.appendChild(iEl);
    } else {
      return c.l('UNKNOWN CONFIG: ', name, cc);
    }
  };
  ref = config.content;
  results = [];
  for (name in ref) {
    cc = ref[name];
    results.push(createInput(name, cc));
  }
  return results;
};
