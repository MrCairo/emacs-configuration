;;; =================================================================
;;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 128 1024 1024))

(defun mrf/display-startup-time ()
   "Calculate and display startup time."
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                    (time-subtract after-init-time before-init-time)))
           gcs-done))
(add-hook 'emacs-startup-hook #'mrf/display-startup-time)

;;; -----------------------------------------------------------------
;;; Add site-lisp as well as all package directories in site-lisp to the
;;; load-path variable.
(defun mrf/integrate-local-site-lisp ()
   (let ((default-directory (expand-file-name "site-lisp" user-emacs-directory)))
      (setq load-path
         (append
            (let ((load-path  (copy-sequence load-path))) ;; Shadow
               (normal-top-level-add-subdirs-to-load-path))
            load-path))))

(eval-when-compile
   (add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
   (mrf/integrate-local-site-lisp)
   (require 'use-package)
   (require 'general)
   (setq use-package-always-ensure t))

;;; -----------------------------------------------------------------
(defvar emacs-config-directory user-emacs-directory)

;;; You'll need to override these from my values. Note that these directories
;;; are NOT automatically created if they don't exist.
;;;
;;; Optionally Set user-emacs-directory to something external to this directory
;;; so that transient files do not "polute" the .emacs.d directory.
(setq user-emacs-directory "~/Documents/Emacs-Related/emacs-working-files")

;;; Setup a documenation directory. This is where things like YASnippet
;;; snippets are saved and also additional color themese are stored.
(defvar mrf/docs-dir "~/Documents/Emacs-Related")

;;; -----------------------------------------------------------------
;; You will most likely need to adjust this font size for your system!
(defvar mrf/default-font-size 175)
(defvar mrf/default-variable-font-size 175)
(defvar mrf/set-frame-maximized t)  ;; or f

;; Make frame transparency overridable
(defvar mrf/frame-transparency '(90 . 90))

;; Set frame transparency
(defun mrf/set-frame-alpha-maximized ()
   "Function to set the alpha and also maximize the frame."
   (set-frame-parameter (selected-frame) 'alpha mrf/frame-transparency)
   (set-frame-parameter (selected-frame) 'fullscreen 'maximized))

;; default window width and height
(defun mrf/custom-set-frame-size ()
   "Simple function to set the default frame width/height."
   (add-to-list 'default-frame-alist '(height . 60))
   (add-to-list 'default-frame-alist '(width . 140)))


(defun mrf/update-face-attribute ()
     ;; ====================================
   ;; Set the font faces
   ;; ====================================  
   (set-face-attribute 'default nil
      :font "Menlo"
      :height mrf/default-font-size)

   ;; Set the fixed pitch face
   (set-face-attribute 'fixed-pitch nil
      :font "Menlo"
      :height mrf/default-font-size)

   ;; Set the variable pitch face
   (set-face-attribute 'variable-pitch nil
      :font "SF Pro"
      :height mrf/default-variable-font-size
      :weight 'regular))

(mrf/set-frame-alpha-maximized)
(mrf/update-face-attribute)
;; (mrf/custom-set-frame-size)

;;; ------------------------------------------------------------------------

 (add-to-list 'custom-theme-load-path (concat mrf/docs-dir "/Additional-Themes"))

 (defvar mrf/list-theme-packages
      '(
          color-theme-sanityinc-tomorrow
          doom-themes
          exotica-theme
          immaterial-theme
          material-theme
          timu-caribbean-theme
          timu-macos-theme
       ))

 (mapc #'(lambda (theme)
           (unless (package-installed-p theme)
             (package-install theme)))
       mrf/list-theme-packages)

;;
;;; --- ---------------------------------------------------------------------
   ;;; List of favorite themes. Uncomment the one that feels good for the day.
   ;; (load-theme 'material t)
   ;; (load-theme 'doom-palenight t)
   ;; (load-theme 'doom-monokai-pro t)
   ;; (load-theme 'afternoon t)
   ;; (load-theme 'tomorrow-night-blue t)
   ;; (load-theme 'tomorrow-night-bright t)
   ;; (load-theme 'borland-blue t)
   ;; (load-theme 'deeper-blue t)
   (load-theme 'modus-vivendi-deuteranopia t)

;;; -----------------------------------------------------------------

(require 'paren)
(show-paren-mode 1)

(defconst *is-a-mac* (eq system-type 'darwin))

(setq inhibit-startup-message t)  ;; Hide the startup message
(setq visible-bell t)             ;; Set up the visible bell

(save-place-mode 1)          ;; Remember where we were last editing a file.

(setq backup-inhibited t)    ;; disable backup
(setq auto-save-default nil) ;; disable auto save

(column-number-mode)
(global-display-line-numbers-mode t) ;; Line numbers appear everywhere

;; number of characters until the fill column
(setq-default fill-column 78)

;; emacs lisp tab size
(setq lisp-indent-offset '3)

;; each line of text gets one line on the screen (i.e., text will run
;; off the left instead of wrapping around onto a new line)
(setq-default truncate-lines 1)

(global-prettify-symbols-mode 1) ;; Display pretty symbols (i.e. λ = lambda)

;; truncate lines even in partial-width windows
(setq truncate-partial-width-windows 1)

(use-package evil-nerd-commenter
   :bind ("M-/" . evilnc-comment-or-uncomment-lines))

;;; (use-package treemacs-all-the-icons)

(use-package rainbow-delimiters
  :config
  (rainbow-delimiters-mode))

(general-def  prog-mode-map
   "C-c ]"  'indent-region
   "C-c }"  'indent-region)

;;; -----------------------------------------------------------------

(require 'package)  
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                           ("org" . "https://orgmode.org/elpa/")
                           ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
   (package-refresh-contents))

;;; -----------------------------------------------------------------
;;;
;;; The following packages aren't properly loaded with the 'require' or
;;; 'use-package' functions (for some reason) so we resort to 'package-install'
;;; instead.
;;
(defvar mrf/must-install-packages
   '(
       cl-lib
       auto-complete
       bind-key
       winum
    ))

(mapc #'(lambda (item)
	  (unless (package-installed-p item)
	    (package-install item)))
      mrf/must-install-packages)

;;; -----------------------------------------------------------------

(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe)
  (auto-package-update-at-time "09:00"))

;;; ------------------------------------------------------------------------
(use-package yasnippet
   :defer t
   :config
   (use-package yasnippet-snippets
      :ensure t)
   (yas-global-mode t)
   (define-key yas-minor-mode-map (kbd "<tab>") nil)
   (define-key yas-minor-mode-map (kbd "C-'") #'yas-expand)
   (add-to-list #'yas-snippet-dirs (concat mrf/docs-dir "/Snippets"))
   (yas-reload-all)
   (setq yas-prompt-functions '(yas-ido-prompt))
   (defun help/yas-after-exit-snippet-hook-fn ()
      (prettify-symbols-mode)
      (prettify-symbols-mode))
   (add-hook 'yas-after-exit-snippet-hook #'help/yas-after-exit-snippet-hook-fn)
   :diminish yas-minor-mode)

(add-to-list 'load-path (concat mrf/docs-dir "/Snippets"))

;;; ------------------------------------------------------------------------
(use-package which-key
   :defer 0
   :diminish which-key-mode
   :custom (which-key-idle-delay 1.5)
   :config
   (which-key-mode)
   (which-key-setup-side-window-right))

;;; ------------------------------------------------------------------------

(require 'winum)
(winum-mode)

(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                2000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-header-scroll-indicators        '(nil . "^^^^^^")
          treemacs-hide-dot-git-directory          t
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask" "/__pycache__")
          treemacs-project-follow-into-home        nil
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               70
          treemacs-width                           35
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    ;; (when treemacs-python-executable
    ;;   (treemacs-git-commit-diff-mode t))

    ;; (pcase (cons (not (null (executable-find "git")))
    ;;              (not (null treemacs-python-executable)))
    ;;   (`(t . t)
    ;;    (treemacs-git-mode 'deferred))
    ;;   (`(t . _)
    ;;    (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)

(use-package treemacs-icons-dired
   :hook (dired-mode . treemacs-icons-dired-enable-once)
   :ensure t)

(use-package treemacs-persp ;;treemacs-perspective if you use perspective.el vs. persp-mode
  :after (treemacs persp-mode) ;;or perspective vs. persp-mode
  :ensure t
  :config (treemacs-set-scope-type 'Perspectives))

(use-package treemacs-tab-bar ;;treemacs-tab-bar if you use tab-bar-mode
  :after (treemacs)
  :ensure t
  :config (treemacs-set-scope-type 'Tabs))

;;; ------------------------------------------------------------------------
(defun mrf/lsp-mode-setup ()
  "Set up LSP header-line."
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . mrf/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :config (setq lsp-ui-sideline-enable t
                lsp-ui-sideline-show-hover t
                lsp-ui-sideline-delay 0.5
                lsp-ui-sideline-ignore-duplicates t
                lsp-ui-doc-delay 3
                lsp-ui-doc-position 'top
                lsp-ui-doc-alignment 'frame
                lsp-ui-doc-header nil
                lsp-ui-doc-show-with-cursor t
                lsp-ui-doc-include-signature t
                lsp-ui-doc-use-childframe t)
  :commands lsp-ui-mode
  :custom
  (lsp-ui-doc-position 'bottom)
  :hook (lsp-mode . lsp-ui-mode))

(general-def lsp-ui-mode-map
   "C-c l d" 'lsp-ui-doc-focus-frame)

(use-package lsp-treemacs
   :after lsp
   :config
   (lsp-treemacs-sync-mode 1)
   (general-def prog-mode-map
      "C-c t" 'treemacs))

(use-package lsp-ivy
  :after lsp ivy)

;; Make sure that we set the read buffer above the default 4k
(setq read-process-output-max (* 1024 1024))

;;; ===========================================================================
;;; Emacs Polyglot is the Emacs LSP client that stays out of your way:

(use-package eglot)

;;; ------------------------------------------------------------------------
(use-package dap-mode
  ;; Uncomment the config below if you want all UI panes to be hidden by default!
  ;; :custom
  ;; (lsp-enable-dap-auto-configure nil)
  :config
   (message "DAP mode loaded.")
   (dap-ui-mode 1)
   (setq lsp-enable-dap-auto-configure nil)
  :commands
   dap-debug
  :custom
   (dap-auto-configure-features '(sessions locals controls tooltip)))

(setq dap-python-debugger 'debugpy)

;; (use-package dap-hydra
;;    :hook (dap-stopped . (lambda (arg) (call-interactively #'dap-hydra))))

;;; ------------------------------------------------------------------------
(use-package dap-python
  :after (dap-mode)
  :ensure t
  :config
  (dap-register-debug-template "Python :: Run file from project directory"
                               (list :type "python"
                                     :args ""
                                     :cwd nil
                                     :module nil
                                     :program nil
                                     :request "launch"))

  (dap-register-debug-template "Python :: Run file (buffer)"
                               (list :type "python"
                                     :args ""
                                     :cwd nil
                                     :module nil 
                                     :program nil
                                     :request "launch"
                                     :name "Python :: Run file (buffer)"))

  (dap-register-debug-template "Python :: Run pytest (buffer)"
                               (list :type "python"
                                     :args ""
                                     :cwd nil
                                     :program nil
                                     :module "pytest"
                                     :request "launch"
                                     :name "Python :: Run pytest (buffer)")))

;;; ------------------------------------------------------------------------
(require 'swiper)

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
;;       ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :custom     (ivy-use-virtual-buffers t)
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :after ivy
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("C-M-j" . 'counsel-switch-buffer)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :config
  (counsel-mode 1))

(use-package ivy-prescient
  :after counsel
  :custom
  (ivy-prescient-enable-filtering nil)
  :config
  ;; Uncomment the following line to have sorting remembered across sessions!
  ;; (prescient-persist-mode 1)
  (ivy-prescient-mode 1))

(use-package ivy-yasnippet)

(use-package tree-sitter-langs)
(use-package tree-sitter
   :after (lsp-mode)
   :config
   ;; Activate tree-sitter globally (minor mode registered on every buffer)
   (global-tree-sitter-mode)
   :hook
   (tree-sitter-after-on . tree-sitter-hl-mode)
   (typescript-mode . lsp-deferred)
   (javascript-mode . lsp-deferred))

;;; -----------------------------------------------------------------

(defun code-compile ()
"Look for a Makefile and compiles the code with gcc/cpp."
(interactive)
(unless (file-exists-p "Makefile")
  (set (make-local-variable 'compile-command)
       (let ((file (file-name-nondirectory buffer-file-name)))
         (format "%s -o %s %s"
                 (if  (equal (file-name-extension file) "cpp") "g++" "gcc" )
                 (file-name-sans-extension file)
                 file)))
  (compile compile-command)))

(global-set-key [f9] 'code-compile)

;;; -----------------------------------------------------------------

(use-package flycheck
  :ensure t
  :config
  (global-flycheck-mode))

(require 'flycheck-package)

(eval-after-load 'flycheck-package
  '(flycheck-package-setup))

(defun mrf/check_fly ()
  "Force the check of the current python file being saved."
  (when (eq major-mode 'python-mode) ;; Python Only
    (flycheck-mode 0)
    (flycheck-mode t)))

(add-hook 'before-save-hook #'mrf/check_fly)

;;; ------------------------------------------------------------------------
(message "Initializing Python mode...")
(message "Make sure the following Python packages are installed for the best experience:")
(message "    python-lsp-server[all]")
(message "    debnugpy")
(message "    singleton-decorator") ;; Needed for several projects

(defun mrf/load-python-file-hook ()
   (message "Running python file Hook")
   (python-mode)
   (dap-mode)
   (display-fill-column-indicator-mode -1)
   (highlight-indentation-mode -1))

(use-package python-mode
   :ensure nil
   :after (lsp-mode dap-mode)
   :hook (python-mode . lsp-mode)
   :config
   ;; (eglot-ensure)
   (dap-tooltip 1)
   (toolit-mode 1)
   (dap-ui-controls-mode 1))

(add-to-list 'auto-mode-alist '("\\.py\\'" . mrf/load-python-file-hook))
(use-package blacken) ;Format Python file upon save.

;;; ------------------------------------------------------------------------
 (use-package elpy
  :ensure t
  :config
  (elpy-enable)
  (highlight-indentation-mode 0))

 ;; Enable Flycheck
(when (require 'flycheck nil t)
   (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
   (add-hook 'elpy-mode-hook 'flycheck-mode))

(use-package realgud
   :disabled
   :ensure t) ;; Keep this around but right now we use DAP

(use-package py-autopep8
 :ensure t
 :config
 (add-hook 'python-mode-hook 'py-autopep8-mode))

(defun mrf/end-debug-session ()
   "End the debug session and delete project Python buffers."
   (interactive)
   (kill-matching-buffers "\*Python :: Run file [from|\(buffer]*" nil :NO-ASK)
   (kill-matching-buffers "\*Python: Current File*" nil :NO-ASK)
   (dap-disconnect (dap--cur-session)))

;;; -----------------------------------------------------------------
(if (package-installed-p 'dap-mode)
  (general-def python-mode-map
     "C-c . /"       'dap-step-in
     "C-c . <right>" 'dap-step-in
     "C-c . ,"       'dap-step-out
     "C-c . <left>"    'dap-step-out
     "C-c . ."       'dap-next
     "C-c . <down>"  'dap-next
     "C-c . ?" 'dap-breakpoint-condition
     "C-c . C-b" 'dap-ui-breakpoints
     "C-c . C-b" 'dap-ui-breakpoints
     "C-c . C-c" 'dap-ui-controls-mode
     "C-c . C-e" 'dap-ui-expressions
     "C-c . C-l" 'dap-ui-locals
     "C-c . C-r" 'dap-ui-repl
     "C-c . b" 'dap-breakpoint-toggle
     "C-c . c" 'dap-continue
     "C-c . d" 'dap-debug
     "C-c . C-d" 'dap-debug-last
     "C-c . i" 'dap-step-in
     "C-c . n" 'dap-next
     "C-c . o" 'dap-step-out
     "C-c . r" 'dap-debug-restart
     "C-c . t" 'dap-breakpoint-toggle
     "C-c . x" 'mrf/end-debug-session
     "C-c . C-x" 'dap-delete-session
     "C-c }" 'indent-region))

;;; =========================================================================
(if (package-installed-p 'realgud)
   (general-def python-mode-map
      "M-p" 'python-nav-backward-defun
      "M-n" 'python-nav-forward-defun
      "C-c p" 'elpy-goto-definition
      "C-c h" 'elpy-doc
      "C-c , j" 'realgud:cmd-jump
      "C-c , k" 'realgud:cmd-kill
      "C-c , s" 'realgud:cmd-step
      "C-c , n" 'realgud:cmd-next
      "C-c , q" 'realgud:cmd-quit
      "C-c , F" 'realgud:window-bt
      "C-c , U" 'realgud:cmd-until
      "C-c , X" 'realgud:cmd-clear
      "C-c , !" 'realgud:cmd-shell
      "C-c , b" 'realgud:cmd-break
      "C-c , f" 'realgud:cmd-finish
      "C-c , D" 'realgud:cmd-delete
      "C-c , +" 'realgud:cmd-enable
      "C-c , R" 'realgud:cmd-restart
      "C-c , -" 'realgud:cmd-disable
      "C-c , B" 'realgud:window-brkpt
      "C-c , c" 'realgud:cmd-continue
      "C-c , e" 'realgud:cmd-eval-dwim
      "C-c , Q" 'realgud:cmd-terminate
      "C-c , T" 'realgud:cmd-backtrace
      "C-c , h" 'realgud:cmd-until-here
      "C-c , u" 'realgud:cmd-older-frame
      "C-c , 4" 'realgud:cmd-goto-loc-hist-4
      "C-c , 5" 'realgud:cmd-goto-loc-hist-5
      "C-c , 6" 'realgud:cmd-goto-loc-hist-6
      "C-c , 7" 'realgud:cmd-goto-loc-hist-7
      "C-c , 8" 'realgud:cmd-goto-loc-hist-8
      "C-c , 9" 'realgud:cmd-goto-loc-hist-9
      "C-c , d" 'realgud:cmd-newer-frame
      "C-c , RET" 'realgud:cmd-repeat-last
      "C-c , E" 'realgud:cmd-eval-at-point
      "C-c , I" 'realgud:cmdbuf-info-describe
      "C-c , C-d" 'realgud:pdb
      "C-c , C-f" 'realgud:flake8-goto-msg-line
      "C-c , C-i" 'realgud:cmd-info-breakpoints))

;;; ------------------------------------------------------------------------
(use-package pyvenv-auto
   :config (message "Starting pyvenv-auto")
   :hook ((python-mode . pyvenv-auto-run)))

;;; ------------------------------------------------------------------------
(use-package company
   :after lsp-mode
   :hook (lsp-mode . company-mode)
   :bind (:map company-active-map
            ("<tab>" . company-complete-selection))
   (:map lsp-mode-map
      ("<tab>" . company-indent-or-complete-common))
   :custom
   (company-minimum-prefix-length 1)
   (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package company-jedi
   :config
   (defun my/company-jedi-python-mode-hook ()
      (add-to-list 'company-backends 'company-jedi))
   (add-hook 'python-mode-hook 'my/company-jedi-python-mode-hook))

(add-hook 'prog-mode-hook 'company-mode)

;;; ------------------------------------------------------------------------

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/Developer")
    (setq projectile-project-search-path '("~/Developer")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :after projectile
  :config (counsel-projectile-mode))

;;; ------------------------------------------------------------------------

(use-package magit
  :commands magit-status
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
(use-package forge
  :after magit)

;;; ------------------------------------------------------------------------

(defun mrf/org-font-setup ()
  "Setup org mode fonts."
  (font-lock-add-keywords
     'org-mode
     '(("^ *\\([-]\\) "
          (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil    :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil    :inherit 'fixed-pitch)
  (set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil     :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil    :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil  :inherit 'fixed-pitch)
  (set-face-attribute 'line-number nil :inherit 'fixed-pitch)
  (set-face-attribute 'line-number-current-line nil :inherit 'fixed-pitch))

;;; -----------------------------------------------------------------

(defun mrf/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(use-package org
  :pin org
  :commands (org-capture org-agenda)
  :hook (org-mode . mrf/org-mode-setup)
  :config
  (setq org-ellipsis " ▾")

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
          (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))

  (setq org-refile-targets
        '(("Archive.org" :maxlevel . 1)
          ("Tasks.org" :maxlevel . 1)))

  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-tag-alist
        '((:startgroup)
                                        ; Put mutually exclusive tags here
          (:endgroup)
          ("@errand" . ?E)
          ("@home" . ?H)
          ("@work" . ?W)
          ("agenda" . ?a)
          ("planning" . ?p)
          ("publish" . ?P)
          ("batch" . ?b)
          ("note" . ?n)
          ("idea" . ?i)))

  ;; Configure custom agenda views
  (setq org-agenda-custom-commands
        '(("d" "Dashboard"
           ((agenda "" ((org-deadline-warning-days 7)))
            (todo "NEXT"
                  ((org-agenda-overriding-header "Next Tasks")))
            (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

          ("n" "Next Tasks"
           ((todo "NEXT"
                  ((org-agenda-overriding-header "Next Tasks")))))

          ("W" "Work Tasks" tags-todo "+work-email")

          ;; Low-effort next actions
          ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
           ((org-agenda-overriding-header "Low Effort Tasks")
            (org-agenda-max-todos 20)
            (org-agenda-files org-agenda-files)))

          ("w" "Workflow Status"
           ((todo "WAIT"
                  ((org-agenda-overriding-header "Waiting on External")
                   (org-agenda-files org-agenda-files)))
            (todo "REVIEW"
                  ((org-agenda-overriding-header "In Review")
                   (org-agenda-files org-agenda-files)))
            (todo "PLAN"
                  ((org-agenda-overriding-header "In Planning")
                   (org-agenda-todo-list-sublevels nil)
                   (org-agenda-files org-agenda-files)))
            (todo "BACKLOG"
                  ((org-agenda-overriding-header "Project Backlog")
                   (org-agenda-todo-list-sublevels nil)
                   (org-agenda-files org-agenda-files)))
            (todo "READY"
                  ((org-agenda-overriding-header "Ready for Work")
                   (org-agenda-files org-agenda-files)))
            (todo "ACTIVE"
                  ((org-agenda-overriding-header "Active Projects")
                   (org-agenda-files org-agenda-files)))
            (todo "COMPLETED"
                  ((org-agenda-overriding-header "Completed Projects")
                   (org-agenda-files org-agenda-files)))
            (todo "CANC"
                  ((org-agenda-overriding-header "Cancelled Projects")
                   (org-agenda-files org-agenda-files)))))))

  (setq org-capture-templates
        `(("t" "Tasks / Projects")
          ("tt" "Task" entry (file+olp "~/Projects/Code/emacs-from-scratch/OrgFiles/Tasks.org" "Inbox")
           "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

          ("j" "Journal Entries")
          ("jj" "Journal" entry
           (file+olp+datetree "~/Projects/Code/emacs-from-scratch/OrgFiles/Journal.org")
           "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
           ;; ,(dw/read-file-as-string "~/Notes/Templates/Daily.org")
           :clock-in :clock-resume
           :empty-lines 1)
          ("jm" "Meeting" entry
           (file+olp+datetree "~/Projects/Code/emacs-from-scratch/OrgFiles/Journal.org")
           "* %<%I:%M %p> - %a :meetings:\n\n%?\n\n"
           :clock-in :clock-resume
           :empty-lines 1)

          ("w" "Workflows")
          ("we" "Checking Email" entry (file+olp+datetree "~/Projects/Code/emacs-from-scratch/OrgFiles/Journal.org")
           "* Checking Email :email:\n\n%?" :clock-in :clock-resume :empty-lines 1)

          ("m" "Metrics Capture")
          ("mw" "Weight" table-line (file+headline "~/Projects/Code/emacs-from-scratch/OrgFiles/Metrics.org" "Weight")
           "| %U | %^{Weight} | %^{Notes} |" :kill-buffer t)))

   (define-key global-map (kbd "C-c j")
      (lambda () (interactive) (org-capture nil "jj")))

   (mrf/org-font-setup))

;;; -----------------------------------------------------------------

(use-package org-bullets
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

;;; -----------------------------------------------------------------

(defun mrf/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . mrf/org-mode-visual-fill))

;;; -----------------------------------------------------------------

(with-eval-after-load 'org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)))

  (push '("conf-unix" . conf-unix) org-src-lang-modes))

;;; -----------------------------------------------------------------

(with-eval-after-load 'org
  ;; This is needed as of Org 9.2
  (require 'org-tempo)

  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python")))

;;; ----------------------------------------------------------------
(use-package org-roam
  :ensure t
  :demand t  ;; Ensure org-roam is loaded by default
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory (concat mrf/docs-dir "/RoamNotes"))
  (org-roam-completion-everywhere t)
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n I" . org-roam-node-insert-immediate)
         ("C-c n p" . my/org-roam-find-project)
         ("C-c n t" . my/org-roam-capture-task)
         ("C-c n b" . my/org-roam-capture-inbox)
         :map org-mode-map
         ("C-M-i" . completion-at-point)
         :map org-roam-dailies-map
         ("Y" . org-roam-dailies-capture-yesterday)
         ("T" . org-roam-dailies-capture-tomorrow))
  :bind-keymap
  ("C-c n d" . org-roam-dailies-map)
  :config
  (require 'org-roam-dailies) ;; Ensure the keymap is available
  (org-roam-db-autosync-mode))

(defun org-roam-node-insert-immediate (arg &rest args)
   (interactive "P")
   (let ((args (push arg args))
           (org-roam-capture-templates
              (list (append (car org-roam-capture-templates)
                       '(:immediate-finish t)))))
    (apply #'org-roam-node-insert args)))

(defun my/org-roam-project-finalize-hook ()
   "Adds the captured project file to `org-agenda-files' if the
capture was not aborted."
   ;; Remove the hook since it was added temporarily
   (remove-hook 'org-capture-after-finalize-hook #'my/org-roam-project-finalize-hook)

   ;; Add project file to the agenda list if the capture was confirmed
   (unless org-note-abort
    (with-current-buffer (org-capture-get :buffer)
      (add-to-list 'org-agenda-files (buffer-file-name)))))

(defun my/org-roam-find-project ()
   (interactive)
  ;; Add the project file to the agenda after capture is finished
   (add-hook 'org-capture-after-finalize-hook #'my/org-roam-project-finalize-hook)

  ;; Select a project file to open, creating it if necessary
   (org-roam-node-find
      nil
      nil
      (my/org-roam-filter-by-tag "Project")
      :templates
      '(("p" "project" plain "* Goals\n\n%?\n\n* Tasks\n\n** TODO Add initial tasks\n\n* Dates\n\n"
           :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+category: ${title}\n#+filetags: Project")
           :unnarrowed t))))

(global-set-key (kbd "C-c n p") #'my/org-roam-find-project)

(defun my/org-roam-capture-inbox ()
   (interactive)
   (org-roam-capture- :node (org-roam-node-create)
      :templates '(("i" "inbox" plain "* %?"
                      :if-new (file+head "Inbox.org" "#+title: Inbox\n")))))

(defun my/org-roam-capture-task ()
  (interactive)
  ;; Add the project file to the agenda after capture is finished
  (add-hook 'org-capture-after-finalize-hook #'my/org-roam-project-finalize-hook)

  ;; Capture the new task, creating the project file if necessary
   (org-roam-capture- :node (org-roam-node-read nil
                            (my/org-roam-filter-by-tag "Project"))
      :templates '(("p" "project" plain "** TODO %?"
                      :if-new
                      (file+head+olp "%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n#+category: ${title}\n#+filetags: Project"
                         ("Tasks"))))))

(defun my/org-roam-copy-todo-to-today ()
   (interactive)
   (let ((org-refile-keep t) ;; Set this to nil to delete the original!
           (org-roam-dailies-capture-templates
              '(("t" "tasks" entry "%?"
                   :if-new (file+head+olp "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n" ("Tasks")))))
           (org-after-refile-insert-hook #'save-buffer)
           today-file pos)
      (save-window-excursion
         (org-roam-dailies--capture (current-time) t)
         (setq today-file (buffer-file-name))
         (setq pos (point)))

      ;; Only refile if the target file is different than the current file
      (unless (equal (file-truename today-file)
                 (file-truename (buffer-file-name)))
         (org-refile nil nil (list "Tasks" today-file nil pos)))))

(add-to-list 'org-after-todo-state-change-hook
   (lambda ()
      (when (equal org-state "DONE")
         (my/org-roam-copy-todo-to-today))))

;; Automatically tangle our Emacs.org config file when we save it
(defun mrf/org-babel-tangle-save-hook ()
   "Save emacs-lisp blocks."
  (when (eq major-mode 'org-mode) ;; Org-mode Only
     (message "org-mode-hook: Executing mrf/org-babel-tangle-config")
     (when (string-equal (file-name-directory (buffer-file-name))
              (expand-file-name emacs-config-directory))
        ;; Dynamic scoping to the rescue
        (let ((org-confirm-babel-evaluate nil))
           (message "... tangle emacs-lisp")
           (org-babel-tangle)))))

(add-hook 'after-save-hook #'mrf/org-babel-tangle-save-hook)

;;; ------------------------------------------------------------------------

(use-package ace-window
   :config
   (general-define-key
      "M-o" 'ace-window))

;;; ------------------------------------------------------------------------
(use-package all-the-icons
   :if (display-graphic-p))

;; Value of dashb oard-startup-banner can be
;; - nil to display no banner
;; - 'official which displays the official emacs logo
;; - 'logo which displays an alternative emacs logo
;; - 1, 2 or 3 which displays one of the text banners
;; - "path/to/your/image.gif", "path/to/your/image.png" or "path/to/your/text.txt"
;;   which displays whatever gif/image/text you would prefer
;; - a cons of '("path/to/your/image.png" . "path/to/your/text.txt")
(use-package dashboard
   :after (dired)
   :ensure t
   :preface
   (defun mrf/dashboard-banner ()
      (setq dashboard-footer-messages '("Greetings Program!"))
      (setq dashboard-banner-logo-title "Welcome to Emacs!")
      (setq dashboard-startup-banner 'logo))
   :hook ((after-init     . dashboard-refresh-buffer)
          (dashboard-mode . mrf/dashboard-banner))
   :custom
   (dashboard-items '((recents . 8)
                        (bookmarks . 5)
                        (projects . 5)))
   :config
   (dashboard-setup-startup-hook)
   (dashboard-open)
   (setq dashboard-center-content t)
   (global-set-key (kbd "C-c d") 'dashboard-open))

;;; ------------------------------------------------------------------------

(defvar ac-directory (unless (file-exists-p "auto-complete")
                     (make-directory "auto-complete")))
(add-to-list 'load-path ac-directory)

(require 'auto-complete)
(ac-config-default)

(global-auto-complete-mode 1)
(setq-default ac-sources '(ac-source-pycomplete
                           ac-source-yasnippet
                           ac-source-abbrev
                           ac-source-dictionary
                           ac-source-words-in-same-mode-buffers))

; hack to fix ac-sources after pycomplete.el breaks it
(add-hook 'python-mode-hook
          #'(lambda ()
             (setq ac-sources '(ac-source-pycomplete
                                ac-source-yasnippet
                                ac-source-abbrev
                                ac-source-dictionary
                                ac-source-words-in-same-mode-buffers))))

;; from http://truongtx.me/2013/01/06/config-yasnippet-and-autocomplete-on-emacs/
; set the trigger key so that it can work together with yasnippet on
; tab key, if the word exists in yasnippet, pressing tab will cause
; yasnippet to activate, otherwise, auto-complete will
(ac-set-trigger-key "TAB")
(ac-set-trigger-key "<tab>")


;; from http://blog.deadpansincerity.com/2011/05/setting-up-emacs-as-a-javascript-editing-environment-for-fun-and-profit/
; Start auto-completion after 2 characters of a word
(setq ac-auto-start 2)
; case sensitivity is important when finding matches
(setq ac-ignore-case nil)

;;; ------------------------------------------------------------------------

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

;;; ------------------------------------------------------------------------
(use-package term
  :commands term
  :config
  (setq explicit-shell-file-name "bash") ;; Change this to zsh, etc
  ;;(setq explicit-zsh-args '())         ;; Use 'explicit-<shell>-args for shell-specific args

  ;; Match the default Bash shell prompt.  Update this if you have a custom prompt
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *"))

;;; ------------------------------------------------------------------------
(use-package eterm-256color
  :hook (term-mode . eterm-256color-mode))

;;; ------------------------------------------------------------------------
(use-package vterm
  :commands vterm
  :config
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")  ;; Set this to match your custom shell prompt
  ;;(setq vterm-shell "zsh")                       ;; Set this to customize the shell to launch
  (setq vterm-max-scrollback 10000))

;;; ------------------------------------------------------------------------
(defun efs/configure-eshell ()
  ;; Save command history when commands are entered
  (add-hook 'eshell-pre-command-hook 'eshell-save-some-history)

  ;; Truncate buffer for performance
  (add-to-list 'eshell-output-filter-functions 'eshell-truncate-buffer)

  ;; Bind some useful keys for evil-mode
  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "C-r") 'counsel-esh-history)
  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "<home>") 'eshell-bol)
  (evil-normalize-keymaps)

  (setq eshell-history-size         10000
        eshell-buffer-maximum-lines 10000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t))

(use-package eshell-git-prompt
  :after eshell)

(use-package eshell
  :hook (eshell-first-time-mode . efs/configure-eshell)
  :config

  (with-eval-after-load 'esh-opt
    (setq eshell-destroy-buffer-when-process-dies t)
    (setq eshell-visual-commands '("htop" "zsh" "vim")))

  (eshell-git-prompt-use-theme 'powerline))

;;; ------------------------------------------------------------------------
(use-package neotree
   :ensure t
   :config
   (global-set-key [f8] 'neotree-toggle))

;;; ------------------------------------------------------------------------
(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

;;; ------------------------------------------------------------------------
;; Prefer g-prefixed coreutils version of standard utilities when available
(let ((gls (executable-find "gls")))
  (when gls (setq insert-directory-program gls)))

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom
   ((dired-listing-switches "-agho --group-directories-first"))
   (dired-dwim-target t))
  ;; :config
  ;; (evil-collection-define-key 'normal 'dired-mode-map
  ;;   "h" 'dired-single-up-directory
  ;;   "l" 'dired-single-buffer))

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-open
  :commands (dired dired-jump)
  :config
  ;; Doesn't work as expected!
  ;;(add-to-list 'dired-open-functions #'dired-open-xdg t)
  (setq dired-open-extensions '(("png" . "feh")
                                ("mkv" . "mpv"))))

(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode))
  ;; :config
  ;; (evil-collection-define-key 'normal 'dired-mode-map
  ;;   "H" 'dired-hide-dotfiles-mode))

;;; ------------------------------------------------------------------------


  (defun mrf/dired-single-keymap-init ()
    "Bunch of stuff to run for dired, either immediately or when it's
     loaded."
    (define-key dired-mode-map
       [remap dired-find-file] 'dired-single-buffer)
    (define-key dired-mode-map
       [remap dired-mouse-find-file-other-window] 'dired-single-buffer-mouse)
    (define-key dired-mode-map
       [remap dired-up-directory] 'dired-single-up-directory))

  (use-package dired-single
     :config
     (mrf/dired-single-keymap-init))
;;    (general-def dired-mode-map
;;       "C-<return>" 'dired-single-magic-buffer
;;       [remap dired-find-file] 'dired-single-buffer
;;       [remap dired-mouse-find-file-other-window] 'dired-single-buffer-mouse
;;       [remap dired-up-directory] 'dired-single-up-directory))

;;; ------------------------------------------------------------------------

;; Line #'s appear everywhere
;; ... except for when in these modes
(dolist (mode '(dashboard-mode-hook
                  eshell-mode-hook
                  eww-mode-hook
                  org-mode-hook
                  shell-mode-hook
                  term-mode-hook
                  term-mode-hook
                  treemacs-mode-hook
                  vterm-mode-hook))
   (add-hook mode (lambda () (display-line-numbers-mode 0))))


  ;;; ===========================================================================
(setq warning-suppress-types '((package reinitialization)
                                 (package-initialize)
                                 (package)
                                 (use-package)
                                 (python-mode)))

(defvar mrf/font-size-slot 1)

(defun mrf/update-font-size ()
   (message "adjusting font size")
   (if (equal mrf/font-size-slot 2)
      (progn
         (message "Large Font")
         (setq mrf/default-font-size 200)
         (setq mrf/default-variable-font-size 200)
         (setq mrf/font-size-slot 1)
         (mrf/update-face-attribute))
      (if (equal mrf/font-size-slot 1)
         (progn
            (message "Medium Font")
            (setq mrf/default-font-size 175)
            (setq mrf/default-variable-font-size 175)
            (setq mrf/font-size-slot 0)
            (mrf/update-face-attribute))
         (progn
            (message "Small Font")
            (setq mrf/default-font-size 150)
            (setq mrf/default-variable-font-size 150)
            (setq mrf/font-size-slot 2)
            (mrf/update-face-attribute)))))

(general-define-key
   "C-c x" '(lambda () (interactive) (mrf/update-font-size)))

;; Some alternate keys below....
(general-define-key
   "C-c 1" '(lambda ()
               (interactive)
               (setq mrf/font-size-slot 0)
               (mrf/update-font-size)))

(general-define-key
   "C-c 2" '(lambda ()
               (interactive)
               (setq mrf/font-size-slot 1)
               (mrf/update-font-size)))

(general-define-key
   "C-c 3" '(lambda ()
               (interactive)
               (setq mrf/font-size-slot 2)
               (mrf/update-font-size)))

;;; ===========================================================================
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
     '(ace-window dap-python yasnippet-snippets winum which-key vterm visual-fill-column typescript-mode treemacs-tab-bar treemacs-projectile treemacs-persp treemacs-magit treemacs-icons-dired treemacs-evil tree-sitter-langs timu-macos-theme timu-caribbean-theme realgud rainbow-delimiters pyvenv-auto python-mode py-autopep8 org-roam org-bullets neotree modus-themes material-theme lsp-ui lsp-ivy ivy-yasnippet ivy-rich ivy-prescient immaterial-theme helpful general forge flycheck exotica-theme evil-nerd-commenter eterm-256color eshell-git-prompt elpy eglot doom-themes doom-modeline dired-single dired-open dired-hide-dotfiles dashboard dap-mode counsel-projectile company-jedi company-box color-theme-sanityinc-tomorrow blacken bind-key better-defaults avy auto-package-update auto-complete all-the-icons-dired))
 '(warning-suppress-log-types
     '(((package reinitialization))
	 (use-package)
	 (python-mode)
	 (package-initialize))))

  ;;; init.el ends here.
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;  (dashboard-open)
