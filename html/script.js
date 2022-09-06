// on resource load, load the defaults

function ensureBoolean(input) {
  if (typeof(input) == 'string') {
    return (input === 'true')
  }
  return input
}

function loadDefaults() {
  sendDynamicFade(localStorage.getItem('dynamicfade'));
  sendFadeSpeed(localStorage.getItem('fadespeed'));
  sendLocalDamage(localStorage.getItem('localdmg'));
  sendPrecision(localStorage.getItem('precision'));
}

function sendDynamicFade(dynamic_fade) {
  if (dynamic_fade == null) {
    dynamic_fade = true
    localStorage.setItem('dynamicfade', dynamic_fade)
  }
  
  let xhr = new XMLHttpRequest();
  xhr.open("POST", "https://ewdamagenumbers/dynamicfadestatus", true);
  xhr.send(JSON.stringify({'dynamicfade': ensureBoolean(dynamic_fade)}));
}

function sendFadeSpeed(fade_speed) {
  if (fade_speed == null) {
    fade_speed = 5
    localStorage.setItem('fadespeed', fade_speed)
  }

  let xhr = new XMLHttpRequest();
  xhr.open("POST", "https://ewdamagenumbers/fadespeedstatus", true);
  xhr.send(JSON.stringify({'fadespeed': Number(fade_speed)}));
}

function sendLocalDamage(damage_local) {
  if (damage_local == null) {
    damage_local = true
    localStorage.setItem('localdmg', damage_local)
  }

  let xhr = new XMLHttpRequest();
  xhr.open("POST", "https://ewdamagenumbers/localdmgstatus", true);
  xhr.send(JSON.stringify({'localdmg': ensureBoolean(damage_local)}));
}

function sendPrecision(precision) {
  if (precision == null) {
    precision = 2
    localStorage.setItem('precision', precision)
  }

  let xhr = new XMLHttpRequest();
  xhr.open("POST", "https://ewdamagenumbers/precisionstatus", true);
  xhr.send(JSON.stringify({'precision': Number(precision)}));
}


// handle setting changes

function dynamicfadetoggle(dynamic_fade) {
  document.getElementById('fadespeedrange').disabled=dynamic_fade;
  localStorage.setItem('dynamicfade', dynamic_fade);

  sendDynamicFade(dynamic_fade);
}

function fadespeedupdate(fade_speed) {
  document.getElementById('fadespeedshow').value=fade_speed;
  localStorage.setItem('fadespeed', fade_speed);

  sendFadeSpeed(fade_speed);
}

function localdmgtoggle(damage_local) {
  localStorage.setItem('localdmg', damage_local);

  sendLocalDamage(damage_local);
}

function precisionupdate(precision) {
  document.getElementById('precisionshow').value=precision;
  localStorage.setItem('precision', precision);

  sendPrecision(precision);
}

// other stuff

const CancelMenu = () => {
  $.post(`https://ewdamagenumbers/cancel`);
};

document.onkeyup = function (event) {
  event = event || window.event;
  let charCode = event.keyCode || event.which;
  if (charCode == 27) {
    CancelMenu();
  }
};

window.addEventListener("message", function (event) {
  let data = event.data;
  if (data.showdmgmenu) {
    let dynstate = ensureBoolean(localStorage.getItem('dynamicfade'));
    document.getElementById('dynamicfadeonoff').checked = dynstate;
    document.getElementById('fadespeedrange').disabled = dynstate;
    let fspeed = Number(localStorage.getItem('fadespeed'));
    document.getElementById('fadespeedrange').value = fspeed;
    document.getElementById('fadespeedshow').value = fspeed;
    document.getElementById('localdmgonoff').checked = ensureBoolean(localStorage.getItem('localdmg'));
    let prec = Number(localStorage.getItem('precision'));
    document.getElementById('precisionrange').value = prec;
    document.getElementById('precisionshow').value = prec;
    $(".dmgmenu").show()
  } else {
    $(".dmgmenu").hide();
  }
});
