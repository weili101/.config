;; Font
(setq doom-font (font-spec :family "Fira Code" :size 18))

;; Start maximized
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Theme
;;(setq doom-theme 'doom-one)
(setq doom-theme 'catppuccin)

(setq display-line-numbers-type t)

;; Press jk quickly to leave insert mode
(setq evil-escape-key-sequence "jk")

(setq org-directory "~/orgfiles/")

;; Make sure the directory exists
(make-directory org-directory t)

(setq org-agenda-files (list org-directory))

(setq org-default-notes-file
      (expand-file-name "inbox.org" org-directory))

(after! org
  (setq org-capture-templates
        `(("t" "Task" entry
           (file ,(expand-file-name "inbox.org" org-directory))
           "* TODO %?\n  %U\n")

          ("n" "Note" entry
           (file ,(expand-file-name "inbox.org" org-directory))
           "* NOTE %?\n  %U\n")

          ("p" "Paper" entry
           (file ,(expand-file-name "papers.org" org-directory))
           "* TODO %^{Paper title} :paper:\n%U\n** Why read this?\n%?\n** Notes\n")

          ("r" "Research idea" entry
           (file ,(expand-file-name "research.org" org-directory))
           "* IDEA %? :research:idea:\n%U\n"))))

(after! pdf-view
(defun my/pdf-view-double-page-open ()
  "Split the current PDF buffer into a side-by-side double page layout."
  (interactive)
  (delete-other-windows)
  (let ((current-page (pdf-view-current-page)))
    (split-window-right)
    (other-window 1)
    (pdf-view-goto-page (+ current-page 1))
    (other-window -1)))

(defun my/pdf-view-double-page-next (arg)
  "Advance both windows by 2 pages."
  (interactive "p")
  (let ((steps (* 2 arg)))
    (pdf-view-next-page steps)
    (other-window 1)
    (pdf-view-next-page steps)
    (other-window -1)))

(defun my/pdf-view-double-page-previous (arg)
  "Move both windows back by 2 pages."
  (interactive "p")
  (let ((steps (* 2 arg)))
    (pdf-view-previous-page steps)
    (other-window 1)
    (pdf-view-previous-page steps)
    (other-window -1)))

;; Bind keys within pdf-view-mode
  ;; Bind keys inside pdf-view-mode using Doom's Evil-aware mapper
  (map! :map pdf-view-mode-map
        :n "D" #'my/pdf-view-double-page-open
        :n "N" #'my/pdf-view-double-page-next
        :n "P" #'my/pdf-view-double-page-previous)
)

(defun +dired/toggle-side-panel ()
  "Toggle a persistent Dired side panel on the left."
  (interactive)
  (let ((buf-name "*Dired-Sidebar*"))
    (if (get-buffer-window buf-name)
        (delete-window (get-buffer-window buf-name))
      (let ((current-prefix-arg nil))
        (dired default-directory)
        (rename-buffer buf-name)
        (let ((window (display-buffer-in-side-window (current-buffer) '((side . left) (slot . 0))))))
        (set-window-dedicated-p (get-buffer-window buf-name) t)
        (setq-local window-size-fixed 'width)
        (set-window-width (get-buffer-window buf-name) 35)))))

;; Bind the function to a key sequence (e.g., SPC o d)
(map! :leader
      :desc "Toggle Dired side panel"
      "o d" #'+dired/toggle-side-panel)

(if (equal major-mode 'markdown-view-mode)
  (local-set-key (kbd "C-x C-q") 'markdown-mode))
(if (equal major-mode 'markdown-mode)
  (local-set-key (kbd "C-x C-q") 'markdown-view-mode))
