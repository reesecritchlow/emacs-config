;; Load packages
(require 'package)
(add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-and-compile
  (setq use-package-always-ensure t
        use-package-expand-minimally t))

;;; GccEmacs (native-comp) stuff
(when (and (fboundp 'native-comp-available-p) (native-comp-available-p))
  (progn
    (setq native-comp-async-report-warnings-errors nil)
    (setq native-comp-deferred-compilation t)
    (add-to-list 'native-comp-eln-load-path (expand-file-name "eln-cache/" user-emacs-directory))
    (setq package-native-compile t)))



(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("9f297216c88ca3f47e5f10f8bd884ab24ac5bc9d884f0f23589b0a46a608fe14" "88f7ee5594021c60a4a6a1c275614103de8c1435d6d08cc58882f920e0cec65e" "7a3f3282c4ce1edc3387deb6f72ed31026ab7dfdf4c25ddcfad9008d2a5a5574" default))
 '(inhibit-startup-screen t)
 '(package-selected-packages
   '(pyvenv all-the-icons neotree csv-mode csv smudge move-text go-mode go exec-path-from-shell autothemer vterm docker company deadgrep doom-modeline doom-themes lsp-mode lsp-pyright lsp-ui magit markdown-mode rainbow-delimiters smartparens smartparens-mode tree-sitter vertico)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq column-number-mode t)
(setq frame-resize-pixelwise t)
(delete-selection-mode 1)

(setq-default standard-indent 4)

(use-package exec-path-from-shell
  :ensure t
  :config (when (memq window-system '(mac ns x))
	    (exec-path-from-shell-initialize)))


(set-face-attribute 'default nil :font "Jetbrains Mono" :height 140)

(use-package magit
  :ensure t)

(use-package vertico
  :ensure t
  :config (vertico-mode))

(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-one t)

  ;; Enable flashing mode-line on errors
;;  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  ;; (doom-themes-neotree-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  ;;(doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  ;; (doom-themes-org-config)
  )

(use-package nerd-icons
  :ensure t)

(use-package doom-modeline
  :ensure t
  :config (setq doom-modeline-height 30)
  :hook (after-init . doom-modeline-mode))

(use-package deadgrep
  :ensure t)

(use-package markdown-mode
  :ensure t)

(use-package tree-sitter
  :ensure t)

(use-package lsp-mode
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  ;; :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
  ;;        ;; if you want which-key integration
  ;;        (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

;; optionally
(use-package lsp-ui :commands lsp-ui-mode)

(use-package lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp))))  ; or lsp-deferred

(use-package eglot
  :ensure t)

(use-package company
  :ensure t)

(use-package rainbow-delimiters
  :ensure t
  :config (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

(use-package smartparens
  :ensure t
  :config (add-hook 'prog-mode-hook #'smartparens-mode))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))
  
(add-to-list 'load-path "~/.emacs.d/dockerfile-mode.el")
(require 'dockerfile-mode)

(use-package move-text
  :ensure t
  :config
  (global-unset-key [M-up])
  (global-unset-key [M-down])
  (global-set-key (kbd "M-n") 'move-text-down)
  (global-set-key (kbd "M-p") 'move-text-up))

(use-package smudge
  :bind-keymap ("C-c ." . smudge-command-map)
  :config
  (setq smudge-oauth2-client-secret "bc3a53dad3a043ff9f012efb7b3b1ce9"
        smudge-oauth2-client-id "fc23856a306d4cc7bc67545888f736be"))

;; (load-file "~/.emacs.d/fds-syntax.el")

(use-package auctex
  :ensure t)

(use-package auctex-latexmk
  :ensure t)

(use-package lsp-latex
  :ensure t
  :config
  (with-eval-after-load "tex-mode"
    (add-hook 'tex-mode-hook 'lsp)
    (add-hook 'latex-mode-hook 'lsp)))

(use-package pdf-tools
  :ensure t
  :config
  (pdf-tools-install))

(setq tex-fontify-script nil)

(use-package pyvenv
  :ensure t)

;; (defun my-latexmk-compile ()
;;   "Run latexmk on the current file and output to a specific buffer. Notify on failure."
;;   (interactive)
;;   (when (string-equal "tex" (file-name-extension buffer-file-name))
;;     (let ((compile-buffer (get-buffer-create "*latexmk-compile*")))
;;       (with-current-buffer compile-buffer
;;         (erase-buffer)) ; Clear the compile buffer before new output
;;       (let ((process (start-process "latexmk" compile-buffer "latexmk" "-pdf" buffer-file-name)))
;;         (set-process-sentinel process 'my-latexmk-sentinel)))))

;; (defun my-update-pdf-buffers (pdf-file)
;;   "Update all open PDF buffers displaying PDF-FILE if the version on disk is newer."
;;   (dolist (buffer (buffer-list))
;;     (with-current-buffer buffer
;;       (when (and (eq major-mode 'pdf-view-mode) ; Check if the buffer is in pdf-view-mode
;;                  buffer-file-name
;;                  (string-equal (file-truename buffer-file-name) (file-truename pdf-file)))
;;         (let ((current-mod-time (visited-file-modtime))
;;               (disk-mod-time (nth 5 (file-attributes pdf-file))))
;;           (when (time-less-p current-mod-time disk-mod-time)
;;             (revert-buffer t t t) ; Revert the buffer if the file on disk is newer
;;             (message "PDF updated: %s" pdf-file)))))))

;; (defun my-latexmk-sentinel (process event)
;;   "Sentinel for handling latexmk process termination."
;;   (when (string-match-p "finished" event)
;;     (if (= (process-exit-status process) 0)
;;         (progn
;;           (message "latexmk compilation successful")
;;           (let ((pdf-file (concat (file-name-sans-extension buffer-file-name) ".pdf")))
;;             (when (file-exists-p pdf-file)
;;               (my-update-pdf-buffers pdf-file)))) ; Call the update function after successful compilation
;;       (message "latexmk compilation failed: %s" event))))

;; ;; (add-hook 'latex-mode-hook 'my-latex-mode-setup)

;; (add-hook 'after-save-hook 'my-latexmk-compile)

;; (defun my-latex-mode-setup ()
;;   "Add latexmk compile to the save hook."
;;   (add-hook 'after-save-hook 'my-latexmk-compile nil t))

;; (add-hook 'latex-mode-hook 'my-latex-mode-setup)

(use-package lsp-julia
  :config
  (setq lsp-julia-default-environment "~/.julia/environments/v1.10"))

(use-package yasnippet
  :ensure t
  :config
  (setq yas-snippet-dirs
      '("~/.emacs.d/snippets"))
  (yas-global-mode 1) 
  (add-hook 'LaTeX-mode-hook #'yas-minor-mode)
  (add-hook 'latex-mode-hook #'yas-minor-mode))


;; use-package with package.el:
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner 'logo))

(add-to-list 'auto-mode-alist '("\\.tex\\'" . latex-mode))

(setq font-latex-script-display nil)
(with-eval-after-load 'font-latex
  ;; Set the face attributes after font-latex has loaded
  (set-face-attribute 'font-latex-superscript-face nil :height 1.0)  ; Default size for superscripts
  (set-face-attribute 'font-latex-subscript-face nil :height 1.0))

(add-to-list 'load-path (expand-file-name "~/.emacs.d/emacs-livedown"))

(require 'livedown)

(defun latexmk-init ()
  "Open a new vterm buffer, change the buffer name to '*latex-compile-BUFFERNAME*',
change to the current buffer's directory, and run 'latexmk -pdf -pvc FILENAME'."
  (interactive)
  ;; Get the directory of the current buffer and the file name
  (let* ((default-directory (file-name-directory (buffer-file-name)))
         (file-name (file-name-nondirectory (buffer-file-name)))
         (buffer-name (file-name-base (buffer-file-name))))
    ;; Open a new vterm buffer
    (vterm)
    ;; Rename the vterm buffer to *latex-compile-BUFFERNAME*
    (rename-buffer (concat "*latexmk-" buffer-name "*"))
    ;; Send the 'cd' command to change to the directory of the current buffer
    (vterm-send-string (concat "cd " default-directory))
    (vterm-send-return)
    ;; Send the 'latexmk -pdf -pvc FILENAME' command
    (vterm-send-string (concat "latexmk -pdf -pvc -lualatex --shell-escape " file-name))
    (vterm-send-return)))

(add-to-list 'auto-mode-alist '("\\.jl\\'" . julia-mode))
(setq major-mode-remap-alist '((julia-ts-mode . julia-mode)))
