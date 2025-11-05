function showTime() {
  document.getElementById('currentTime').innerHTML = new Date().toUTCString();
}
showTime();
setInterval(showTime, 1000);
function showTime() {
  document.getElementById('currentTime').innerText = new Date().toUTCString();
}
showTime();
setInterval(showTime, 1000);