;; init.el --- My customized emacs init file -- lexical-binding: t --
;;

;;; ==========================================================================
(setq
   ;; ------------ Primary feature enabling switches ------------
   enable-dap 0                          ;; Debug Adapter Protocol
   enable-dap-js 0                       ;; DAP JavaScript support
   enable-dape t                         ;; DAP for Emacs.
   enable-corfu 0                        ;; Alternative to Ivy/Swiper/Company
   enable-org-ai 0                       ;; Interface to OpenAI
   enable-centaur-tabs 0                 ;; Top Tabs for files
   enable-neotree 0                      ;; Load Neotree
   enable-zoom 0                         ;; Re-size active frame to
                                         ;;   golden ratio
   enable-anaconda 0                     ;; Use Anaconda for python Dev
                                         ;;   Environment
   ;; !!!! Use Anaconda or Elpy but NOT BOTH !!!!
   enable-elpy t                         ;; Use Elpy as the Python Dev
                                         ;;   Environment
   )

;;; init.el --- emacs main initializationfile
;;; Commentary:
;;;    Generated from Config.org  
;;; Code:
;;;
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
       (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(setq straight-use-package-by-default t
      use-package-verbose t)
(straight-use-package 'use-package)

;; (setq use-package-compute-statistics t
;;    use-package-verbose t
;;    use-package-always-defer t)

(use-package el-patch)

;; Load org early on in the init process
(straight-use-package 'org)
(require 'org-faces)

(setq-default
   ;; enable smooth scrolling.
   pixel-scroll-mode t
   ;; try to guess target directory
   dired-dwim-target t
   ;; truncate lines even in partial-width windows
   truncate-partial-width-windows 1
   ;; disable auto save
   auto-save-default nil
   ;; disable backup (No ~ tilde files)
   backup-inhibited t
   ;; Refresh buffer if file has changed
   global-auto-revert-mode 1
   global-auto-revert-non-file-buffers t
   ;; Reasonable buffer length
   history-length 25
   ;; Hide the startup message
   inhibit-startup-message t
   ;; emacs lisp tab size
   lisp-indent-offset '3
   ;; Set up the visible bell
   visible-bell t
   ;; long lines of text do not wrap
   truncate-lines 1
   ;; Default line limit for fills
   fill-column 80
   ;; The text representation of the loaded custom theme 
   loaded-theme nil
   ;; The index into the list of custom themes."
   theme-selector 0
   ;; Used as root dir to specify where documents can be stored
   mrf/docs-dir "~/Documents/Emacs-Related"
   ;; Needed to fix an issue on Mac which causes dired to fail
   dired-listing-switches "-agho --group-directories-first"
   )

(global-display-line-numbers-mode 1) ;; Line numbers appear everywhere
(save-place-mode 1)                  ;; Remember where we were last editing a file.
(savehist-mode t)
(show-paren-mode 1)
(tool-bar-mode -1)                   ;; Hide the toolbar
(global-prettify-symbols-mode 1)     ;; Display pretty symbols (i.e. λ = lambda)

;;; ==========================================================================
;;; Set a variable that represents the actual emacs configuration directory.
;;; This is being done so that the user-emacs-directory which normally points
;;; to the .emacs.d directory can be re-assigned so that customized files don't
;;; pollute the configuration directory. This is where things like YASnippet
;;; snippets are saved and also additional color themese are stored.

(defvar emacs-config-directory user-emacs-directory)

;;; The config directory contains the extension part of the actual config
;;; directory. So ~/.emacs.d.mitchorg becomes mitchorg
(setq mrf/config-extension
   (file-name-extension (replace-regexp-in-string
  			 "/$" "" user-emacs-directory)))

;;; Different emacs configuration installs with have their own configuration
;;; directory.
(setq mrf/working-files-directory
   (concat mrf/docs-dir (concat "/emacs-working-files_" mrf/config-extension)))
(make-directory mrf/working-files-directory t)  ;; Continues to work even if dir exists

;;; Point the user-emacs-directory to the new working directory
(setq user-emacs-directory mrf/working-files-directory)
(message (concat ">>> Setting emacs-working-files directory to: " user-emacs-directory))

;;; Put any emacs cusomized variables in a special file
(setq custom-file (concat mrf/docs-dir "/custom-vars-org.el"))
(load custom-file 'noerror 'nomessage)

;;; ==========================================================================

;;
;; 1. The function `mrf/load-theme-from-selector' is called from the
;;    "C-= =" Keybinding (just search for it).
;;
;; 2. Once the new theme is loaded via the `theme-selector', the previous
;;    theme is unloaded (or disabled) the function(s) defined in the
;;    `disable-theme-functions' hook are called (defined in the load-theme.el
;;    package).
;;
;; 3. The function `mrf/cycle-theme-selector' is called by the hook. This
;;    function increments the theme-selector by 1, cycling the value to 0
;;    if beyond the `theme-list' bounds.
;;

;; The list of my custom choice of themes.
(defcustom theme-list '(palenight-deeper-blue
  		      ef-symbiosis
  		      ef-maris-light
  		      ef-maris-dark
  		      ef-kassio
  		      ef-melissa-dark
  		      doom-palenight
  		      deeper-blue)
   "My personal list of themes to cycle through. Indexed by `theme-selector'."
   :type '(repeat string))

(setq-default loaded-theme (nth theme-selector theme-list))
(add-to-list 'savehist-additional-variables 'loaded-theme)
(add-to-list 'savehist-additional-variables 'theme-selector)

;;; ==========================================================================

(defun mrf/cycle-theme-selector (&rest theme)
   "Cycle the `theme-selector' by 1, resetting to 0 if beyond array bounds."
   (interactive)
   (unless (equal (format "%S" theme) "(user)")
      (if (>= theme-selector (- (length theme-list) 1))
       (setq theme-selector 0)
       (setq theme-selector (+ 1 theme-selector)))
     )
   )

;; This is used to trigger the cycling of the theme-selector
;; It is called when a theme is disabled. The theme is disabled from the
;; `mrf/load-theme-from-selector' function.
(add-hook 'disable-theme-functions #'mrf/cycle-theme-selector)

;;; ==========================================================================

(defun mrf/load-theme-from-selector ()
   "Load the theme in `theme-list' indexed by `theme-selector'"
   (interactive)
   (when loaded-theme
      (disable-theme loaded-theme))
   (setq loaded-theme (nth theme-selector theme-list))
   (message (concat ">>> Loading theme " (format "%d: %S" theme-selector loaded-theme)))
   (load-theme loaded-theme t)
   (if (equal (fboundp 'mrf/org-font-setup) t)
      (mrf/org-font-setup))
   )

;;; ==========================================================================

;; Use shell path

(defun set-exec-path-from-shell-PATH ()
   ;;; Set up Emacs' `exec-path' and PATH environment variable to match"
   ;;; that used by the user's shell.
   ;;; This is particularly useful under Mac OS X and macOS, where GUI
   ;;; apps are not started from a shell."
   (interactive)
   (let ((path-from-shell (replace-regexp-in-string "[ \t\n]*$" ""
                             (shell-command-to-string "$SHELL --login -c 'echo $PATH'"))))
      (setenv "PATH" path-from-shell)
      (setq exec-path (split-string path-from-shell path-separator))))

;;; ==========================================================================

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;;; ==========================================================================

;; Frame (view) setup including fonts.
;; You will most likely need to adjust this font size for your system!

(setq-default mrf/small-font-size 150)
(setq-default mrf/small-variable-font-size 170)

(setq-default mrf/medium-font-size 170)
(setq-default mrf/medium-variable-font-size 190)

(setq-default mrf/large-font-size 190)
(setq-default mrf/large-variable-font-size 210)

(setq-default mrf/x-large-font-size 220)
(setq-default mrf/x-large-variable-font-size 240)

(setq-default mrf/default-font-size mrf/medium-font-size)
(setq-default mrf/default-variable-font-size mrf/medium-variable-font-size)
;; (setq-default mrf/set-frame-maximized t)  ;; or f

;; Make frame transparency overridable
;; (setq-default mrf/frame-transparency '(90 . 90))

(setq frame-resize-pixelwise t)

;;; ==========================================================================

;; Functions to set the frame size

(defun mrf/frame-recenter (&optional frame)
   "Center FRAME on the screen.  FRAME can be a frame name, a terminal name,
  or a frame.  If FRAME is omitted or nil, use currently selected frame."
   (interactive)
   ;; (set-frame-size (selected-frame) 250 120)
   (unless (eq 'maximised (frame-parameter nil 'fullscreen))
      (progn
       (let ((width (nth 3 (assq 'geometry (car (display-monitor-attributes-list)))))
  	       (height (nth 4 (assq 'geometry (car (display-monitor-attributes-list))))))
  	  (cond (( > width 3000) (mrf/update-large-display))
  	        (( > width 2000) (mrf/update-built-in-display))
  	        (t (mrf/set-frame-alpha-maximized)))
  	  )
       )
      )
   )

(defun mrf/update-large-display ()
   (modify-frame-parameters
      frame '((user-position . t)
  	      (top . 0.0)
  	      (left . 0.70)
  	      (width . (text-pixels . 2800))
  	      (height . (text-pixels . 1650))) ;; 1800
      )
   )

(defun mrf/update-built-in-display ()
   (modify-frame-parameters
      frame '((user-position . t)
  	      (top . 0.0)
  	      (left . 0.90)
  	      (width . (text-pixels . 1800))
  	      (height . (text-pixels . 1170)));; 1329
      )
   )


;; Set frame transparency
(defun mrf/set-frame-alpha-maximized ()
   "Function to set the alpha and also maximize the frame."
   ;; (set-frame-parameter (selected-frame) 'alpha mrf/frame-transparency)
   (set-frame-parameter (selected-frame) 'fullscreen 'maximized)
   (add-to-list 'default-frame-alist '(fullscreen . maximized)))

;; default window width and height
(defun mrf/custom-set-frame-size ()
   "Simple function to set the default frame width/height."
   ;; (set-frame-parameter (selected-frame) 'alpha mrf/frame-transparency)
   (setq swidth (nth 3 (assq 'geometry (car (display-monitor-attributes-list)))))
   (setq sheight (nth 4 (assq 'geometry (car (display-monitor-attributes-list)))))

   (add-to-list 'default-frame-alist '(fullscreen . maximized))
   (mrf/frame-recenter)
   )

;;; ==========================================================================

;; Default fonts

(defun mrf/update-face-attribute ()
   ;; ====================================
   ;; Set the font faces
   ;; ====================================
   (set-face-attribute 'default nil
      ;; :font "Hack"
      ;; :font "Fira Code Retina"
      ;; :font "Menlo"
      :family "SF Mono"
      :height mrf/default-font-size
      :weight 'medium)

   ;; Set the fixed pitch face
   (set-face-attribute 'fixed-pitch nil
      ;; :font "Lantinghei TC Demibold"
      :family "SF Mono"
      ;; :font "Fira Code Retina"
      :height mrf/default-font-size
      :weight 'medium)

   ;; Set the variable pitch face
   (set-face-attribute 'variable-pitch nil
      :family "SF Pro"
      :height mrf/default-variable-font-size
      :weight 'medium))

(mrf/update-face-attribute)
;; (add-hook 'window-setup-hook #'mrf/frame-recenter)
;; (add-hook 'after-init-hook #'mrf/frame-recenter)
(mrf/frame-recenter)

;;; ==========================================================================

(use-package diminish)

(defun mrf/set-diminish ()
   (diminish 'projectile-mode "PrM")
   (diminish 'anaconda-mode)
   (diminish 'tree-sitter-mode "ts")
   (diminish 'ts-fold-mode)
   (diminish 'counsel-mode)
   (diminish 'company-box-mode)
   (diminish 'company-mode))

;; Need to run late in the startup process
(add-hook 'after-init-hook 'mrf/set-diminish)

;; (use-package pabbrev)

;;; ==========================================================================

(use-package spacious-padding
   :hook (after-init . spacious-padding-mode)
   :custom
   (spacious-padding-widths
      '( :internal-border-width 15
  	:header-line-width 4
  	:mode-line-width 6
  	:tab-width 4
  	:right-divider-width 30
  	:scroll-bar-width 8)))

;; Read the doc string of `spacious-padding-subtle-mode-line' as it
;; is very flexible and provides several examples.
;; (setq spacious-padding-subtle-mode-line
;;       `( :mode-line-active 'default
;;          :mode-line-inactive vertical-border))

;;; ==========================================================================

(column-number-mode)

(use-package page-break-lines
   :config
   (global-page-break-lines-mode))

(use-package rainbow-delimiters
  :config
  (rainbow-delimiters-mode))

;;; ==========================================================================

;; Macintosh specific configurations.

(defconst *is-a-mac* (eq system-type 'darwin))
(when (eq system-type 'darwin)
   (setq mac-option-key-is-meta nil
         mac-command-key-is-meta t
         mac-command-modifier 'meta
         mac-option-modifier 'super))

;;; ==========================================================================

;; Prompt indicator/Minibuffer

(use-package emacs
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t))

;;; ==========================================================================

;; General Keybinding

(use-package general)

(general-def prog-mode-map
   "C-c ]"  'indent-region
   "C-c }"  'indent-region)

(general-define-key
   "C-x C-j" 'dired-jump)

(use-package evil-nerd-commenter
   :bind ("M-/" . evilnc-comment-or-uncomment-lines))

;;
;; Ctl-mouse to adjust/scale fonts will be disabled.
;; I personally like this since it was all to easy to accidentally
;; change the size of the font.
;;
(global-unset-key (kbd "C-<mouse-4>"))
(global-unset-key (kbd "C-<mouse-5>"))
(global-unset-key (kbd "C-<wheel-down>"))
(global-unset-key (kbd "C-<wheel-up>"))

;;; ==========================================================================

(add-to-list 'custom-theme-load-path (concat mrf/docs-dir "/Themes/"))
(add-to-list 'custom-theme-load-path (concat emacs-config-directory "/lisp/"))

(use-package ef-themes)

(use-package modus-themes)

(use-package color-theme-modern
   :defer t)

(use-package material-theme
   :defer t)

(use-package moe-theme
   :defer t)

(use-package zenburn-theme
    :defer t)

(use-package doom-themes
   :defer t)

(use-package kaolin-themes
   :defer t)
;;    :straight (kaolin-themes
;; 		:type git
;; 		:flavor melpa
;; 		:files (:defaults "themes/*.el" "kaolin-themes-pkg.el")
;; 		:host github
;; 		:repo "ogdenwebb/emacs-kaolin-themes"))

;; (use-package color-theme-sanityinc-tomorrow
;;    :straight (color-theme-sanityinc-tomorrow
;; 		:type git
;; 		:flavor melpa
;; 		:host github
;; 		:repo "purcell/color-theme-sanityinc-tomorrow"))

(use-package timu-caribbean-theme
   :defer t)

;; (use-package solarized-theme
;;    :ensure nil)

;;; ==========================================================================

;;
;; (load-theme 'doom-badger t)
;; (load-theme 'doom-challenger-deep t)
;; (load-theme 'doom-dark+ t)
;; (load-theme 'doom-feather-dark t)
;; (load-theme 'doom-gruvbox t)
;; (load-theme 'doom-material-dark t)
;; (load-theme 'doom-monokai-classic t)
;; (load-theme 'doom-monokai-machine t)
;; (load-theme 'doom-monokai-octagon t)
;; (load-theme 'doom-monokai-pro t)
;; (load-theme 'doom-monokai-spectrum t)
;; (load-theme 'doom-opera t)
;; (load-theme 'doom-oksolar-dark t)
;; (load-theme 'doom-palenight t)  ;; A1: Include A2 for good combo, in that order
;; (load-theme 'doom-rouge t)
;; (load-theme 'doom-tokyo-night t)
;; (load-theme 'doom-sourcerer t)

;;; ==========================================================================

(defun mrf/customize-modus-theme ()
   (message "Applying modus customization")
   (setq modus-themes-common-palette-overrides
      '((bg-mode-line-active bg-blue-intense)
          (fg-mode-line-active fg-main)
          (border-mode-line-active blue-intense))))

;;
;; (load-theme 'modus-vivendi t)
;; (load-theme 'modus-operandi t)
;; (load-theme 'modus-vivendi-tinted t)
;; (load-theme 'modus-operandi-tinted t)
;; (load-theme 'modus-vivendi-deuteranopia t)
;; (load-theme 'modus-vivendi-tritanopia t)
;; (load-theme 'modus-operandi-tritanopia t)
;; (load-theme 'modus-vivendi-deuteranopia t)
;; (load-theme 'modus-operandi-deuteranopia t)

(add-hook 'after-init-hook 'mrf/customize-modus-theme)

;; (load-theme 'ef-duo-dark :no-confirm)
;; (load-theme 'ef-night :no-confirm)
;; (load-theme 'ef-elea-dark :no-confirm)
;; (load-theme 'ef-deuteranopia-dark :no-confirm)
;; (load-theme 'ef-symbiosis :no-confirm)
;; (load-theme 'ef-maris-dark :no-confirm)

(setq ef-themes-common-palette-overrides
   '(  (bg-mode-line bg-blue-intense)
       (fg-mode-line fg-main)
       (border-mode-line-active blue-intense)))

;; (add-hook 'after-init-hook 'mrf/customize-ef-theme)

;;; ==========================================================================

;;
;; List of favorite themes. Uncomment the one that feels good for the day.
;; -----------------------------------------------------------------------
;; (load-theme 'afternoon t)
;; (load-theme 'borland-blue t)
;; (load-theme 'deep-blue t)
;; (load-theme 'material t)
;; (load-theme 'kaolin-dark t)
;; (load-theme 'sanityinc-tomorrow-eighties t)
;; (load-theme 'timu-caribbean t)
;; (load-theme 'deeper-blue t)   ;; A2: Use A1 before this
;; (load-theme 'cobalt t)       
;; (load-theme 'robin-hood t)
;; (load-theme 'railscast t)
;; (load-theme 'moe-dark t)

;; Zenburn
;; (setq zenburn-override-colors-alist
;;     '(("zenburn-bg+05" . "#282828")
;;       ("zenburn-bg+1"  . "#2F2F2F")
;;       ("zenburn-bg+2"  . "#3F3F3F")
;;       ("zenburn-bg+3"  . "#4F4F4F")))
;; (load-theme 'zenburn t)

;;; ==========================================================================

(defun mrf/print-custom-theme-name ()
   (message (format "Custom theme is %S" loaded-theme)))

(general-define-key
   "C-= =" 'mrf/load-theme-from-selector
   "C-= ?" 'mrf/print-custom-theme-name)

;;; ==========================================================================
(mrf/load-theme-from-selector)

;; For terminal mode we choose Material theme
(unless (display-graphic-p)
   (load-theme 'material t))

;;; ==========================================================================

;; Automatic Package Updates

(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe)
  (auto-package-update-at-time "09:00"))

;;; ==========================================================================

;; YASnippets

(use-package yasnippet
   :straight (yasnippet :type git :flavor melpa
  	      :files ("yasnippet.el" "snippets" "yasnippet-pkg.el")
  	      :host github
  	      :repo "joaotavora/yasnippet")
   :defer t
   :config
   (yas-global-mode t)
   (define-key yas-minor-mode-map (kbd "<tab>") nil)
   (define-key yas-minor-mode-map (kbd "C-'") #'yas-expand)
   (add-to-list #'yas-snippet-dirs (concat mrf/docs-dir "/Snippets"))
   (yas-reload-all)
   (setq yas-prompt-functions '(yas-ido-prompt))
   (defun help/yas-after-exit-snippet-hook-fn ()
      (prettify-symbols-mode)
      (prettify-symbols-mode))
   (add-hook 'yas-after-exit-snippet-hook #'help/yas-after-exit-snippet-hook-fn))

(use-package yasnippet-snippets
   :defer t
   :straight (yasnippet-snippets :type git :flavor melpa
  	      :files ("*.el" "snippets" ".nosearch" "yasnippet-snippets-pkg.el")
  	      :host github
  	      :repo "AndreaCrotti/yasnippet-snippets"))

;;; ==========================================================================

;; Which Key Helper

(use-package which-key
   :defer 0
   :diminish which-key-mode
   :custom (which-key-idle-delay 1)
   :config
   (which-key-mode)
   (which-key-setup-side-window-right))

;;; ==========================================================================

;;; --------------------------------------------------------------------------
;;; Window Number

(use-package winum
   :straight (winum :type git :flavor melpa :host github :repo "deb0ch/emacs-winum"))
(winum-mode)

;;; ==========================================================================

;;; Treemacs

(use-package treemacs
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
          treemacs-persist-file                    (expand-file-name
  						      ".cache/treemacs-persist"
                                                      user-emacs-directory)
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules"
                                                       "/.venv"
                                                       "/.cask"
                                                       "/__pycache__")
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
          treemacs-width                           38
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil
       )

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
       (`(t . t)
  	(treemacs-git-mode 'deferred))
       (`(t . _)
  	(treemacs-git-mode 'simple)))
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

;;; ==========================================================================

(use-package treemacs-projectile
  :after (treemacs projectile))

;;; ==========================================================================

(use-package treemacs-magit
  :after (treemacs magit)
   )

;;; ==========================================================================

(use-package treemacs-icons-dired
   :hook (dired-mode . treemacs-icons-dired-enable-once)
   )

;;; ==========================================================================

;; (use-package treemacs-perspective
;;    :disabled
;;    :straight (treemacs-perspective :type git :flavor melpa
;; 		:files ("src/extra/treemacs-perspective.el" "treemacs-perspective-pkg.el")
;; 		:host github :repo "Alexander-Miller/treemacs")
;;    :after (treemacs persp-mode) ;;or perspective vs. persp-mode
;;    :config (treemacs-set-scope-type 'Perspectives))


(use-package treemacs-persp ;;treemacs-perspective if you use perspective.el vs. persp-mode
   :straight (treemacs-persp :type git :flavor melpa
  	      :files ("src/extra/treemacs-persp.el" "treemacs-persp-pkg.el")
  	      :host github :repo "Alexander-Miller/treemacs")
   :after (treemacs persp-mode) ;;or perspective vs. persp-mode
   :config (treemacs-set-scope-type 'Perspectives))

;;; ==========================================================================

(use-package treemacs-tab-bar ;;treemacs-tab-bar if you use tab-bar-mode
  :after (treemacs)
  :config (treemacs-set-scope-type 'Tabs))

;;; ==========================================================================

(use-package treemacs-all-the-icons
 :if (display-graphic-p))

;;; ==========================================================================

;;; Language Server Protocol

(defun mrf/lsp-mode-setup ()
   (message "Set up LSP header-line and other vars")
   (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
   (setq lsp-clangd-binary-path "/Users/strider/Developer/plain_unix/llvm-project/build/bin/clangd")
   ;;     (setq lsp-clients-clangd-library-directories
   ;;        ("/Users/strider/Developer/plain_unix/llvm-project/build/lib"))
   (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
   :defer t
   :commands (lsp lsp-deferred)
   :hook (lsp-mode . mrf/lsp-mode-setup)
   :init
   (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
   :config
   (lsp-enable-which-key-integration t))

(use-package lsp-ui
   :after lsp
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

;;; ==========================================================================

;;; Alternate fork to handle possible performance bug(s)
(use-package jsonrpc
   :straight (jsonrpc :type git :host github :repo "svaante/jsonrpc"))

(if (equal enable-dape t)
   (progn
      (use-package dape
       :after (jsonrpc)
       ;; :defer t
       ;; To use window configuration like gud (gdb-mi)
       ;; :init
       ;; (setq dape-buffer-window-arrangement 'gud)
       :custom
       (dape-buffer-window-arrangement 'right)  ;; Info buffers to the right
       ;; To not display info and/or buffers on startup
       ;; (remove-hook 'dape-on-start-hooks 'dape-info)
       (remove-hook 'dape-on-start-hooks 'dape-repl)

       ;; To display info and/or repl buffers on stopped
       ;; (add-hook 'dape-on-stopped-hooks 'dape-info)
       ;; (add-hook 'dape-on-stopped-hooks 'dape-repl)

       ;; By default dape uses gdb keybinding prefix
       ;; If you do not want to use any prefix, set it to nil.
       ;; (setq dape-key-prefix "\C-x\C-a")

       ;; Kill compile buffer on build success
       ;; (add-hook 'dape-compile-compile-hooks 'kill-buffer)

       ;; Save buffers on startup, useful for interpreted languages
       ;; (add-hook 'dape-on-start-hooks
       ;;           (defun dape--save-on-start ()
       ;;             (save-some-buffers t t)))

       ;; Projectile users
       (setq dape-cwd-fn 'projectile-project-root)
       ;; :straight (dape :type git
       ;; 	      :host github :repo "emacs-straight/dape"
       ;; 	      :files ("*" (:exclude ".git")))
       :config
       (message "DAPE Configured")
       )
      )
   )

;;; ==========================================================================

(setq mrf/vscode-js-debug-dir (file-name-concat user-emacs-directory "dape/vscode-js-debug"))

(defun mrf/install-vscode-js-debug ()
   "Run installation procedure to install JS debugging support"
   (interactive)
   (mkdir mrf/vscode-js-debug-dir t)
   (let ((default-directory (expand-file-name mrf/vscode-js-debug-dir)))

      (vc-git-clone "https://github.com/microsoft/vscode-js-debug.git" "." nil)
      (message "git repository created")
      (call-process "npm" nil "*snam-install*" t "install")
      (message "npm dependencies installed")
      (call-process "npx" nil "*snam-install*" t "gulp" "dapDebugServer")
      (message "vscode-js-debug installed")))

(defun mrf/dape-end-debug-session ()
   "End the debug session."
   (interactive)
   (dape-quit))

(defun mrf/dape-delete-all-debug-sessions ()
   "End the debug session and delete all breakpoints."
   (interactive)
   (dape-breakpoint-remove-all)
   (mrf/dape-end-debug-session))

(defhydra dape-hydra (:color pink :hint nil :foreign-keys run)
   "
  ^Stepping^          ^Switch^                 ^Breakpoints^          ^Debug^                     ^Eval
  ^^^^^^^^----------------------------------------------------------------------------------------------------------------
  _._: Next           _st_: Thread            _bb_: Toggle           _dd_: Debug                 _ee_: Eval Expression
  _/_: Step in        _si_: Info              _bd_: Delete           _dw_: Watch dwim
  _,_: Step out       _sf_: Stack Frame       _ba_: Add              _dx_: end session
  _c_: Continue       _su_: Up stack frame    _bc_: Set condition    _dX_: end all sessions
  _r_: Restart frame  _sd_: Down stack frame  _bl_: Set log message
  _Q_: Disconnect     _sR_: Session Repl
                      _sU_: Info Update

"
         ("n" dape-next)
         ("i" dape-step-in)
         ("o" dape-step-out)
         ("." dape-next)
         ("/" dape-step-in)
         ("," dape-step-out)
         ("c" dape-continue)
         ("r" dape-restart)
         ("si" dape-info)
         ("st" dape-select-thread)
         ("sf" dape-select-stack)
         ("su" dape-stack-select-up)
         ("sU" dape-info-update)
         ("sd" dape-stack-select-down)
         ("sR" dape-repl)
         ("bb" dape-breakpoint-toggle)
         ("ba" dape--breakpoint-place)
         ("bd" dape-breakpoint-remove-at-point)
         ("bc" dape-breakpoint-expression)
         ("bl" dape-breakpoint-log)
         ("dd" dape)
         ("dw" dape-watch-dwim)
         ("ee" dape-evaluate-expression)
         ("dx" mrf/dape-end-debug-session)
         ("dX" mrf/dape-delete-all-debug-sessions)
         ("x" nil "exit Hydra" :color yellow)
         ("q" mrf/dape-end-debug-session "quit" :color blue)
         ("Q" mrf/dape-delete-all-debug-sessions :color red))

;;; ==========================================================================
;;; Debug Adapter Protocol
(if (equal enable-dap t)
   (progn
      (use-package dap-mode
     ;; Uncomment the config below if you want all UI panes to be hidden by default!
     ;; :custom
     ;; (lsp-enable-dap-auto-configure nil)
     :commands
     dap-debug
     :custom
     (dap-auto-configure-features '(sessions locals breakpoints expressions repl controls tooltip))
     :config
     (message "DAP mode loaded.")
     (dap-ui-mode 1)
     )
      (require 'dap-lldb)
      ;; (require 'dap-cpptools)
      (setq dap-lldb-debug-program `(,(expand-file-name
  				       "~/Developer/plain_unix/llvm-project/build/bin/lldb-dap")))
      ;; (setq dap-lldb-debug-program "/Users/strider/Developer/plain_unix/llvm-project/build/bin/lldb-dap")
      )
   )

;;; ==========================================================================

;;; DAP for Python

(if (equal enable-dap t)
   (progn
      (use-package dap-python
       :straight (dap-python :type git :host github :repo "emacs-lsp/dap-mode")
       :after (dap-mode)
       :config
       (setq dap-python-executable "python3") ;; Otherwise it looks for 'python' else error.
       (setq dap-python-debugger 'debugpy)
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
       )
      )
   )

;;; ==========================================================================

;;; DAP for NodeJS

(defun my-setup-dap-node ()
   "Require dap-node feature and run dap-node-setup if VSCode module isn't already installed"
   (require 'dap-node)
   (unless (file-exists-p dap-node-debug-path) (dap-node-setup)))

(if (equal enable-dap t)
   (progn
      (use-package dap-node
  	 :defer t
  	 :straight (dap-node :type git
  		      :flavor melpa
  		      :files (:defaults "icons" "dap-mode-pkg.el")
  		      :host github
  		      :repo "emacs-lsp/dap-mode")
  	 :after (dap-mode)
  	 :config
  	 (require 'dap-firefox)
  	 (dap-register-debug-template
  	    "Launch index.ts"
  	    (list :type "node"
  	       :request "launch"
  	       :program "${workspaceFolder}/index.ts"
  	       :dap-compilation "npx tsc index.ts --outdir dist --sourceMap true"
  	       :outFiles (list "${workspaceFolder}/dist/**/*.js")
  	       :name "Launch index.ts"))
  	 ;; (dap-register-debug-template
  	 ;;    "Launch index.ts"
  	 ;;    (list :type "node"
  	 ;; 	 :request "launch"
  	 ;; 	 :program "${workspaceFolder}/index.ts"
  	 ;; 	 :dap-compilation "npx tsc index.ts --outdir dist --sourceMap true"
  	 ;; 	 :outFiles (list "${workspaceFolder}/dist/**/*.js")
  	 ;; 	 :name "Launch index.ts"))
  	 )
      (add-hook 'typescript-mode-hook 'my-setup-dap-node)
      (add-hook 'js2-mode-hook 'my-setup-dap-node)
      )
   )

;;; ==========================================================================

(use-package hydra)

;;; ==========================================================================

;;; Swiper and IVY mode

(use-package ivy
   :diminish I
   :bind (("C-s" . swiper)
	  :map ivy-minibuffer-map
	  ;;; ("TAB" . ivy-alt-done)
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
   :custom (ivy-use-virtual-buffers t)
   :config
   (ivy-mode 1))

(use-package ivy-rich
   :after ivy
   :init
   (ivy-rich-mode 1)
   :config
   (setcdr (assq t ivy-format-functions-alist) #'ivy-format-function-line))

(use-package ivy-yasnippet
   :straight (ivy-yasnippet :type git :flavor melpa :host github :repo "mkcms/ivy-yasnippet"))

;;; ==========================================================================

(use-package swiper)

;;; ==========================================================================

(use-package counsel
   :straight t
   :bind (("C-M-j" . 'counsel-switch-buffer)
  	  :map minibuffer-local-map
  	  ("C-r" . 'counsel-minibuffer-history))
   :custom
   (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
   :config
   (counsel-mode 1))

;;; ==========================================================================

(use-package ivy-prescient
  :after counsel
  :custom
  (ivy-prescient-enable-filtering nil)
  :config
  (prescient-persist-mode 1)
  (ivy-prescient-mode 1))

;;; ==========================================================================

;;;; Code Completion
(if (equal enable-corfu t)
   (use-package corfu
      ;; Optional customizations
      :custom
      (corfu-cycle t)                 ; Allows cycling through candidates
      (corfu-auto t)                  ; Enable auto completion
      (corfu-auto-prefix 2)
      (corfu-auto-delay 0.8)
      (corfu-popupinfo-delay '(0.5 . 0.2))
      (corfu-preview-current 'insert) ; insert previewed candidate
      (corfu-preselect 'prompt)
      (corfu-on-exact-match nil)      ; Don't auto expand tempel snippets
      ;; Optionally use TAB for cycling, default is `corfu-complete'.
      :bind (:map corfu-map
               ("M-SPC"      . corfu-insert-separator)
               ("TAB"        . corfu-next)
               ([tab]        . corfu-next)
               ("S-TAB"      . corfu-previous)
               ([backtab]    . corfu-previous)
               ("S-<return>" . corfu-insert)
               ("RET"        . nil))
      :init
      (global-corfu-mode)
      (corfu-history-mode)
      (corfu-popupinfo-mode) ; Popup completion info
      :config
      (add-hook 'eshell-mode-hook
       (lambda () (setq-local corfu-quit-at-boundary t
                  corfu-quit-no-match t
                  corfu-auto nil)
            (corfu-mode))))

   (use-package corfu-prescient
      :after corfu)
   )

;;; ==========================================================================

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;;; ==========================================================================

(defun mrf/tree-sitter-setup ()
   (tree-sitter-hl-mode t)
   (ts-fold-mode t))

(use-package tree-sitter-langs)

(use-package tree-sitter
   :init
   (message ">>> Loading tree-sitter")
   ;; :after (lsp-mode)
   :config
   ;; Activate tree-sitter globally (minor mode registered on every buffer)
   (global-tree-sitter-mode)
   :hook
   (tree-sitter-after-on . mrf/tree-sitter-setup)
   (typescript-mode . lsp-deferred)
   (c-mode . lsp-deferred)
   (c++-mode . lsp-deferred)
   (js2-mode . lsp-deferred))

(use-package ts-fold
   :straight (ts-fold :type git
  	      :host github
  	      :repo "emacs-tree-sitter/ts-fold")
   :config
   (general-define-key
      "C-<tab>" 'ts-fold-toggle
      "C-c f"   'ts-fold-open-all))

;;; ==========================================================================

(if (equal enable-dap t)
   (use-package typescript-ts-mode
      ;; :after (dap-mode)
      :mode "\\.ts\\'"
      :hook
      (typescript-ts-mode . lsp-deferred)
      (js2-mode . lsp-deferred)
      :config
      (setq typescript-indent-level 4)
      (dap-node-setup)))

(if (equal enable-dape t)
   (use-package typescript-ts-mode
      :after (dape-mode)
      :mode ("\\.ts\\'")
      :hook
      (typescript-ts-mode . lsp-deferred)
      (js2-mode . lsp-deferred)
      :config
      (general-define-key
       :keymaps '(typescript-ts-mode-map)
       "C-c ," 'dape-hydra/body)
      (setq typescript-indent-level 4)))

(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))

;;; ==========================================================================

(defun mrf/load-js-file-hook ()
   (message "Running JS file hook")
   (js2-mode)
   (if (equal enable-dap t)
      (progn
       (dap-mode)
       (dap-firefox-setup)))
   (if (equal enable-dape t)
      (dape))
   (dap-firefox-setup)
   (highlight-indentation-mode -1))

(use-package nodejs-repl)

(if (equal enable-dap-js t)
   (progn
      (setq ff-debug-dir (concat emacs-config-directory
  	    ".extension/vscode/firefox-devtools.vscode-firefox-debug/extension/dist/adapter.bundle.js"))
      (use-package js2-mode
       :custom
       (js-indent-level 2)
       (dap-firefox-debug-program
  	  '("node" ff-debug-dir))
       :init
       (require 'dap-firefox))
      (add-to-list 'auto-mode-alist '("\\.[m]js\\'" . mrf/load-js-file-hook))
      )
   )

(defun mrf/nvm-which ()
   (let ((output (shell-command-to-string "source ~/.nvm/nvm.sh; nvm which")))
      (cadr (split-string output "[\n]+" t))))

(setq nodejs-repl-command #'mrf/nvm-which)

(use-package js2-mode
   :hook (js-mode . js2-minor-mode)
   :mode ("\\.js\\'" "\\.mjs\\'")
   :custom (js2-highlight-level 3))

(use-package ac-js2
   :hook (js2-mode . ac-js2-mode))

(general-define-key
   :keymaps '(js-mode-map)
   "{" 'paredit-open-curly
   "}" 'paredit-close-curly-and-newline)

(add-to-list 'auto-mode-alist '("\\.json$" . js-mode))

;;; ==========================================================================

(defun mrf/load-c-file-hook ()
   (message "Running C/C++ file hook")
   (c-mode)
   (if (featurep 'zoom)
      (if (default-value 'zoom-mode)
       (progn
  	  ;;(zoom--off)
  	  (message "Turning zoom off")
  	  )))
   (if (equal enable-dap t)
      (dap-mode))
   (highlight-indentation-mode -1)
   (display-fill-column-indicator-mode t))

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
(add-to-list 'auto-mode-alist '("\\.c\\'" . mrf/load-c-file-hook))

;;; ==========================================================================

;; (use-package graphql-mode)
(use-package js2-mode)
(use-package rust-mode :defer t)
(use-package swift-mode :defer t)

;;; ==========================================================================

(use-package flycheck
  :config
  (global-flycheck-mode))

(use-package flycheck-package)

(eval-after-load 'flycheck
  '(flycheck-package-setup))

(defun mrf/before-save ()
  "Force the check of the current python file being saved."
  (when (eq major-mode 'python-mode) ;; Python Only
     (flycheck-mode 0)
     (flycheck-mode t)
     (message "deleting trailing whitespace enabled")
     (delete-trailing-whitespace)))

(add-hook 'before-save-hook 'mrf/before-save)

;;; ==========================================================================


(defun mrf/load-python-file-hook ()
   (message "Running python file hook")
   (python-mode)
   (if (featurep 'zoom)
      (if (default-value 'zoom-mode)
       (progn
  	  ;;(zoom--off)
  	  (message "Turning zoom off")
  	  )))
   (if (equal enable-dap t)
      (dap-mode))
   (diff-hl-mode)
   (highlight-indentation-mode -1)
   (display-fill-column-indicator-mode t))

(defun mrf/python-mode-triggered ()
   (message "Calling mrf/python-mode-triggered")
   (treemacs t))

(use-package python-mode
   :defer t
   :hook (python-mode . (lambda () (set-fill-column 80)))
   )

;; (use-package python-mode
;;    :defer t
;;    :config
;;    (if (equal enable-dap t)
;;       (progn
;; 	 (dap-tooltip 1)
;; 	 (dap-ui-controls-mode 1)))
;;    (tooltip-mode 1)
;;    :custom
;;    (python-shell-completion-native-enable nil)
;;    :bind (:map python-mode-map
;; 	      ("C-c |" . (display-fill-column-indicator-mode 1))))

;; (add-hook 'python-mode-hook 'mrf/python-mode-triggered)
(add-to-list 'auto-mode-alist '("\\.py\\'" . mrf/load-python-file-hook))
(use-package blacken
   :after python) ;Format Python file upon save.

(if (boundp 'python-shell-completion-native-disabled-interpreters)
   (add-to-list 'python-shell-completion-native-disabled-interpreters "python3")
   (setq python-shell-completion-native-disabled-interpreters '("python3")))

;;; ==========================================================================

(if (equal enable-anaconda t)
   (use-package anaconda-mode
      :bind (("C-c C-x" . next-error))
      :config
      (require 'pyvenv)
      :hook
      (python-mode-hook . anaconda-eldoc-mode)))

;;; ==========================================================================

(if (equal enable-elpy t)
   (progn
      (use-package elpy
       :after python
       :custom
       (elpy-rpc-python-command "python3")
       (display-fill-column-indicator-mode 1)
       (highlight-indentation-mode 0)
       :config
       (elpy-enable))
      (message "elpy loaded")
      ;; Enable Flycheck
      (use-package flycheck
       :straight (flycheck
  		    :type git
  		    :flavor melpa
  		    :host github
  		    :repo "flycheck/flycheck")
       :config
       (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
       :hook (elpy-mode . flycheck-mode))
      ))

;;; ==========================================================================

(use-package py-autopep8
   :after python-mode
   :hook ((python-mode) . py-autopep8-mode))

;;; ==========================================================================

(if (equal enable-elpy t)
 (general-define-key
    :keymaps '(python-mode-map)
    "C-c g a"    'elpy-goto-assignment
    "C-c g o"    'elpy-goto-definition-other-window
    "C-c g g"    'elpy-goto-definition
    "C-c g ?"    'elpy-doc))

;;; ==========================================================================

(if (equal enable-anaconda t)
   (general-define-key
      :keymaps '(python-mode-map)
      "C-c g o"    'anaconda-mode-find-definitions-other-frame
      "C-c g g"    'anaconda-mode-find-definitions))

;;; ==========================================================================

;; This is a helpful macro that is used to put double quotes around a word.
(defalias 'quote-word
   (kmacro "\" M-d \" <left> C-y"))

(defalias 'quote-region
   (kmacro "C-w \" \" <left> C-y <right>"))

(general-define-key
   :keymaps '(python-mode-map)
   "C-c C-q"    'quote-region
   "C-c q"      'quote-word
   "C-c |"      'display-fill-column-indicator-mode)

;;; ==========================================================================

(if (equal enable-dap t)
   (general-define-key
      :keymaps '(python-mode-map typescript-ts-mode-map c-mode-map c++-mode-map)
      "C-c ."      'dap-hydra/body)
   )

(if (equal enable-dape t)
   (general-define-key
      :keymaps '(python-mode-map typescript-ts-mode-map c-mode-map c++-mode-map)
      "C-c ."      'dape-hydra/body)
   )

(defun mrf/end-debug-session ()
   "End the debug session and delete project Python buffers."
   (interactive)
   (kill-matching-buffers "\*Python :: Run file [from|\(buffer]*" nil :NO-ASK)
   (kill-matching-buffers "\*Python: Current File*" nil :NO-ASK)
   (kill-matching-buffers "\*dap-ui-*" nil :NO-ASK)
   (dap-disconnect (dap--cur-session)))

(defun mrf/delete-all-debug-sessions ()
   "End the debug session and delete project Python buffers and all breakpoints."
   (interactive)
   (dap-breakpoint-delete-all)
   (mrf/end-debug-session))

(defun mrf/begin-debug-session ()
   "Begin a debug session with several dap windows enabled."
   (interactive)
   (dap-ui-show-many-windows)
   (dap-debug))

(defhydra dap-hydra (:color pink :hint nil :foreign-keys run)
   "
  ^Stepping^          ^Switch^                 ^Breakpoints^          ^Debug^                     ^Eval
  ^^^^^^^^----------------------------------------------------------------------------------------------------------------
  _._: Next           _ss_: Session            _bb_: Toggle           _dd_: Debug                 _ee_: Eval
  _/_: Step in        _st_: Thread             _bd_: Delete           _dr_: Debug recent          _er_: Eval region
  _,_: Step out       _sf_: Stack frame        _ba_: Add              _dl_: Debug last            _es_: Eval thing at point
  _c_: Continue       _su_: Up stack frame     _bc_: Set condition    _de_: Edit debug template   _ea_: Add expression.
  _r_: Restart frame  _sd_: Down stack frame   _bh_: Set hit count    _ds_: Debug restart
  _Q_: Disconnect     _sl_: List locals        _bl_: Set log message  _dx_: end session
                    _sb_: List breakpoints                          _dX_: end all sessions
                    _sS_: List sessions
                    _sR_: Session Repl
"
   ("n" dap-next)
   ("i" dap-step-in)
   ("o" dap-step-out)
   ("." dap-next)
   ("/" dap-step-in)
   ("," dap-step-out)
   ("c" dap-continue)
   ("r" dap-restart-frame)
   ("ss" dap-switch-session)
   ("st" dap-switch-thread)
   ("sf" dap-switch-stack-frame)
   ("su" dap-up-stack-frame)
   ("sd" dap-down-stack-frame)
   ("sl" dap-ui-locals)
   ("sb" dap-ui-breakpoints)
   ("sR" dap-ui-repl)
   ("sS" dap-ui-sessions)
   ("bb" dap-breakpoint-toggle)
   ("ba" dap-breakpoint-add)
   ("bd" dap-breakpoint-delete)
   ("bc" dap-breakpoint-condition)
   ("bh" dap-breakpoint-hit-condition)
   ("bl" dap-breakpoint-log-message)
   ("dd" dap-debug)
   ("dr" dap-debug-recent)
   ("ds" dap-debug-restart)
   ("dl" dap-debug-last)
   ("de" dap-debug-edit-template)
   ("ee" dap-eval)
   ("ea" dap-ui-expressions-add)
   ("er" dap-eval-region)
   ("es" dap-eval-thing-at-point)
   ("dx" mrf/end-debug-session)
   ("dX" mrf/delete-all-debug-sessions)
   ("x" nil "exit Hydra" :color yellow)
   ("q" mrf/end-debug-session "quit" :color blue)
   ("Q" mrf/delete-all-debug-sessions :color red))

;;; ==========================================================================

(use-package pyvenv-auto
   :after python
   :config (message "Starting pyvenv-auto")
   :hook (python-mode . pyvenv-auto-run))

;;; ==========================================================================

(use-package z80-mode
   :straight (z80-mode
  	      :type git
  	      :host github
  	      :repo "SuperDisk/z80-mode"))

(use-package mwim
   :straight (mwim
  	      :type git
  	      :flavor melpa
  	      :host github
  	      :repo "alezost/mwim.el"))

(use-package rgbds-mode
   :after mwim
   :straight (rgbds-mode
  	      :type git :host github
  	      :repo "japanoise/rgbds-mode"))

;;; ==========================================================================

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

(add-hook 'after-init-hook 'global-company-mode)

;;; ==========================================================================

(use-package company-box
   :diminish cb
   :hook (company-mode . company-box-mode))

(use-package company-jedi
   :disabled
   :config
   (defun my/company-jedi-python-mode-hook ()
      (add-to-list 'company-backends 'company-jedi))
   (add-hook 'python-mode-hook 'my/company-jedi-python-mode-hook))

(use-package company-anaconda
   :after anaconda
   :hook (python-mode . anaconda-mode))

(eval-after-load "company"
   '(add-to-list 'company-backends 'company-anaconda))

;;; ==========================================================================


(use-package projectile
  :diminish P>
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

;;; ==========================================================================


(use-package magit
   :defer t
;;  :commands (magit-status magit-get-current-branch)
;; :custom
;;  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
   )

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started

(use-package forge
  :after magit)

(defun mrf/org-theme-override-values ()
   (defface org-block-begin-line
      '((t (:underline "#1D2C39" :foreground "SlateGray" :background "#1D2C39")))
      "Face used for the line delimiting the begin of source blocks.")

   (defface org-block
      '((t (:background "#242635" :extend t)))
      "Face used for the source block background.")

   (defface org-block-end-line
      '((t (:overline "#1D2C39" :foreground "SlateGray" :background "#1D2C39")))
      "Face used for the line delimiting the end of source blocks.")
   )

;;; ==========================================================================

(defun mrf/org-font-setup ()
  "Setup org mode fonts."
  (font-lock-add-keywords
     'org-mode
     '(("^ *\\([-]\\) "
          (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
   ;; (setq org-src-fontify-natively t)

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
  (set-face-attribute 'org-block nil    :foreground 'unspecified :inherit 'fixed-pitch)
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

;; -----------------------------------------------------------------

(defun mrf/org-mode-setup ()
   (org-indent-mode)
   (variable-pitch-mode 1)
   (visual-line-mode 1)
   (setq org-ellipsis " ▾")
   (setq org-agenda-start-with-log-mode t)
   (setq org-log-done 'time)
   (setq org-log-into-drawer t)
   ;; (use-package org-habit)
   ;; (add-to-list 'org-modules 'org-habit)
   ;; (setq org-habit-graph-column 60)
   (setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
  	(sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)"
  	   "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))
   (setq org-refile-targets
      '(("Archive.org" :maxlevel . 1)
  	("Tasks.org" :maxlevel . 1))))

;;; ==========================================================================
;; -----------------------------------------------------------------

(defun mrf/org-setup-agenda ()
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
   ) ;; mrf/org-setup-agenda

;;; ==========================================================================

;; -----------------------------------------------------------------

(defun mrf/org-setup-capture-templates ()
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
          ("we" "Checking Email" entry (file+olp+datetree
  				  "~/Projects/Code/emacs-from-scratch/OrgFiles/Journal.org")
             "* Checking Email :email:\n\n%?" :clock-in :clock-resume :empty-lines 1)

          ("m" "Metrics Capture")
          ("mw" "Weight" table-line (file+headline
  				     "~/Projects/Code/emacs-from-scratch/OrgFiles/Metrics.org"
  				     "Weight")
             "| %U | %^{Weight} | %^{Notes} |" :kill-buffer t))))

;;; ==========================================================================
;; -----------------------------------------------------------------

(mrf/org-theme-override-values)

(use-package org
   :defer t
   ;; :init
   ;; :straight (org :type git
   ;; 		:repo "https://git.savannah.gnu.org/git/emacs/org-mode.git"
   ;; 		:local-repo "org"
   ;; 		:depth full
   ;; 		:pre-build (straight-recipes-org-elpa--build)
   ;; 		:build (:not autoloads)
   ;; 		:files (:defaults "lisp/*.el" ("etc/styles/" "etc/styles/*")))
   :commands (org-capture org-agenda)
   :hook (org-mode . mrf/org-mode-setup)
   :config
   (general-def org-mode-map
      "C-c e" 'org-edit-src-code)
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
   (mrf/org-setup-agenda)
   ;; Configure custom agenda views
   (mrf/org-setup-capture-templates)
   (define-key global-map (kbd "C-c j")
      (lambda () (interactive) (org-capture nil "jj")))
   (mrf/org-font-setup))

;;; ==========================================================================

;; -----------------------------------------------------------------

(use-package org-bullets
   :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

;; -----------------------------------------------------------------

(defun mrf/org-mode-visual-fill ()
  (setq visual-fill-column-width 110
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . mrf/org-mode-visual-fill))

;;; ==========================================================================

;; -----------------------------------------------------------------

(with-eval-after-load 'org
   (org-babel-do-load-languages
      'org-babel-load-languages
      '((emacs-lisp . t)
      (js . t)
      (shell . t)
      (python . t)))

  (push '("conf-unix" . conf-unix) org-src-lang-modes))

;;; ==========================================================================

;; -----------------------------------------------------------------

(with-eval-after-load 'org
  ;; This is needed as of Org 9.2

  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python")))

;; (use-package emacsql)
;; (use-package emacsql-sqlite)

(use-package org-roam
   ;; :demand t  ;; Ensure org-roam is loaded by default
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
   (my/org-roam-refresh-agenda-list)
   (add-to-list 'org-after-todo-state-change-hook
      (lambda ()
       (when (equal org-state "DONE")
            (my/org-roam-copy-todo-to-today))))
   (org-roam-db-autosync-mode))

(defun org-roam-node-insert-immediate (arg &rest args)
   (interactive "P")
   (let ((args (push arg args))
           (org-roam-capture-templates
              (list (append (car org-roam-capture-templates)
                       '(:immediate-finish t)))))
    (apply #'org-roam-node-insert args)))

;; The buffer you put this code in must have lexical-binding set to t!
;; See the final configuration at the end for more details.

(defun my/org-roam-filter-by-tag (tag-name)
  (lambda (node)
    (member tag-name (org-roam-node-tags node))))

(defun my/org-roam-list-notes-by-tag (tag-name)
  (mapcar #'org-roam-node-file
          (seq-filter
           (my/org-roam-filter-by-tag tag-name)
           (org-roam-node-list))))

(defun my/org-roam-refresh-agenda-list ()
  (interactive)
  (setq org-agenda-files (my/org-roam-list-notes-by-tag "Project")))

;; Build the agenda list the first time for the session

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

;;; ==========================================================================

;; Automatically tangle our Configure.org config file when we save it
;; Org files that should use this need to add a '#+auto_tangle: t'
;; in the org file.
(use-package org-auto-tangle
   :defer t
   :hook (org-mode . org-auto-tangle-mode))

;; no longer used but I keep it jic
;; (defun mrf/org-babel-tangle-save-hook ()
;;    "Save emacs-lisp blocks."
;;   (when (eq major-mode 'org-mode) ;; Org-mode Only
;;      (when (string-equal (file-name-directory (buffer-file-name))
;;               (expand-file-name emacs-config-directory))
;;         (message "org-mode-hook: Executing mrf/org-babel-tangle-config")
;;         ;; Dynamic scoping to the rescue
;;         (let ((org-confirm-babel-evaluate nil))
;;            (message "... tangle emacs-lisp")
;;            (org-babel-tangle)))))

;;; ==========================================================================

(with-eval-after-load 'org
  (require 'ox-gfm nil t))

;;; ==========================================================================

(if (equal enable-org-ai t)
   (use-package org-ai
      :after org
      :custom
      (org-ai-openai-api-token "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")
      ;; :config
      ;; (load "copilot")
      ))

;;; ==========================================================================

(use-package marginalia)

(use-package vertico)
(vertico-mode 1)

;; (use-package vertico-posframe
;;    :custom
;;    (vertico-posframe-parameters
;;       '((left-fringe . 8)
;;           (right-fringe . 8))))

;;; ==========================================================================

(use-package solaire-mode
   :hook (after-init . solaire-global-mode)
   :config
   (push '(treemacs-window-background-face . solaire-default-face) solaire-mode-remap-alist)
   (push '(treemacs-hl-line-face . solaire-hl-line-face) solaire-mode-remap-alist))

;;; ==========================================================================

;; Golen Ratio / Zoom

(if (equal enable-zoom 1)
   (use-package zoom
      :hook (after-init . zoom-mode)
      :custom
      (zoom-size '(0.618 . 0.618))
      ;; (golden-ratio-auto-scale t)
      (zoom-ignored-major-modes '(dired-mode occur-mode
  				  undo-tree-visualizer-mode
  				  inferior-python-mode
  				  vundo-mode
  				  python-mode
  				  help-mode
  				  dap-ui-repl-mode
  				  dap-mode
  				  dap-ui-mode
  				  dap-ui-many-windows-mode
  				  markdown-mode))))

;;; ==========================================================================

(use-package ace-window
   :config
   (general-define-key
      "M-o" 'ace-window))

;;; ==========================================================================

(use-package all-the-icons
   :if (display-graphic-p))

(use-package dashboard
   :after (dired)
   :preface
   (defun mrf/dashboard-banner ()
      (setq dashboard-footer-messages '("Greetings Program!"))
      (setq dashboard-banner-logo-title "Welcome to Emacs!")
      (setq dashboard-startup-banner 'logo))
   :hook ((after-init     . dashboard-refresh-buffer)
          (dashboard-mode . mrf/dashboard-banner))
   :custom
   (dashboard-items '((recents . 10)
                      (bookmarks . 5)
                      (projects . 10)))
   (dashboard-icon-type 'all-the-icons) ;; use `all-the-icons' package
   (dashboard-display-icons-p t)
   (dashboard-center-content t)
   (dashboard-set-heading-icons t)
   (dashboard-set-file-icons t)
   (initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
   :config
   (dashboard-setup-startup-hook)
   (dashboard-open)
   (global-set-key (kbd "C-c d") 'dashboard-open))

;;; ==========================================================================

;; A cleaner undo package from undo-tree.

(use-package vundo
   :bind (("C-x u" . vundo)
  	("C-x r u" . vundo))
   :config
   (setq vundo-glyph-alist vundo-unicode-symbols)
   (set-face-attribute 'vundo-default nil :family "Wingdings2"))

;;; ==========================================================================

;; helpful package

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

;;; ==========================================================================

(use-package term
  :defer t
  :commands term
  :config
  (setq explicit-shell-file-name "bash") ;; Change this to zsh, etc
  ;;(setq explicit-zsh-args '())         ;; Use 'explicit-<shell>-args for shell-specific args

  ;; Match the default Bash shell prompt.  Update this if you have a custom prompt
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *"))

;;; ==========================================================================

(use-package eterm-256color
  :defer t
  :hook (term-mode . eterm-256color-mode))

;;; ==========================================================================

(use-package vterm
  :defer t
  :commands vterm
  :config
  (setq vterm-environment ("PS1=\\u@\\h:\\w \n$"))
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")  ;; Set this to match your custom shell prompt
  (setq vterm-shell "zsh")                       ;; Set this to customize the shell to launch
  (setq vterm-max-scrollback 10000))

;;; ==========================================================================


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
  :defer t
  :hook (eshell-first-time-mode . efs/configure-eshell)
  :config
  (with-eval-after-load 'esh-opt
    (setq eshell-destroy-buffer-when-process-dies t)
    (setq eshell-visual-commands '("htop" "zsh" "vim")))

  (eshell-git-prompt-use-theme 'powerline))

;;; ==========================================================================

(if (equal enable-neotree t)
   (use-package neotree
      :config
      (global-set-key [f8] 'neotree-toggle)
      (setq neo-theme (if (display-graphic-p) 'icons 'arrow))))

;;; ==========================================================================

(use-package all-the-icons)

;; (use-package doom-modeline
;;   :diabled
;;   :init (doom-modeline-mode 1)
;;   :custom ((doom-modeline-height 15)))

;; Functions to insert the buffer file name at the current cursor position
;;
(defun mrf/insert-buffer-full-name-at-point ()
   (interactive)
   (insert buffer-file-name))

(defun mrf/insert-buffer-name-at-point ()
   (interactive)
   (insert (file-name-nondirectory (buffer-file-name))))

(general-define-key
   "C-c i f" 'mrf/insert-buffer-name-at-point
   "C-c i F" 'mrf/insert-buffer-full-name-at-point
   )

;;; ==========================================================================

;; Enable tabs for each buffer

(if (equal enable-centaur-tabs t)
   (use-package centaur-tabs
      :custom
      ;; Set the style to rounded with icons (setq centaur-tabs-style "bar")
      (centaur-tabs-style "bar")
      (centaur-tabs-set-icons t)
      (centaur-tabs-set-modified-marker t)
      :bind (("C-c <" . centaur-tabs-backward)
  	     ("C-c >" . centaur-tabs-forward))
      :config ;; Enable centaur-tabs
      (centaur-tabs-mode t)))

;;; ==========================================================================

(use-package diff-hl)

;;; ==========================================================================

(use-package pulsar
   :config
   (pulsar-global-mode)
   (let ((map global-map))
      (define-key map (kbd "C-c h p") #'pulsar-pulse-line)
      (define-key map (kbd "C-c h h") #'pulsar-highlight-line))
   :custom
   (pulsar-pulse t)
   (pulsar-delay 0.055)
   (pulsar-iterations 10)
   (pulsar-face 'pulsar-magenta)
   (pulsar-highlight-face 'pulsar-yellow))

;;; ==========================================================================

(use-package popper
  :defer t
  :straight t
  :init
  (setq popper-reference-buffers
     '("\\*Messages\\*"
       "\\*scratch\\*"
       "\\*ielm\\*"
         "Output\\*$"
         "\\*Async Shell Command\\*"
       "^\\*eshell.*\\*$" eshell-mode ;eshell as a popup
         "^\\*shell.*\\*$"  shell-mode  ;shell as a popup
         "^\\*term.*\\*$"   term-mode   ;term as a popup
         "^\\*vterm.*\\*$"  vterm-mode  ;vterm as a popup
         help-mode
         compilation-mode))
  (popper-mode +1)
  (popper-echo-mode +1))

(general-define-key
   "C-`"   'popper-toggle
   "M-`"   'popper-cycle
   "C-M-`" 'popper-toggle-type)

;;; ==========================================================================

;; Prefer g-prefixed coreutils version of standard utilities when available
(let ((gls (executable-find "gls")))
  (when gls (setq insert-directory-program gls)))

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

;;; ==========================================================================

;; Single Window dired - don't continually open new buffers

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

;;; ==========================================================================

;; Ignore Line Numbers for the following modes:

;; Line #'s appear everywhere
;; ... except for when in these modes
(dolist (mode '(dashboard-mode-hook
  		helpful-mode-hook
                  eshell-mode-hook
                  eww-mode-hook
  		help-mode-hook
                  org-mode-hook
                  shell-mode-hook
                  term-mode-hook
                  treemacs-mode-hook
                  vterm-mode-hook))
   (add-hook mode (lambda () (display-line-numbers-mode 0))))

(setq warning-suppress-types '((package reinitialization)
                                 (package-initialize)
                                 (package)
                                 (use-package)
                                 (python-mode)))

;;; ==========================================================================

;; Frame font selection

(defvar mrf/font-size-slot 1)

(defun mrf/update-font-size ()
   (message "adjusting font size")
   (cond ((equal mrf/font-size-slot 3)
  	  (progn
               (message "X-Large Font")
               (setq mrf/default-font-size mrf/x-large-font-size
  		mrf/default-variable-font-size mrf/x-large-variable-font-size
  		mrf/font-size-slot 2)
               (mrf/update-face-attribute)))
         ((equal mrf/font-size-slot 2)
            (progn
               (message "Large Font")
               (setq mrf/default-font-size mrf/large-font-size
  		mrf/default-variable-font-size mrf/large-variable-font-size
  		mrf/font-size-slot 1)
               (mrf/update-face-attribute)))       
         ((equal mrf/font-size-slot 1)
            (progn
               (message "Medium Font")
               (setq mrf/default-font-size mrf/medium-font-size
  		mrf/default-variable-font-size mrf/medium-variable-font-size
  		mrf/font-size-slot 0)
               (mrf/update-face-attribute)))
         ((equal mrf/font-size-slot 0)
            (progn
               (message "Small Font")
               (setq mrf/default-font-size mrf/small-font-size
  		mrf/default-variable-font-size mrf/small-variable-font-size
  		mrf/font-size-slot 3)
               (mrf/update-face-attribute)))
      )
   )

;; Some alternate keys below....
(general-define-key
   "C-c 1" 'use-small-display-font)

(general-define-key
   "C-c 2" 'use-medium-display-font)

(general-define-key
   "C-c 3" 'use-large-display-font)

(general-define-key
   "C-c 4" 'use-x-large-display-font)

;; Frame support functions

(defun mrf/set-frame-font (slot)
   (setq mrf/font-size-slot slot)
   (mrf/update-font-size)
   (mrf/frame-recenter)
   )

(defun use-small-display-font ()
   (interactive)
   (mrf/set-frame-font 0)
   (mrf/frame-recenter)
   )

(defun use-medium-display-font ()
   (interactive)
   (mrf/set-frame-font 1)
   (mrf/frame-recenter)
   )

(defun use-large-display-font ()
   (interactive)
   (mrf/set-frame-font 2)
   (mrf/frame-recenter)
   )

(defun use-x-large-display-font ()
   (interactive)
   (mrf/set-frame-font 3)
   (mrf/frame-recenter)
   )

(add-hook 'after-init-hook 'use-medium-display-font)

;;; ==========================================================================

(custom-set-variables
   ;; custom-set-variables was added by Custom.
   ;; If you edit it by hand, you could mess it up, so be careful.
   ;; Your init file should contain only one such instance.
   ;; If there is more than one, they won't work right.
   '(warning-suppress-log-types
       '(((python python-shell-completion-native-turn-on-maybe))
  	 ((package reinitialization))
  	 (comp)
  	 (treesit)
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
