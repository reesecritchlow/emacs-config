;; Initialize package sources
(require 'package)
(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))
(package-initialize)

;; Bootstrap `use-package`
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-and-compile
  (setq use-package-always-ensure t
        use-package-expand-minimally t))

;;; Native Compilation (GccEmacs)
(when (and (fboundp 'native-comp-available-p)
           (native-comp-available-p))
  (setq native-comp-async-report-warnings-errors nil
        native-comp-deferred-compilation t
        package-native-compile t)
  (add-to-list 'native-comp-eln-load-path
               (expand-file-name "eln-cache/" user-emacs-directory)))

;;; straight.el bootstrapping (optional)
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el"
                         user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;;; Basic UI Configuration
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq column-number-mode t
      frame-resize-pixelwise t
      inhibit-startup-screen t
      default-frame-alist '((font . "Jetbrains Mono-14")))
(delete-selection-mode 1)
(setq-default standard-indent 4)
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;;; Shell environment (macOS/Linux GUI)
(use-package exec-path-from-shell
  :config (when (memq window-system '(mac ns x))
            (exec-path-from-shell-initialize)))

;;; Theme and modeline
(use-package doom-themes
  :straight t
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-one t))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :config (setq doom-modeline-height 30))

;;; Icons
(use-package nerd-icons)

;;; File tree / UI
(use-package neotree)
(use-package all-the-icons) ;; Needed by neotree/doom-modeline

;;; Completion and Search
(use-package vertico
  :straight t
  :config (vertico-mode))

(use-package deadgrep
  :straight t)

;;; Git
(use-package magit)

;;; Programming
(use-package rainbow-delimiters
  :straight t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package smartparens
  :straight t
  :hook (prog-mode . smartparens-mode))

(use-package company
  :hook (prog-mode . company-mode))

(use-package tsc
  :straight t)

(use-package tree-sitter
  :straight t
  :config
  (global-tree-sitter-mode))

;;; LSP Setup
(use-package lsp-mode
  :init (setq lsp-keymap-prefix "C-c l")
  :commands lsp)

(use-package lsp-ui
  :commands lsp-ui-mode)

(use-package lsp-pyright
  :straight t
  :hook (python-mode . (lambda ()
                         (require 'lsp-pyright)
                         (lsp))))

(use-package eglot)

;;; Languages
(use-package markdown-mode)
(use-package go-mode
  :ensure t
  :hook ((go-mode . lsp)
         (go-mode . company-mode)
         (go-mode . flycheck-mode)
         (go-mode . (lambda () (setq tab-width 8)))))

;;; Move text
(use-package move-text
  :config
  (global-unset-key [M-up])
  (global-unset-key [M-down])
  (global-set-key (kbd "M-n") 'move-text-down)
  (global-set-key (kbd "M-p") 'move-text-up))

;;; Spotify integration
(use-package smudge
  :bind-keymap ("C-c ." . smudge-command-map)
  :config
  (setq smudge-oauth2-client-id     "fc23856a306d4cc7bc67545888f736be"
        smudge-oauth2-client-secret "bc3a53dad3a043ff9f012efb7b3b1ce9"))

;;; Dockerfile mode
(use-package dockerfile-mode
  :straight t
  :mode "Dockerfile\\'")

;;; Custom extras
(load-file "~/.emacs.d/fds-syntax.el")

;;; Copilot (commented example shown)
;; (use-package copilot
;;   :straight (copilot :type git :host github :repo "copilot-emacs/copilot.el")
;;   :hook (prog-mode . copilot-mode)
;;   :config
;;   (define-key copilot-mode-map (kbd "M-<tab>") #'copilot-accept-completion))

(add-hook 'prog-mode-hook 'copilot-mode)

;;; Custom themes
(custom-set-variables
 '(custom-safe-themes
   '("9f297216c88ca3f47e5f10f8bd884ab24ac5bc9d884f0f23589b0a46a608fe14"
     "88f7ee5594021c60a4a6a1c275614103de8c1435d6d08cc58882f920e0cec65e"
     "7a3f3282c4ce1edc3387deb6f72ed31026ab7dfdf4c25ddcfad9008d2a5a5574"
     default))
 '(package-selected-packages
   '(pyvenv all-the-icons neotree csv-mode smudge move-text go-mode
     exec-path-from-shell vterm docker company deadgrep doom-modeline
     doom-themes lsp-mode lsp-pyright lsp-ui magit markdown-mode
     rainbow-delimiters smartparens tree-sitter vertico)))

(custom-set-faces)
