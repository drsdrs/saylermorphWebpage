var H, W, c, canvas, config, configControls, configControls_element, ctx, d, draw, initCanvas, startPos;

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
  ctx.strokeStyle = 'rgba(0, 0, 0, 1)';
  ctx.lineWidth = config.width;
  ctx.shadowBlur = 0;
  return ctx.shadowColor = '#00ff00';
};

config = {
  width: 2,
  length: 1.5,
  branchAngle: 120,
  branchAmount: 8,
  branchLengthShrink: .4,
  maxIterations: 10,
  randomAngle: 2
};

configControls = {
  trgContainerId: 'configControls',
  content: {
    'Branch Length': {
      funct: function(val) {
        return config.length = val;
      },
      type: 'range',
      min: 0.01,
      max: .75,
      step: .01,
      value: config.length
    },
    Reset: {
      funct: initCanvas,
      type: 'button'
    }
  }
};

draw = function(startPos, lastAngle, lastLength, iteration) {
  var angle, branchAmount, branchAngle, branchNr, doNext, i, radian, ref, results, startAngle, trgLength, trgPos;
  if (iteration > config.maxIterations) {
    return false;
  }
  if (iteration === 0) {
    branchAmount = 0;
    branchAngle = 0;
    startAngle = lastAngle;
  } else {
    branchAmount = config.branchAmount - 1;
    branchAngle = config.branchAngle / branchAmount;
    startAngle = lastAngle - config.branchAngle / 2;
    branchAngle += (config.randomAngle / 2) - (Math.random() * config.randomAngle);
  }
  results = [];
  for (branchNr = i = 0, ref = branchAmount; (0 <= ref ? i <= ref : i >= ref); branchNr = 0 <= ref ? ++i : --i) {
    ctx.lineWidth = config.width / (iteration + 1);
    ctx.beginPath(branchNr);
    angle = startAngle + branchAngle * branchNr;
    radian = convAngleRadian(angle);
    trgLength = lastLength * config.branchLengthShrink;
    trgPos = convDeg2d(trgLength, radian, startPos);
    ctx.moveTo(startPos.x, startPos.y);
    ctx.lineTo(trgPos.x, trgPos.y);
    ctx.stroke();
    doNext = function(trgPos, angle, trgLength, iteration) {
      return setTimeout((function() {
        return draw(trgPos, angle, trgLength, iteration);
      }), 0); //.1*branchNr*iteration
    };
    results.push(doNext(trgPos, angle, trgLength, iteration + 2));
  }
  return results;
};

initCanvas();

configGenerator(configControls);

startPos = {
  x: W / 2,
  y: H
};

draw(startPos, -90, config.length * H, 0);
