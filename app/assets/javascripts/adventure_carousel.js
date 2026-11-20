document.addEventListener("DOMContentLoaded", function () {
  const element = document.getElementById("adventureCarousel");
  if (!element || element.querySelectorAll(".carousel-item").length < 2) return;

  const carousel = bootstrap.Carousel.getOrCreateInstance(element, {
    interval: 7000,
    ride: false,
    pause: false,
    touch: true
  });
  const button = element.querySelector(".adventure-pause");
  let playing = !window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  function updateButton() {
    button.textContent = playing ? "Pause slideshow" : "Play slideshow";
    button.setAttribute("aria-label", button.textContent);
  }

  button.hidden = false;
  updateButton();
  if (playing) carousel.cycle();
  button.addEventListener("click", function () {
    playing = !playing;
    if (playing) {
      carousel.cycle();
    } else {
      carousel.pause();
    }
    updateButton();
  });
});
