;; show line numbers
(global-linum-mode t)

(setq tramp-default-method "ssh")

;; MELPA installation
(require 'package)
(add-to-list 'package-archives
         '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

;; custom theme (blackboard-theme)
(add-to-list 'custom-theme-load-path "~/.emacs.d/blackboard-theme-master")
(load-theme 'blackboard t)
;; solatized theme
(add-to-list 'custom-theme-load-path "~/.emacs.d/emacs-color-theme-solarized-master")
;;(load-theme 'solarized t)

;; default font for new (non special-display) frames
(add-to-list 'default-frame-alist '(font . "DejaVu Sans Mono-10.5" ))

;; save buffers after exiting
;;(desktop-save-mode 1)

;; remove UI stuff
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;; cursor stuff
(setq-default cursor-type 'bar)
(add-to-list 'default-frame-alist '(cursor-color . "#FFFFFF"))

(add-to-list 'load-path "~/.emacs.d/emacs-powerline")
(require 'powerline)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["dark red" "red" "green" "yellow" "deep sky blue" "magenta" "cyan" "tan"])
 '(custom-safe-themes
   (quote
    ("f641bdb1b534a06baa5e05ffdb5039fb265fde2764fbfd9a90b0d23b75f3936b" default))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; disable start screen
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message t)

(setq initial-scratch-message "")

;; I want an easy command for opening new shells:
;;(defun new-shell (name)
;;  "Opens a new shell buffer with the given name in
;;asterisks (*name*) in the current directory and changes the
;;prompt to 'name>'."
;;  (interactive "sName: ")
;;  (pop-to-buffer (concat "*" name "*"))
;;  (unless (eq major-mode 'shell-mode)
;;    (shell (current-buffer))
;;    (sleep-for 0 200)
;;    (delete-region (point-min) (point-max))
;;    (comint-simple-send (get-buffer-process (current-buffer)) 
;;                        (concat "export PS1=\"\033[33m" name "\033[0m:\033[35m\\W\033[0m>\""))))

;; remote shell
(defun anr-shell (buffer)
  "Opens a new shell buffer where the given buffer is located."
  (interactive "sBuffer: ")
  (pop-to-buffer (concat "*" buffer "*"))
  (unless (eq major-mode 'shell-mode)
    (dired buffer)
    (shell buffer)
    (sleep-for 0 200)
    (delete-region (point-min) (point-max))
    (comint-simple-send (get-buffer-process (current-buffer)) 
                        (concat "export PS1=\"\033[33m" buffer "\033[0m:\033[35m\\W\033[0m>\""))))
(global-set-key (kbd "C-c C-u s") 'anr-shell) 

(defun new-shell ()
  (interactive)
  (let (
        (currentbuf (get-buffer-window (current-buffer)))
        (newbuf     (generate-new-buffer-name "*shell*"))
       )

   (generate-new-buffer newbuf)
   (set-window-dedicated-p currentbuf nil)
   (set-window-buffer currentbuf newbuf)
   (shell newbuf)
  )
  )

(global-set-key (kbd "C-c s") 'new-shell)

(defun afs ()
   (interactive)
   (let ((default-directory "/ssh:phn@unix.andrew.cmu.edu:"))
     (shell)))

;; interpret and use ansi color codes in shell output windows
(setq ansi-color-names-vector ["dark red" "red" "saddle brown" "yellow" "deep sky blue" "magenta" "cyan" "tan"])


(require 'ansi-color)
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
;;(ansi-color-for-comint-mode-on)
;;(setq ansi-color-map (ansi-color-make-color-map))
;;(add-to-list 'comint-output-filter-functions 'ansi-color-process-output)

;; select window by direction
;;(when (fboundp 'windmove-default-keybindings)
;;(windmove-default-keybindings))
(add-to-list 'load-path "~/.emacs.d/site-lisp/")
(add-to-list 'load-path "~/share/emacs/site-lisp/");
(require 'framemove)
(global-set-key (kbd "M-N") 'windmove-down)
(global-set-key (kbd "M-P") 'windmove-up)
(global-set-key (kbd "M-B") 'windmove-left)
(global-set-key (kbd "M-F") 'windmove-right)
;; (global-set-key (kbd "C-M-F") 'fm-right-frame)
;; (global-set-key (kbd "C-M-N") 'fm-down-frame)
;; (global-set-key (kbd "C-M-P") 'fm-up-frame)
;; (global-set-key (kbd "C-M-B") 'fm-left-frame)
(global-set-key (kbd "C-o") 'other-frame)

(global-set-key (kbd "C-M-f") 'forward-list)
(global-set-key (kbd "C-M-b") 'backward-list)


;; tabs as spaces
(setq-default indent-tabs-mode nil)
(setq tab-width 2)

(require 'ace-jump-mode)
(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)
;; (setq ace-jump-mode-submode-list
;;       '(ace-jump-char-mode              ;; the first one always map to : C-c SPC
;;         ace-jump-word-mode              ;; the second one always map to: C-u C-c SPC            
;;         ace-jump-line-mode) )           ;; the third one always map to ：C-u C-u C-c SPC

(setq doc-view-continuous t)

(show-paren-mode 1)
(setq show-paren-delay 0)

;;resize windows using arrow keys
(global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "S-C-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "S-C-<down>") 'shrink-window)
(global-set-key (kbd "S-C-<up>") 'enlarge-window)

;; remove ^M character from log files
(defun remove-dos-eol ()
  "Do not show ^M in files containing mixed UNIX and DOS line endings."
  (interactive)
  (setq buffer-display-table (make-display-table))
  (aset buffer-display-table ?\^M []))
(add-hook 'text-mode-hook 'remove-dos-eol)

;; kills to beginning of line
(global-set-key "\M-k" '(lambda () (interactive) (kill-line 0)) ) ;M-k kills to the left

;; C-h for backspace
;;(global-set-key "\C-h" 'backward-delete-char-untabify)
;;(define-key isearch-mode-map "\C-h" 'isearch-delete-char)
;;(global-set-key [(hyper h)] 'help-command)

;; C-h for goto-line
;; (global-set-key "\C-h" 'goto-line)

;; C-' for line or region comment toggle
(defun comment-or-uncomment-line-or-region ()
  "Comments or uncomments the current line or region."
  (interactive)
  (if (region-active-p)
      (comment-or-uncomment-region (region-beginning) (region-end))
    (comment-or-uncomment-region (line-beginning-position) (line-end-position))
    )
  )
(global-set-key (kbd "C-'") 'comment-or-uncomment-line-or-region)

;; stop getting process killed confirmations, just kill them
(setq kill-buffer-query-functions
  (remq 'process-kill-buffer-query-function
        kill-buffer-query-functions))

;; kill whole line with M-k
(global-set-key "\M-k" 'kill-whole-line)

;; start server for emacsclient
;; (server-start)

;; backup files in temp directory
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))
;; purge week old temp files
(message "Deleting old backup files...")
(let ((week (* 60 60 24 7))
      (current (float-time (current-time))))
  (dolist (file (directory-files temporary-file-directory t))
    (when (and (backup-file-name-p file)
               (> (- current (float-time (fifth (file-attributes file))))
                  week))
      (message "%s" file)
      (delete-file file))))

;; pdf-tools
;; has some dependencies: see https://github.com/politza/pdf-tools
;;(add-to-list 'load-path "~/.emacs.d/tablist")
;;(pdf-tools-install)

;; (add-to-list 'load-path "~/.emacs.d/emacs-ctable")
;; (add-to-list 'load-path "~/.emacs.d/emacs-deferred")
;; (add-to-list 'load-path "~/.emacs.d/emacs-epc")
;; (add-to-list 'load-path "~/.emacs.d/emacs-webkit")
;; (require 'webkit)

;;; xwidget stuff
;; (require 'xwidget)
;; ;; make these keys behave like normal browser
;; (define-key xwidget-webkit-mode-map [mouse-4] 'xwidget-webkit-scroll-down)
;; (define-key xwidget-webkit-mode-map [mouse-5] 'xwidget-webkit-scroll-up)
;; (define-key xwidget-webkit-mode-map (kbd "<up>") 'xwidget-webkit-scroll-down)
;; (define-key xwidget-webkit-mode-map (kbd "<down>") 'xwidget-webkit-scroll-up)
;; (define-key xwidget-webkit-mode-map (kbd "M-w") 'xwidget-webkit-copy-selection-as-kill)
;; (define-key xwidget-webkit-mode-map (kbd "C-c") 'xwidget-webkit-copy-selection-as-kill)

;; adapt webkit according to window configuration chagne automatically
;; without this hook, every time you change your window configuration,
;; you must press 'a' to adapt webkit content to new window size
;; (add-hook 'window-configuration-change-hook (lambda ()
;;                (when (equal major-mode 'xwidget-webkit-mode)
;;                  (xwidget-webkit-adjust-size-dispatch))))

;; by default, xwidget reuses previous xwidget window,
;; thus overriding your current website, unless a prefix argument
;; is supplied
;;
;; This function always opens a new website in a new window
;; (defun xwidget-browse-url-no-reuse (url &optional sessoin)
;;   (interactive (progn
;;                  (require 'browse-url)
;;                  (browse-url-interactive-arg "xwidget-webkit URL: "
;;                                              )))
;;   (xwidget-webkit-browse-url url t))

;; ;; make xwidget default browser
;; (setq browse-url-browser-function (lambda (url session)
;;                     (other-window 1)
;;                     (xwidget-browse-url-no-reuse url)))
;;;

;; sml
(autoload 'sml-mode "sml-mode" "Major mode for editing SML." t)
(autoload 'run-sml "sml-proc" "Run an inferior SML process." t)

;; scala
;; If necessary, make sure "sbt" and "scala" are in the PATH environment
;; (setenv "PATH" (concat "/path/to/sbt/bin:" (getenv "PATH")))
;; (setenv "PATH" (concat "/path/to/scala/bin:" (getenv "PATH")))
;;
;; On Macs, it might be a safer bet to use exec-path instead of PATH, for instance: 
;; (setq exec-path (append exec-path '("/usr/local/bin")))
;;(add-to-list 'load-path "~/.emacs.d/scala-mode2")
;;(require 'scala-mode2)
;;(require 'ensime)
;;(add-hook 'scala-mode-hook 'ensime-scala-mode-hook)

;; latex
;;(setq TeX-auto-save t)
;;(setq TeX-parse-self t)
;;(setq-default TeX-PDF-mode t)
;;(setq-default TeX-engine 'xetex)
;; spellcheck
;;(add-hook 'LaTeX-mode-hook 'flyspell-mode)


;;haskell
(add-hook 'haskell-mode-hook 'haskell-indentation-mode)
(require 'haskell-interactive-mode)
(require 'haskell-process)
(add-hook 'haskell-mode-hook 'interactive-haskell-mode)
(custom-set-variables
  '(haskell-process-suggest-remove-import-lines t)
  '(haskell-process-auto-import-loaded-modules t)
  '(haskell-process-log t))
(eval-after-load 'haskell-mode '(progn
(define-key haskell-mode-map (kbd "C-c C-l") 'haskell-process-load-or-reloa)
  (define-key haskell-mode-map (kbd "C-`") 'haskell-interactive-bring)
  (define-key haskell-mode-map (kbd "C-c C-t") 'haskell-process-do-type)
  (define-key haskell-mode-map (kbd "C-c C-i") 'haskell-process-do-info)
  (define-key haskell-mode-map (kbd "C-c C-c") 'haskell-process-cabal-build)
  (define-key haskell-mode-map (kbd "C-c C-k") 'haskell-interactive-mode-clear)
  (define-key haskell-mode-map (kbd "C-c c") 'haskell-process-cabal)
  (define-key haskell-mode-map (kbd "SPC") 'haskell-mode-contextual-space)
  (define-key haskell-mode-map (kbd "C-c C-o") 'haskell-compile)))
(eval-after-load 'haskell-cabal '(progn
  (define-key haskell-cabal-mode-map (kbd "C-c C-z") 'haskell-interactive-switch)
  (define-key haskell-cabal-mode-map (kbd "C-c C-k") 'haskell-interactive-mode-clear)
  (define-key haskell-cabal-mode-map (kbd "C-c C-c") 'haskell-process-cabal-build)
  (define-key haskell-cabal-mode-map (kbd "C-c c") 'haskell-process-cabal)
  (define-key haskell-cabal-mode-map (kbd "C-c C-o") 'haskell-compile)))

(let ((my-cabal-path (expand-file-name "~/.cabal/bin")))
  (setenv "PATH" (concat my-cabal-path ":" (getenv "PATH")))
  (add-to-list 'exec-path my-cabal-path))

(autoload 'ghc-init "ghc" nil t)
(autoload 'ghc-debug "ghc" nil t)
;;(add-hook 'haskell-mode-hook (lambda () (ghc-init)))
;;(add-hook 'haskell-mode-hook 'flymake-hlint-load)

;;tutch
(add-to-list 'load-path "~/.emacs.d/site-lisp/")
(load "tutch-mode.el")
(require 'tutch-mode)

;;C
(c-set-offset (quote cpp-macro) 0 nil)
;;doxygen
;;(require 'doxymacs)
;;(add-hook 'c-mode-common-hook'doxymacs-mode)
;;(defun my-doxymacs-font-lock-hook ()
;;    (if (or (eq major-mode 'c-mode) (eq major-mode 'c++-mode))
;;        (doxymacs-font-lock)))
;;(add-hook 'font-lock-mode-hook 'my-doxymacs-font-lock-hook)


;;ocaml
;; Add the opam lisp dir to the emacs load path
;;(add-to-list
;; 'load-path
;; (replace-regexp-in-string
;;  "\n" "/share/emacs/site-lisp"
;;  (shell-command-to-string "opam config var prefix")))

;; Automatically load utop.el
;;(autoload 'utop "utop" "Toplevel for OCaml" t)

;; Use the opam installed utop
;;(setq utop-command "opam config exec -- utop -emacs")

;;(load "~/.emacs.d/tuareg/tuareg-site-file")
;;(setq tuareg-indent-align-with-first-arg nil)
