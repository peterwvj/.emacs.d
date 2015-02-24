;; Time-stamp: <2015-02-23 23:28:13 kmodi>

;; dired, dired-x, dired+, dired-single
;; http://www.emacswiki.org/emacs-en/dired-single.el
;; http://truongtx.me/2013/04/24/dired-as-default-file-manager-1-introduction

(use-package dired-single
  :commands (dired dired-single-magic-buffer-current-dir dired-single-magic-buffer)
  :init
  (progn
    (bind-keys
     :map modi-mode-map
     ;; Change the default `C-x C-d` key binding from `ido-list-directory'
     ("C-x C-d" . dired-single-magic-buffer-current-dir)
     ;; Change the default `C-x C-j` key binding from `dired-jump'
     ;; Opens dired-single-magic-buffer but asks which directory to open that
     ;; dired buffer for.
     ("C-x C-j" . dired-single-magic-buffer)))
  :config
  (progn
    (setq dired-recursive-deletes 'always)
    (setq dired-recursive-copies  'always)
    ;; Set this variable to non-nil, Dired will try to guess a default
    ;; target directory. This means: if there is a dired buffer
    ;; displayed in the next window, use its current subdir, instead
    ;; of the current subdir of this dired buffer. The target is used
    ;; in the prompt for file copy, rename etc.
    (setq dired-dwim-target t)

    (use-package dired+
      :config
      (progn
        ;; detail toggling is bound to `(' in dired-mode by default
        (setq diredp-hide-details-initially-flag nil)
        (setq diredp-hide-details-last-state     nil)
        ))

    (use-package dired-x
      :config
      (progn
        (setq dired-omit-verbose nil)
        ;; hide backup, autosave, *.*~ files
        ;; omit mode can be toggled using `M-o' in dired buffer
        (setq-default dired-omit-mode t)))

    (defun dired-single-magic-buffer-current-dir ()
      "Open a single magic dired buffer for the current buffer directory."
      (interactive)
      (dired-single-magic-buffer default-directory))

    (defun dired-single-up-directory ()
      (interactive)
      (dired-single-buffer ".."))

    (defun rename-dired-buffer-name ()
      "Rename the dired buffer name to distinguish it from file buffers.
It added extra strings at the front and back of the default dired buffer name."
      (let ((name (buffer-name)))
        (if (not (string-match "/$" name))
            (rename-buffer (concat "*Dired* " name "/") t))))
    (add-hook 'dired-mode-hook #'rename-dired-buffer-name)

    (bind-keys
     :map dired-mode-map
     ("<return>"         . dired-single-buffer)
     ("<double-mouse-1>" . dired-single-buffer-mouse)
     ("^"                . dired-single-up-directory))

    ;; http://oremacs.com/2015/02/21/hydra-docstring-sexp
    (defhydra hydra-dired-marked (dired-mode-map "" :color pink)
      "
Number of marked items: %(length (dired-get-marked-files))
"
      ("m"   dired-mark             "mark")
      ("u"   dired-unmark           "unmark")
      ("U"   dired-unmark-all-marks "unmark ALL")
      ("t"   dired-toggle-marks     "toggle marks")
      ("P"   dired-prev-marked-file "prev marked")
      ("M-{" dired-prev-marked-file "prev marked")
      ("N"   dired-next-marked-file "next marked")
      ("M-}" dired-next-marked-file "next marked")
      ("C-g" nil                    "cancel" :color blue))))


(provide 'setup-dired)

;; TIPS

;; (1) Jump to the dired of the current file
;; `C-x C-j` - Calls `dired-jump' function.
;; Jump to dired buffer corresponding to current buffer.
;; If in a file, dired the current directory and move to file's line.
;; If in Dired already, pop up a level and goto old directory's line.
;; In case the proper dired file line cannot be found, refresh the dired
;; buffer and try again.
