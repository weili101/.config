;; init.el --- Emacs configuration bootstrap -*- lexical-binding: t; -*-

;; The real configuration lives in config.org.  `org-babel-load-file'
;; tangles its emacs-lisp source blocks into config.el and loads it,
;; re-tangling only when config.org is newer.
(require 'org)
(org-babel-load-file (expand-file-name "config.org" user-emacs-directory))
