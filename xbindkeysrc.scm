;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start of xbindkeys guile configuration ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This configuration is guile based.
;;   http://www.gnu.org/software/guile/guile.html
;; any functions that work in guile will work here.
;; see EXTRA FUNCTIONS:

;; Version: 1.8.2

;; If you edit this file, do not forget to uncomment any lines
;; that you change.
;; The semicolon(;) symbol may be used anywhere for comments.

;; To specify a key, you can use 'xbindkeys --key' or
;; 'xbindkeys --multikey' and put one of the two lines in this file.

;; A list of keys is in /usr/include/X11/keysym.h and in
;; /usr/include/X11/keysymdef.h
;; The XK_ is not needed.

;; List of modifier:
;;   Release, Control, Shift, Mod1 (Alt), Mod2 (NumLock),
;;   Mod3 (CapsLock), Mod4, Mod5 (Scroll).


;; The release modifier is not a standard X modifier, but you can
;; use it if you want to catch release instead of press events

;; By defaults, xbindkeys does not pay attention to modifiers
;; NumLock, CapsLock and ScrollLock.
;; Uncomment the lines below if you want to use them.
;; To dissable them, call the functions with #f


;;;;EXTRA FUNCTIONS: Enable numlock, scrolllock or capslock usage
;;(set-numlock! #t)
;;(set-scrolllock! #t)
;;(set-capslock! #t)

;;;;; Scheme API reference
;;;;
;; Optional modifier state:
;; (set-numlock! #f or #t)
;; (set-scrolllock! #f or #t)
;; (set-capslock! #f or #t)
;; 
;; Shell command key:
;; (xbindkey key "foo-bar-command [args]")
;; (xbindkey '(modifier* key) "foo-bar-command [args]")
;; 
;; Scheme function key:
;; (xbindkey-function key function-name-or-lambda-function)
;; (xbindkey-function '(modifier* key) function-name-or-lambda-function)
;; 
;; Other functions:
;; (remove-xbindkey key)
;; (run-command "foo-bar-command [args]")
;; (grab-all-keys)
;; (ungrab-all-keys)
;; (remove-all-keys)
;; (debug)


;; Examples of commands:

;; (xbindkey '(control shift q) "xbindkeys_show")

;; set directly keycode (here control + f with my keyboard)
;; (xbindkey '("m:0x4" "c:41") "xterm")

;; specify a mouse button
;; (xbindkey '(control "b:2") "xterm")

;;(xbindkey '(shift mod2 alt s) "xterm -geom 50x20+20+20")

;; set directly keycode (control+alt+mod2 + f with my keyboard)
;; (xbindkey '(alt "m:4" mod2 "c:0x29") "xterm")

;; Control+Shift+a  release event starts rxvt
;; (xbindkey '(release control shift a) "rxvt")

;; Control + mouse button 2 release event starts rxvt
;; (xbindkey '(releace control "b:2") "rxvt")

; (xbindkey '(down Menu) "xdotool keydown control")
; (xbindkey '(release Menu) "xdotool keyup control")
; "xdotool keydown control_r"
;   Menu + Down

; "xdotool keyup control_r"
;   Menu + Up

; "alacritty"
;   Control_R


;; Extra features
;; (xbindkey-function '(control a)
;;                    (lambda ()
;;                      (display "Hello from Scheme!")
;;                      (newline)))
;; 
;; (xbindkey-function '(shift p)
;;                    (lambda ()
;;                      (run-command "xterm")))


;; Double click test
;; (xbindkey-function '(control w)
;;                    (let ((count 0))
;;                      (lambda ()
;;                        (set! count (+ count 1))
;;                        (if (> count 1)
;;                            (begin
;;                             (set! count 0)
;;                             (run-command "xterm"))))))

;; Time double click test:
;;  - short double click -> run an xterm
;;  - long  double click -> run an rxvt
;; (xbindkey-function '(shift w)
;;                    (let ((time (current-time))
;;                          (count 0))
;;                      (lambda ()
;;                        (set! count (+ count 1))
;;                        (if (> count 1)
;;                            (begin
;;                             (if (< (- (current-time) time) 1)
;;                                 (run-command "xterm")
;;                                 (run-command "rxvt"))
;;                             (set! count 0)))
;;                        (set! time (current-time)))))


;; Chording keys test: Start differents program if only one key is
;; pressed or another if two keys are pressed.
;; If key1 is pressed start cmd-k1
;; If key2 is pressed start cmd-k2
;; If both are pressed start cmd-k1-k2 or cmd-k2-k1 following the
;;   release order
(define (define-chord-keys key1 key2 cmd-k1 cmd-k2 cmd-k1-k2 cmd-k2-k1)
    "Define chording keys"
  (let ((k1 #f) (k2 #f))
    (xbindkey-function key1 (lambda () (set! k1 #t)))
    (xbindkey-function key2 (lambda () (set! k2 #t)))
    (xbindkey-function (cons 'release key1)
                       (lambda ()
                         (if (and k1 k2)
                             (run-command cmd-k1-k2)
                             (if k1 (run-command cmd-k1)))
                         (set! k1 #f) (set! k2 #f)))
    (xbindkey-function (cons 'release key2)
                       (lambda ()
                         (if (and k1 k2)
                             (run-command cmd-k2-k1)
                             (if k2 (run-command cmd-k2)))
                         (set! k1 #f) (set! k2 #f)))))


;; Example:
;;   Shift + b:1                   start an xterm
;;   Shift + b:3                   start an rxvt
;;   Shift + b:1 then Shift + b:3  start gv
;;   Shift + b:3 then Shift + b:1  start xpdf

;; (define-chord-keys '(shift "b:1") '(shift "b:3")
;;   "xterm" "rxvt" "gv" "xpdf")

;; Here the release order have no importance
;; (the same program is started in both case)
;; (define-chord-keys '(alt "b:1") '(alt "b:3")
;;   "gv" "xpdf" "xterm" "xterm")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; End of xbindkeys guile configuration ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start of Yong Jie's customization ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Mouse Chording / Mouse Modifier Button
;; Inspired by the code on ArchWiki:
;; https://wiki.archlinux.org/title/Xbindkeys#Mouse_Chording

(define (first-in-inner list-of-lists)
  ;; first-in-inner returns a list containing the first element in the list of
  ;; lists passed in as argument. For example, given:
  ;;     (("a", "b"), (1, 2))
  ;; the function returns:
  ;;     ("a", 1)
  (map (lambda (inner-list) (list-ref inner-list 0))
       list-of-lists))

(define (bind-all definitions)
  ;; bind-all accepts a list of definitions, and bind each definition.
  ;; Usage:
  ;;     (bind-all
  ;;      '((list '(release "b:1") "xdotool key a")
  ;;        (list '(release "b:3") "xdotool key b")))
    (for-each (lambda (definition)
                (let ((key (list-ref definition 0))
                      (binding (list-ref definition 1)))
                  (xbindkey-function key (lambda () (run-command binding)))))
              definitions))

(define (unbind-all keys)
  ;; unbind-all accepts a list of keys, and bind each key.
  ;; Usage:
  ;;     (unbind-all
  ;;      (list
  ;;       '(release "b:1")
  ;;       '(release "b:3")))
  (for-each (lambda (key) (remove-xbindkey key)) keys))

(define (define-mouse-modifiers chord-key . definitions)
  ;; define-mouse-modifiers defines chord actions, such that the chord-key acts
  ;; like a modifier key that changes the behavior of the other keys as per the
  ;; definitions.
  ;; For example, the following code changes the behavior of:
  ;;  - mouse button 1 to ctrl+c when mouse button 9 is held down, and
  ;;  - mouse button 3 to ctrl+v when mouse button 9 is held down:
  ;;     (define-mouse-modifiers "b:9"
  ;;       (list '(release "b:1") "xdotool key ctrl+c")
  ;;       (list '(release "b:3") "xdotool key ctrl+v"))
  (define (start-mouse-chord)
    (bind-all definitions)
    (xbindkey-function `(release ,chord-key)
                       (lambda ()
                         (remove-xbindkey `(release ,chord-key))
                         (unbind-all (first-in-inner definitions)))))
  (xbindkey-function chord-key start-mouse-chord))

(define-mouse-modifiers "b:9"
  (list '(release "b:1") "xdotool key ctrl+c") ; "forward" + left mouse button -> copy
  (list '(release "b:3") "xdotool key ctrl+v")) ; "backward" + right mouse button -> paste

(define-mouse-modifiers "b:8"
  (list '(release "b:1") "xdotool key ctrl+z") ; "forward" + left mouse button -> undo
  (list '(release "b:3") "xdotool key ctrl+y")) ; "backward" + right mouse button -> redo


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; End of Yong Jie's customization ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
