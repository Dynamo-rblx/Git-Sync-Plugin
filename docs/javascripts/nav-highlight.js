(() => {
  let timer;

  function clearHighlights() {
    document.querySelectorAll(".nav-highlight").forEach(link => {
      link.classList.remove("nav-highlight");
    });
  }

  document.addEventListener("click", event => {
    const trigger = event.target.closest("[data-highlight-pages]");
    if (!trigger) return;

    clearTimeout(timer);
    clearHighlights();

    const pages = new Set(
      trigger.dataset.highlightPages.trim().split(/\s+/)
    );

    document.querySelectorAll(
      '[data-slot="sidebar-menu"] a[href]'
    ).forEach(link => {
      const path = new URL(link.href).pathname;

      // Support /pushing/, /pushing/index.html, and /pushing.html.
      const page = path
        .replace(/\/index\.html$/, "/")
        .replace(/\/$/, "")
        .split("/")
        .pop()
        .replace(/\.html$/, "");

      if (pages.has(page)) {
        link.classList.add("nav-highlight");
      }
    });

    timer = setTimeout(clearHighlights, 2000);
  });
})();