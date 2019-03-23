function preventAll(e) {
  e.preventDefault();
}

function preventArrows(e) {
  if (e.key == 'ArrowUp' || e.key == 'ArrowDown'
      || e.key == 'ArrowLeft' || e.key == 'ArrowRight') {
    e.preventDefault();
  }
}

function prepareCanvas(canvas) {
  canvas.tabIndex = 1;
  canvas.addEventListener('keypress', preventAll);
  canvas.addEventListener('keydown', preventArrows);
}
