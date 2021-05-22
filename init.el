;;; init.el --- Yong Jie's (very messy) Emacs init file

;;; Commentary:

;; To-do's:

;; - Learn about difference between use-package and plain require.
;; - Decide on how to modularize the init file(s):
;;   - Whether to use separate files, or one single file (leaning towards
;;     latter).
;;   - How to split into different sections (e.g., some packages like
;;     company-mode naturally affects different programming modes, so
;;     should I have a section for company-mode, or should those
;;     settings be subsumed under the settings for the programming
;;     languages modes).
;;   - Standardize config files across devices.
;;   - Add proper comments.
;;   - Standardize use of # symbol.
;;     - https://www.gnu.org/software/emacs/manual/html_node/elisp/Index.html
;;     - http://endlessparentheses.com/get-in-the-habit-of-using-sharp-quote.html
;;   - Learn how folding works in Emacs, develop a workflow.


;;;-----------------------------------------------------------------------------
;;; Per-Machine Settings
;;;-----------------------------------------------------------------------------

;; Set yj-org-directory to the base directory for org-mode. E.g.,
;; "/home/yongjie/syncthing/org".
(defvar yj-org-directory "/home/yongjie/syncthing/org")
(setq default-directory yj-org-directory)


;;;-----------------------------------------------------------------------------
;;; Emacs GUI-related
;;;-----------------------------------------------------------------------------

(setq inhibit-startup-message t)

(tool-bar-mode -1)
(menu-bar-mode -1)
(add-to-list 'default-frame-alist
             '(vertical-scroll-bars . nil))


;;;-----------------------------------------------------------------------------
;;; Package Management
;;;-----------------------------------------------------------------------------

;; Initialize MELPA
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; delight allows us to hide major and minor modes from the mode-line. For
;; built-in modes, the configuration will be located here; whereas for installed
;; modes, they will be configured in the respective use-package section.
(use-package delight
  :ensure t
  :config
  (delight 'whitespace-mode nil "whitespace")
  (delight 'subword-mode nil "subword"))


;;;-----------------------------------------------------------------------------
;;; Vanilla Emacs Settings
;;;-----------------------------------------------------------------------------

;;; Some sensible defaults

;; Wrap at 80 charactors by default when using "M-q"
(setq-default fill-column 80)

;; Show trailing whitespace by default
(setq-default show-trailing-whitespace t)

;; Recent files
(setq recentf-max-menu-items 25)
(setq recentf-max-saved-items 25)
(recentf-mode 1)
;; Automatically save to the recent file list (in addition to the default
;; behavior of saving on closing Emacs). Also using a lambda to save silently
;; without printing a message to the minibuffer, based on stackechange answer:
;; https://emacs.stackexchange.com/a/45700/23895
(run-at-time nil (* 5 60) (lambda ()
                            (let ((save-silently t))
                              (recentf-save-list))))

;; don't print message when auto-saving
(setq-default auto-save-no-message t)

;; remember cursor position, for emacs 25.1 or later
(save-place-mode 1)

;; scroll line by line, instead of jumping half page at a time
;; from https://www.emacswiki.org/emacs/SmoothScrolling
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse
(setq scroll-step 1) ;; keyboard scroll one line at a time
(setq scroll-step            1
      scroll-conservatively  10000)

;; Increase font size by default, so there is no need to increase
;; everytime opening something; Also this is needed for company-mode's
;; overlay to behave nicely. Also needed to decrease the default frame size
;; because the font is now bigger.
;;
;; See GitHub issue:
;; https://github.com/company-mode/company-mode/issues/299
;(add-to-list 'default-frame-alist
;             '(font . "-outline-Courier New-normal-normal-normal-mono-23-*-*-*-c-*-iso8859-1"))
(add-to-list 'default-frame-alist '(font . "Iosevka-24"))
(add-to-list 'default-frame-alist '(height . 24))
(add-to-list 'default-frame-alist '(width . 60))
;(set-frame-font "Iosevka 24" nil t)

(setq initial-scratch-message nil)
(setq tab-stop-list (number-sequence 4 120 4))
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)
(setq visible-bell 1)
(setq save-interprogram-paste-before-kill t)
(setq completion-ignore-case t)
(setq-default dired-listing-switches "-alh")

;; Back-up files
(defvar --backup-directory (concat user-emacs-directory "backups"))
(if (not (file-exists-p --backup-directory))
    (make-directory --backup-directory t))
(setq backup-directory-alist `(("." . ,--backup-directory)))
(setq make-backup-files t          ; backup of a file the first time it is saved
      backup-by-copying t          ; don't clobber symlinks
      version-control t            ; version numbers of backup files
      delete-old-versions t        ; delete excess backup files silently
      delete-by-moving-to-trash t
      kept-old-versions 6          ; oldest versions to keep when a
                                   ; new numbered backup is made
                                   ; (default: 2)
      kept-new-versions 9          ; newest versions to keep when a
                                   ; new numbered backup is made
                                   ; (default: 2)
      auto-save-default t          ; auto-save every buffer that visits a file
      auto-save-timeout 20         ; number of seconds idle time before auto-save (default: 30)
      auto-save-interval 200       ; number of keystrokes between auto-saves (default 300)
      )


;; Display column number in mode line.
(column-number-mode 1)

;;; Keybindings

(global-set-key "\M-Z" 'zap-up-to-char)
(global-set-key (kbd "C-S-s") 'isearch-forward-symbol-at-point)


;; Use ibuffer as the default buffer switching mode.
(global-set-key (kbd "C-x C-b") 'ibuffer)
(autoload 'ibuffer "ibuffer" "List buffers." t)

;; Adapted from https://www.emacswiki.org/emacs/IbufferMode
(setq-default ibuffer-saved-filter-groups
      `(("default"
               ("dired" (mode . dired-mode))
               ("emacs" (or
                         (name . "^\\*scratch\\*$")
                         (name . "^\\*Messages\\*$"))))))


;;;-----------------------------------------------------------------------------
;;; Look-and-Feel
;;;-----------------------------------------------------------------------------

;; Use the zenburn theme, which is the default for the Prelude
;; distribution (https://github.com/bbatsov/prelude), which is the
;; distribution that first made Emacs a true delight for me.
(use-package zenburn-theme
  :ensure t
  :config
  (load-theme 'zenburn t)
  ;; Make the mode-line and header-line fonts smaller. Note: This code is put
  ;; here to prevent Zenburn from overwritting the font size.
  (set-face-attribute 'mode-line nil :font "Iosevka-13")
  (set-face-attribute 'header-line nil :font "Iosevka-13"))

;; Display characters beyond column 80 in a different color
(setq-default
 whitespace-line-column 80
 whitespace-style       '(face lines-tail))

;; Display vertical line at column specified by fill-column variable
(display-fill-column-indicator-mode)

;; smart-mode-line provides a less ugly mode-line:
;; (https://github.com/Malabarba/smart-mode-line)
;; TODO: Continue evaluating this mode-line and make changes as necessary
(use-package smart-mode-line
  :ensure t
  :defer 0.2
  :config
  (sml/setup)
  (setq sml/mode-width 'full
        sml/name-width 30))

;; hide-mode-line-mode is a minor mode that hides the mode-line. We
;; can use it to toggle the visibility of mode-line by
;; enabling/disabling the minor mode.
;; (https://github.com/hlissner/emacs-hide-mode-line)
(use-package hide-mode-line
  :ensure t
  :commands hide-mode-line-mode)


;;;-----------------------------------------------------------------------------
;;; Miscellaneus / Minor Packages
;;;-----------------------------------------------------------------------------

;; expand-region.el (https://github.com/magnars/expand-region.el)
(use-package expand-region
  :ensure t
  :bind ("C-=" . 'er/expand-region))

;; golden-ration-scroll-screen
;; (https://github.com/jixiuf/golden-ratio-scroll-screen)
(use-package golden-ratio-scroll-screen
  :ensure t)
(global-set-key [remap scroll-down-command] 'golden-ratio-scroll-screen-down)
(global-set-key [remap scroll-up-command] 'golden-ratio-scroll-screen-up)

;; eldoc (http://elpa.gnu.org/packages/eldoc.html)
;; Show function arglist or variable docstring in echo area.
(global-eldoc-mode -1)

;; ido
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode t)

;; smex
(use-package smex
  :ensure t
  :init (smex-initialize))
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands) ; This is your old M-x.
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

;; undo-tree
(use-package undo-tree
  :ensure t
  :commands undo-tree)

;; elpy
(use-package elpy
  :ensure t
  :init
  (elpy-enable))

;; flycheck
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

(setq flycheck-check-syntax-automatically '(mode-enabled save))

;; Always save bookmark files (and not just on exit)
(setq bookmark-save-flag 1)

;; which-key
(use-package which-key
  :ensure t
  :delight which-key-mode
  :config (which-key-mode))

(use-package protobuf-mode
  :ensure t)


;;;-----------------------------------------------------------------------------
;;; Major Packages
;;;-----------------------------------------------------------------------------


(use-package company
  :ensure t
  :config

  ;; Immediately show completions after two characters are typed
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 2)

  ;; Enable company-tng-mode, which uses tab key for navigating through
  ;; suggestions, and inserting into the buffer the currently suggestion as we
  ;; are tabbing through. For more, details, see the comany-tng.el file.
  (add-hook 'after-init-hook 'company-tng-mode)
  )


;;; Counsel (includes the dependencies Ivy and Swiper)
;;; (https://oremacs.com/swiper/)
;;; Ivy is a generic completion frontend
;;; Swiper is an alternative isearch with a preview of all matching lines
;;; Counsel is a collection of Ivy-enhanced versions of common Emacs commands
(use-package counsel
  :ensure t
  :delight ivy-mode
  :config
  (ivy-mode 1)

  ;; Basic customization as recommended on official documentation
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format " (%d/%d) ")

  ;; Below are the key bindings as listed on the official documentation.
  ;; TODO: Uncomment them out as I explore new functionalities.

  ;; Ivy-based interface to standard commands
  :bind (;;("C-s" . swiper-isearch)
         ("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ("M-y" . counsel-yank-pop)
         ;;("<f1> f" . counsel-describe-function)
         ;;("<f1> v" . counsel-describe-variable)
         ;;("<f1> l" . counsel-find-library)
         ;;("<f2> i" . counsel-info-lookup-symbol)
         ;;("<f2> u" . counsel-unicode-char)
         ;;("<f2> j" . counsel-set-variable)
         ;;("C-x b" . ivy-switch-buffer)
         ;;("C-c v" . ivy-push-view)
         ;;("C-c V" . ivy-pop-view)

         ;; Ivy-based interface to shell and system tools
         ;;("C-c c" . counsel-compile)
         ;;("C-c g" . counsel-git)
         ;;("C-c j" . counsel-git-grep)
         ;;("C-c L" . counsel-git-log)
         ;;("C-c k" . counsel-rg)
         ;;("C-c m" . counsel-linux-app)
         ;;("C-c n" . counsel-fzf)
         ;;("C-x l" . counsel-locate)
         ;;("C-c J" . counsel-file-jump)
         ;;("C-S-o" . counsel-rhythmbox)
         ;;("C-c w" . counsel-wmctrl)

         ;; Ivy-resume and other commands
         ("C-c C-r" . ivy-resume)
         ;;("C-c b" . counsel-bookmark)
         ;;("C-c d" . counsel-descbinds)
         ;;("C-c g" . counsel-git)
         ;;("C-c o" . counsel-outline)
         ;;("C-c t" . counsel-load-theme)
         ;;("C-c F" . counsel-org-file)
         ))


;;;-----------------------------------------------------------------------------
;;; Text Mode: General
;;;-----------------------------------------------------------------------------

(use-package yaml-mode
  :ensure t)

;; Adapted from http://blog.binchen.org/posts/emacs-auto-completion-for-non-programmers.html
;; "text-mode" is a major mode for editing files of text in a human language
;; most major modes for non-programmers inherit from text-mode.
(add-hook 'text-mode-hook 'text-mode-hook-setup)
(add-hook 'text-mode-hook #'whitespace-mode)
(add-hook 'text-mode-hook #'company-mode)
(defun text-mode-hook-setup ()
  ;; make `company-backends' local is critcal
  ;; or else, you will have completion in every major mode, that's very annoying!
  (make-local-variable 'company-backends)

  ;; company-ispell is the plugin to complete words
  (add-to-list 'company-backends 'company-ispell))

(defun toggle-company-ispell ()
  (interactive)
  (cond
   ((memq 'company-ispell company-backends)
    (setq company-backends (delete 'company-ispell company-backends))
    (message "company-ispell disable"))
   (t
    (add-to-list 'company-backends 'company-ispell)
    (message "company-ispell enabled!"))))


;; Taken from markdown-mode, for more sensible separating of paragraphs:
;; https://raw.githubusercontent.com/jrblevin/markdown-mode/master/markdown-mode.el
(add-hook 'text-mode-hook
          (lambda()
            (setq paragraph-start
                        ;; Should match start of lines that start or separate paragraphs
                        (mapconcat #'identity
                                   '(
                                     "\f" ; starts with a literal line-feed
                                     "[ \t\f]*$" ; space-only line
                                     "\\(?:[ \t]*>\\)+[ \t\f]*$"; empty line in blockquote
                                     "[ \t]*[*+-][ \t]+" ; unordered list item
                                     "[ \t]*\\(?:[0-9]+\\|#\\)\\.[ \t]+" ; ordered list item
                                     "[ \t]*\\[\\S-*\\]:[ \t]+" ; link ref def
                                     "[ \t]*:[ \t]+" ; definition
                                     "^|" ; table or Pandoc line block
                                     )
                                   "\\|"))))
(add-hook 'text-mode-hook
          (lambda()
            (setq-local paragraph-separate
                        ;; Should match lines that separate paragraphs without being
                        ;; part of any paragraph:
                        (mapconcat #'identity
                                   '("[ \t\f]*$" ; space-only line
                                     "\\(?:[ \t]*>\\)+[ \t\f]*$"; empty line in blockquote
                                     ;; The following is not ideal, but the Fill customization
                                     ;; options really only handle paragraph-starting prefixes,
                                     ;; not paragraph-ending suffixes:
                                     ".*  $" ; line ending in two spaces
                                     "^#+"
                                     "[ \t]*\\[\\^\\S-*\\]:[ \t]*$") ; just the start of a footnote def
                                   "\\|"))))


;;;-----------------------------------------------------------------------------
;;; Text Mode: Org-mode
;;;-----------------------------------------------------------------------------

;; For exporting org files to Confluence compatible format. Make sure to
;; download the file from
;; https://github.com/emacsmirror/org/blob/master/contrib/lisp/ox-confluence.el
;; into the load-path as below, before uncommenting. This is necessary because
;; ox-confluence can't be installed automatically.
;;(add-to-list 'load-path "~/.emacs.d/ox-confluence")
;;(require 'ox-confluence)

;; Add virtual spaces to indent org headings
(add-hook 'org-mode-hook #'org-indent-mode)
(setq org-indent-indentation-per-level 1) ; 1 virtual space per nesting level

;; Enable bold / italics over multiple lines
;; Taken from:
;; - https://emacs.stackexchange.com/a/61404/23895
;; - https://ox-hugo.scripter.co/test/posts/multi-line-bold/
(with-eval-after-load 'org
  ;; Allow multiple line Org emphasis markup.
  ;; http://emacs.stackexchange.com/a/13828/115
  (setcar (nthcdr 4 org-emphasis-regexp-components) 20) ;Up to 20 lines, default is just 1
  ;; Below is needed to apply the modified `org-emphasis-regexp-components'
  ;; settings from above.
  (org-set-emph-re 'org-emphasis-regexp-components org-emphasis-regexp-components))

(add-hook 'org-mode-hook #'visual-line-mode)
(add-hook 'org-mode-hook #'hl-line-mode)

;; Treat CamelCaseSubWords as separate words (affects keys like "M-b"/"M-f").
(add-hook 'org-mode-hook #'subword-mode)

;;; Org-capture
(setq org-directory yj-org-directory)
(setq org-default-notes-file (concat org-directory "/main.org"))

;; C-c c to start org-capture
(global-set-key (kbd "C-c c") 'org-capture)

;; C-c a to start org-agenda
(global-set-key (kbd "C-c a") 'org-agenda)

;; Capture templates for: TODO tasks, Notes, appointments, phone calls, meetings, and org-protocol
(setq org-capture-templates
      (quote (("t" "todo" entry (file+datetree (concat org-directory "/captured-todos.org"))
              "* TODO %?\nCreated %U\n")
              ("c" "chat_logs" entry (file+datetree (concat org-directory "/conversations.org"))
               "* Chat with %?\nCreated: %U\n"))))

;; Recursively adds file ending with .org to the agenda files, required
;; because newly created files are not automatically added.
(setq org-agenda-files (directory-files-recursively
                        (concat org-directory "/") "\\.org$"))
(setq org-agenda-files (cl-remove-if
                        (lambda (k)
                          (or (string-match ".stversions" k) ; removes syncthing artefacts
                              (string-match "sync-conflict" k))) ; removes syncthing artefacts
                        org-agenda-files))
(setq org-todo-keywords
      '((sequence "NEXT(n)" "TODO(t)" "WAIT(w@/!)" "|" "DONE(d!)" "SUPERSEDED(s@)")))

;; Based on comments to this reddit post on How do org-refile-targets work?
;; https://www.reddit.com/r/emacs/comments/4366f9/how_do_orgrefiletargets_work/?utm_source=share&utm_medium=web2x&context=3
(setq org-refile-targets '((nil :maxlevel . 4)
                           (org-agenda-files :maxlevel . 4)))
(setq org-outline-path-complete-in-steps nil)           ; Refile in a single go
(setq org-refile-use-outline-path t)                  ; Show full paths for refiling

;; When showing clocked time in org-agenda using
;; org-agenda-clockreport-mode (using =R=), skip 0 entries.  Taken
;; from https://emacs.stackexchange.com/a/52691/23895.
(setq org-agenda-clockreport-parameter-plist '(:stepskip0 t :link t :maxlevel 4 :fileskip0 t))


;;;-----------------------------------------------------------------------------
;;; Text Mode: markdown-mode
;;;-----------------------------------------------------------------------------
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

(add-hook 'markdown-mode-hook' 'auto-fill-mode)


;;;-----------------------------------------------------------------------------
;;; Programming Mode: General
;;;-----------------------------------------------------------------------------

;; Highlight current line only in programming modes (this excludes
;; shell and terminal modes).
(add-hook 'prog-mode-hook #'hl-line-mode)

;; Display white space characters.
(add-hook 'prog-mode-hook #'whitespace-mode)

;; Show verticle line at column 80.
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

;; Highlight matching parenthesis in programming modes.
(add-hook 'prog-mode-hook #'show-paren-mode)

;; Treat CamelCaseSubWords as separate words in every programming mode.
(add-hook 'prog-mode-hook #'subword-mode)

(use-package web-mode
  :ensure t
  :mode "\\.html?\\'")

(use-package paredit
  :ensure t
  :delight
  :commands paredit-mode
  :init
  (add-hook 'lisp-mode-hook #'paredit-mode))


;;;-----------------------------------------------------------------------------
;;; Programming Mode: lsp-mode
;;;-----------------------------------------------------------------------------

;; Adapted from lsp-mode official page:
;; https://emacs-lsp.github.io/lsp-mode/page/installation/
;;
;; For details on how to configure the UI more, see
;; https://emacs-lsp.github.io/lsp-mode/tutorials/how-to-turn-off/
(use-package lsp-mode
  :ensure t
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         (go-mode . lsp)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

;; optionally
(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-doc-enable nil))
;; if you are helm user
;;(use-package helm-lsp :commands helm-lsp-workspace-symbol)
;; if you are ivy user
;;(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs
  :ensure t
  :commands lsp-treemacs-errors-list
  :config
  (treemacs-resize-icons 16))

;; optionally if you want to use debugger
;;(use-package dap-mode)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language


;;;-----------------------------------------------------------------------------
;;; Programming Mode: TypeScript
;;;-----------------------------------------------------------------------------

(use-package typescript-mode
  :ensure t
  :mode "\\.ts\\'"
  :config
  (add-hook 'typescript-mode-hook #'yj/typescript-mode-hook))
(defun yj/typescript-mode-hook ()
  "Custom configurations for typescript-mode."
  (setq typescript-indent-level 2)
  (setq tab-width 2)
  (setq tab-stop-list (number-sequence 2 120 2)))


;;;-----------------------------------------------------------------------------
;;; Programming Mode: Python
;;;-----------------------------------------------------------------------------

(add-hook 'python-mode-hook #'company-mode)


;;;-----------------------------------------------------------------------------
;;; Programming Mode: Clojure and other lisps
;;;-----------------------------------------------------------------------------

;;; Clojure
(use-package clojure-mode
  :ensure t
  :commands clojure-mode
  :config
  (add-hook 'clojure-mode-hook #'eldoc-mode)
  (add-hook 'clojure-mode-hook #'company-mode)
  (add-hook 'clojure-mode-hook #'paredit-mode))

;;; Emacs-lisp
(add-hook 'emacs-lisp-mode-hook #'eldoc-mode)
(add-hook 'emacs-lisp-mode-hook #'company-mode)
(add-hook 'emacs-lisp-mode-hook #'paredit-mode)


;;;-----------------------------------------------------------------------------
;;; Programming Mode: Go
;;;-----------------------------------------------------------------------------

(use-package go-mode
  :ensure t
  :mode "\\.go\\'"
  :config
  (add-hook 'company-mode-hook #'yas-minor-mode)
  (add-hook 'before-save-hook #'gofmt-before-save)
  (setq gofmt-command "goimports")
  )


;;;-----------------------------------------------------------------------------
;;; Tools: Docker
;;;-----------------------------------------------------------------------------

(use-package dockerfile-mode
  :ensure t
  :commands dockerfile-mode)


;;;-----------------------------------------------------------------------------
;;; Tools: Magit
;;;-----------------------------------------------------------------------------

(use-package magit
  :ensure t
  :commands magit-status)


;;;-----------------------------------------------------------------------------
;;; END
;;;-----------------------------------------------------------------------------

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-quickhelp-color-background "#4F4F4F")
 '(company-quickhelp-color-foreground "#DCDCCC")
 '(custom-enabled-themes (quote (sanityinc-tomorrow-eighties)))
 '(custom-safe-themes
   (quote
    ("f56eb33cd9f1e49c5df0080a3e8a292e83890a61a89bceeaa481a5f183e8e3ef" "82d2cac368ccdec2fcc7573f24c3f79654b78bf133096f9b40c20d97ec1d8016" "1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" "54f2d1fcc9bcadedd50398697618f7c34aceb9966a6cbaa99829eb64c0c1f3ca" "628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" "d91ef4e714f05fff2070da7ca452980999f5361209e679ee988e3c432df24347" "0598c6a29e13e7112cfbc2f523e31927ab7dce56ebb2016b567e1eff6dc1fd4f" default)))
 '(elpy-rpc-virtualenv-path (quote current))
 '(magit-diff-use-overlays nil)
 '(package-selected-packages
   (quote
    (go-mode use-package org-bullets color-theme)))
 '(pdf-view-midnight-colors (quote ("#DCDCCC" . "#383838"))))

(put 'upcase-region 'disabled nil)
(provide 'init)
;;; init.el ends here