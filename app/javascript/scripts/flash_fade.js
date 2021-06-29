document.addEventListener('DOMContentLoaded', function () {

  var alert = document.getElementsByClassName('alert')[0]
  if (!alert) return
  fadeOut(alert)
})
function fade(el) {
  var op = 1;
  var timer = setInterval(function () {
    if (op <= 0.1){
      clearInterval(timer);
      el.remove();
    }
    el.style.opacity = op;
    op -= op * 0.1;
  }, 50);
}
function fadeOut(el){
  el.style.opacity = 1;

  (function fade() {
    if ((el.style.opacity -= .1) < 0) {
      el.remove();
    } else {
      setTimeout(fade, 250);
    }
  })();
}
