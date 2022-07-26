// on resource load, load the defaults

var xhr = new XMLHttpRequest();
var state = localStorage.getItem('dynamicfade');
if (state == null) {
  state = true
  localStorage.setItem('dynamicfade', state)
}
// document.getElementById('fadespeedrange').disabled=state;
// document.getElementById('dynamicfadeonoff').checked=state;
xhr.open("POST", "https://ewdamagenumbers/dynamicfadestatus", true);
xhr.send(JSON.stringify({'dynamicfade': state}));

var xhr = new XMLHttpRequest();
var val = localStorage.getItem('fadespeed');
if (val == null) {
  val = 5
  localStorage.setItem('fadespeed', val)
}
// document.getElementById('fadespeedshow').value=val;
// document.getElementById('fadespeedrange').value=val;
xhr.open("POST", "https://ewdamagenumbers/fadespeedstatus", true);
xhr.send(JSON.stringify({'fadespeed': val}));

var xhr = new XMLHttpRequest();
var state = localStorage.getItem('localdmg');
if (state == null) {
  state = true
  localStorage.setItem('localdmg', state)
}
// document.getElementById('localdmgonoff').checked=state;
xhr.open("POST", "https://ewdamagenumbers/localdmgstatus", true);
xhr.send(JSON.stringify({'localdmg': state}));

var xhr = new XMLHttpRequest();
var val = localStorage.getItem('precision');
if (val == null) {
  val = 2
  localStorage.setItem('precision', val)
}
// document.getElementById('precisionrange').value=val;
xhr.open("POST", "https://ewdamagenumbers/precisionstatus", true);
xhr.send(JSON.stringify({'precision': val}));


// handle setting changes

function dynamicfadetoggle(state) {
  document.getElementById('fadespeedrange').disabled=state;
  localStorage.setItem('dynamicfade', state);

  var xhr = new XMLHttpRequest();
  xhr.open("POST", "https://ewdamagenumbers/dynamicfadestatus", true);
  xhr.send(JSON.stringify({'dynamicfade': state}));
}

// if (localStorage.getItem("dynamicfade") == 'true') {
//   $("#HealthBar").fadeIn()
//   healthtogglemenu.checked = true;
// } else {
//   $("#HealthBar").fadeOut()
//   healthtogglemenu.checked = false;
// }

function fadespeedupdate(val) {
  document.getElementById('fadespeedshow').value=val;
  localStorage.setItem('fadespeed', val);

  var xhr = new XMLHttpRequest();
  xhr.open("POST", "https://ewdamagenumbers/fadespeedstatus", true);
  xhr.send(JSON.stringify({'fadespeed': val}));
}

function localdmgtoggle(state) {
  localStorage.setItem('localdmg', state);

  var xhr = new XMLHttpRequest();
  xhr.open("POST", "https://ewdamagenumbers/localdmgstatus", true);
  xhr.send(JSON.stringify({'localdmg': state}));
}

function precisionupdate(val) {
  document.getElementById('precisionshow').value=val;
  localStorage.setItem('precision', val);

  var xhr = new XMLHttpRequest();
  xhr.open("POST", "https://ewdamagenumbers/precisionstatus", true);
  xhr.send(JSON.stringify({'precision': val}));
}

// fetch(`https://ewdamagenumbers/dynamicfadestatus`, {
//   method: 'POST',
//   headers: {
//   'Content-Type': 'application/json; charset=UTF-8',
// },
// body: JSON.stringify({
// dynamicfade: localStorage.getItem("dynamicfade")
// })
// }).then(resp => resp.json()).then(resp => console.log(resp));


// fetch(`https://ewdamagenumbers/localdmgstatus`, {
//   method: 'POST',
//   headers: {
//   'Content-Type': 'application/json; charset=UTF-8',
// },
// body: JSON.stringify({
// localdmg: localStorage.getItem("localdmg")
// })
// }).then(resp => resp.json()).then(resp => console.log(resp));


// fetch(`https://ewdamagenumbers/precisionstatus`, {
//   method: 'POST',
//   headers: {
//   'Content-Type': 'application/json; charset=UTF-8',
// },
// body: JSON.stringify({
// precision: localStorage.getItem("precision")
// })
// }).then(resp => resp.json()).then(resp => console.log(resp));

const CancelMenu = () => {
  $.post(`https://ewdamagenumbers/cancel`);
};

document.onkeyup = function (event) {
  event = event || window.event;
  var charCode = event.keyCode || event.which;
  if (charCode == 27) {
    CancelMenu();
  }
};

// event.data.action == "open"


window.addEventListener("message", function (event) {
  let data = event.data;
  // console.log(data);
  if (data.showdmgmenu == true) {
    var dynstate = (localStorage.getItem('dynamicfade') === 'true');
    document.getElementById('dynamicfadeonoff').checked = dynstate;
    document.getElementById('fadespeedrange').disabled = dynstate;
    var fspeed = localStorage.getItem('fadespeed');
    document.getElementById('fadespeedrange').value = fspeed;
    document.getElementById('fadespeedshow').value = fspeed;
    document.getElementById('localdmgonoff').checked = (localStorage.getItem('localdmg') === 'true');
    var prec = localStorage.getItem('precision');
    document.getElementById('precisionrange').value = prec;
    document.getElementById('precisionshow').value = prec;
    $(".dmgmenu").show()
  } else if (data.showdmgmenu == false) {
    $(".dmgmenu").hide();
  }

});
