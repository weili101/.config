;; -*- lexical-binding: t; -*-

;; Prevent package.el from loading before init.el (if you use straight/use-package with :ensure)
(setq package-enable-at-startup nil)

;; This is the key setting: stop Emacs from resizing the frame
;; when toolbar/menubar/scrollbar/font settings change
(setq frame-inhibit-implied-resize t)

;; Disable UI chrome here (BEFORE frame creation) instead of in init.el
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; Set an explicit size/position so it doesn't need to resize to fit content later
(push '(fullscreen . maximized) default-frame-alist)
;; (push '(width . 120) default-frame-alist)
;; (push '(height . 45) default-frame-alist)

;; Optional: set font here too, so frame is sized correctly from the start
(push '(font . "Fira Code-16") default-frame-alist)

;; Avoid the mode-line/frame flashing white before your theme loads
;; (push '(background-color . "#1e1e1e") default-frame-alist)
;; (push '(foreground-color . "#dddddd") default-frame-alist)

;; Speed up startup (bonus, unrelated to resize but commonly paired)
(setq gc-cons-threshold most-positive-fixnum)
(setq inhibit-splash-screen t)
