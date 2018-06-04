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
    (smex ido-completing-read+ ido-ubiquitous powershell json-mode magit helm flx-ido markdown-mode ahk-mode framemove powerline blackboard-theme intero flymake-hlint omnisharp))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; show line numbers
;; (global-linum-mode t)
;; only when less than 5000 lines
(add-hook 'prog-mode-hook
(lambda () (linum-mode (- (* 5000 80) (buffer-size)))))

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
;;(require 'camelCase-mode)
;;(camelCase-mode)

;; disable start screen
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message t)

(setq initial-scratch-message "")
(setq initial-major-mode 'text-mode)
;; (add-hook 'text-mode-hook 'turn-on-auto-fill)

;; Open new empty buffer without prompting for name
(defun xah-new-empty-buffer ()
  "Create a new empty buffer.
New buffer will be named 'scratch' or 'scratch<2>', 'scratch<3>', etc.

It returns the buffer (for elisp programing).

URL `http://ergoemacs.org/emacs/emacs_new_empty_buffer.html'
Version 2017-11-01"
  (interactive)
  (let (($buf (generate-new-buffer "scratch")))
    (switch-to-buffer $buf)
    (funcall initial-major-mode)
    (setq buffer-offer-save t)
    $buf
    ))
(global-set-key (kbd "C-c b") 'xah-new-empty-buffer)
(global-set-key (kbd "C-c C-b") 'xah-new-empty-buffer)

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

;;Inserting text while mark active will delete selected text
(delete-selection-mode 1)

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

;;BEGIN IDO

;; better buffer switch
(require 'ido)
(ido-mode t)
(ido-everywhere 1)

(require 'ido-completing-read+)
(ido-ubiquitous-mode 1)

(require 'smex)
(smex-initialize) ; Can be omitted. This might cause a (minimal) delay
                  ; when Smex is auto-initialized on its first run.
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
;; This is your old M-x.
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

;;For any case where ido cannot be used, there is another older mode called icomplete-mode that integrates with standard emacs completion and adds some ido-like behavior.
(require 'icomplete)
(icomplete-mode 1)

;; (ido-mode 'buffers) ;; only use this line to turn off ido for file names!
(setq ido-ignore-buffers '("^ " "*Completions*" "*Shell Command Output*"
                           "*Messages*" "Async Shell Command" "*Warnings*" "*Help*"))
(require 'ido-better-flex)
(ido-better-flex/enable)

;; (global-set-key
;;  "\M-x"
;;  (lambda ()
;;    (interactive)
;;    (call-interactively
;;     (intern
;;      (ido-completing-read
;;       "M-x "
;;       (all-completions "" obarray 'commandp))))))

;; Display ido results vertically, rather than horizontally
(setq ido-decorations (quote ("\n-> " "" "\n   " "\n   ..." "[" "]" " [No match]" " [Matched]" " [Not readable]" " [Too big]" " [Confirm]")))
(defun ido-disable-line-truncation () (set (make-local-variable 'truncate-lines) nil))
  (add-hook 'ido-minibuffer-setup-hook 'ido-disable-line-truncation)
  (defun ido-define-keys () ;; C-n/p is more intuitive in vertical layout
    (define-key ido-completion-map (kbd "C-n") 'ido-next-match)
    (define-key ido-completion-map (kbd "C-p") 'ido-prev-match))
(add-hook 'ido-setup-hook 'ido-define-keys)

;; ;;make ido complete almost anything (except the stuff where it shouldn'
;; (defvar ido-enable-replace-completing-read t
;;   "If t, use ido-completing-read instead of completing-read if possible.
    
;;     Set it to nil using let in around-advice for functions where the
;;     original completing-read is required.  For example, if a function
;;     foo absolutely must use the original completing-read, define some
;;     advice like this:
    
;;     (defadvice foo (around original-completing-read-only activate)
;;       (let (ido-enable-replace-completing-read) ad-do-it))")
;; ;; Replace completing-read wherever possible, unless directed otherwise
;; (defadvice completing-read
;;     (around use-ido-when-possible activate)
;;   (if (or (not ido-enable-replace-completing-read) ; Manual override disable ido
;;           (and (boundp 'ido-cur-list)
;;                ido-cur-list)) ; Avoid infinite loop from ido calling this
;;       ad-do-it
;;     (let ((allcomp (all-completions "" collection predicate)))
;;       (if allcomp
;;           (setq ad-return-value
;;                 (ido-completing-read prompt
;;                                      allcomp
;;                                      nil require-match initial-input hist def))
;;         ad-do-it))))
;; (add-hook 'dired-mode-hook
;;           '(lambda ()
;;              (set (make-local-variable 'ido-enable-replace-completing-read) nil)))

;;END IDO

;; BEGIN HELM

;; (require 'helm)
;; (require 'helm-config)

;; ;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
;; ;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
;; ;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
;; (global-set-key (kbd "C-c h") 'helm-command-prefix)
;; (global-unset-key (kbd "C-x c"))

;; (global-set-key (kbd "M-x") 'helm-M-x)
;; (setq helm-M-x-fuzzy-match t) ;; optional fuzzy matching for helm-M-x
;; (global-set-key (kbd "M-y") 'helm-show-kill-ring)
;; (global-set-key (kbd "C-x b") 'helm-mini)
;; (setq helm-buffers-fuzzy-matching t
;;       helm-recentf-fuzzy-match    t)
;; (global-set-key (kbd "C-x C-f") 'helm-find-files)
;; (when (executable-find "ack-grep")
;;   (setq helm-grep-default-command "ack-grep -Hn --no-group --no-color %e %p %f"
;;         helm-grep-default-recurse-command "ack-grep -H --no-group --no-color %e %p %f"))

;; (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
;; (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB work in terminal
;; (define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z

;; (when (executable-find "curl")
;;   (setq helm-google-suggest-use-curl-p t))

;; (setq helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
;;       helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
;;       helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
;;       helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
;;       helm-ff-file-name-history-use-recentf t
;;       helm-echo-input-in-header-line t)

;; (defun spacemacs//helm-hide-minibuffer-maybe ()
;;   "Hide minibuffer in Helm session if we use the header line as input field."
;;   (when (with-helm-buffer helm-echo-input-in-header-line)
;;     (let ((ov (make-overlay (point-min) (point-max) nil nil t)))
;;       (overlay-put ov 'window (selected-window))
;;       (overlay-put ov 'face
;;                    (let ((bg-color (face-background 'default nil)))
;;                      `(:background ,bg-color :foreground ,bg-color)))
;;       (setq-local cursor-type nil))))


;; (add-hook 'helm-minibuffer-set-up-hook
;;           'spacemacs//helm-hide-minibuffer-maybe)

;; (setq helm-autoresize-max-height 0)
;; (setq helm-autoresize-min-height 20)
;; (helm-autoresize-mode 1)

;; (helm-mode 1)


;;END HELM

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
;; (add-hook 'haskell-mode-hook 'intero-mode)

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
;; (add-hook 'csharp-mode-hook 'omnisharp-mode)
;; (eval-after-load
;;     'company
;;   '(add-to-list 'company-backends 'company-omnisharp))

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

;; (add-hook 'csharp-mode-hook 'my-csharp-mode-setup t)
(put 'upcase-region 'disabled nil)

;;nxml
(defun my-nxml-mode-setup ()
  (local-set-key (kbd "C-M-n") 'nxml-forward-balanced-item)
  (local-set-key (kbd "C-M-p") 'nxml-backward-up-element)
  (local-set-key (kbd "C-M-f") 'nxml-forward-element)
  (local-set-key (kbd "C-M-b") 'nxml-backward-element)
  )
(add-hook 'nxml-mode-hook 'my-nxml-mode-setup t)
