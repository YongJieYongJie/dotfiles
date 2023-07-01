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
;;
;; - Make electric-pair work with backticks:
;;   - https://emacs.stackexchange.com/questions/2538/how-to-define-additional-mode-specific-pairs-for-electric-pair-mode

;;;-----------------------------------------------------------------------------
;;; Per-Machine Settings
;;;-----------------------------------------------------------------------------

;; Set yj-org-directory to the base directory for org-mode. E.g.,
;; "/home/yongjie/syncthing/org".
(cond
 ((eq system-type 'darwin)
  (defvar yj-org-directory "~/syncthing/org"))
 ((eq system-type 'windows-nt)
  (defvar yj-org-directory "c:/syncthing/org"))
 ((or (eq system-type 'gnu) (eq system-type 'gun/linux) (eq system-type 'cygwin))
  (defvar yj-org-directory "/home/yongjie/syncthing/org"))
 (t (defvar yj-org-directory "/home/yongjie/syncthing/org")))

(make-directory yj-org-directory t)
(setq default-directory yj-org-directory)


;;;-----------------------------------------------------------------------------
;;; My Custom Functions
;;;-----------------------------------------------------------------------------

(defun yj/file-location-at-point ()
  "Return full file path with line number at point"
  (interactive)
  (let ((line-number (substring (what-line) 5 nil)))
   (kill-new (concat (buffer-file-name) "::" line-number))))

;;; For shrinking infomation-displaying (as opposed to text-editing) windows
;;; containing buffers like *Help* and *xref*, which shouldn't always take up
;;; half the frame.

(defvar yj/info-window-buffer-name '("*Help*" "*xref*" "*company-documentation*" "*Occur*")
  "List of buffer names (string) representing informational buffers.
Such informational buffers might contain help content, documentation,
references, and may contain only a few lines of text.")

(defun yj/shrink-info-window (&optional window)
  "Shrinks WINDOW to fit buffer size if it is a info-window.
Info-window is defined in the list `yj/info-window-buffer-name'."
  (if window (let* ((b (window-buffer window))
                    (bname (buffer-name b)))
               (if (member bname yj/info-window-buffer-name)
                   (shrink-window-if-larger-than-buffer window)))
    (shrink-window-if-larger-than-buffer (selected-window))))

(defun yj/shrink-info-windows (&rest _)
  (mapc 'yj/shrink-info-window (window-list)))

(defvar yj/info-window-creating-fns
  (list 'describe-variable 'company-show-doc-buffer 'lsp-show-xrefs 'occur)
  "List of symbols represent functions that creates infomational windows.")

(mapc (lambda (fn) (advice-add fn :after 'yj/shrink-info-windows))
      yj/info-window-creating-fns)

;; yj/find-file-at-point improves on projectile-find-file-dwim by handling
;; filenames with row and column indication like "main.go:69:420". To use this
;; defun, we'll also need to edit projectile-select-files in projectile.el to
;; look something like the following:
;;
;;(defun projectile-select-files (project-files &optional invalidate-cache)
;;   "Select a list of files based on filename at point.
;;
;;With a prefix arg INVALIDATE-CACHE invalidates the cache first."
;;  (projectile-maybe-invalidate-cache invalidate-cache)
;;  (let* ((file (if (region-active-p)
;;                   (buffer-substring (region-beginning) (region-end))
;;                 (or (thing-at-point 'filename) "")))
;;         (file (if (string-match "\\.?\\./" file)
;;                   (file-relative-name (file-truename file) (projectile-project-root))
;;                 file))
;;         (file (if (string-match "\\([^:]+\\)\\(:[0-9]\\)+" file) ; Added to remove things like the trailing ":420:69" in "main.go:420:69"
;;                   (match-string 1 file)                          ;
;;                 file))                                           ;
;;         (file (if (string-match "\\./\\(.*\\)" file)
;;                   (match-string 1 file)
;;                 file))
;;         (files (if file
;;                    (cl-remove-if-not
;;                     (lambda (project-file)
;;                       (string-match file project-file))
;;                     project-files)
;;                  nil)))
;;    files)
(defun yj/find-file-at-point ()
  (interactive)
  (let* ((filename-at-point (or (thing-at-point 'filename) ""))
         (line-no (if (string-match "\\w:\\([0-9]+\\)" filename-at-point)
                      (match-string 1 filename-at-point)))
         (col-no (if (string-match "\\w:[0-9]+:\\([0-9]+\\)" filename-at-point)
                      (match-string 1 filename-at-point))))
    (projectile-find-file-dwim)
    (if line-no
        (forward-line (- (string-to-number line-no) (line-number-at-pos))))
    (if col-no
        (move-to-column (string-to-number col-no)))))


;;;-----------------------------------------------------------------------------
;;; Emacs GUI-related
;;;-----------------------------------------------------------------------------

(setq inhibit-startup-message t)

(if (display-graphic-p)
  (tool-bar-mode -1))
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

;; exec-path-from-shell makes Emacs use the $PATH environment variable as set up
;; by the user's shell, so that it can find the necessary binaries (e.g.,
;; language servers) more easily.
(use-package exec-path-from-shell
  :ensure t
  :init
  (setq exec-path-from-shell-variables
        '("PATH" "MANPATH"
          "GONOPROXY" "GONOSUMDB" "GOPRIVATE" "GOPATH"))
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))


;;;-----------------------------------------------------------------------------
;;; Vanilla Emacs Settings
;;;-----------------------------------------------------------------------------

;;; Some sensible defaults

;; Show the same line wrapping indicators when using visual-line-mode. Note:
;; visual-line-mode does word-level (as opposed to character-level) wrapping at
;; window boundaries.
(setq visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow))

;; Enable repeating popping of mark using "C-SPC".
(setq set-mark-command-repeat-pop t)

;; Call push-mark before moving large distances so we return to the postion by
;; popping the mark.
(advice-add 'beginning-of-defun :before 'push-mark)
(advice-add 'end-of-defun :before 'push-mark)

;; Show total number of occurence when using isearch
(setq isearch-lazy-count t)

;; Wrap at 80 charactors by default when using "M-q"
(setq-default fill-column 80)

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
(add-to-list 'default-frame-alist '(font . "Iosevka-21:weight=light"))
(add-to-list 'default-frame-alist '(height . 17))
(add-to-list 'default-frame-alist '(width . 60))
;; (set-frame-font "Iosevka-21:weight=light" nil t)

(defun yj/change-font-size (p)
  "Change font size for all buffers, windows and frames, based on prefix P."
  (interactive "p")
  (let* ((current-font-size 20)
         (new-font-size (+ current-font-size p)))
   (set-frame-font (concat "Iosevka-" (number-to-string new-font-size) ":weight=light") nil t)))

(setq initial-scratch-message nil)
(setq tab-stop-list (number-sequence 4 120 4))
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)
(setq visible-bell 1)
(setq save-interprogram-paste-before-kill t)
(setq completion-ignore-case t)
(setq-default dired-listing-switches "-alhF")
(add-hook 'dired-mode-hook 'dired-hide-details-mode) ;; Hide details by default, redisplay using "("

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

;; Auto-save files
(defvar --auto-save-directory
  (expand-file-name (concat user-emacs-directory "auto-saves/")))
(if (not (file-exists-p --auto-save-directory))
    (make-directory --auto-save-directory t))
;;https://stackoverflow.com/a/15303598/5821101
(add-to-list
 'auto-save-file-name-transforms
 ;; Note: We cannot use 'expand-file-name below to construct the file because on
 ;; windows, the double backslashes will be converted to the root of the
 ;; drive. But for this, using 'expand-file-name might have been the "more
 ;; correct" way.
 (list "\\(.+/\\)*\\(.*?\\)" (concat --auto-save-directory "\\2"))
 t)

;; Display column number in mode line.
(column-number-mode 1)

;; Make sure certain buffers are always created with a bottom split, and shrank
;; as necessary.
(customize-set-variable
 'display-buffer-alist
 '(("\\*Gofmt Errors\\*\\|\\*xref\\*"
    (display-buffer-below-selected display-buffer-at-bottom)
    (inhibit-same-window . t)
    (window-height . shrink-window-if-larger-than-buffer))))

;;; Keybindings

;; Text editing.
(global-set-key "\M-Z" 'zap-up-to-char)
(global-set-key (kbd "C-S-s") 'isearch-forward-symbol-at-point)

;; Easier windows navigation and manipulation.

(defun yj/num-side-windows ()
  "Return the number of side windows in the selected frame."
  (seq-count (lambda (w) (window-parameter w 'window-side)) (window-list)))

(defun yj/side-window-p (w)
  "Return non-nil if W is a side window."
  (window-parameter w 'window-side))

(defun yj/delete-other-windows-dwim ()
  "Delete other windows based on what windows are open and which is focused.

Case 0 (only 1 window) - calls 'writeroom--enable' if the function is bound.

Case 1 (only 1 window or no side windows) - passthrough to
'delete-other-windows'

Case 2 (only 1 non-side window) - passthrough
to'window-toggle-side-windows'

Default case (has at least 1 side window and 2 non-side window) -
close other non-side window such that only one is left; next call
to this function will result in Case 2"
  (interactive)
  (let* ((num-windows (length (window-list)))
         (num-side-windows (yj/num-side-windows))
         (num-main-windows (- num-windows num-side-windows)))
    (cond
     ((= num-windows 1)
      (when (fboundp 'writeroom-mode)
        (writeroom-mode 'toggle)))
     ((zerop num-side-windows)
      (delete-other-windows))
     ((= num-main-windows 1)
      (window-toggle-side-windows))
     (t
      (progn
        (when (yj/side-window-p (selected-window)) (select-window (get-lru-window)))
        (window-toggle-side-windows)
        (delete-other-windows)
        (window-toggle-side-windows)))))
  (yj/window-divider-mode))

(defun yj/window-buffer-names ()
  "Return a list of strings of names of buffers in the displayed windows."
  (let ((bufs (mapcar 'window-buffer (window-list))))
    (mapcar 'buffer-name bufs)))

(defun yj/delete-window-or-kill-buffer ()
  "Delete the selected window or kill the buffer, depending on window state.
If there is only one non-side window, calls 'kill-buffer',
otherwise calls 'delete-window'."
  (interactive)
  (let ((num-non-side-window (- (length (window-list)) (yj/num-side-windows))))
   (if (= num-non-side-window 1)
       (kill-buffer)
     (delete-window)))
  (yj/window-divider-mode))

(defvar yj/non-editing-buffer-regexp '("magit" "*Minibuf-" "*eshell*" "*vterm*" "*Treemacs" " *Org todo*"  "*Ibuffer*"))

(defun yj/is-editing-buffer (buffer)
  "Return non-nil if BUFFER is an editing buffer."
  (not (seq-some (lambda (regexp) (string-match regexp (buffer-name buffer)))
             yj/non-editing-buffer-regexp)))

(defun yj/other-editing-buffer ()
  "Return the most recently used \"editing\" buffer.
This means that buffers like magit will be excluded."
  (let ((order-buffer-list (cdr (buffer-list (selected-frame)))))
    (seq-find 'yj/is-editing-buffer order-buffer-list (other-buffer))))

(defun yj/other-org-buffer ()
  "Return the most recently used `org-mode' buffer.
This means that buffers like magit will be excluded."
  (let ((order-buffer-list (cdr (buffer-list (selected-frame)))))
    (seq-find
     (lambda (buffer) (string-match "\.org$" (buffer-name buffer)))
     order-buffer-list
     (other-buffer))))

(defun yj/switch-to-previous-editing-buffer (prefix)
  (interactive "P")
  (if prefix
      (switch-to-buffer (yj/other-org-buffer))
    (switch-to-buffer (yj/other-editing-buffer))))

;; We need to unbound "C-[" from ESC first, before we can bind it to anything
;; else. From https://emacs.stackexchange.com/a/10273/23895
(define-key input-decode-map [?\C-\[] (kbd "<C-[>"))
(global-set-key (kbd "<C-[>") 'magit)
;; Bind same key in magit to toggle back to an "editing" buffer

;; TODO: Bind C-` C-1 C-2 ... C-0 C-[ C-]

(defun yj/toggle-buffer ()
  (interactive)
  (switch-to-buffer (other-buffer)))

(defun yj/other-window-dwim ()
  (interactive)
  (if (= (length (window-list)) 1)
      (switch-to-buffer-other-window nil t)
    (other-window 1))
  (yj/window-divider-mode))

(defun yj/other-window-reversed ()
  (interactive)
  (if (= (length (window-list)) 1)
      (progn
        (split-window-sensibly)
        (switch-to-buffer (other-buffer)))
    (other-window -1))
  (yj/window-divider-mode))

;; Adapted from reddit answer:
;; https://www.reddit.com/r/emacs/comments/gtfxg4/zoommonocle_a_buffer/fsbe7da?utm_source=share&utm_medium=web2x&context=3
(defun yj/toggle-maximize-buffer ()
  "Maximize current buffer"
  (interactive)
  (let ((cb (current-buffer)))
    ;; Keep a reference to current buffer in case the previous minimize was
    ;; trigger while in another buffer
    (if (one-window-p)
        (let ((ws (window-start))
              (wp (window-point)))
          ;; Keep a reference to the position of the window in the buffer, and
          ;; the point in the window, so we can restore the position (and
          ;; avoiding going back to the state when the minimize was called).
          (jump-to-register '_)
          (switch-to-buffer cb)
          (set-window-start (selected-window) ws)
          (set-window-point (selected-window) wp))
      (window-configuration-to-register '_)
      (delete-other-windows)))
  (yj/window-divider-mode))

(defun yj/window-divider-mode ()
  "Enable and disable window-divider-mode sensibly"
  (interactive)
  (let ((num-windows (length (window-list))))
    (if (> num-windows 1)
        (window-divider-mode 1)
      (window-divider-mode -1))))

(defun yj/highlight (prefix)
  (interactive "P")
  (let* ((highlighted-regexps (if (boundp 'hi-lock-interactive-lighters)
                                  (mapcar 'car hi-lock-interactive-lighters)
                                nil))
         (selected-text (if (use-region-p)
                            (buffer-substring (region-beginning) (region-end))))
         (to-highlight-or-unhighlight
          (or selected-text (symbol-name (symbol-at-point))))
         (already-highlighted (seq-find
                               (lambda (pat) (string-match to-highlight-or-unhighlight pat))
                               highlighted-regexps)))
    (cond
     (prefix (unhighlight-regexp t)) ;; unhighlight all if prefix argument passed in
     (already-highlighted (unhighlight-regexp already-highlighted)) ;; if symbol at point is already highlighted, remove it
     ((use-region-p)
      (let ((selected-text (buffer-substring (region-beginning) (region-end))))
        (hi-lock-face-buffer selected-text)))
     (t (hi-lock-face-symbol-at-point))))) ;; else, highlight the symbol

(defun yj/counsel-rg (prefix)
  (interactive "P")
  (let ((symbol-name-at-point (symbol-name (symbol-at-point))))
    (if (and prefix symbol-name-at-point)
        (counsel-rg symbol-name-at-point (counsel--git-root) nil nil)
      (counsel-rg))))

(defun yj/imenu (prefix)
  (interactive "p")
  (cond ((= prefix 1) ;; single prefix
         (counsel-imenu))
        ((= prefix 16) ;; double prefix
         (lsp-ui-imenu))
        (t
         (imenu (imenu-choose-buffer-index)))))

(global-set-key (kbd "C-0") 'yj/delete-window-or-kill-buffer)
(global-set-key (kbd "C-1") 'yj/delete-other-windows-dwim)
(global-set-key (kbd "C-2") 'yj/counsel-rg)
(global-set-key (kbd "C-3") 'yj/switch-to-previous-editing-buffer)
(global-set-key (kbd "C-5") 'yj/highlight)
(global-set-key (kbd "C-7") 'swiper)
(global-set-key (kbd "C-8") 'yj/imenu)
;; (global-set-key (kbd "C-9") 'projectile-find-file-dwim)
(global-set-key (kbd "C-9") 'yj/find-file-at-point)
(global-set-key (kbd "C-x C-j") 'dired-jump)
(global-set-key (kbd "M-o") 'yj/other-window-dwim)
(add-hook 'ibuffer-mode-hook
          (lambda () (define-key ibuffer-mode-map (kbd "M-o") nil)))
(global-set-key (kbd "M-O") 'yj/other-window-reversed)

(global-set-key (kbd "C-M-`") 'tab-next)

;; Bound to "C-z" because tmux uses prefix-z for similar functionality.
(global-set-key (kbd "C-z") 'yj/toggle-maximize-buffer)

;; Use "C-`" to toggle back-and-forth between eshell.
(global-set-key (kbd "C-`") 'yj/eshell-or-vterm)

(global-set-key (kbd "C-S-w") 'global-subword-mode)
(global-set-key (kbd "C-S-l") 'global-hide-mode-line-mode)

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
(defun yj/ibuffer-switch-to-default ()
  (interactive)
  (ibuffer-switch-to-saved-filter-groups "default"))
(add-hook 'ibuffer-mode-hook 'yj/ibuffer-switch-to-default)


;; Copied From https://gist.github.com/fspeech/6004949
(defun hs-cycle (&optional arg)
  "Visibility cycling for hs-minor-mode, inspired by outline-cycle from
outline-magic.el (https://github.com/tj64/outline-magic).
When repeatedly called we cycle through three states:
 1. HIDE: Show only headlines in the current context.
 2. OVERVIEW: Expand one level below HIDE to show more details.
 3. SHOW: Show everything in the current context."
  (interactive "P")
  (setq deactivate-mark t)
  (cond
   ((eq last-command 'hs-cycle-hide)
    ;; current state is HIDE, next OVERVIEW
    (hs-hide-level 2)
    (message "OVERVIEW...")
    (setq this-command 'hs-cycle-overview))
   ((eq last-command 'hs-cycle-overview)
    ;; current state is OVERVIEW, next SHOW
    (hs-life-goes-on
     (message "SHOWING...")
     ;; we could (hs-hide-level A_LARGE_NUMBER) but that would be inefficient
     (let ((minp (point-min))
           (maxp (point-max)))
       (save-excursion
	     (when (hs-find-block-beginning)
	       (setq minp (1+ (point)))
	       (funcall hs-forward-sexp-func 1)
	       (setq maxp (1- (point))))
	     (hs-discard-overlays minp maxp)))
     (setq this-command 'hs-cycle-show)))
   (t
    ;; Default: HIDE
    (hs-hide-level 1)
    (message "HIDING...")
    (setq this-command 'hs-cycle-hide))))

(add-hook 'hs-minor-mode-hook
          (lambda () (define-key hs-minor-mode-map (kbd "C-<tab>") 'hs-cycle)))
(setq hs-isearch-open t) ;; automatically unfolds when searching


;;; Experiment keybindngs
;; These are keybindngs that I am trying out find now

;; TODO: Bind to "C-9" (9 == nine == mnemonic for notes) to toggle open the last
;; org buffer / or a tagged buffer. OR add a feature to set "control group" to
;; buffer.

(global-set-key (kbd "C-4") 'treemacs)
(global-set-key (kbd "C-S-t") 'toggle-truncate-lines)


;;;-----------------------------------------------------------------------------
;;; Terminal-related
;;;-----------------------------------------------------------------------------

(use-package eshell
  :init
  (setq eshell-prompt-function 'yj/eshell-prompt)
  (setq eshell-prompt-regexp "^[^#$<]*[$#>] ")
  (setq eshell-highlight-prompt nil)

  (setq eshell-cmpl-ignore-case t)
  (setq eshell-cmpl-dir-ignore "\\`\\(\\.\\.?\\|CVS\\|\\.svn\\|\\.git\\)/\\'")
  (setq eshell-save-history-on-exit t)
  (setq eshell-hist-ignoredups t)
  (setq eshell-cmpl-cycle-completions t)
  (setq eshell-hist-match-partial nil)
  (setq eshell-history-size 65536) ;; default is 128

  :config
  (add-hook 'eshell-mode-hook 'yj/eshell-custom-keymap)
  (add-hook 'eshell-mode-hook 'yj/eshell-max-proess-read)
  (add-hook 'eshell-mode-hook 'hl-line-mode)
  (add-hook 'eshell-mode-hook 'company-mode)
  (add-hook 'eshell-mode-hook (lambda () (setenv "PAGER" "cat"))) ;; avoid paging with less
  ;; (add-to-list 'company-backends 'company-eshell-history)
  )

(defun yj/eshell-max-proess-read ()
    (make-local-variable 'read-process-output-max)
    (setq read-process-output-max 4096)) ;; Keep this value to default so we don't buffer too much


(defun yj/next-go-source-file-name ()
  (interactive)
  (forward-word) ;; to avoid searching current word
  (search-forward-regexp "\\w+\\.go" nil t 1)
  (backward-word 2))
(defun yj/prev-go-source-file-name ()
  (interactive)
  (search-backward-regexp "\\W\\w+\\.go" nil t nil)
  (forward-char))
(defun yj/eshell-custom-keymap ()
  ;; (local-set-key (kbd "C-`") 'previous-buffer)
  (local-set-key (kbd "C-`") 'yj/switch-to-previous-editing-buffer)
  (local-set-key (kbd "C-<tab>") 'yj/next-or-new-eshell)
  (local-set-key (kbd "M-N") 'yj/next-go-source-file-name)
  (local-set-key (kbd "M-P") 'yj/prev-go-source-file-name)
  (local-set-key (kbd "M-R") 'eshell-insert-history)
  (local-set-key (kbd "C-c o") 'org-open-at-point))

(defun eshell-insert-history ()
  "Displays the eshell history to select and insert back into your eshell."
  (interactive)
  (insert (completing-read "Eshell history: "
                               (delete-dups
                                (ring-elements eshell-history-ring)))))

(defun with-face (str &rest face-plist)
  (propertize str 'face face-plist))

(defun yj/eshell-prompt ()
  (concat
   "\n"
   (with-face (format-time-string "[%Y-%m-%d %H:%M] " (current-time)) :foreground "#888")
   (with-face (concat (eshell/pwd) " "))
   (with-face "\n")
   "> "))

(defun company-eshell-history (command &optional arg &rest ignored)
  "Prompt user with a list of eshell history."
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend 'company-eshell-history))
    (prefix (and (eq major-mode 'eshell-mode)
                 (let ((word (company-grab-word)))
                   (save-excursion
                     (eshell-bol)
                     (and (looking-at-p (s-concat word "$")) word)))))
    (candidates (delete-dups
                 (->> (ring-elements eshell-history-ring)
                      (seq-filter (lambda (item) (s-prefix-p arg item)))
                      (mapcar 's-trim))
                 ))
    (sorted t)))


(use-package vterm
  :ensure t
  :config
  (defun yj/vterm-custom-keymap ()
    (local-set-key (kbd "C-`") 'yj/switch-to-previous-editing-buffer)
    (local-set-key (kbd "C-<tab>") 'yj/next-or-new-eshell))
  (add-hook 'vterm-mode-hook 'yj/vterm-custom-keymap))


(defun yj/eshell-or-vterm (prefix)
  "Switch the last recently used eshell, or create one if none; vterm if PREFIX."
  (interactive "P")
  (if prefix
      (vterm)
    (yj/mru-shell)))

(defun yj/mru-shell ()
  "Switch to most recently used shell, or create one if none."
  (interactive)
  (let* ((buffers (buffer-list))
        (is-shell-p (lambda (b) (string-match "\*eshell.*\\|\*vterm\*" (buffer-name b))))
        (shell-buffers (seq-filter is-shell-p buffers))
        (recent-shell-buffer (car shell-buffers)))
    (if recent-shell-buffer
        (switch-to-buffer recent-shell-buffer)
      (eshell))))

(defun yj/next-or-new-eshell (prefix)
  "Switch to the next eshell or vterm; with PREFIX, create a new eshell."
  (interactive "P")
  (let* ((other-buffers (reverse (cdr (buffer-list))))
         (is-eshell-p (lambda (b) (string-match "\*eshell.*\\|\*vterm\*" (buffer-name b))))
         (other-eshell-buffers (seq-filter is-eshell-p other-buffers)))
    (cond
     (prefix (eshell t))
     ((zerop (length other-eshell-buffers)) (eshell t))
     (t (switch-to-buffer (car other-eshell-buffers))))))


;;;-----------------------------------------------------------------------------
;;; Look-and-Feel
;;;-----------------------------------------------------------------------------

(setq window-divider-default-bottom-width 1)
(setq window-divider-default-right-width 1)
(setq window-divider-default-places t)

;; split-width-threshold affects how Emacs decide whether to create a split to
;; the right (horizontally) or to the bottom (vertically).
;;(setq split-width-threshold 150)

;; writeroom-mode provides an experience much like VSCode's zen mode, centering
;; the single window, with blank areas on both side. A very clean and enjoyable
;; view.
(use-package writeroom-mode
  :ensure t
  :config
  (setq writeroom-width 100)
  (setq writeroom-header-line t))

;; solaire mode slightly changes the background colors of "editable" buffers as
;; compare to "non-editable" buffers like the minibuffer, treemacs side window
;; etc.
;; (use-package solaire-mode
;;   :ensure t
;;   :config
;;   (add-to-list 'solaire-mode-themes-to-face-swap 'zenburn)
;;   (solaire-global-mode +1))

(defun yj/update-font-sizes ()
  ;; Make the mode-line and header-line fonts smaller. Note: This code may need
  ;; to be called after the theme is loaded to prevent the theme from
  ;; overwritting the font size.
  (set-face-attribute 'mode-line nil :font "Iosevka-17")
  (set-face-attribute 'header-line nil :font "Iosevka-17"))

;; Use the zenburn theme, which is the default for the Prelude
;; distribution (https://github.com/bbatsov/prelude), which is the
;; distribution that first made Emacs a true delight for me.
(use-package zenburn-theme
  :disabled
  :ensure t
  :config
  (load-theme 'zenburn t)
  (yj/update-font-sizes))

;; Use the Dark+ theme from Visual Code. Note the this theme current lacks good
;; support for org-mode (e.g., different colors for different heading levels,
;; different colors for inline verbatim vs code).
(use-package vscode-dark-plus-theme
  ;; :disabled
  :ensure t
  :config
  (load-theme 'vscode-dark-plus t)
  (yj/update-font-sizes))

;; Use the Darcula theme from JetBrains.
(use-package jetbrains-darcula-theme
  :disabled
  :ensure t
  :config
  (load-theme 'jetbrains-darcula t)
  (yj/update-font-sizes))

;; Use the dracula theme, which provides visually- distinct colors for the
;; following:
;;  - various heading levels in org-mode
;;  - text selection
;;  - highlight of symbol at point
(use-package dracula-theme
  :disabled
  :ensure t
  :config
  (load-theme 'dracula t)
  (yj/update-font-sizes))

;; Display characters beyond column 80 in a different color
(setq-default
 whitespace-line-column 100
 whitespace-style       '(face lines-tail))

;; Display vertical line at column specified by fill-column variable
(when (boundp 'display-fill-column-indicator-mode)
  (display-fill-column-indicator-mode))

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
  :defer 0.3
  :config
  (global-hide-mode-line-mode))


;;;-----------------------------------------------------------------------------
;;; Miscellaneus / Minor Packages
;;;-----------------------------------------------------------------------------

;; git-link is used to copy the URL to GitHub, GitLab, Bitbucket, etc.
;; (https://github.com/sshaw/git-link)
(use-package git-link
  :ensure t
  :commands git-link)

;; rainbow-mode is used to display common color formats (e.g., #RRGGBB) with the
;; actual colors being represented. This is useful when editing CSS / themes.
;; (http://git.savannah.gnu.org/cgit/emacs/elpa.git/?h=externals/rainbow-mode)
(use-package rainbow-mode
  :ensure t
  :commands rainbow-mode)

;; deadgrep is used for dwim grepping. Grepping is static (as opposed to live),
;; and the results are presented in a user-friendly buffer. Depending on use
;; case, I might choose between using this or counsel-rg.
;; (https://github.com/Wilfred/deadgrep)
(use-package deadgrep
  :ensure t
  :commands deadgrep)

;; git-gutter mode is used to disable in the left gutter indicators showing
;; whether the current line is added / modified.
;; (https://github.com/emacsorphanage/git-gutter)
(use-package git-gutter
  :ensure t
  :delight git-gutter-mode
  :config
  (global-git-gutter-mode)
  :bind (("M-n" . git-gutter:next-hunk)
         ("M-p" . git-gutter:previous-hunk)))

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
  :disabled
  :ensure t
  :delight undo-tree-mode
  :config
  (global-undo-tree-mode))

;; elpy
(use-package elpy
  :ensure t
  :init
  (elpy-enable))

;; flycheck
(use-package flycheck
  :ensure t
  :delight flycheck-mode
  :init (global-flycheck-mode)
  :bind (("M-N" . flycheck-next-error)
         ("M-P" . flycheck-previous-error)))

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

(defun yj/company-echo-doc-as-metadata-frontend (command)
  "Adapted from company-echo-metadata-frontend; COMMAND must be `post-command'."
  (pcase command
    (`post-command (company-echo-show-soon 'yj/company-fetch-doc))
    (`unhide (company-echo-show))
    (`hide (company-echo-hide))))

(defun yj/company-fetch-doc ()
  "Adapted from company-fetch-metadata and company-show-doc-buffer."
  (let ((selected (nth (or company-selection 0) company-candidates)))
    (unless (eq selected (car company-last-metadata))
      (setq company-last-metadata
            (cons selected (company-call-backend 'doc-buffer selected))))
    (with-current-buffer (cdr company-last-metadata)
      (buffer-string))))

(use-package company
  :ensure t
  :commands company-mode
  :config

  ;; Immediately show completions after two characters are typed
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 2)

  (setq company-show-numbers t)
  (setq company-selection-wrap-around t)

  ;; Use "C-n" and "C-p" to navigate lines in the file (as opposed to
  ;; company-mode's suggestions) as I already use tab to navigate the
  ;; suggestions.
  (define-key company-active-map (kbd "C-n") nil)
  (define-key company-active-map (kbd "C-p") nil)

  (define-key company-active-map (kbd "C-v") 'company-next-page)
  (define-key company-active-map (kbd "M-v") 'company-previous-page)

  ;; Unbind "C-d" to re-enable its default behavior instead of calling
  ;; `company-show-doc-buffer', which is already bound to "C-h".
  (define-key company-active-map (kbd "C-d") nil)

  ;; Enable company-tng-mode, which uses tab key for navigating through
  ;; suggestions, and inserting into the buffer the currently suggestion as we
  ;; are tabbing through. For more, details, see the comany-tng.el file.
  (add-hook 'after-init-hook 'company-tng-mode))

;; TODO: Find a way to get company-mode to also show documentation in a
;; user-friendly manner. Currently, when selecting a completion candidate, I can
;; press "C-d" to show the documentation in is buffer that'll take up half the
;; screen; this is horrible. I have also tried various other packages:
;;
;;  - company-posframe: seems to be a little too heavy. Current complaints:
;;    1. still need to find a way to reconfigure bindings to use tab to navigate
;;       through completion candidates,
;;    2. the documentation takes a while to show; and
;;    3. there is screen flicker when it shows the documentation for the first
;;       time.
;; (use-package company-posframe
;;   :ensure t
;;   :after company
;;   :config
;;   (setq company-posframe-show-indicator nil)
;;   (setq company-posframe-quickhelp-delay 0)
;;   (setq company-posframe-quickhelp-show-header nil)
;;   (company-posframe-mode 1))
;;
;;  - company-box: Seems nice. Current complaints:
;;    1. documentation are shown to far to the right; I'll need to find a way to
;;       perhaps show the annotations (i.e., the function signature) in the echo
;;       area, leaving enough space for the documentation; alternatively, I have
;;       need to find a way to show the function signature + documentation
;;       together
;;    2. delay
;; (use-package company-box
;;   :ensure t
;;   :after company
;;   :hook (company-mode . company-box-mode))
;;
;;  - company-quickhelp: Seems nice and fast, but the font size (as displayed by
;;                       pos-tip) is too small.
;; (use-package pos-tip)
;; (use-package company-quickhelp
;;   :ensure t
;;   :after company
;;   :config
;;   (setq company-quickhelp-delay 0)
;;   (company-quickhelp-mode 1))


;;; Counsel (includes the dependencies Ivy and Swiper)
;;; (https://oremacs.com/swiper/)
;;; Ivy is a generic completion frontend
;;; Swiper is an alternative isearch with a preview of all matching lines
;;; Counsel is a collection of Ivy-enhanced versions of common Emacs commands
(use-package counsel
  :ensure t
  :delight ivy-mode
  :init
  ;; Basic customization as recommended on official documentation
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format " (%d/%d) ")
  (setq ivy-re-builders-alist
        '((t . ivy--regex-ignore-order)))
  (setq ivy-initial-inputs-alist nil) ;; Disable the caret (^) in all ivy prompts
  :config
  (ivy-mode 1)

  ;; Below are the key bindings as listed on the official documentation.
  ;; TODO: Uncomment them out as I explore new functionalities.

  ;; Ivy-based interface to standard commands
  :bind (;;("C-s" . swiper-isearch)
         ("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ;;("M-y" . counsel-yank-pop) ;; tried and did not like
         ;;("<f1> f" . counsel-describe-function)
         ;;("<f1> v" . counsel-describe-variable)
         ;;("<f1> l" . counsel-find-library)
         ;;("<f2> i" . counsel-info-lookup-symbol)
         ;;("<f2> u" . counsel-unicode-char)
         ;;("<f2> j" . counsel-set-variable)
         ("C-x b" . ivy-switch-buffer)
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

(use-package ivy-hydra
  :ensure t)

;;; projectile
(use-package projectile
  :ensure t
  :delight projectile-mode
  :init
  (setq projectile-completion-system 'ivy)
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("s-p" . projectile-command-map)
              ("C-c p" . projectile-command-map))
  :config
  (use-package treemacs-projectile
    ;; Properly configure treemacs as a standalone dependency since I'm relying
    ;; on it. Also harmonize with how lsp-treemacs is configured. Sidenote: the
    ;; documentation is also rather good
    ;; https://github.com/Alexander-Miller/treemacs#installation
    :ensure t
    :config
    (treemacs-fringe-indicator-mode 'only-when-focused)))

(def-projectile-commander-method ?2
  "Call counsel-rg in project."
  (counsel-rg nil (projectile-project-root) nil nil))


;;;-----------------------------------------------------------------------------
;;; Text Mode: General
;;;-----------------------------------------------------------------------------

(use-package yaml-mode
  :ensure t)

;; "text-mode" is a major mode for editing files of text in a human language
;; most major modes for non-programmers inherit from text-mode.
;; (add-hook 'text-mode-hook 'text-mode-hook-setup)
;; (add-hook 'text-mode-hook #'company-mode)

;; Adapted from http://blog.binchen.org/posts/emacs-auto-completion-for-non-programmers.html
(defun text-mode-hook-setup ()
  ;; make `company-backends' local is critcal
  ;; or else, you will have completion in every major mode, that's very annoying!
  (make-local-variable 'company-backends)

  ;; company-ispell is the plugin to complete words
  (add-to-list 'company-backends 'company-ispell))

(defun yj/show-whitespace-local ()
  ;; Show trailing white spaces
  (setq-local show-trailing-whitespace t))
(add-hook 'text-mode-hook #'yj/show-whitespace-local)

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
  (org-set-emph-re 'org-emphasis-regexp-components org-emphasis-regexp-components)

  ;; https://emacs-china.org/t/orgmode/9740/12
  ;; 让中文也可以不加空格就使用行内格式
  ;;(setcar (nthcdr 0 org-emphasis-regexp-components) " \t('\"{[:nonascii:]")
  ;;(setcar (nthcdr 1 org-emphasis-regexp-components) "- \t.,:!?;'\")}\\[[:nonascii:]")
  ;;(org-set-emph-re 'org-emphasis-regexp-components org-emphasis-regexp-components)
  ;;(org-element-update-syntax)
  ;; 规定上下标必须加 {}，否则中文使用下划线时它会以为是两个连着的下标
  ;;(setq org-use-sub-superscripts "{}")


  ;; https://emacs-china.org/t/orgmode/9740/18
  (setq org-emphasis-regexp-components '("-[:multibyte:][:space:]('\"{" "-[:multibyte:][:space:].,:!?;'\")}\\[" "[:space:]" "." 20))
  (org-set-emph-re 'org-emphasis-regexp-components org-emphasis-regexp-components)
  (org-element-update-syntax)
  )

(add-hook 'org-mode-hook #'visual-line-mode)
(add-hook 'org-mode-hook #'hl-line-mode)

;; Treat CamelCaseSubWords as separate words (affects keys like "M-b"/"M-f").
;;(add-hook 'org-mode-hook #'subword-mode)

;;; Org-capture
(setq org-directory yj-org-directory)
(setq org-default-notes-file (concat org-directory "/main.org"))

;; C-c c to start org-capture
(global-set-key (kbd "C-c c") 'org-capture)

;; C-c a to start org-agenda
(global-set-key (kbd "C-c a") 'org-agenda)

;; Capture templates for: TODO tasks, Notes, appointments, phone calls, meetings, and org-protocol
(setq org-capture-templates
      (quote (("t" "todo" entry (file+datetree (lambda () (concat org-directory "/captured-todos.org")))
              "* TODO %?\nCreated %U\n")
              ("c" "chat_logs" entry (file+datetree (lambda () (concat org-directory "/conversations.org")))
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

(defun yj/update-org-agenda-files ()
  (interactive)
  ;; Recursively adds file ending with .org to the agenda files, required
  ;; because newly created files are not automatically added.
  (setq org-agenda-files (directory-files-recursively
                          (concat org-directory "/") "\\.org$"))
  (setq org-agenda-files (cl-remove-if
                          (lambda (k)
                            (or (string-match ".stversions" k) ; removes syncthing artefacts
                                (string-match "sync-conflict" k))) ; removes syncthing artefacts
                          org-agenda-files)))

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

;; (add-hook 'markdown-mode-hook #'auto-fill-mode)


;;;-----------------------------------------------------------------------------
;;; Programming Mode: General
;;;-----------------------------------------------------------------------------

;; Highlight current line only in programming modes (this excludes
;; shell and terminal modes).
(add-hook 'prog-mode-hook #'hl-line-mode)

;; Show verticle line at column 80.
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

;; Highlight matching parenthesis in programming modes.
(add-hook 'prog-mode-hook #'show-paren-mode)

;; Automatically close parentheses, brackets, quotes, etc.
(add-hook 'prog-mode-hook #'electric-pair-local-mode)

;; Display white space characters.
(add-hook 'prog-mode-hook #'yj/show-whitespace-local)

;; Treat CamelCaseSubWords as separate words in every programming mode.
;;(add-hook 'prog-mode-hook #'subword-mode)

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
  ;; performance tuning, see https://github.com/emacs-lsp/lsp-mode/blob/master/docs/page/performance.md for details
  (setq gc-cons-threshold (* 800000 128)) ;; default is 800000, now is around 100 MB
  (setq read-process-output-max (* 1024 1024)) ;; default is 4096, now 1 MB

  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         (go-mode . lsp)
         (java-mode . lsp)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp
  :config
  (setq lsp-completion-show-detail t)
  (setq lsp-completion-show-kind nil)

  ;; more performance tuning: avoid watching vendor directory
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\vendor\\'")

  (defun yj/lsp-hide-doc ()
    (interactive)
    (lsp-ui-doc-unfocus-frame)
    (lsp-ui-doc-hide))

  (defun yj/bind-lsp-ui-doc-frame-hook-map (&rest _)
    (define-key lsp-ui-doc-frame-mode-map (kbd "q") 'yj/lsp-hide-doc))
  (add-hook 'lsp-ui-doc-frame-hook #'yj/bind-lsp-ui-doc-frame-hook-map)

  (defun yj/lsp-show-doc ()
    (interactive)
    (lsp-ui-doc-show)
    (lsp-ui-doc-focus-frame))

  (define-key lsp-mode-map (kbd "M-?") 'lsp-find-references) ; Replaces `xref-find-local'
  (define-key lsp-mode-map (kbd "M-Y") 'lsp-goto-type-definition) ; Using Y for tYpe
  (define-key lsp-mode-map (kbd "M-I") 'lsp-find-implementation)
  (define-key lsp-mode-map (kbd "C-h l") 'yj/lsp-show-doc)

  ;; A better highlight color when highlighting occurences of symbol under
  ;; cursor.
  (set-face-attribute 'lsp-face-highlight-textual nil
                      ;; :inherit 'nobreak-hyphen
                      :slant 'italic
                      :underline t
                      :overline nil))

;; optionally
(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-sideline-enable nil)
  (setq lsp-ui-doc-enable nil)
  (setq lsp-lens-enable nil))
;; if you are helm user
;;(use-package helm-lsp :commands helm-lsp-workspace-symbol)
;; if you are ivy user
;;(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs
  :ensure t
  :commands lsp-treemacs-errors-list
  :init
  (setq treemacs-no-delete-other-windows nil)
  (setq-default treemacs-fringe-indicator-mode 'only-when-focused)
  :config
  (treemacs-resize-icons 16))

;; optionally if you want to use debugger
;;(use-package dap-mode)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language


;;;-----------------------------------------------------------------------------
;;; Programming Mode: Tree-sitter
;;;-----------------------------------------------------------------------------

(require 'treesit)

;; Note: The parsers below must be manually built by cloning the repo and
;; running the build script.
(add-to-list 'treesit-extra-load-path "/home/yongjie/git-repos/casouri/tree-sitter-module/dist")

(defun yj/find-function-references ()
  "Find references of current function from any point within the function body."
  (interactive)
  (let* ((major-mode (buffer-local-value 'major-mode (current-buffer)))
         (lang (string-remove-suffix "-mode" (symbol-name major-mode))))
    (treesit-parser-create (intern lang))
    (treesit-search-forward-goto (treesit-node-at (point)) "function" t t)
    lsp-find-references))

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
(add-hook 'go-mode-hook #'hs-minor-mode)

(defun yj/go-mode-hook ()
  (let* ((trimmed (remove 'company-echo-metadata-frontend company-frontends))
         (new-company-frontends (push 'yj/company-echo-doc-as-metadata-frontend trimmed)))
    (set (make-local-variable 'company-frontends) new-company-frontends)))
(add-hook 'go-mode-hook 'yj/go-mode-hook)


(defvar previous-before-save-hooks nil)
(defun yj/toggle-before-save-hook () ;; Useful for turning of gofmt before saving
  (interactive)
  (if before-save-hook
      (progn
        (setq previous-before-save-hooks before-save-hook)
        (setq before-save-hook nil))
    (progn
      (setq before-save-hook previous-before-save-hooks)
      (setq previous-before-save-hooks nil))))


;;;-----------------------------------------------------------------------------
;;; Programming Mode: Rust
;;;-----------------------------------------------------------------------------

;; rustic is recommended by article at
;; https://robert.kra.hn/posts/2021-02-07_rust-with-emacs/
(use-package rustic
  :ensure t)


;;;-----------------------------------------------------------------------------
;;; Programming Mode: C
;;;-----------------------------------------------------------------------------


;; Copied from https://github.com/MaskRay/ccls/wiki/lsp-mode#use-package
(use-package ccls
  :ensure t
  :hook ((c-mode c-ts-mode c++-mode objc-mode cuda-mode) .
         (lambda () (require 'ccls) (lsp))))


;;;-----------------------------------------------------------------------------
;;; Programming Mode: Java
;;;-----------------------------------------------------------------------------

(use-package lsp-java
  :ensure t)
(add-hook 'java-mode-hook #'company-mode)


;;;-----------------------------------------------------------------------------
;;; Programming Mode: Kotlin
;;;-----------------------------------------------------------------------------

;; Note: This is manually install by git cloning the repo to the local below
(add-to-list 'load-path "/home/yongjie/git-repos/YongJieYongJie/emacs-kotlin-ts-mode")
(require 'kotlin-ts-mode)
(add-to-list 'auto-mode-alist '("\\.kt\\'" . kotlin-ts-mode))


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
  :commands magit-status
  :config
  (define-key magit-mode-map (kbd "<C-[>") 'yj/switch-to-previous-editing-buffer)
  (setq magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1))

;; Configure ediff, which I usually only use from Magit
(setq ediff-split-window-function 'split-window-horizontally)
(setq ediff-window-setup-function 'ediff-setup-windows-plain) ; avoid creating new frame


;;;-----------------------------------------------------------------------------
;;; END
;;;-----------------------------------------------------------------------------

;; Ensure proper aligned of Chinese/Japanese characters and English characters
;; (especially in org-mode tables)
;;
;; Steps:
;; 1. Use <C-u><C-x>= to find the font of a Chinese character, and an English
;;    character
;; 2. Pass in the names of the two fonts, setting them to the same size.
(eval-when-compile (require 'cl))
(defun set-font (english chinese english-size chinese-size)
  (set-face-attribute 'default nil :font
		              (format "%s:pixelsize=%d" english english-size))
  (dolist (charset '(kana han symbol cjk-misc bopomofo))
    (set-fontset-font (frame-parameter nil 'font) charset
		              (font-spec :family chinese :size chinese-size))))
(ecase system-type
       (gnu/linux
        (set-face-bold 'bold nil)
        (set-face-underline 'bold nil)
        (set-font "Iosevka" "Noto Sans CJK KR"  22 22)))

;; Move the irritating custom-set-* to a seperate file outside of source
;; control.
(setq custom-file (expand-file-name "custom-file.el" user-emacs-directory))

(provide 'init)
;;; init.el ends here

(message "(￣^￣ )ゞ") ;; Emacs reporting for duty

(put 'dired-find-alternate-file 'disabled nil)

(use-package auctex
  :defer t
  :ensure t
  :config
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq-default TeX-master nil)
  (setq LaTeX-electric-left-right-brace t))
