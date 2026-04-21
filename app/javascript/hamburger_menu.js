// app/javascript/hamburger_menu.js

// 直前のページで付けたイベントを外すためのクリーンアップ用変数
let cleanupHamburger = null;

const initHamburgerMenu = () => {
  // まず前のページで付けたイベントを解除
  if (cleanupHamburger) {
    cleanupHamburger();
    cleanupHamburger = null;
  }

  const header = document.querySelector(".app-header");
  const button = document.getElementById("js-hamburger-button");
  const nav = document.getElementById("global-nav");

  // このページにヘッダー or メニューがないなら何もしない
  if (!header || !button || !nav) return;

  const toggleMenu = () => {
    const isOpen = header.classList.toggle("is-menu-open");
    button.setAttribute("aria-expanded", String(isOpen));
  };

  const onButtonClick = (event) => {
    event.stopPropagation();
    toggleMenu();
  };

  const onDocumentClick = (event) => {
    if (!header.classList.contains("is-menu-open")) return;

    // ボタン or メニューの中をクリックしているなら閉じない
    if (
      button.contains(event.target) ||
      nav.contains(event.target)
    ) {
      return;
    }

    header.classList.remove("is-menu-open");
    button.setAttribute("aria-expanded", "false");
  };

  const onNavClick = () => {
    if (!header.classList.contains("is-menu-open")) return;
    header.classList.remove("is-menu-open");
    button.setAttribute("aria-expanded", "false");
  };

  // イベントを登録
  button.addEventListener("click", onButtonClick);
  document.addEventListener("click", onDocumentClick);
  nav.addEventListener("click", onNavClick);

  // 次のページ遷移時に外せるように退避
  cleanupHamburger = () => {
    button.removeEventListener("click", onButtonClick);
    document.removeEventListener("click", onDocumentClick);
    nav.removeEventListener("click", onNavClick);
  };
};

// Turbo でページが表示されるたびに初期化
document.addEventListener("turbo:load", initHamburgerMenu);

// （念のため通常リロード用も付けておく）
document.addEventListener("DOMContentLoaded", initHamburgerMenu);
