/*
 * App Verse Games: embeds a game in a WordPress page.
 * Copyright (c) App Verse Games. All rights reserved.
 *
 * In the page's Custom HTML block:
 *
 *   <div class="avg-embed" data-src="/play/sudoku/" data-title="Sudoku"></div>
 *   <script src="/play/sudoku/embed.js" defer></script>
 *
 * Desktop (mouse or trackpad): the game is shown in the page, as before.
 *
 * Touch screens: a live game in the page takes every touch, so a swipe that
 * starts on it can't scroll the page. Instead the page shows a "Play" card;
 * tapping it opens the game over the whole screen, with a Close bar at the
 * top. The phone's Back button closes it too. Closing keeps the game, so
 * Play again continues where the player left off; while it is closed the
 * game is sent {avgEmbed: 'hide'} (then 'show') so it can pause its clock.
 *
 * Optional attributes on the div:
 *   data-icon  picture on the card (default: <data-src>icons/Icon-192.png)
 *   data-mode  "auto" (default), "tap" (always the card) or "live" (always
 *              in the page). For testing, ?avg-embed=tap or =live in the
 *              page address overrides it.
 */
(function () {
  'use strict';

  var NAVY = '#16193A';
  var AMBER = '#F2A541';
  var IVORY = '#F6F3EC';

  var CSS =
    '.avg-embed-live{width:100%;height:700px;max-height:85vh;border:0;' +
    'border-radius:24px;display:block}' +
    '.avg-embed-card{box-sizing:border-box;width:100%;min-height:240px;' +
    'display:flex;flex-direction:column;align-items:center;' +
    'justify-content:center;gap:12px;padding:28px 16px;border:0;' +
    'border-radius:24px;background:' + NAVY + ';color:' + IVORY + ';' +
    'font:inherit;text-align:center;cursor:pointer;' +
    '-webkit-tap-highlight-color:transparent}' +
    '.avg-embed-card img{width:96px;height:96px;border-radius:22px}' +
    '.avg-embed-title{font-size:1.5em;font-weight:700;line-height:1.2}' +
    '.avg-embed-play{display:inline-flex;align-items:center;gap:8px;' +
    'padding:12px 28px;border-radius:999px;background:' + AMBER + ';' +
    'color:' + NAVY + ';font-weight:700;font-size:1.1em}' +
    '.avg-embed-note{font-size:.85em;opacity:.75}' +
    '.avg-embed-overlay{position:fixed;inset:0;width:100%;height:100%;' +
    'height:100dvh;z-index:2147483000;display:flex;flex-direction:column;' +
    'background:' + IVORY + '}' +
    '.avg-embed-overlay[hidden]{display:flex;visibility:hidden;' +
    'pointer-events:none}' +
    '.avg-embed-bar{flex:none;display:flex;align-items:center;' +
    'justify-content:space-between;gap:12px;box-sizing:border-box;' +
    'min-height:48px;padding:0 8px 0 16px;' +
    'padding-top:env(safe-area-inset-top);background:' + NAVY + ';' +
    'color:' + IVORY + ';font-weight:700}' +
    '.avg-embed-close{display:inline-flex;align-items:center;gap:6px;' +
    'min-height:40px;padding:0 14px;border:1px solid rgba(246,243,236,.4);' +
    'border-radius:999px;background:transparent;color:' + IVORY + ';' +
    'font:inherit;font-weight:700;cursor:pointer}' +
    '.avg-embed-overlay iframe{flex:1;width:100%;min-height:0;border:0;' +
    'display:block;padding-bottom:env(safe-area-inset-bottom);' +
    'box-sizing:border-box;background:' + IVORY + '}';

  function addStyles() {
    if (document.getElementById('avg-embed-css')) return;
    var style = document.createElement('style');
    style.id = 'avg-embed-css';
    style.textContent = CSS;
    document.head.appendChild(style);
  }

  function el(tag, className, text) {
    var e = document.createElement(tag);
    if (className) e.className = className;
    if (text) e.textContent = text;
    return e;
  }

  function gameFrame(src, title) {
    var frame = document.createElement('iframe');
    frame.src = src;
    frame.title = title;
    frame.setAttribute('allow', 'fullscreen');
    return frame;
  }

  function wantsCard(box) {
    var forced = /[?&]avg-embed=(tap|live)\b/.exec(location.search);
    var mode = forced ? forced[1] : box.getAttribute('data-mode') || 'auto';
    if (mode === 'tap') return true;
    if (mode === 'live') return false;
    // Touch is the main input: phones and tablets.
    return window.matchMedia && matchMedia('(pointer: coarse)').matches;
  }

  function setUp(box) {
    if (box.getAttribute('data-avg-ready')) return;
    box.setAttribute('data-avg-ready', '1');
    var src = box.getAttribute('data-src');
    if (!src) return;
    var title = box.getAttribute('data-title') || 'Game';

    if (!wantsCard(box)) {
      var live = gameFrame(src, title);
      live.className = 'avg-embed-live';
      box.appendChild(live);
      return;
    }

    // The card in the page.
    var card = el('button', 'avg-embed-card');
    card.type = 'button';
    var icon = document.createElement('img');
    icon.src =
      box.getAttribute('data-icon') ||
      src.replace(/\/?$/, '/') + 'icons/Icon-192.png';
    icon.alt = '';
    var play = el('span', 'avg-embed-play', '\u25B6 Play ' + title);
    var note = el('span', 'avg-embed-note', 'Opens full screen');
    card.appendChild(icon);
    card.appendChild(el('span', 'avg-embed-title', title));
    card.appendChild(play);
    card.appendChild(note);
    box.appendChild(card);

    // The full-screen layer, added to <body> so no theme styles on the
    // page's own containers can trap or clip it. The game is only loaded
    // on the first tap.
    var overlay = el('div', 'avg-embed-overlay');
    overlay.hidden = true;
    overlay.setAttribute('role', 'dialog');
    overlay.setAttribute('aria-label', title);
    var bar = el('div', 'avg-embed-bar');
    bar.appendChild(el('span', '', title));
    var close = el('button', 'avg-embed-close', '\u2715 Close');
    close.type = 'button';
    bar.appendChild(close);
    overlay.appendChild(bar);
    document.body.appendChild(overlay);

    var frame = null;
    var isOpen = false;
    var pushed = false;
    var saved = { html: '', body: '' };

    // Tells the game whether it can be seen, so it can pause its clock.
    function tell(state) {
      try {
        frame.contentWindow.postMessage({ avgEmbed: state }, location.origin);
      } catch (e) {
        // Not loaded yet: nothing to pause.
      }
    }

    function open() {
      if (isOpen) return;
      isOpen = true;
      if (!frame) {
        frame = gameFrame(src, title);
        overlay.appendChild(frame);
      } else {
        tell('show');
      }
      overlay.hidden = false;
      // Stop the page behind from scrolling while the game is open.
      saved.html = document.documentElement.style.overflow;
      saved.body = document.body.style.overflow;
      document.documentElement.style.overflow = 'hidden';
      document.body.style.overflow = 'hidden';
      // So the phone's Back button closes the game instead of leaving.
      try {
        history.pushState({ avgEmbed: true }, '');
        pushed = true;
      } catch (e) {
        pushed = false;
      }
      setTimeout(function () {
        if (frame) frame.focus();
      }, 50);
    }

    function hide() {
      if (!isOpen) return;
      isOpen = false;
      overlay.hidden = true;
      tell('hide');
      document.documentElement.style.overflow = saved.html;
      document.body.style.overflow = saved.body;
      play.textContent = '\u25B6 Continue ' + title;
      note.textContent = 'Your game is still open';
      card.focus();
    }

    card.addEventListener('click', open);
    close.addEventListener('click', function () {
      if (pushed) {
        pushed = false;
        history.back(); // fires popstate, which hides the game
      } else {
        hide();
      }
    });
    window.addEventListener('popstate', function () {
      pushed = false;
      hide();
    });
    document.addEventListener('keydown', function (e) {
      if (isOpen && e.key === 'Escape') close.click();
    });
  }

  function start() {
    addStyles();
    var boxes = document.querySelectorAll('.avg-embed');
    for (var i = 0; i < boxes.length; i++) setUp(boxes[i]);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', start);
  } else {
    start();
  }
})();
