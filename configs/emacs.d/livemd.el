;;; livemd.el --- Typora-like live Markdown rendering with math -*- lexical-binding: t; -*-

;; Author: Math Previewer project
;; Version: 0.1.0
;; Package-Requires: ((emacs "27.1") (markdown-mode "2.5"))
;; Keywords: markdown, wysiwyg, tex, convenience

;;; Commentary:
;;
;; `livemd-mode' is a minor mode that gives a Typora-like editing
;; experience on top of `markdown-mode':
;;
;;   * Markup characters (**, _, `, #, >) are hidden, and revealed only
;;     on the line your cursor is on -- so text reads like the rendered
;;     document while staying fully editable.
;;
;;   * LaTeX math ($..$, $$..$$, \(..\), \[..\]) is rendered inline as an
;;     image via a real LaTeX toolchain.  Move point into a fragment to
;;     edit its source; leave to re-render.
;;
;; Requirements: GUI Emacs with SVG support, `markdown-mode', and a LaTeX
;; toolchain.  Math fragments are rendered with this pipeline (all three
;; must be on PATH):
;;
;;     pdflatex  ->  gs (ghostscript, tight bbox crop)  ->  pdftocairo -svg
;;
;; These are standard: pdflatex ships with any TeX install; gs and
;; pdftocairo come from Ghostscript and Poppler (e.g. `brew install
;; ghostscript poppler').  No extra LaTeX packages are needed.
;;
;; Usage:  M-x livemd-mode  in a Markdown buffer.
;;
;;; Code:

(require 'markdown-mode)
(require 'subr-x)

(defgroup livemd nil
  "Typora-like live Markdown rendering."
  :group 'markdown
  :prefix "livemd-")

(defcustom livemd-math-scale 1.4
  "Display scale applied to rendered math images."
  :type 'number)

(defcustom livemd-idle-delay 0.4
  "Idle seconds after a change before math is re-rendered."
  :type 'number)

(defcustom livemd-header-scaling t
  "When non-nil, scale heading faces (Typora-like)."
  :type 'boolean)

(defcustom livemd-latex-template
  "\\documentclass[12pt]{article}
\\usepackage{amsmath,amssymb,amsfonts}
\\usepackage{xcolor}
\\pagestyle{empty}
\\begin{document}
\\color[HTML]{%s}%s
\\end{document}
"
  "LaTeX document used to render a fragment.
First %%s is the foreground color as RRGGBB, second is the math body
\(already wrapped in $..$ or \\[..\\]).  The page is cropped tightly to
the content afterwards, so no special document class is required."
  :type 'string)

(defvar livemd-mode)                    ; defined below by `define-minor-mode'

(defvar livemd--cache-dir
  (expand-file-name "livemd-cache" temporary-file-directory)
  "Directory holding cached math images.")

(defvar-local livemd--revealed nil
  "Overlays currently revealed at point (to be re-concealed on move).")

(defvar-local livemd--idle-timer nil)
(defvar-local livemd--render-timer nil)
(defvar-local livemd--queue nil
  "Math overlays still awaiting a rendered image.")

;;; ---------------------------------------------------------------- math

(defun livemd--color-hex (color)
  "Return COLOR as an RRGGBB hex string, defaulting to black."
  (let ((vals (and (stringp color) (color-values color))))
    (if vals
        (apply #'format "%02X%02X%02X"
               (mapcar (lambda (c) (/ c 256)) vals))
      "000000")))

(defun livemd--run (prog &rest args)
  "Run PROG with ARGS; return t on exit code 0."
  (eq 0 (apply #'call-process prog nil nil nil args)))

(defun livemd--run-out (prog &rest args)
  "Run PROG with ARGS; return combined output string, or nil on failure."
  (with-temp-buffer
    (when (eq 0 (apply #'call-process prog nil (list t t) nil args))
      (buffer-string))))

(defun livemd--compile (body fg base)
  "Compile BODY (foreground color FG) into BASE.svg via pdflatex+gs+pdftocairo.
Return (FILE . TYPE) or nil on failure."
  (let* ((tmp (make-temp-file "livemd" t))
         (tex (expand-file-name "m.tex" tmp))
         (pdf (expand-file-name "m.pdf" tmp))
         (crop (expand-file-name "c.pdf" tmp))
         (svg (concat base ".svg"))
         (default-directory tmp))
    (with-temp-file tex (insert (format livemd-latex-template fg body)))
    (unwind-protect
        (when (and (livemd--run "pdflatex" "-interaction=nonstopmode"
                                "-halt-on-error" tex)
                   (file-exists-p pdf))
          (let ((bbox (livemd--run-out "gs" "-q" "-dBATCH" "-dNOPAUSE"
                                       "-sDEVICE=bbox" pdf)))
            (when (and bbox
                       (string-match
                        "HiResBoundingBox: \\([0-9.]+\\) \\([0-9.]+\\) \\([0-9.]+\\) \\([0-9.]+\\)"
                        bbox))
              (let* ((llx (match-string 1 bbox))
                     (lly (match-string 2 bbox))
                     (w (number-to-string
                         (- (string-to-number (match-string 3 bbox))
                            (string-to-number llx))))
                     (h (number-to-string
                         (- (string-to-number (match-string 4 bbox))
                            (string-to-number lly)))))
                (when (and (livemd--run
                            "gs" "-o" crop "-sDEVICE=pdfwrite"
                            (concat "-dDEVICEWIDTHPOINTS=" w)
                            (concat "-dDEVICEHEIGHTPOINTS=" h)
                            "-dFIXEDMEDIA"
                            "-c" (format "<</PageOffset [-%s -%s]>> setpagedevice"
                                         llx lly)
                            "-f" pdf)
                           (livemd--run "pdftocairo" "-svg" crop svg)
                           (file-exists-p svg))
                  (cons svg 'svg))))))
      (delete-directory tmp t))))

(defun livemd--math-image (tex displayp &optional compile)
  "Return an image for math TEX (display when DISPLAYP).
Use the on-disk cache; only run LaTeX when COMPILE is non-nil."
  (make-directory livemd--cache-dir t)
  (let* ((fg (livemd--color-hex (or (face-foreground 'default nil t) "black")))
         (body (if displayp (format "\\[%s\\]" tex) (format "$%s$" tex)))
         (key (secure-hash 'sha1 (format "%s|%S|%s" body displayp fg)))
         (base (expand-file-name key livemd--cache-dir))
         (svg (concat base ".svg"))
         (mk (lambda (file type)
               (create-image file type nil
                              :scale livemd-math-scale :ascent 'center))))
    (cond ((file-exists-p svg) (funcall mk svg 'svg))
          (compile (when-let ((res (livemd--compile body fg base)))
                     (funcall mk (car res) (cdr res))))
          (t nil))))

(defun livemd--parse-math (str)
  "Return (INNER . DISPLAYP) for math source STR (with delimiters)."
  (cond ((string-prefix-p "$$" str) (cons (substring str 2 -2) t))
        ((string-prefix-p "\\[" str) (cons (substring str 2 -2) t))
        ((string-prefix-p "\\(" str) (cons (substring str 2 -2) nil))
        (t (cons (substring str 1 -1) nil))))

(defconst livemd--math-re
  (concat "\\$\\$\\(?:.\\|\n\\)+?\\$\\$"          ; $$ .. $$
          "\\|\\\\\\[\\(?:.\\|\n\\)+?\\\\\\]"     ; \[ .. \]
          "\\|\\\\(\\(?:.\\|\n\\)+?\\\\)"         ; \( .. \)
          "\\|\\$[^$\n]+?\\$")                    ; $ .. $
  "Regexp matching a math fragment.")

(defun livemd--code-face-p (pos)
  "Non-nil if POS is inside Markdown code/pre (should not be math)."
  (let ((f (get-text-property pos 'face)))
    (seq-some (lambda (x) (memq x '(markdown-code-face
                                    markdown-pre-face
                                    markdown-inline-code-face)))
              (if (listp f) f (list f)))))

(defun livemd--available-p ()
  "Non-nil if the LaTeX toolchain for math is on PATH."
  (and (executable-find "pdflatex")
       (executable-find "gs")
       (executable-find "pdftocairo")))

(defun livemd--render-overlay (ov)
  "Compile the math source stored on OV and show it as an image."
  (when (overlay-buffer ov)
    (let* ((p (livemd--parse-math (overlay-get ov 'livemd-src)))
           (img (ignore-errors
                  (livemd--math-image (string-trim (car p)) (cdr p) t))))
      (when img
        (overlay-put ov 'livemd-image img)
        ;; Do not cover the source if point is currently editing it.
        (unless (memq ov livemd--revealed)
          (overlay-put ov 'display img))))))

(defun livemd--render-tick (buf)
  "Render one queued fragment in BUF; stop the timer when done."
  (if (not (buffer-live-p buf))
      (progn (when (timerp livemd--render-timer)
               (cancel-timer livemd--render-timer)))
    (with-current-buffer buf
      (let ((ov (pop livemd--queue)))
        (when ov (livemd--render-overlay ov)))
      (unless livemd--queue
        (when (timerp livemd--render-timer)
          (cancel-timer livemd--render-timer)
          (setq livemd--render-timer nil))))))

(defun livemd--kick-render ()
  "Start (or restart) progressive background rendering of the queue."
  (when (and livemd--queue (not (timerp livemd--render-timer)))
    (setq livemd--render-timer
          (run-with-idle-timer 0.05 t #'livemd--render-tick
                               (current-buffer)))))

(defun livemd--scan-math ()
  "Find math fragments, show source now, and queue images to render."
  (when (livemd--available-p)
    (dolist (ov (overlays-in (point-min) (point-max)))
      (when (eq (overlay-get ov 'livemd) 'math) (delete-overlay ov)))
    (setq livemd--queue nil)
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward livemd--math-re nil t)
        (let ((b (match-beginning 0)) (e (match-end 0))
              (str (match-string-no-properties 0)))
          (unless (livemd--code-face-p b)
            (let* ((ov (make-overlay b e))
                   (p (livemd--parse-math str))
                   ;; Cache hit: show instantly, no LaTeX, no flicker.
                   (img (ignore-errors
                          (livemd--math-image (string-trim (car p)) (cdr p) nil))))
              (overlay-put ov 'livemd 'math)
              (overlay-put ov 'livemd-src str)
              (overlay-put ov 'evaporate t)
              (if img
                  (progn (overlay-put ov 'livemd-image img)
                         (overlay-put ov 'display img))
                (push ov livemd--queue)))))))
    (setq livemd--queue (nreverse livemd--queue))
    (livemd--point-update)
    (livemd--kick-render)))

;;; ------------------------------------------------------------- markup

(defconst livemd--markup-faces
  '(markdown-markup-face markdown-header-delimiter-face)
  "Faces whose characters are treated as concealable markup.")

(defun livemd--markup-p (pos)
  "Non-nil if POS carries a concealable Markdown markup face."
  (let ((f (get-text-property pos 'face)))
    (seq-some (lambda (x) (memq x livemd--markup-faces))
              (if (listp f) f (list f)))))

(defun livemd--jit-markup (beg end)
  "Hide Markdown markup between BEG and END with overlays."
  (dolist (ov (overlays-in beg end))
    (when (eq (overlay-get ov 'livemd) 'markup) (delete-overlay ov)))
  (let ((pos beg))
    (while (< pos end)
      (if (livemd--markup-p pos)
          (let ((s pos))
            (while (and (< pos end) (livemd--markup-p pos))
              (setq pos (1+ pos)))
            (let ((ov (make-overlay s pos)))
              (overlay-put ov 'livemd 'markup)
              (overlay-put ov 'invisible 'livemd-markup)
              (overlay-put ov 'evaporate t)))
        (setq pos (1+ pos))))))

;;; -------------------------------------------------------- reveal logic

(defun livemd--conceal-all ()
  "Re-conceal every overlay previously revealed at point."
  (dolist (ov livemd--revealed)
    (when (overlay-buffer ov)
      (pcase (overlay-get ov 'livemd)
        ('markup (overlay-put ov 'invisible 'livemd-markup))
        ('math   (overlay-put ov 'display (overlay-get ov 'livemd-image))))))
  (setq livemd--revealed nil))

(defun livemd--reveal (ov)
  "Reveal source under overlay OV."
  (pcase (overlay-get ov 'livemd)
    ('markup (overlay-put ov 'invisible nil))
    ('math   (overlay-put ov 'display nil)))
  (push ov livemd--revealed))

(defun livemd--point-update ()
  "Reveal markup on the current line and math under point."
  (when livemd-mode
    (livemd--conceal-all)
    (let* ((pt (point))
           (lb (line-beginning-position))
           (le (line-end-position)))
      (dolist (ov (overlays-in (min lb pt) (max le pt (1+ pt))))
        (pcase (overlay-get ov 'livemd)
          ('markup (livemd--reveal ov))
          ('math (when (and (<= (overlay-start ov) pt)
                            (>= (overlay-end ov) pt))
                   (livemd--reveal ov))))))))

;;; --------------------------------------------------------------- glue

(defun livemd--after-change (&rest _)
  "Schedule a math re-scan after edits settle."
  (when (timerp livemd--idle-timer) (cancel-timer livemd--idle-timer))
  (setq livemd--idle-timer
        (run-with-idle-timer
         livemd-idle-delay nil
         (lambda (buf)
           (when (buffer-live-p buf)
             (with-current-buffer buf
               (when livemd-mode (livemd--scan-math)))))
         (current-buffer))))

;;;###autoload
(define-minor-mode livemd-mode
  "Typora-like live Markdown rendering with inline math."
  :lighter " LiveMD"
  (if livemd-mode
      (progn
        (unless (derived-mode-p 'markdown-mode)
          (user-error "livemd-mode requires a `markdown-mode' buffer"))
        (setq-local markdown-hide-markup nil) ; we hide markup ourselves
        (when (and livemd-header-scaling
                   (fboundp 'markdown-update-header-faces))
          (ignore-errors
            (markdown-update-header-faces t markdown-header-scaling-values)))
        (add-to-invisibility-spec 'livemd-markup)
        (jit-lock-register #'livemd--jit-markup)
        (add-hook 'post-command-hook #'livemd--point-update nil t)
        (add-hook 'after-change-functions #'livemd--after-change nil t)
        (font-lock-flush)
        ;; Defer the first scan so the buffer displays immediately; math
        ;; then renders progressively in the background (see `livemd--kick-render').
        (run-with-idle-timer
         0.2 nil
         (lambda (buf) (when (buffer-live-p buf)
                         (with-current-buffer buf
                           (when livemd-mode (livemd--scan-math)))))
         (current-buffer)))
    ;; teardown
    (jit-lock-unregister #'livemd--jit-markup)
    (remove-hook 'post-command-hook #'livemd--point-update t)
    (remove-hook 'after-change-functions #'livemd--after-change t)
    (remove-from-invisibility-spec 'livemd-markup)
    (when (timerp livemd--idle-timer) (cancel-timer livemd--idle-timer))
    (when (timerp livemd--render-timer) (cancel-timer livemd--render-timer))
    (setq livemd--render-timer nil livemd--queue nil)
    (dolist (ov (overlays-in (point-min) (point-max)))
      (when (overlay-get ov 'livemd) (delete-overlay ov)))
    (setq livemd--revealed nil)
    (font-lock-flush)))

(provide 'livemd)
;;; livemd.el ends here
