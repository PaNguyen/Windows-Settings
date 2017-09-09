(require 'package) ;; You might already have this line
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (url (concat (if no-ssl "http" "https") "://melpa.org/packages/")))
  (add-to-list 'package-archives (cons "melpa" url) t))
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize) ;; You might already have this line

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["dark red" "red" "green" "yellow" "deep sky blue" "magenta" "cyan" "tan"])
 '(custom-safe-themes
   (quote
    ("f641bdb1b534a06baa5e05ffdb5039fb265fde2764fbfd9a90b0d23b75f3936b" default)))
 '(haskell-process-auto-import-loaded-modules t)
 '(haskell-process-log t)
 '(haskell-process-suggest-remove-import-lines t)
 '(haskell-process-type (quote stack-ghci))
 '(haskell-tags-on-save t)
 '(package-selected-packages
   (quote
    (flx-ido markdown-mode ahk-mode framemove powerline blackboard-theme intero flymake-hlint omnisharp))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; show line numbers
(global-linum-mode t)

(setq tramp-default-method "ssh")

(load-theme 'blackboard t)

;; remove UI stuff
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;; cursor stuff
(setq-default cursor-type 'bar)
(add-to-list 'default-frame-alist '(cursor-color . "#FFFFFF"))

(add-to-list 'load-path "~/.emacs.d/site-lisp")
(require 'powerline)

;; disable start screen
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message t)

(setq initial-scratch-message "")

;; An easy command for opening new shells:
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

;; interpret and use ansi color codes in shell output windows
(setq ansi-color-names-vector ["dark red" "red" "saddle brown" "yellow" "deep sky blue" "magenta" "cyan" "tan"])
(require 'ansi-color)
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

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

(show-paren-mode 1)
(setq show-paren-delay 0)

;;resize windows using arrow keys
(global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "S-C-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "S-C-<down>") 'shrink-window)
(global-set-key (kbd "S-C-<up>") 'enlarge-window)


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

;; backup files in temp directory
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

 ;; scroll one line at a time (less "jumpy" than defaults)
(setq mouse-wheel-scroll-amount '(3 ((shift) . 1))) ;; one line at a time
(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse
(setq scroll-step 1) ;; keyboard scroll one line at a time

;; (global-set-key "C-x C-b" 'switch-to-buffer)
(define-key global-map (kbd "C-x C-b") 'switch-to-buffer)

(server-start)

;; better buffer switch
(require 'ido)
(ido-mode 'buffers) ;; only use this line to turn off ido for file names!
(setq ido-ignore-buffers '("^ " "*Completions*" "*Shell Command Output*"
               "*Messages*" "Async Shell Command" "*Warnings*" "*Help*"))

;; ;;haskell
;; ;;https://github.com/serras/emacs-haskell-tutorial/blob/master/tutorial.md
;; ;;cabal dependencies: happy, hasktags, stylish-haskell
(add-hook 'haskell-mode-hook 'haskell-indentation-mode)
;; (require 'haskell-interactive-mode)
;; (require 'haskell-process)
;; (add-hook 'haskell-mode-hook 'interactive-haskell-mode)
;; (custom-set-variables
;;   '(haskell-process-suggest-remove-import-lines t)
;;   '(haskell-process-auto-import-loaded-modules t)
;;   '(haskell-process-log t))
;; ;; (eval-after-load 'haskell-mode '(haskell-session-change))
;; (eval-after-load 'haskell-mode '(progn
;;   (define-key haskell-mode-map (kbd "C-c C-l") 'haskell-process-load-or-reload)
;;   (define-key haskell-mode-map (kbd "C-c C-z") 'haskell-interactive-switch)
;;   (define-key haskell-mode-map (kbd "C-c C-n C-t") 'haskell-process-do-type)
;;   (define-key haskell-mode-map (kbd "C-c C-n C-i") 'haskell-process-do-info)
;;   (define-key haskell-mode-map (kbd "C-c C-n C-c") 'haskell-process-cabal-build)
;;   (define-key haskell-mode-map (kbd "C-c C-n c") 'haskell-process-cabal)))
;; (eval-after-load 'haskell-cabal '(progn
;;   (define-key haskell-cabal-mode-map (kbd "C-c C-z") 'haskell-interactive-switch)
;;   (define-key haskell-cabal-mode-map (kbd "C-c C-k") 'haskell-interactive-mode-clear)
;;   (define-key haskell-cabal-mode-map (kbd "C-c C-c") 'haskell-process-cabal-build)
;;   (define-key haskell-cabal-mode-map (kbd "C-c c") 'haskell-process-cabal)))

;; ;; (let ((my-cabal-path (expand-file-name "~/.cabal/bin")))
;;   ;; (setenv "PATH" (concat my-cabal-path ":" (getenv "PATH")))
;;   ;; (add-to-list 'exec-path my-cabal-path))

;; (let ((my-cabal-path (expand-file-name "~/.cabal/bin")))
;;   (setenv "PATH" (concat my-cabal-path ";" (getenv "PATH")))
;;   (add-to-list 'exec-path my-cabal-path))
;; (custom-set-variables '(haskell-tags-on-save t))

;; (autoload 'ghc-init "ghc" nil t)
;; (autoload 'ghc-debug "ghc" nil t)
;; ;;(add-hook 'haskell-mode-hook (lambda () (ghc-init)))
;; ;;(add-hook 'haskell-mode-hook 'flymake-hlint-load)

;; ;; when using cabal
;; ;; (custom-set-variables '(haskell-process-type 'cabal-repl))
;; ;; when using stack
;; (custom-set-variables '(haskell-process-type 'stack-ghci))
;; (setq haskell-process-args-stack-ghci '("--ghci-options=-ferror-spans"))

(package-install 'intero)
(add-hook 'haskell-mode-hook 'intero-mode)

;; Key binding	Description
;; M-.	Jump to definition
;; C-c C-i	Show information of identifier at point
;; C-c C-t	Show the type of thing at point, or the selection
;; C-u C-c C-t	Insert a type signature for the thing at point
;; C-c C-l	Load this module in the REPL
;; C-c C-r	Apply suggestions from GHC
;; C-c C-k	Clear REPL
;; C-c C-z	Switch to and from the REPL
;; Why does C-c C-l start the session, not the process?

;; Don't use emacs' haskell-session-, instead use haskell-process-:

;; Command	Description
;; haskell-process-cabal		Prompts for a Cabal command to run
;; haskell-process-cabal-build		Build the Cabal project
;; haskell-process-cd		Change directory
;; haskell-process-restart		Restart the inferior Haskell process
;; haskell-process-clear		Clear the current process
;; haskell-process-reload		Reload the current buffer file
;; haskell-process-load-file		Load the current buffer file



;;C#
(add-hook 'csharp-mode-hook 'omnisharp-mode)
(eval-after-load
    'company
  '(add-to-list 'company-backends 'company-omnisharp))

;;configuration
(defun my-csharp-mode-setup ()
  (setq indent-tabs-mode nil)
  (setq c-syntactic-indentation t)
  (setq c-basic-offset 4)
  (setq truncate-lines t)
  (setq tab-width 4)
  (setq evil-shift-width 4)
  (local-set-key (kbd "C-c C-c") 'recompile)
  (local-set-key (kbd "C-.") 'omnisharp-go-to-definition)
  (local-set-key (kbd "C-,") 'omnisharp-auto-complete)
  (local-set-key (kbd "C-c C-r") 'omnisharp-rename)
  )

(add-hook 'csharp-mode-hook 'my-csharp-mode-setup t)
(put 'upcase-region 'disabled nil)

;;nxml
(defun my-nxml-mode-setup ()
  (local-set-key (kbd "C-M-n") 'nxml-forward-balanced-item)
  (local-set-key (kbd "C-M-p") 'nxml-backward-up-element)
  (local-set-key (kbd "C-M-f") 'nxml-forward-element)
  (local-set-key (kbd "C-M-b") 'nxml-backward-element)
  )
(add-hook 'nxml-mode-hook 'my-nxml-mode-setup t)
