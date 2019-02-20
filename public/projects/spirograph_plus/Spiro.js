var H, W, c, canvas, configControls_element, ctx, d, draw, initCanvas, oldXY, playing, spiroConfig, spiroConfigControls, spiroPos;

d = document;

c = console;

c.l = c.log;

W = H = canvas = ctx = null;

configControls_element = d.getElementById('configControls');

d.getElementById('openCloseConfig').onclick = function() {
  if (configControls_element.style.display === 'none') {
    return configControls_element.style.display = 'block';
  } else {
    return configControls_element.style.display = 'none';
  }
};

initCanvas = function() {
  if (canvas !== null) {
    d.body.removeChild(canvas);
  }
  W = Math.min(window.innerWidth, window.innerHeight);
  H = W;
  canvas = d.createElement('canvas');
  canvas.height = H;
  canvas.width = W;
  ctx = canvas.getContext('2d');
  d.body.appendChild(canvas);
  ctx.fillStyle = '#ffffff';
  ctx.fillRect(0, 0, W, H);
  ctx.rect(0, 0, W, H);
  ctx.stroke();
  ctx.strokeStyle = 'rgba(0, 0, 0, 0.1)';
  ctx.lineWidth = spiroConfig.lineAttr.width;
  ctx.shadowBlur = spiroConfig.lineAttr.blur;
  return ctx.shadowColor = '#ffffff';
};

spiroConfig = {
  length: [.1, .3, .1],
  speed: [.02, .002, .2],
  lineAttr: {
    width: .3,
    blur: 0,
    color: 0x000000,
    blurColor: 0xffffff
  }
};

spiroConfigControls = {
  trgContainerId: 'configControls',
  mainObject: 'spiroConfig',
  content: {
    Length_0: {
      funct: function(val) {
        return spiroConfig.length[0] = val;
      },
      type: 'range',
      min: 0.001,
      max: .75,
      step: 0.01,
      value: spiroConfig.length[0]
    },
    Length_1: {
      funct: function(val) {
        return spiroConfig.length[1] = val;
      },
      type: 'range',
      min: 0.001,
      max: .75,
      step: 0.01,
      value: spiroConfig.length[1]
    },
    Length_2: {
      funct: function(val) {
        return spiroConfig.length[2] = val;
      },
      type: 'range',
      min: 0.001,
      max: .75,
      step: 0.01,
      value: spiroConfig.length[2]
    },
    Speed_0: {
      funct: function(val) {
        return spiroConfig.speed[0] = val;
      },
      type: 'range',
      min: 0.001,
      max: Math.PI / 8,
      step: 0.001,
      value: spiroConfig.speed[0]
    },
    Speed_1: {
      funct: function(val) {
        return spiroConfig.speed[1] = val;
      },
      type: 'range',
      min: 0.001,
      max: Math.PI / 8,
      step: 0.001,
      value: spiroConfig.speed[1]
    },
    Speed_2: {
      funct: function(val) {
        return spiroConfig.speed[2] = val;
      },
      type: 'range',
      min: 0.001,
      max: Math.PI / 8,
      step: 0.001,
      value: spiroConfig.speed[2]
    },
    Line_Width: {
      funct: function(val) {
        return ctx.lineWidth = spiroConfig.lineAttr.width = val;
      },
      type: 'range',
      min: .1,
      max: 2,
      step: 0.01,
      value: spiroConfig.lineAttr.width
    },
    Blur_Width: {
      funct: function(val) {
        return ctx.shadowBlur = spiroConfig.lineAttr.blur = val;
      },
      type: 'range',
      min: 0,
      max: 3,
      step: 0.001,
      value: spiroConfig.lineAttr.blur
    },
    Reset: {
      funct: initCanvas,
      type: 'button'
    },
    SaveImage: {
      funct: function() {
        var img;
        img = canvas.toDataURL('image/png').replace('image/png', 'image/octet-stream');
        return window.location.href = img;
      },
      type: 'button'
    }
  }
};

playing = true;

spiroPos = [0, 0, 0];

oldXY = {
  x: W / 2,
  y: H / 2
};

draw = function() {
  var center, circleNr, i;
  ctx.beginPath();
  center = {
    x: W / 2,
    y: H / 2
  };
  ctx.moveTo(oldXY.x, oldXY.y);
  for (circleNr = i = 0; i <= 2; circleNr = ++i) {
    center = convDeg2d(W * spiroConfig.length[circleNr], spiroPos[circleNr], center);
    spiroPos[circleNr] += spiroConfig.speed[circleNr];
    ctx.lineTo(center.x, center.y);
  }
  ctx.stroke();
  return oldXY = center;
};

initCanvas();

configGenerator(spiroConfigControls);

setInterval((function() {
  return draw();
}), -1);
