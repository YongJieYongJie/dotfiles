;; Emacs GUI-related
(setq inhibit-startup-message t)

(tool-bar-mode -1)
(toggle-scroll-bar -1)
(menu-bar-mode -1)

;; Initialize MELPA

(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Some sensible defaults

(setq initial-scratch-message nil)
(setq tab-stop-list (number-sequence 4 120 4))
(setq-default tab-width 4)
(setq indent-tabs-mode nil)
(setq visible-bell 1)
(setq save-interprogram-paste-before-kill t)
(setq completion-ignore-case t)
(setq complete-ignore-case t)

(add-hook 'prog-mode-hook #'show-paren-mode)

;;Treat CamelCaseSubWords as separate words in every programming mode.
(add-hook 'prog-mode-hook #'subword-mode)

;; Look-and-Feel

(use-package zenburn-theme
  :ensure t)

(use-package solarized-theme
  :ensure t
  :config
  (load-theme 'solarized-light t))

(add-hook 'prog-mode-hook #'hl-line-mode) ; highlight current line only in programming modes (this excludes shell and terminal modes)

;; Display characters beyond column 80 in a different color
(setq-default
 whitespace-line-column 80
 whitespace-style       '(face lines-tail))

(add-hook 'prog-mode-hook #'whitespace-mode)

;; Keybindings

;;; Navigation

(global-set-key "\M-Z" 'zap-up-to-char)
(global-set-key (kbd "C-S-s") 'isearch-forward-symbol-at-point)

(use-package expand-region
  :ensure t)
(global-set-key (kbd "C-=") 'er/expand-region)

(use-package golden-ratio-scroll-screen
  :ensure t)
(global-set-key [remap scroll-down-command] 'golden-ratio-scroll-screen-down)
(global-set-key [remap scroll-up-command] 'golden-ratio-scroll-screen-up)

;; Mode-related

(global-eldoc-mode -1)

;;; Org mode

(add-hook 'org-mode-hook 'org-indent-mode)

;;; Recent files

(setq recentf-max-menu-items 25)
(setq recentf-max-saved-items 25)
(recentf-mode 1)

;;; IDO mode

(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode t)

;;; smex

(use-package smex
  :ensure t
  :init (smex-initialize))
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands) ; This is your old M-x.
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

;;; Other modes

(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

(add-hook 'markdown-mode-hook' 'auto-fill-mode)
(setq fill-column 80)

(use-package typescript-mode
  :ensure t)

(use-package csharp-mode
  :ensure t)

(use-package web-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode)))

(use-package yaml-mode
  :ensure t)

(use-package company
  :ensure t
  :config
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 3))

(with-eval-after-load 'company
  (define-key company-active-map (kbd "M-n") nil)
  (define-key company-active-map (kbd "M-p") nil)
  (define-key company-active-map (kbd "C-n") #'company-select-next)
  (define-key company-active-map (kbd "C-p") #'company-select-previous))

(add-hook 'python-mode-hook #'company-mode)

; (use-package omnisharp
;   :ensure t)
; 
; (add-hook 'csharp-mode-hook #'omnisharp-mode)
; (add-hook 'omnisharp-mode #'company-mode)
; (eval-after-load 'company
;   '(add-to-list 'company-backends 'company-mode))


;; Miscellaneous

(use-package which-key
  :ensure t
  :config (which-key-mode))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
	("d91ef4e714f05fff2070da7ca452980999f5361209e679ee988e3c432df24347" "0598c6a29e13e7112cfbc2f523e31927ab7dce56ebb2016b567e1eff6dc1fd4f" default)))
 '(package-selected-packages
   (quote
	(typescript-mode csharp-mode golden-ratio-scroll-screen solarized-theme yaml-mode expand-region company company-mode zenburn-theme which-key use-package org-bullets color-theme))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
