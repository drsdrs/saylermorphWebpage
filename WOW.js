(function() {
  // requestAnimationFrame polyfill by Erik Möller. fixes from Paul Irish and Tino Zijdel
  // MIT license
  /*
    VM_INSTRUCTIONS
    --- STACK ---
    w = pointer up
    s = pointer down
    a = pointer left
    d = pointer right
    r = inc cell
    f = dec cell
    c = set cell to tempRegister
    v = set tempRegister to cell
    x = set pointerX to tempregister
    y = set pointerY to tempregister
    --- LOOP ---
    0-9 = repeat prev instruction, following numbers are multiplied
    --- MATH --- use operator on pointerValue and tempregister then copy result into tempregister
    + = add
    - = remove
    & = AND
    | = OR
    ^ = XOR

    > = Shift TmpRegister Right
    < = Shift TmpRegister Right

   */
  /*
   * TODO:
    only render on button press

   */
  var DEBUG, DEBUG_TEMPREGISTER, H, Textmode, W, addEventListeners, alu, aniCnt, aniSpeed, audioCtx, bonusPointsColor, branchCnt, branchDrawn, c, canvas, center, checkBorderCollision, checkCollision, checkKeysPressed, checkLevel, clearCanvas, color, config, configControls, configControls_element, configGen, ctx, cx, cy, d, decStackCell, defaultSize, dir, dispCanvas, dispCtx, doneDrawBranches, dots, draw, drawBorder, drawBranchPositions, drawDot, drawDots, drawShip, drawStar, drawStats, enemyBodyColor, enemyColor, enemyTrailColor, enemys, gameRes, gameTick, getDot, getEnemys, getRandomDot, getStackCell, getStar, getTempRegister, h, hiddenCanvas, hiddenCtx, highscore, imgData, incStackCell, init, initCanvas, instructionPointer, instructions, instructionsPerCycle, isDrawing, isDrawing_element, isPlaying, keysPressed, killPlayer, killed, level, loopit, maxBranches, moveEnemy, nextFrame, nextMsgType, oldXY, osc, oscgain, parseInstructions, pieceSizeH, pieceSizeW, placeRandomDots, playing, pointer, pointer2D, position, process, processInstructionSet, processing, programmListing, res, resetStack, score, setDot, setGameRes, setPointer2D, setPointerFrom2D, setStackCell, setTempRegister, shipColor, shipDirDots, shipPos, shipTrailColor, shipVel, sinea, sineagain, spiroConfig, spiroConfigControls, spiroPos, stack, stackLength, stars, startDrawing, startGame, startPos, startRes, t, tempRegister, w, wallColor, worldEdge, x, y;

  (function() {
    var lastTime, vendors, x;
    lastTime = 0;
    vendors = ['ms', 'moz', 'webkit', 'o'];
    x = 0;
    while (x < vendors.length && !window.requestAnimationFrame) {
      window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame'];
      window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] || window[vendors[x] + 'CancelRequestAnimationFrame'];
      ++x;
    }
    if (!window.requestAnimationFrame) {
      window.requestAnimationFrame = function(callback, element) {
        var currTime, id, timeToCall;
        currTime = (new Date).getTime();
        timeToCall = Math.max(0, 16 - (currTime - lastTime));
        id = window.setTimeout((function() {
          callback(currTime + timeToCall);
        }), timeToCall);
        lastTime = currTime + timeToCall;
        return id;
      };
    }
    if (!window.cancelAnimationFrame) {
      window.cancelAnimationFrame = function(id) {
        clearTimeout(id);
      };
    }
  })();

  init = function() {
    var audioData, audioVolume, audioVolumeEL, canvasEl, changeCpuFrequ, changeVolume, cpufreqNumberEL, cpufreqRangeEL, ctx, cycle, data, imageData, keyyy, nxtBtnEl, prevTextValue, refreshAutomatic, setBuffer, startBtnEl, stopBtnEl, textEl, textOriginalEl, wwCanvas;
    canvasEl = document.getElementById('canvas');
    nxtBtnEl = document.getElementById('nextFrame');
    startBtnEl = document.getElementById('start');
    stopBtnEl = document.getElementById('stop');
    textEl = document.getElementById('textarea');
    textOriginalEl = document.getElementById('textOriginal');
    cpufreqRangeEL = document.getElementById('cpufreq_range');
    cpufreqNumberEL = document.getElementById('cpufreq_number');
    audioVolumeEL = document.getElementById('audio_volume');
    canvasEl.width = 256;
    canvasEl.height = 256;
    ctx = canvasEl.getContext('2d');
    imageData = ctx.getImageData(0, 0, canvasEl.width, canvasEl.height);
    data = imageData.data;
    audioData = new Uint8Array(canvasEl.width * canvasEl.height);
    refreshAutomatic = true;
    audioVolume = audioVolumeEL.value;
    wwCanvas = new Worker("./coffee/worker.js");
    setBuffer = function() {
      var bs, bufferCnt, sr;
      sr = Pico.sampleRate;
      bs = Pico.bufferSize;
      bufferCnt = 0;
      return function(e) {
        var i, out, pos;
        out = e.buffers;
        i = 0;
        while (i < e.bufferSize) {
          pos = bs * bufferCnt;
          out[0][i] = audioData[pos + i] / 255 / 255 * audioVolume;
          out[1][i] = out[0][i];
          i++;
        }
        if ((bufferCnt + 2) * bs > audioData.length) {
          return bufferCnt = 0;
        } else {
          return bufferCnt++;
        }
      };
    };
    cycle = function() {
      wwCanvas.postMessage("G"); // get image data array
      if (refreshAutomatic) {
        return requestAnimationFrame(cycle);
      }
    };
    wwCanvas.onmessage = function(n) {
      var len, pos, wwData;
      len = n.data.length;
      while (len--) {
        audioData[len] = n.data[len];
        pos = len * 4;
        wwData = n.data[len];
        data[pos] = wwData;
        data[pos + 1] = wwData;
        data[pos + 2] = wwData;
        data[pos + 3] = 255;
      }
      return ctx.putImageData(imageData, 0, 0);
    };
    prevTextValue = "";
    keyyy = function(e) {
      var char, charOrig, instrRaw, j, len1, ref;
      char = "";
      ref = textOriginalEl.value;
      for (j = 0, len1 = ref.length; j < len1; j++) {
        charOrig = ref[j];
        if (charOrig === "a") {
          char += "&#8592;";
        } else if (charOrig === "d") {
          char += "&#8594;";
        } else if (charOrig === "w") {
          char += "&#8593;";
        } else if (charOrig === "s") {
          char += "&#8595;";
        } else if (charOrig === "r") {
          char += "&#10595;";
        } else if (charOrig === "f") {
          char += "&#10597;";
        } else if (charOrig === "y") {
          char += "Y";
        } else if (charOrig === "x") {
          char += "X";
        } else if (charOrig === "c") {
          char += "&#8630;";
        } else if (charOrig === "v") {
          char += "&#8631;";
        } else if (charOrig === "\n") {
          char += "<br/>";
        } else {
          char += charOrig;
        }
      }
      textEl.innerHTML = char;
      instrRaw = textOriginalEl.value;
      instrRaw = instrRaw.replace(/[^23456789wasdrfyxcv\+\-\|\&\^]/g, "");
      if (instrRaw.length === 0 || prevTextValue === e.target.value) {
        return;
      }
      prevTextValue = e.target.value;
      wwCanvas.postMessage("S");
      return wwCanvas.postMessage(instrRaw);
    };
    changeVolume = function(e) {
      audioVolume = e.target.value;
      if (Pico.isPlaying === false) {
        return Pico.play(setBuffer());
      }
    };
    changeCpuFrequ = function(e) {
      cpufreqRangeEL.value = e.target.value;
      cpufreqNumberEL.value = e.target.value;
      wwCanvas.postMessage("C");
      return wwCanvas.postMessage(e.target.value);
    };
    textOriginalEl.addEventListener("keyup", keyyy);
    cpufreqRangeEL.addEventListener("change", changeCpuFrequ);
    cpufreqNumberEL.addEventListener("change", changeCpuFrequ);
    audioVolumeEL.addEventListener("change", changeVolume);
    nxtBtnEl.addEventListener("click", function() {
      refreshAutomatic = false;
      return cycle();
    });
    startBtnEl.addEventListener("click", function() {
      if (refreshAutomatic) {
        return false;
      }
      refreshAutomatic = true;
      return cycle();
    });
    stopBtnEl.addEventListener("click", function() {
      return refreshAutomatic = false;
    });
    keyyy({
      target: textEl
    });
    cycle();
    return Pico.play(setBuffer());
  };

  window.onload = init;

  DEBUG = false;

  DEBUG_TEMPREGISTER = false;

  instructions = "";

  instructionPointer = 0;

  defaultSize = 256;

  stack = new Uint8Array(defaultSize * defaultSize);

  stackLength = defaultSize * defaultSize;

  pointer = 0;

  pointer2D = new Uint8Array(2);

  instructionsPerCycle = 32768;

  processing = false;

  tempRegister = new Uint8Array(1); // for temporary register as calculation

  incStackCell = function() {
    return stack[pointer]++;
  };

  decStackCell = function() {
    return stack[pointer]--;
  };

  getStackCell = function() {
    return stack[pointer];
  };

  setStackCell = function(val) {
    return stack[pointer] = val;
  };

  getTempRegister = function() {
    return tempRegister[0];
  };

  setTempRegister = function(newVal) {
    tempRegister[0] = newVal;
    tempRegister[0] &= 255;
    if (DEBUG_TEMPREGISTER) {
      return console.log('setTempregister ' + tempRegister[0]);
    }
  };

  alu = function(operator) {
    if (operator === "+") {
      return setTempRegister(getStackCell() + getTempRegister());
    } else if (operator === "-") {
      return setTempRegister(getStackCell() - getTempRegister());
    } else if (operator === "&") {
      return setTempRegister(getStackCell() & getTempRegister());
    } else if (operator === "^") {
      return setTempRegister(getStackCell() ^ getTempRegister());
    } else if (operator === "|") {
      return setTempRegister(getStackCell() | getTempRegister());
    } else if (operator === "<") {
      return setTempRegister(getTempRegister() << 1);
    } else if (operator === ">") {
      return setTempRegister(getTempRegister() >> 1);
    }
  };

  resetStack = function() {
    var i;
    i = stackLength;
    while (i--) {
      stack[i] = 0;
    }
    instructionPointer = 0;
    pointer = 0;
    pointer2D[0] = 0;
    pointer2D[1] = 0;
    return setTempRegister(0);
  };

  parseInstructions = function(instrUnparsed) {
    var checkLoop, i, j, lastInstr, len1, loopStack, parsedInst;
    parsedInst = "";
    lastInstr = "";
    loopStack = [];
    checkLoop = function() {
      var results, totalLoopLength;
      if (loopStack.length > 0) {
        totalLoopLength = 1;
        while (loopStack.length) {
          totalLoopLength *= loopStack.pop();
        }
        totalLoopLength--;
        if (totalLoopLength > stackLength) {
          totalLoopLength = stackLength;
        }
        results = [];
        while (totalLoopLength--) {
          results.push(parsedInst += lastInstr || "");
        }
        return results;
      }
    };
    for (j = 0, len1 = instrUnparsed.length; j < len1; j++) {
      i = instrUnparsed[j];
      if (isNaN(i)) { //# NOT Number
        checkLoop();
        parsedInst += i;
        lastInstr = i; // NUMBER
      } else {
        if (i !== 0) {
          loopStack.push(i);
        }
      }
    }
    checkLoop();
    resetStack();
    //console.log 'setInstr: '+parsedInst
    return instructions = parsedInst;
  };

  process = function(i) { // i=instruction
    if (i === "w" || i === "a" || i === "s" || i === "d") {
      return setPointer2D(i);
    } else if (i === "+" || i === "-" || i === "^" || i === "&" || i === "|" || i === "<" || i === ">") {
      return alu(i);
    } else if (i === "r") {
      return incStackCell();
    } else if (i === "f") {
      return decStackCell();
    } else if (i === "x") {
      pointer2D[0] = getTempRegister();
      return setPointerFrom2D();
    } else if (i === "y") {
      pointer2D[1] = getTempRegister();
      return setPointerFrom2D();
    } else if (i === "c") {
      return setStackCell(getTempRegister());
    } else if (i === "v") {
      return setTempRegister(getStackCell());
    }
  };

  processInstructionSet = function() {
    var instrLen, instruction, len, tempInstr, x;
    if (processing === true) { //throw 666
      return;
    }
    tempInstr = instructions;
    instrLen = tempInstr.length;
    if (instrLen === 0) {
      return;
    }
    len = instructionsPerCycle;
    processing = true;
    x = 0;
    while (len--) {
      if (instructionPointer === instrLen) {
        instructionPointer = 0;
      }
      instruction = tempInstr[instructionPointer];
      process(instruction);
      if (DEBUG) {
        console.log('next instruction: ' + instruction + ' pointer: ' + pointer2D + ' stackValue: ' + getStackCell() + ' tempregister: ' + getTempRegister());
      }
      instructionPointer++;
    }
    return processing = false;
  };

  setPointer2D = function(dir) {
    if (dir === "w") {
      if (pointer2D[1] === 0) {
        pointer2D[1] = defaultSize - 1;
      } else {
        pointer2D[1]--;
      }
      return setPointerFrom2D();
    } else if (dir === "s") {
      if (pointer2D[1] === defaultSize - 1) {
        pointer2D[1] = 0;
      } else {
        pointer2D[1]++;
      }
      return setPointerFrom2D();
    } else if (dir === "a") {
      if (pointer2D[0] === 0) {
        pointer2D[0] = defaultSize - 1;
      } else {
        pointer2D[0]--;
      }
      return setPointerFrom2D();
    } else if (dir === "d") {
      if (pointer2D[0] === defaultSize - 1) {
        pointer2D[0] = 0;
      } else {
        pointer2D[0]++;
      }
      return setPointerFrom2D();
    } else {
      return console.log("ERROR in setPointer2D, dir: " + dir);
    }
  };

  setPointerFrom2D = function() {
    return pointer = pointer2D[0] + (pointer2D[1] * defaultSize);
  };

  nextMsgType = "";

  self.onmessage = function(n) {
    if (nextMsgType === "getInstructions") {
      nextMsgType = '';
      while (processing === true) {
        null; //throw 6660666
      }
      parseInstructions(n.data);
    } else if (nextMsgType === "getCpuFreq") {
      instructionsPerCycle = parseInt(n.data);
      nextMsgType = '';
    }
    if (n.data === 'S') { // set instructions
      nextMsgType = 'getInstructions';
    } else if (n.data === 'C') {
      nextMsgType = 'getCpuFreq';
    } else if (n.data === 'G') { // get imagedata
      self.postMessage(stack);
      processInstructionSet();
    }
  };

  (function() {    // requestAnimationFrame polyfill by Erik Möller. fixes from Paul Irish and Tino Zijdel
    // MIT license
    var lastTime, vendors, x;
    lastTime = 0;
    vendors = ['ms', 'moz', 'webkit', 'o'];
    x = 0;
    while (x < vendors.length && !window.requestAnimationFrame) {
      window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame'];
      window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] || window[vendors[x] + 'CancelRequestAnimationFrame'];
      ++x;
    }
    if (!window.requestAnimationFrame) {
      window.requestAnimationFrame = function(callback, element) {
        var currTime, id, timeToCall;
        currTime = (new Date).getTime();
        timeToCall = Math.max(0, 16 - (currTime - lastTime));
        id = window.setTimeout((function() {
          callback(currTime + timeToCall);
        }), timeToCall);
        lastTime = currTime + timeToCall;
        return id;
      };
    }
    if (!window.cancelAnimationFrame) {
      window.cancelAnimationFrame = function(id) {
        clearTimeout(id);
      };
    }
  })();

  init = function() {
    var activeCharCode, activeLiEl, adjustFont, centerScreen, centerScreenFunct, fontSize, getStyle, iconPos, mouseWheelHandler, resizeFont, screenEl, screenWrapEl, setIcon, styleBackgroundSize, styleHoverChar, tm;
    screenEl = document.getElementById('textmode_screen');
    screenWrapEl = document.getElementById('textmode_wrap');
    styleHoverChar = document.createElement("style");
    styleBackgroundSize = document.createElement("style");
    tm = new Textmode(screenEl);
    iconPos = 0;
    fontSize = 25;
    activeCharCode = String.fromCharCode(0xe0a9);
    activeLiEl = null;
    mouseWheelHandler = function(e) {
      var charCodeString, delta;
      e = window.event || e;
      delta = Math.max(-1, Math.min(1, e.wheelDelta || -e.detail));
      iconPos += delta;
      iconPos = iconPos < 0 ? 95 : iconPos > 94 ? 0 : iconPos;
      charCodeString = "e0" + (0xa0 + iconPos).toString(16);
      activeCharCode = String.fromCharCode(parseInt(charCodeString, 16));
      return setIcon();
    };
    setIcon = function() {
      return styleHoverChar.innerHTML = '#textmode_screen ul li:hover::before {\n content: "' + activeCharCode + '";\n font-size: ' + fontSize + 'px;\n }';
    };
    centerScreenFunct = function() {
      return centerScreen(screenWrapEl, screenEl);
    };
    centerScreen = function(parent, child) {
      var paddingLeft, paddingTop;
      parent.height = window.innerHeight;
      paddingLeft = (parent.offsetWidth - child.offsetWidth) / 2;
      paddingTop = (parent.height - child.offsetHeight) / 2;
      if (paddingTop < 2 || paddingLeft < 2) {
        return -1;
      } else if ((paddingTop > child.offsetHeight / 5) && (paddingLeft > child.offsetWidth / 5)) {
        return 1;
      } else {
        parent.style.padding = paddingTop + 'px ' + paddingLeft + 'px';
        return 0;
      }
    };
    getStyle = function(className) {
      var classes, x;
      classes = document.styleSheets[0].rules || document.styleSheets[0].cssRules;
      x = 0;
      while (x < classes.length) {
        if (classes[x].selectorText === className) {
          return classes[x].style;
        }
        x++;
      }
    };
    window.addEventListener('resize', function() {
      centerScreenFunct();
      adjustFont();
      return setIcon();
    });
    screenEl.addEventListener('mouseover', function(e) {
      if (e.target.tagName.toLowerCase() === 'li') {
        return activeLiEl = e.target;
      }
    });
    screenEl.addEventListener('mousewheel', mouseWheelHandler);
    screenEl.addEventListener('contextmenu', function(e) {
      e.preventDefault();
      activeCharCode = activeLiEl.innerHTML;
      if (activeCharCode === "&nbsp;") {
        activeCharCode = String.fromCharCode(0xa0);
      }
      setIcon();
      return false;
    });
    screenEl.addEventListener('click', function() {
      if (activeLiEl != null) {
        return activeLiEl.innerHTML = activeCharCode;
      }
    });
    resizeFont = function(amount) {
      fontSize += amount;
      screenEl.style.fontSize = (fontSize + amount) + 'px';
      return styleBackgroundSize.innerHTML = '#textmode_wrap::after { background-size: ' + (fontSize * 0.175) + 'px }';
    };
    adjustFont = function() {
      var cnt, resizeRes;
      resizeRes = centerScreenFunct();
      cnt = 0;
      while (resizeRes !== 0) {
        resizeRes = centerScreenFunct();
        resizeFont(resizeRes);
        cnt++;
        if ((cnt++) > 120) {
          resizeRes = 0; //;alert 'problem detected in adjustFont Function'
        }
      }
      resizeFont(0);
      return centerScreenFunct();
    };
    document.head.appendChild(styleHoverChar);
    document.head.appendChild(styleBackgroundSize);
    centerScreenFunct();
    adjustFont();
    return setIcon();
  };

  window.onload = init;

  Textmode = (function() {
    class Textmode {
      constructor(textEl) {
        this.keydown = this.keydown.bind(this);
        this.keypress = this.keypress.bind(this);
        this.newLine = this.newLine.bind(this);
        this.cycle = this.cycle.bind(this);
        this.el = textEl;
        this.initScreen();
        this.welcomeMsg();
        window.addEventListener('keydown', this.keydown);
        window.addEventListener('keypress', this.keypress);
        requestAnimationFrame(this.cycle);
      }

      keydown(e) {
        if (e.keyCode === 8) { // BACKSPACE
          e.preventDefault();
          this.delChar();
          return false;
        }
        if (e.ctrlKey && e.shiftKey) {
          return this.switchCaps();
        } else if (e.keyCode === 37) {
          return this.checkCursor(this.cursor.x - 1, null); // LEFT ARROW
        } else if (e.keyCode === 39) {
          return this.checkCursor(this.cursor.x + 1, null); // RIGHT ARROW
        } else if (e.keyCode === 40) {
          return this.checkCursor(null, this.cursor.y + 1); // TOP ARROW
        } else if (e.keyCode === 38) {
          return this.checkCursor(null, this.cursor.y - 1); // BOTTOM ARROW
        }
      }

      keypress(e) {
        var charCode;
        if (e.keyCode === 13) {
          return this.getLine(); // ENTER
        } else if ((e.keyCode || e.charCode) === 32) {
          return this.putChar('&nbsp;'); // SPACE
        } else {
          charCode = e.keyCode === 0 ? e.charCode : e.keyCode;
          return this.putChar(String.fromCharCode(charCode));
        }
      }

      switchCaps() {
        return this.el.className = this.el.className !== 'capsMode' ? 'capsMode' : '';
      }

      welcomeMsg() {
        return this.writeDelayed('\n     **** saylermorph.com v0.1 ****\n\n 64k ram system 38911 basic bytes free\n\nready.\n');
      }

      initScreen() {
        var cellEl, j, l, ref, ref1, results, rowEl, x, y;
        results = [];
        for (y = j = 0, ref = this.SCREENSIZE.h; (0 <= ref ? j < ref : j > ref); y = 0 <= ref ? ++j : --j) {
          rowEl = document.createElement('ul');
          for (x = l = 0, ref1 = this.SCREENSIZE.w; (0 <= ref1 ? l < ref1 : l > ref1); x = 0 <= ref1 ? ++l : --l) {
            cellEl = document.createElement('li');
            cellEl.innerHTML = '&nbsp;';
            rowEl.appendChild(cellEl);
          }
          results.push(this.el.appendChild(rowEl));
        }
        return results;
      }

      checkCursor(x, y) {
        this.cursor.blink = false;
        this.getCell().className = '';
        if (x != null) {
          this.cursor.x = x;
        }
        if (y != null) {
          this.cursor.y = y;
        }
        if (this.cursor.x === this.SCREENSIZE.w) {
          this.cursor.x = 0;
          this.cursor.y++;
        } else if (this.cursor.x === -1) {
          this.cursor.x = this.SCREENSIZE.w - 1;
          this.cursor.y--;
        }
        if (this.cursor.y === this.SCREENSIZE.h) {
          this.cursor.y -= 1;
          this.shiftScreenUp();
        } else if (this.cursor.y === -1) {
          this.cursor.y = this.SCREENSIZE.h - 1;
        }
        return this.cursor.blink = true;
      }

      //@getCell().className = 'inverted'
      cmdInterpreter(cmd) {
        var interval;
        interval = null;
        if (cmd.trim().length === 0) {
          return true;
        }
        if (cmd.split('clear').length > 1) {
          this.clearScreen();
        } else if (cmd.split('list').length > 1) {
          this.writeDelayed(programmListing);
        } else if (cmd.split('reset').length > 1) {
          this.clearScreen();
          this.welcomeMsg();
        } else if (cmd.split('help').length > 1) {
          this.writeDelayed('\n\ncall 0900-drs-will-do-it\nready.\n');
        } else if (cmd.split('load').length > 1) {
          this.writeDelayed('\n\npress play on tape\nloading\n');
          this.writeDelayed('ready.\n');
        } else if (cmd.split('run').length > 1) {
          this.clearScreen();
          this.writeDelayed('1. A robot may not injure a human being\n   or, through inaction, allow a human \n   being to come to harm. \n\n2. A robot must obey the orders given \n   it by human beings except where such\n   orders would conflict with the First\n   Law. \n\n3. A robot must protect its own \n   existence as long as such protection\n   does not conflict with\n   the First or Second Laws \n\n\n\nready.\n');
        } else {
          this.writeDelayed('\n?syntax error\nready.\n');
        }
        return true;
      }

      getCell() {
        return this.el.childNodes[this.cursor.y].childNodes[this.cursor.x];
      }

      getLine() {
        var char, child, j, len1, lineText, ref;
        lineText = '';
        ref = this.el.childNodes[this.cursor.y].childNodes;
        for (j = 0, len1 = ref.length; j < len1; j++) {
          child = ref[j];
          char = child.innerHTML;
          lineText += char === '&nbsp;' ? ' ' : char;
        }
        if (this.cmdInterpreter(lineText.toLowerCase())) {
          this.newLine();
        }
        return this.checkCursor();
      }

      blinkCursor() {
        if (this.cursor.blink) {
          this.getCell().className = 'inverted';
        } else {
          this.getCell().className = '';
        }
        return this.cursor.blink = !this.cursor.blink;
      }

      putChar(char) {
        var cell;
        this.checkCursor();
        cell = this.getCell();
        cell.innerHTML = char;
        return this.checkCursor(this.cursor.x + 1, null);
      }

      delChar() {
        var cell;
        this.checkCursor(this.cursor.x - 1, null);
        cell = this.getCell();
        return cell.innerHTML = '&nbsp;';
      }

      newLine() {
        this.checkCursor(0, this.cursor.y + 1);
        return this.getCell().className = 'inverted';
      }

      clearScreen() {
        var cell, j, l, len1, len2, line, ref, ref1;
        this.getCell().className = '';
        this.cursor = {
          x: 0,
          y: 0,
          blink: false
        };
        ref = this.el.childNodes;
        for (j = 0, len1 = ref.length; j < len1; j++) {
          line = ref[j];
          ref1 = line.childNodes;
          for (l = 0, len2 = ref1.length; l < len2; l++) {
            cell = ref1[l];
            cell.innerHTML = '&nbsp;';
          }
        }
        return this.getCell().className = 'inverted';
      }

      setColor() {
        return null; // TODO ???
      }

      shiftScreenUp() {
        var child, i, j, l, len, len1, len2, li, original, ref, ref1, replacement;
        len = this.el.childNodes;
        ref = this.el.childNodes;
        for (i = j = 0, len1 = ref.length; j < len1; i = ++j) {
          child = ref[i];
          if (i === this.el.childNodes.length - 1) {
            ref1 = child.childNodes;
            for (l = 0, len2 = ref1.length; l < len2; l++) {
              li = ref1[l];
              li.innerHTML = "&nbsp";
            }
            return true;
          }
          replacement = this.el.childNodes[i + 1].innerHTML;
          original = this.el.childNodes[i];
          original.innerHTML = replacement;
        }
      }

      writeDelayed(text) {
        return this.textToWriteDelayed += text;
      }

      nextDelayedText() {
        this.write(this.textToWriteDelayed[0]);
        return this.textToWriteDelayed = this.textToWriteDelayed.substring(1, this.textToWriteDelayed.length);
      }

      write(text) { // TODO implement \0 - \f \! codes \fore /background foreground and inverted
        var char, j, len1, results;
        results = [];
        for (j = 0, len1 = text.length; j < len1; j++) {
          char = text[j];
          if (char === '\n') {
            results.push(this.newLine());
          } else {
            results.push(this.putChar(char === ' ' ? char = '&nbsp;' : char));
          }
        }
        return results;
      }

      cycle() {
        if ((this.time++) % 35 === 0) {
          this.blinkCursor();
        }
        if (this.textToWriteDelayed.length > 0) {
          this.nextDelayedText();
        }
        return requestAnimationFrame(this.cycle);
      }

    };

    Textmode.prototype.SCREENSIZE = {
      w: 40,
      h: 25
    };

    Textmode.prototype.time = 0; // count every animation frame

    Textmode.prototype.cursor = {
      x: 0,
      y: 0,
      blink: true
    };

    Textmode.prototype.textToWriteDelayed = "";

    return Textmode;

  }).call(this);

  programmListing = '0   "----- DISK LISTING ----"    1\n' + '6   "HELP"                       PRG\n' + '12  "DRAW"                       PRG\n' + '1   "ROBOT RULES"                PRG\n' + '1   "ROBOT RULES"                PRG\n' + '5   "CONTACT"                    PRG\n' + '512 BLOCKS FREE.\n' + 'READY.\n';

  c = console;

  c.l = c.log;

  res = 255;

  w = window.innerWidth;

  h = window.innerHeight;

  hiddenCanvas = document.createElement('canvas');

  hiddenCanvas.width = res;

  hiddenCanvas.height = res;

  hiddenCtx = hiddenCanvas.getContext('2d');

  hiddenCtx.fillStyle = 'black';

  hiddenCtx.font = '30px monospace';

  hiddenCtx.fillText('Saylermorph', res / 8, res * .4);

  hiddenCtx.font = '12px monospace';

  hiddenCtx.fillText('Fear not | You are hellcome', res / 7.5, res * .5);

  imgData = hiddenCtx.getImageData(0, 0, res, res);

  dispCanvas = document.createElement('canvas');

  dispCtx = dispCanvas.getContext('2d');

  dispCanvas.width = w;

  dispCanvas.height = h;

  dispCtx.webkitImageSmoothingEnabled = dispCtx.mozImageSmoothingEnabled = dispCtx.imageSmoothingEnabled = true;

  dispCanvas.style.background = 'grey';

  document.body.appendChild(dispCanvas);

  y = 0;

  x = 0;

  loopit = function() {
    var data, i;
    i = imgData.data.length;
    data = imgData.data;
    while (i) {
      if (data[i - 1] < 127) {
        data[i - 0] = (t ^ t >> 8) & 255;
        data[i - 1] = (data[i - 2] + Math.random() * 8) & 255;
        data[i - 3] = ((t & t >> 6) ^ t >> 4) % 64;
        //data[i-3] = 0
        data[i - 4] = (t ^ t >> 9) & 128;
      }
      i -= 4;
    }
    imgData.data = data;
    hiddenCtx.putImageData(imgData, 0, 0);
    dispCtx.drawImage(hiddenCanvas, x, y, w, h);
    if (Math.random() < .5) {
      y += Math.random() - .5;
      x += Math.random() - .5;
      x %= res;
      y %= res;
    }
    sinea.frequency.value = 50 + ((t & t >> 6) ^ t >> 4) % 444;
    osc.frequency.value = 50 + ((t & t >> 16) & t >> 3) % 1200;
    sineagain.gain.value = (t ^ t >> 8) & 255;
    if (oscgain.gain.value < .25) {
      oscgain.gain.value += .0005;
    }
    return t += 3;
  };

  // FM SYNTH
  audioCtx = new (window.AudioContext || window.webkitAudioContext)();

  sinea = audioCtx.createOscillator();

  sinea.frequency.value = 25.5;

  sinea.type = "sine";

  sineagain = audioCtx.createGain();

  sineagain.gain.value = 100;

  sinea.connect(sineagain);

  sinea.start();

  osc = audioCtx.createOscillator();

  osc.type = "sine";

  osc.frequency.value = 440;

  oscgain = audioCtx.createGain();

  oscgain.gain.value = 0;

  osc.connect(oscgain);

  sineagain.connect(osc.frequency);

  oscgain.connect(audioCtx.destination);

  osc.start();

  t = 1;

  loopit();

  setInterval(loopit, 1000 / 20);

  d = document;

  c = console;

  c.l = c.log;

  W = H = canvas = ctx = null;

  maxBranches = 29000;

  branchCnt = 0;

  branchDrawn = 0;

  isDrawing = false;

  configGen = function() {
    return {
      startWidth: 25 * (.5 + Math.random()),
      startLength: window.innerHeight * .3,
      branchAngle: 50 * (.5 + Math.random()),
      maxBranchAmount: 3 * (2 + Math.random() * 4),
      maxBranchWidth: .025 + (Math.random() * 1.5),
      maxBranchChanges: 5 + (Math.random() * 10),
      branchShrinkrate: .85 + (Math.random() * .1),
      randomBranchSpread: .2 + (Math.random() * .8)
    };
  };

  config = configGen();

  configControls_element = d.getElementById('configControls');

  isDrawing_element = d.getElementById('isDrawing');

  d.getElementById('newtree').onclick = function() {
    if (isDrawing === false) {
      return startDrawing();
    }
  };

  initCanvas = function() {
    if (canvas !== null) {
      d.body.removeChild(canvas);
    }
    W = Math.min(window.innerWidth - 75, window.innerHeight - 75);
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
    ctx.lineCap = "round";
    ctx.shadowBlur = 0;
    return ctx.shadowColor = '#00ff00';
  };

  drawBranchPositions = function(startPos, length, branchChanges, startAngle, branchWidth) {
    var blue, branchAmount, branchChangePositions, green, i, j, l, len1, len2, m, newAngle, newBranches, newStartPos, nxtLength, randomDeg, red, ref;
    if (isDrawing === false) {
      isDrawing_element.innerText = 'Working...';
      isDrawing = true;
    }
    branchCnt++;
    newBranches = [];
    branchDrawn++;
    if (branchCnt > maxBranches || branchWidth < config.maxBranchWidth) {
      return doneDrawBranches();
    }
    branchChangePositions = (function() {
      var j, ref, results;
      results = [];
      for (i = j = 0, ref = branchChanges; (0 <= ref ? j < ref : j > ref); i = 0 <= ref ? ++j : --j) {
        results.push(Math.random() * (length / branchChanges * 1.5));
      }
      return results;
    })();
    for (i = j = 0, len1 = branchChangePositions.length; j < len1; i = ++j) {
      nxtLength = branchChangePositions[i];
      randomDeg = startAngle + (22 - (Math.random() * 44));
      ctx.lineWidth = branchWidth;
      red = Math.round(Math.random() * 32);
      green = Math.round(Math.random() * 32);
      blue = Math.round(Math.random() * 16);
      red += 100;
      green += 50;
      ctx.strokeStyle = 'rgba(' + red + ', ' + green + ', ' + blue + ', 1)';
      ctx.beginPath();
      ctx.moveTo(startPos.x, startPos.y);
      startPos = convDeg2d(nxtLength, convAngleRadian(randomDeg), startPos);
      ctx.lineTo(startPos.x, startPos.y);
      ctx.stroke();
      branchWidth *= config.branchShrinkrate;
      if (Math.random() < config.randomBranchSpread) {
        newBranches.push(startPos);
      }
    }
    branchAmount = Math.random() * config.maxBranchAmount;
    if (branchCnt < maxBranches + branchAmount) {
      for (i = l = 0, ref = branchAmount; (0 <= ref ? l <= ref : l >= ref); i = 0 <= ref ? ++l : --l) {
        newBranches.push(startPos);
      }
    }
    for (m = 0, len2 = newBranches.length; m < len2; m++) {
      newStartPos = newBranches[m];
      //setTimeout (->
      newAngle = 1 - (Math.random() * 2);
      newAngle *= config.branchAngle;
      drawBranchPositions(newStartPos, length * .75, config.maxBranchChanges, startAngle + newAngle, branchWidth * config.branchShrinkrate);
    }
    //), -1
    return branchDrawn--;
  };

  doneDrawBranches = function() {
    return setTimeout((function() {
      branchDrawn--;
      if (branchDrawn === 0) {
        c.l('done: ', branchCnt, branchDrawn);
        isDrawing_element.innerText = 'Done!';
        isDrawing = false;
        branchCnt = 0;
        return config = configGen();
      }
    }), 250);
  };

  clearCanvas = function() {
    ctx.fillStyle = '#ffffff';
    return ctx.fillRect(0, 0, W, H);
  };

  initCanvas();

  //configGenerator configControls
  startPos = {
    x: W / 2,
    y: H
  };

  startDrawing = function() {
    clearCanvas();
    return drawBranchPositions(startPos, config.startLength, config.maxBranchChanges, -90, config.startWidth);
  };

  startDrawing();

  window.onload = function() {
    addEventListeners();
    initCanvas();
    return startGame();
  };

  (function() {    // requestAnimationFrame polyfill by Erik Möller. fixes from Paul Irish and Tino Zijdel
    // MIT license
    var lastTime, vendors;
    lastTime = 0;
    vendors = ['ms', 'moz', 'webkit', 'o'];
    x = 0;
    while (x < vendors.length && !window.requestAnimationFrame) {
      window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame'];
      window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] || window[vendors[x] + 'CancelRequestAnimationFrame'];
      ++x;
    }
    if (!window.requestAnimationFrame) {
      window.requestAnimationFrame = function(callback, element) {
        var currTime, id, timeToCall;
        currTime = (new Date).getTime();
        timeToCall = Math.max(0, 16 - (currTime - lastTime));
        id = window.setTimeout((function() {
          callback(currTime + timeToCall);
        }), timeToCall);
        lastTime = currTime + timeToCall;
        return id;
      };
    }
    if (!window.cancelAnimationFrame) {
      window.cancelAnimationFrame = function(id) {
        clearTimeout(id);
      };
    }
  })();

  d = document;

  c = console;

  c.l = c.log;

  canvas = ctx = null;

  W = Math.round(Math.min(window.innerWidth - 75, window.innerHeight - 75));

  H = W;

  initCanvas = function() {
    canvas = d.createElement('canvas');
    canvas.height = H;
    canvas.width = W;
    ctx = canvas.getContext('2d');
    d.getElementById('canvasContainer').appendChild(canvas);
    ctx.fillStyle = '#ffffff';
    ctx.fillRect(0, 0, W, H);
    ctx.rect(0, 0, W, H);
    ctx.stroke();
    return ctx;
  };

  clearCanvas = function() {
    ctx.fillStyle = '#000';
    return ctx.fillRect(0, 0, W, H);
  };

  checkLevel = function() {
    if (score > 1000 && level === 0) {
      level++;
      return aniSpeed -= 2;
    } else if (score > 2500 && level === 1) {
      level++;
      gameRes -= 8;
      return setGameRes();
    } else if (score > 5000 && level === 2) {
      level++;
      gameRes -= 8;
      return setGameRes();
    } else if (score > 10000 && level === 3) {
      level++;
      gameRes -= 4;
      return setGameRes();
    } else if (score > 20000 && level === 4) {
      level++;
      gameRes -= 2;
      return setGameRes();
    } else if (score > 30000 && level === 5) {
      level++;
      gameRes -= 2;
      return setGameRes();
    } else if (score > 45000 && level === 6) {
      level++;
      gameRes -= 2;
      return setGameRes();
    } else if (score > 65000 && level === 7) {
      level++;
      gameRes -= 2;
      return setGameRes();
    } else if (score > 80000 && level === 8) {
      level++;
      gameRes -= 2;
      return setGameRes();
    } else if (score > 10000 && level === 9) {
      level++;
      return aniSpeed -= 1;
    }
  };

  checkCollision = function() {
    var dot, j, len1, ref, results, sp;
    ref = shipDirDots[dir];
    // check collision with dot
    results = [];
    for (j = 0, len1 = ref.length; j < len1; j++) {
      sp = ref[j];
      dot = getDot(sp[0] + shipPos.x, sp[1] + shipPos.y);
      if (dot > 0) {
        c.l(dot);
        if (dot === 10) {
          score += 100 * (level + 1);
          setDot(sp[0] + shipPos.x, sp[1] + shipPos.y, 0);
          results.push(placeRandomDots(1, 1));
        } else {
          results.push(killed--);
        }
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  // check collision with wall
  checkBorderCollision = function() {
    if (shipPos.x >= worldEdge.x) {
      shipPos.x = -worldEdge.x;
    } else if (shipPos.x < -worldEdge.x) {
      shipPos.x = worldEdge.x - 1;
    }
    if (shipPos.y >= worldEdge.y) {
      return shipPos.y = -worldEdge.x;
    } else if (shipPos.y < -worldEdge.y) {
      return shipPos.y = worldEdge.x - 1;
    }
  };

  getDot = function(x, y) {
    x = x + worldEdge.x;
    y = y + worldEdge.y;
    //if x<0 || x>=gameRes || y<0 || y>=gameRes then return# c.l 'getDot Out of bound',x,y
    return dots[x + (y * worldEdge.x * 2)];
  };

  setDot = function(x, y, type) {
    x = x + worldEdge.x;
    y = y + worldEdge.y;
    if (x < 0 || x >= worldEdge.x * 2 || y < 0 || y >= worldEdge.x * 2) {
      return false; // c.l 'setDot Out of bound',x,y
    }
    return dots[x + (y * worldEdge.x * 2)] = type;
  };

  getRandomDot = function(saveArea) {
    var maxTries, tries;
    x = Math.round(worldEdge.x - (Math.random() * worldEdge.x * 2));
    y = Math.round(worldEdge.y - (Math.random() * worldEdge.y * 2));
    maxTries = 128;
    saveArea = saveArea || 0;
    tries = 0;
    while (x > -saveArea && x < saveArea && y > -saveArea && y < saveArea && getDot(x, y) === 0) {
      tries++;
      x = Math.round(worldEdge.x - (Math.random() * worldEdge.x * 2));
      y = Math.round(worldEdge.y - (Math.random() * worldEdge.y * 2));
      if (tries > maxTries) {
        return c.l('getRandomDot overload');
      }
    }
    return {
      x: x,
      y: y
    };
  };

  placeRandomDots = function(amount, saveArea, id) {
    var dot, results;
    amount = amount || 100;
    saveArea = saveArea || worldEdge.x * .6;
    results = [];
    while (amount--) {
      dot = getRandomDot(saveArea);
      results.push(setDot(dot.x, dot.y, id || 10));
    }
    return results;
  };

  drawDot = function(x, y, col) {
    var canvasX, canvasY;
    canvasX = (x + cx) * pieceSizeW;
    canvasY = (y + cy) * pieceSizeH;
    if (canvasX < -pieceSizeW || canvasX > W || canvasY < -pieceSizeH || canvasY > H) { // c.l 'DRAW_DOT ERROR', canvasX, canvasY, x, y
      return;
    }
    ctx.fillStyle = '#' + col;
    return ctx.fillRect(.25 + canvasX, .25 + canvasY, pieceSizeW - .5, pieceSizeH - .5);
  };

  drawShip = function(dir) {
    var j, len1, ref, results, xy;
    ref = shipDirDots[dir];
    results = [];
    for (j = 0, len1 = ref.length; j < len1; j++) {
      xy = ref[j];
      results.push(drawDot(xy[0], xy[1], shipColor));
    }
    return results;
  };

  drawBorder = function() {
    var borderStartX, borderStartY;
    if (shipPos.x + cx > worldEdge.x) {
      borderStartX = W - (shipPos.x + cx - worldEdge.x) * pieceSizeW;
      ctx.fillStyle = '#' + wallColor;
      ctx.fillRect(borderStartX, 0, W, H);
    }
    if (shipPos.x - cx < -worldEdge.x) {
      borderStartX = -(shipPos.x - cx + worldEdge.x) * pieceSizeW;
      ctx.fillStyle = '#' + wallColor;
      ctx.fillRect(0, 0, borderStartX, H);
    }
    if (shipPos.y + cy > worldEdge.y) {
      borderStartY = W - (shipPos.y + cy - worldEdge.y) * pieceSizeH;
      ctx.fillStyle = '#' + wallColor;
      ctx.fillRect(0, borderStartY, W, H);
    }
    if (shipPos.y - cy < -worldEdge.y) {
      borderStartY = -(shipPos.y - cy + worldEdge.y) * pieceSizeW;
      ctx.fillStyle = '#' + wallColor;
      return ctx.fillRect(0, 0, W, borderStartY);
    }
  };

  drawStats = function() {
    var fontSize;
    fontSize = W / 35;
    ctx.fillStyle = '#fff';
    ctx.font = fontSize + 'px c64';
    ctx.fillText('HIGHSCORE: ' + highscore, 6, 4 + fontSize);
    ctx.fillText('SCORE: ' + score, 6, 4 + fontSize * 2);
    return ctx.fillText('LEVEL: ' + level, 6, 4 + fontSize * 3);
  };

  drawDots = function() { // Draw visible dots
    var col, dot, endX, endY, j, maxX, posX, posY, ref, ref1, results, startX, startY;
    if (worldEdge.x * 2 < gameRes) {
      maxX = worldEdge.x;
      startX = -worldEdge.x - shipPos.x;
      endX = worldEdge.x - shipPos.x;
      startY = -worldEdge.y - shipPos.y;
      endY = worldEdge.y - shipPos.y;
    } else {
      maxX = Math.round(gameRes / 2);
      startX = startY = -maxX;
      endX = endY = maxX;
    }
//[Math.floor(-(gameRes/2))...(gameRes/2)]
    results = [];
    for (x = j = ref = startX, ref1 = endX; (ref <= ref1 ? j < ref1 : j > ref1); x = ref <= ref1 ? ++j : --j) {
      posX = x + shipPos.x;
      results.push((function() {
        var l, ref2, ref3, results1;
// [Math.floor(-(gameRes/2))...(gameRes/2)]
        results1 = [];
        for (y = l = ref2 = startY, ref3 = endY; (ref2 <= ref3 ? l < ref3 : l > ref3); y = ref2 <= ref3 ? ++l : --l) {
          posY = shipPos.y + y;
          dot = getDot(posX, posY);
          if (dot > 0) {
            col = dot === 1 ? shipTrailColor : dot === 6 ? enemyColor : dot === 7 ? enemyTrailColor : dot === 8 ? enemyBodyColor : dot === 10 ? bonusPointsColor : dot === 25 ? 'f00' : dot >= 50 && dot < 64 ? (dot += 1, setDot(posX, posY, dot), col = (0xfff - ((dot - 50) * 0x111)).toString(16)) : dot >= 64 ? (setDot(posX, posY, 0), '000') : 'fff';
            results1.push(drawDot(x, y, col));
          } else {
            results1.push(void 0);
          }
        }
        return results1;
      })());
    }
    return results;
  };

  enemys = [];

  getEnemys = function(cnt) {
    enemys = [];
    // for i in [0..cnt]
    //   m = if Math.random()>.5 then 1 else -1
    //   if Math.random()>.5
    //     mx = m
    //     my = 0
    //   else
    //     mx = 0
    //     my = m
    //   pos = getRandomDot(worldEdge.x/10)
    enemys.push({
      pos: {
        x: -worldEdge.x + 2,
        y: -6
      },
      mx: 1,
      my: 0
    });
    enemys.push({
      pos: {
        x: -worldEdge.x + 2,
        y: -3
      },
      mx: 1,
      my: 0
    });
    enemys.push({
      pos: {
        x: -worldEdge.x + 2,
        y: 0
      },
      mx: 1,
      my: 0
    });
    enemys.push({
      pos: {
        x: -worldEdge.x + 2,
        y: 3
      },
      mx: 1,
      my: 0
    });
    return enemys.push({
      pos: {
        x: -worldEdge.x + 2,
        y: 6
      },
      mx: 1,
      my: 0
    });
  };

  moveEnemy = function() {
    var e, ei, enemy, j, len1, results;
    results = [];
    for (ei = j = 0, len1 = enemys.length; j < len1; ei = ++j) {
      enemy = enemys[ei];
      e = enemy.pos;
      setDot(e.x, e.y, 0);
      setDot(e.x - 1, e.y, 0);
      setDot(e.x + 1, e.y, 0);
      setDot(e.x, e.y + 1, 0);
      setDot(e.x, e.y - 1, 0);
      if (Math.abs(e.x) > worldEdge.x) {
        e.x = -e.x;
      }
      if (Math.abs(e.y) > worldEdge.y) {
        e.y = -e.y;
      }
      if (Math.random() > .995) {
        if (-worldEdge.x + 2 < e.x && worldEdge.x - 2 > e.x && -worldEdge.y + 2 < e.y && worldEdge.y - 2 > e.y) {
          x = enemy.mx;
          enemy.mx = enemy.my;
          enemy.my = x;
        }
      } else if (Math.random() > .995) {
        if (-worldEdge.x + 2 < e.x && worldEdge.x - 2 > e.x && -worldEdge.y + 2 < e.y && worldEdge.y - 2 > e.y) {
          enemy.mx *= -1;
          enemy.my *= -1;
        }
      }
      e.x += enemy.mx;
      e.y += enemy.my;
      setDot(e.x, e.y, 8);
      setDot(e.x - 1, e.y, 6);
      setDot(e.x + 1, e.y, 6);
      setDot(e.x, e.y + 1, 6);
      setDot(e.x, e.y - 1, 6);
      if (gameTick % 41 === 40 && level >= 1) {
        results.push(setDot(e.x - enemy.mx * 2, e.y - enemy.my * 2, 7));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  (function() {    // requestAnimationFrame polyfill by Erik Möller. fixes from Paul Irish and Tino Zijdel
    // MIT license
    var lastTime, vendors;
    lastTime = 0;
    vendors = ['ms', 'moz', 'webkit', 'o'];
    x = 0;
    while (x < vendors.length && !window.requestAnimationFrame) {
      window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame'];
      window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] || window[vendors[x] + 'CancelRequestAnimationFrame'];
      ++x;
    }
    if (!window.requestAnimationFrame) {
      window.requestAnimationFrame = function(callback, element) {
        var currTime, id, timeToCall;
        currTime = (new Date).getTime();
        timeToCall = Math.max(0, 16 - (currTime - lastTime));
        id = window.setTimeout((function() {
          callback(currTime + timeToCall);
        }), timeToCall);
        lastTime = currTime + timeToCall;
        return id;
      };
    }
    if (!window.cancelAnimationFrame) {
      window.cancelAnimationFrame = function(id) {
        clearTimeout(id);
      };
    }
  })();

  pieceSizeW = W / gameRes;

  pieceSizeH = H / gameRes;

  killed = false;

  cx = gameRes / 2;

  cy = gameRes / 2;

  shipPos = {
    x: 0,
    y: 0
  };

  shipVel = {
    x: 0,
    y: 0
  };

  dir = 0;

  keysPressed = ["w"];

  score = 0;

  highscore = 0;

  gameRes = 0;

  aniSpeed = 666;

  level = 0;

  gameTick = 0;

  startRes = 60;

  worldEdge = {
    x: 127,
    y: 127
  };

  dots = new Uint8Array(worldEdge.x * 2 * worldEdge.y * 2);

  shipDirDots = null;

  shipColor = 'b0ec51';

  shipTrailColor = '598e07';

  enemyColor = '8333a5';

  enemyBodyColor = 'ac61cc';

  enemyTrailColor = '3e49d2';

  bonusPointsColor = 'e4cc1f';

  wallColor = '20363e';

  shipDirDots = [[[-1, 0], [0, 0], [+1, 0], [0, -1]], [[0, 0 - 1], [0, 0], [0, 0 + 1], [0 + 1, 0]], [[0 - 1, 0], [0, 0], [0 + 1, 0], [0, 0 + 1]], [[0, 0 - 1], [0, 0], [0, 0 + 1], [0 - 1, 0]]];

  killPlayer = function(i) {
    i = i || 0;
    clearCanvas();
    drawDots();
    drawBorder();
    if (i < Math.sqrt(gameRes * gameRes + gameRes * gameRes) / 2) {
      drawDot(0 + i, 0 + i, shipColor);
      drawDot(0 - i, 0 - i, shipColor);
      drawDot(0 + i, 0 - i, shipColor);
      drawDot(0 - i, 0 + i, shipColor);
      i++;
      return requestAnimationFrame((function() {
        return killPlayer(i);
      }));
    } else {
      highscore = Math.max(score, highscore);
      score = 0;
      return startGame();
    }
  };

  startGame = function() {
    var lasers;
    shipPos = {
      x: 0,
      y: 19
    };
    shipVel = {
      x: 0,
      y: 0
    };
    dir = 0;
    keysPressed = ['w'];
    dots = new Uint8Array(worldEdge.x * 2 * worldEdge.y * 2);
    killed = false;
    worldEdge.x = 31; // must be uneven
    worldEdge.y = 31; // must be uneven
    gameRes = 5;
    aniSpeed = 14;
    level = 0;
    lasers = 10;
    getEnemys(4);
    moveEnemy();
    setGameRes();
    placeRandomDots(10);
    return nextFrame();
  };

  setGameRes = function() {
    pieceSizeW = W / gameRes;
    pieceSizeH = H / gameRes;
    cx = gameRes / 2;
    return cy = gameRes / 2;
  };

  checkKeysPressed = function() {
    var k;
    k = keysPressed.shift();
    if (k) {
      if (k === 'w') {
        shipVel = {
          x: 0,
          y: -1
        };
        return dir = 0;
      } else if (k === 'd') {
        shipVel = {
          x: 1,
          y: 0
        };
        return dir = 1;
      } else if (k === 's') {
        shipVel = {
          x: 0,
          y: 1
        };
        return dir = 2;
      } else if (k === 'a') {
        shipVel = {
          x: -1,
          y: 0
        };
        return dir = 3;
      }
    }
  };

  aniCnt = aniSpeed;

  nextFrame = function() {
    if (aniCnt < aniSpeed) {
      aniCnt++;
      return requestAnimationFrame(nextFrame);
    } else {
      aniCnt = 0;
    }
    if (aniSpeed > 5) {
      aniSpeed -= 1;
    }
    if (gameRes < startRes && level === 0) {
      gameRes += 4;
      setGameRes();
    }
    checkKeysPressed();
    shipPos.x += shipVel.x;
    shipPos.y += shipVel.y;
    checkCollision();
    checkBorderCollision();
    moveEnemy();
    checkCollision();
    checkLevel();
    clearCanvas();
    drawDots();
    drawBorder();
    drawShip(dir);
    drawStats();
    //setDot shipPos.x, shipPos.y, 1
    if (Math.random() < .05) {
      placeRandomDots(1, 1);
    }
    score += 1 + level;
    gameTick++;
    if (killed === false) {
      return requestAnimationFrame(nextFrame);
    } else {
      return killPlayer();
    }
  };

  addEventListeners = function() {
    return d.body.addEventListener('keydown', function(e) {
      if ((e.key === 'w' || e.key === 'd' || e.key === 's' || e.key === 'a') && e.key !== keysPressed[keysPressed.length - 1]) {
        return keysPressed.push(e.key);
      }
    });
  };

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
    var center, circleNr, j;
    ctx.beginPath();
    center = {
      x: W / 2,
      y: H / 2
    };
    ctx.moveTo(oldXY.x, oldXY.y);
    for (circleNr = j = 0; j <= 2; circleNr = ++j) {
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

  d = document;

  c = console;

  c.l = c.log;

  W = H = canvas = ctx = center = null;

  initCanvas = function() {
    if (canvas !== null) {
      d.body.removeChild(canvas);
    }
    W = window.innerWidth;
    H = window.innerHeight;
    center = {
      x: W / 2,
      y: H / 2
    };
    canvas = d.createElement('canvas');
    canvas.height = H;
    canvas.width = W;
    ctx = canvas.getContext('2d');
    d.body.appendChild(canvas);
    canvas.onmousemove = function(e) {
      return center = {
        x: W - e.clientX,
        y: H - e.clientY
      };
    };
    ctx.strokeStyle = '#adadad';
    ctx.fillStyle = '#000000';
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.fillRect(0, 0, W, H);
    return ctx.stroke();
  };

  stars = [];

  getStar = function() {
    var z;
    x = W - Math.random() * W * 2;
    y = H - Math.random() * H * 2;
    z = 25 + (Math.random() * 75);
    return {
      x: x * z,
      y: y * z,
      z: z
    };
  };

  drawStar = function(star) {
    var size, starPos3d;
    ctx.beginPath();
    //ctx.moveTo center.x-28, center.y
    //ctx.lineTo center.x+28, center.y
    //ctx.moveTo center.x, center.y-28
    //ctx.lineTo center.x, center.y+28
    starPos3d = conv3d2d(star.x, star.y, star.z, center, 1);
    size = 64 / star.z;
    ctx.rect(starPos3d.x - size / 2, starPos3d.y - size / 2, size, size);
    return ctx.stroke();
  };

  draw = function() {
    var i, j, len1, results, star;
    ctx.fillStyle = 'rgba(0,0,0,.15)';
    ctx.fillRect(0, 0, W, H);
    while (stars.length < 255) {
      stars.push(getStar());
    }
    results = [];
    for (i = j = 0, len1 = stars.length; j < len1; i = ++j) {
      star = stars[i];
      drawStar(star);
      star.z -= .75;
      if (star.z < 1) {
        results.push(stars[i] = getStar());
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  initCanvas();

  setInterval((function() {
    return draw();
  }), 1000 / 60);

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
    W = config.canvasWidth;
    H = config.canvasHeight;
    canvas = d.createElement('canvas');
    c.l(W, H);
    canvas.height = H;
    canvas.width = W;
    ctx = canvas.getContext('2d');
    d.body.appendChild(canvas);
    ctx.fillStyle = '#ffffff';
    ctx.fillRect(0, 0, W, H);
    //ctx.rect 0, 0, W, H
    ctx.stroke();
    ctx.strokeStyle = 'rgba(0, 0, 0, 1)';
    ctx.lineWidth = config.width;
    ctx.shadowBlur = 0;
    return ctx.shadowColor = '#00ff00';
  };

  clearCanvas = function() {
    ctx.fillStyle = '#ffffff';
    return ctx.fillRect(0, 0, W, H);
  };

  config = {
    canvasWidth: 1024,
    canvasHeight: 1024,
    startX1: 0,
    startY1: 0,
    startX2: 0,
    startY2: 0,
    incX1: 3,
    incY1: 165,
    incX2: 217,
    incY2: 4,
    rndX1: 0,
    lineWidth: .1,
    startRed: 0,
    startBlue: 0,
    startGreen: 0,
    incRed: 255,
    incBlue: 255,
    incGreen: 255,
    iterations: 7255
  };

  position = {
    x1: config.startX1,
    y1: config.startY1,
    x2: config.startX2,
    y2: config.startY2
  };

  color = {
    red: config.startRed,
    green: config.startGreen,
    blue: config.startBlue
  };

  isPlaying = true;

  // incX incY incX2 incY2 canvasWidth canvasHeight
  configControls = {
    trgContainerId: 'configControls',
    content: {
      'Increase X1': {
        funct: function(val) {
          return config.incX1 = val;
        },
        type: 'range',
        min: -config.canvasWidth / 8,
        max: config.canvasWidth / 8,
        step: .001,
        value: config.incX1
      },
      'Increase X2': {
        funct: function(val) {
          return config.incX2 = val;
        },
        type: 'range',
        min: -config.canvasWidth / 8,
        max: config.canvasWidth / 8,
        step: .001,
        value: config.incX1
      },
      'Increase Y1': {
        funct: function(val) {
          return config.incX1 = val;
        },
        type: 'range',
        min: -config.canvasHeight / 8,
        max: config.canvasHeight / 8,
        step: .001,
        value: config.incX2
      },
      'Increase Y2': {
        funct: function(val) {
          return config.incX1 = val;
        },
        type: 'range',
        min: -config.canvasHeight / 8,
        max: config.canvasHeight / 8,
        step: .001,
        value: config.incY2
      },
      'Increase Red': {
        funct: function(val) {
          return config.incRed = val;
        },
        type: 'range',
        min: 0,
        max: 255,
        step: 1,
        value: config.incRed
      },
      'Increase Green': {
        funct: function(val) {
          return config.incGreen = val;
        },
        type: 'range',
        min: 0,
        max: 255,
        step: 1,
        value: config.incGreen
      },
      'Increase Blue': {
        funct: function(val) {
          return config.incBlue = val;
        },
        type: 'range',
        min: 0,
        max: 255,
        step: 1,
        value: config.incBlue
      },
      'Line Width': {
        funct: function(val) {
          return config.lineWidth = val;
        },
        type: 'range',
        min: 0.001,
        max: 2,
        step: 0.001,
        value: config.lineWidth
      },
      'Iterations': {
        funct: function(val) {
          return config.iterations = val;
        },
        type: 'range',
        min: 0,
        max: 10000,
        step: 1,
        value: config.iterations
      },
      SaveImage: {
        funct: function() {
          return window.location.href = canvas.toDataURL('image/png').replace('image/png', 'image/octet-stream');
        },
        type: 'button'
      },
      ResetColors: {
        funct: function() {
          return color = {
            red: 0,
            green: 0,
            blue: 0
          };
        },
        type: 'button'
      },
      Render: {
        funct: function() {
          return draw();
        },
        type: 'button'
      },
      Clear: {
        funct: function() {
          position = {
            x1: config.startX1,
            y1: config.startY1,
            x2: config.startX2,
            y2: config.startY2
          };
          return clearCanvas();
        },
        type: 'button'
      }
    }
  };

  draw = function() {
    var len;
    ctx.strokeStyle = 'rgba(' + color.red + ', ' + color.green + ', ' + color.blue + ', 1)';
    ctx.lineWidth = config.lineWidth;
    len = config.iterations;
    ctx.beginPath();
    while (len--) {
      ctx.moveTo(position.x1, position.y1);
      ctx.lineTo(position.x2, position.y2);
      position.x1 += config.incX1;
      position.y1 += config.incY1;
      position.x2 += config.incX2;
      position.y2 += config.incY2;
      if (position.x1 > W * 2) {
        position.x1 = -W;
      } else if (position.x1 < -W) {
        position.x1 = W * 2;
      }
      if (position.x2 > W * 2) {
        position.x2 = -W;
      } else if (position.x2 < -W) {
        position.x2 = W * 2;
      }
      if (position.y1 > H * 2) {
        position.y1 = -H;
      } else if (position.y1 < -H) {
        position.y1 = H * 2;
      }
      if (position.y2 > H * 2) {
        position.y2 = -H;
      } else if (position.y2 < -H) {
        position.y2 = H * 2;
      }
    }
    ctx.stroke();
    color.red += config.incRed;
    color.green += config.incGreen;
    color.blue += config.incBlue;
    if (color.red > 255) {
      color.red = 0;
    }
    if (color.green > 255) {
      color.green = 0;
    }
    if (color.blue > 255) {
      return color.blue = 0;
    }
  };

  // color.red %= 255
  // color.blue %= 255
  // color.green %= 255
  initCanvas();

  configGenerator(configControls);

  draw();

}).call(this);
