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
(menu-bar-mode 1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq column-number-mode t
      frame-resize-pixelwise t
      inhibit-startup-screen t
      default-frame-alist '((font . "JetBrainsMono Nerd Font-12")))
(delete-selection-mode 1)
(global-auto-revert-mode 1)
(setq auto-revert-avoid-polling t)
(setq-default standard-indent 4)
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(global-hl-line-mode 1)

;;; Project management
(use-package projectile
  :config
  (projectile-mode +1)
  (setq projectile-switch-project-action #'projectile-dired)
  (defun my/project-setup ()
    "Setup actions when switching to a project."
    (when (projectile-project-root)
      ;; Switch to a perspective named after the project
      (when (fboundp 'persp-switch)
        (persp-switch (projectile-project-name)))
      ;; Open neotree at project root
      (neotree-dir (projectile-project-root))))
  (add-hook 'projectile-after-switch-project-hook #'my/project-setup)
  :bind-keymap ("C-c p" . projectile-command-map))



;;; Buffer isolation per project
(use-package perspective
  :straight t
  :custom
  (persp-mode-prefix-key (kbd "C-c M-p"))
  :config
  (persp-mode))

;;; Dashboard
(use-package dashboard
  :config
  (setq dashboard-startup-banner 'logo
        dashboard-center-content t
        dashboard-projects-backend 'projectile
        dashboard-projects-switch-function (lambda (dir)
                                            (require 'claude-code-ide)
                                            (my/open-project-with-claude-from-dir dir))
        dashboard-items '((recents . 5)
                          (projects . 5)))
  (dashboard-setup-startup-hook))

;;; Shell environment (macOS/Linux GUI)
(use-package exec-path-from-shell
  :config (when (memq window-system '(mac ns x))
            (exec-path-from-shell-initialize)))

;;; Terminal emulator
(use-package eat
  :straight t
  :hook (eshell-load . eat-eshell-mode))

;;; Theme and modeline
(use-package doom-themes
  :straight t
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-one t))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :config (setq doom-modeline-height 25))

;;; Icons
(use-package nerd-icons)
(use-package all-the-icons)

;; (use-package treemacs)

;; (use-package treemacs-nerd-icons
;;   :after (treemacs nerd-icons)
;;   :config
;;   (treemacs-load-theme "nerd-icons"))

(use-package all-the-icons
  :if (display-graphic-p))

(use-package treemacs-all-the-icons
  :after (treemacs all-the-icons)
  :config
  (treemacs-load-theme "all-the-icons"))

;;; File tree / UI
(use-package neotree
  :config (setq neo-theme (if (display-graphic-p) 'icons 'arrow)
               neo-window-width 35))



;;; Completion and Search
(use-package vertico
  :straight t
  :config (vertico-mode))

(use-package deadgrep
  :straight t)

;;; Git
(use-package magit
  :bind ("C-x g" . magit-status))

(use-package diff-hl
  :straight t
  :hook ((prog-mode . diff-hl-mode)
         (text-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode)
         (magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  (diff-hl-flydiff-mode))

;;; Programming
(use-package rainbow-delimiters
  :straight t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package smartparens
  :straight t
  :hook (prog-mode . smartparens-mode))

(use-package indent-bars
  :straight t
  :custom
  (indent-bars-prefer-character t)
  (indent-bars-no-stipple-char ?│)
  (indent-bars-color '(highlight :face-bg t :blend 0.15))
  (indent-bars-color-by-depth '(:regexp "outline-\\([0-9]+\\)" :blend 1))
  (indent-bars-highlight-current-depth '(:blend 0.5))
  (indent-bars-display-on-blank-lines t)
  :hook (prog-mode . indent-bars-mode))

(use-package company
  :hook (prog-mode . company-mode))

;;; Tree-sitter (Emacs 29+ built-in)
(use-package treesit-auto
  :straight t
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;;; LSP Setup
(use-package lsp-mode
  :init (setq lsp-keymap-prefix "C-c l")
  :config
  (setq lsp-auto-guess-root nil
        lsp-keep-workspace-alive nil)
  (defun my/lsp-maybe ()
    (unless (derived-mode-p 'emacs-lisp-mode 'lisp-mode 'python-mode 'python-ts-mode)
      (lsp-deferred)))
  :hook (prog-mode . my/lsp-maybe))

(use-package lsp-ui
  :commands lsp-ui-mode)

(with-eval-after-load 'lsp-headerline
  (set-face-attribute 'lsp-headerline-breadcrumb-symbols-face nil
                      :foreground "#c678dd"))

(use-package pyvenv
  :straight t
  :init
  (defun my/pyvenv-find-root (dir)
    "Walk up from DIR to find nearest Python project root."
    (or (locate-dominating-file dir ".venv")
        (locate-dominating-file dir "pyproject.toml")
        (locate-dominating-file dir "setup.py")
        (locate-dominating-file dir "requirements.txt")))

  (defun my/pyvenv-auto-activate ()
    "Auto-activate venv from .venv, poetry, or uv."
    (let* ((start-dir (if buffer-file-name
                          (file-name-directory buffer-file-name)
                        default-directory))
           (root (my/pyvenv-find-root start-dir)))
      (message "[pyvenv] buffer-file-name: %s" buffer-file-name)
      (message "[pyvenv] start-dir: %s" start-dir)
      (message "[pyvenv] root: %s" root)
      (if (not root)
          (message "[pyvenv] No project root found!")
        (let ((venv-path (expand-file-name ".venv" root)))
          (message "[pyvenv] venv-path: %s (exists: %s)" venv-path (file-directory-p venv-path))
          (cond
           ;; .venv in project root
           ((file-directory-p venv-path)
            (pyvenv-activate venv-path)
            (message "[pyvenv] Activated venv: %s" venv-path))
           ;; Poetry external venv
           ((file-exists-p (expand-file-name "pyproject.toml" root))
            (let* ((expanded-root (expand-file-name root))
                   (cmd (format "cd \"%s\" && /opt/homebrew/bin/poetry env info -p 2>/dev/null" expanded-root))
                   (poetry-venv (string-trim (shell-command-to-string cmd))))
              (message "[pyvenv] poetry cmd: %s" cmd)
              (message "[pyvenv] poetry result: '%s' (exists: %s)" poetry-venv (file-directory-p poetry-venv))
              (if (and (not (string-empty-p poetry-venv))
                       (file-directory-p poetry-venv))
                  (progn
                    (pyvenv-activate poetry-venv)
                    (message "[pyvenv] Activated poetry venv: %s" poetry-venv))
                (message "[pyvenv] Poetry venv not found or invalid"))))
           (t (message "[pyvenv] No .venv and no pyproject.toml at root")))))))
  :config
  (add-hook 'pyvenv-post-activate-hooks
            (lambda () (when (bound-and-true-p lsp-mode) (lsp-restart-workspace)))))

(use-package lsp-pyright
  :straight t
  :hook ((python-mode . my/python-lsp-setup)
         (python-ts-mode . my/python-lsp-setup))
  :init
  (defun my/python-lsp-setup ()
    (my/pyvenv-auto-activate)
    (require 'lsp-pyright)
    (when pyvenv-virtual-env
      (let ((venv-dir (directory-file-name pyvenv-virtual-env)))
        (setq-local lsp-pyright-venv-path (file-name-directory venv-dir))
        (setq-local lsp-pyright-venv-directory (file-name-nondirectory venv-dir))))
    (lsp-deferred)))

(use-package eglot)

;;; Languages
(use-package markdown-mode
  :custom
  (markdown-fontify-code-blocks-natively t)
  (markdown-hide-urls nil)
  ;; GFM parsing; disable pandoc's built-in highlighter so highlight.js
  ;; (loaded in markdown-preview-mode) can style code blocks with the
  ;; GitHub palette instead of pandoc's default skylighting colors.
  (markdown-command "pandoc -f gfm -t html --syntax-highlighting=none"))

;; poly-markdown: real major-mode inside fenced code blocks (full font-lock,
;; indentation, and LSP hooks fire), plus gfm-mode for the prose.
;; markdown-preview-mode still works because it hooks after-change / after-save,
;; both of which fire regardless of polymode's inner buffers.
(use-package polymode :straight t)
(use-package poly-markdown
  :straight t
  :after (markdown-mode polymode)
  :mode (("\\.md\\'" . poly-gfm-mode)
         ("\\.markdown\\'" . poly-gfm-mode)))
(use-package markdown-preview-mode
  :straight t
  :after markdown-mode
  :bind (:map markdown-mode-map
              ("C-c C-v" . markdown-preview-mode))
  :custom
  (markdown-preview-delay-time 0.3)
  :config
  (setq markdown-preview-stylesheets
        (list "https://cdn.jsdelivr.net/npm/github-markdown-css@5.5.1/github-markdown.min.css"
              "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css"
              "<style>
                 body{box-sizing:border-box;max-width:980px !important;margin:0 auto !important;padding:45px !important;
                      font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Helvetica,Arial,sans-serif}
               </style>")
        markdown-preview-javascript
        (list "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"
              "<script>
                 window.mdHighlight = function() {
                   document.querySelectorAll('pre[class]').forEach(function(pre){
                     var code = pre.querySelector('code');
                     var lang = pre.classList[0];
                     if (code && lang && !code.className) {
                       code.classList.add('language-' + lang);
                     }
                   });
                   document.querySelectorAll('pre code').forEach(function(code){
                     code.removeAttribute('data-highlighted');
                     if (window.hljs) hljs.highlightElement(code);
                   });
                 };
               </script>")
        markdown-preview-script-oninit "window.addEventListener('load', mdHighlight);"
        markdown-preview-script-onupdate "mdHighlight();"))
(use-package go-mode
  :ensure t
  :hook ((go-mode . flycheck-mode)
         (go-mode . (lambda () (setq tab-width 4)))))
(add-hook 'go-ts-mode-hook
          (lambda ()
            (setq tab-width 4)
            (setq-local electric-indent-inhibit t)))

;;; Move text
(use-package move-text
  :config
  (global-unset-key [M-up])
  (global-unset-key [M-down])
  (global-set-key (kbd "M-n") 'move-text-down)
  (global-set-key (kbd "M-p") 'move-text-up))

;;; Dockerfile mode
(use-package dockerfile-mode
  :straight t
  :mode "Dockerfile\\'")

(use-package typescript-mode
  :straight t
  :config
  ;; Use tree-sitter modes for ts/tsx when available
  (when (treesit-available-p)
    (add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
    (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))))

;;; LaTeX
(use-package auctex)
(use-package auctex-latexmk)

(use-package lsp-latex
  :config
  (with-eval-after-load "tex-mode"
    (add-hook 'tex-mode-hook 'lsp)
    (add-hook 'latex-mode-hook 'lsp)))

(use-package pdf-tools
  :config (pdf-tools-install))

(setq tex-fontify-script nil
      font-latex-script-display nil)

(with-eval-after-load 'font-latex
  (set-face-attribute 'font-latex-superscript-face nil :height 1.0)
  (set-face-attribute 'font-latex-subscript-face nil :height 1.0))

(add-to-list 'auto-mode-alist '("\\.tex\\'" . latex-mode))

(use-package yasnippet
  :config
  (setq yas-snippet-dirs '("~/.emacs.d/snippets"))
  (yas-global-mode 1)
  (add-hook 'LaTeX-mode-hook #'yas-minor-mode)
  (add-hook 'latex-mode-hook #'yas-minor-mode))

;; `latexmk-init' relies on vterm for the compile pane.
(use-package vterm)

(defun latexmk-init ()
  "Open a vterm buffer for latexmk, a PDF preview, and split windows as follows:
- The left side (50% width) contains the LaTeX source on top and a vterm at the bottom.
- The right side (50% width) contains the PDF preview with auto-revert-mode enabled."
  (interactive)
  (let* ((file-dir (file-name-directory (buffer-file-name)))
         (file-name (file-name-nondirectory (buffer-file-name)))
         (buffer-name (file-name-base (buffer-file-name)))
         (pdf-file (concat file-dir buffer-name ".pdf")))
    (split-window-right)
    (other-window 1)
    (let ((default-directory file-dir))
      (find-file pdf-file)
      (auto-revert-mode 1))
    (other-window 1)
    (split-window-below)
    (other-window 1)
    (vterm)
    (rename-buffer (concat "*latexmk-" buffer-name "*"))
    (vterm-send-string (concat "cd " file-dir))
    (vterm-send-return)
    (vterm-send-string (concat "latexmk -pdf -pvc -lualatex --shell-escape " file-name))
    (vterm-send-return)
    (other-window 1)))


(use-package claude-code-ide
  :ensure nil
  :demand t
  :custom
  (claude-code-ide-use-ide-diff t)
  :config
  (defun my/iterm-project-window (dir name port &optional claude-args)
    "Open an iTerm2 window for project NAME at DIR.
PORT is the MCP WebSocket server port for IDE integration.
Top pane runs claude with IDE integration, bottom pane is a blank shell.
CLAUDE-ARGS is an optional string appended to the claude invocation."
    (let* ((venv-path (expand-file-name ".venv/bin/activate" dir))
           (venv-source (if (file-exists-p venv-path)
                            (concat " && source " venv-path)
                          ""))
           (claude-suffix (or claude-args ""))
           (script (format "
tell application \"iTerm2\"
  activate
  set newWindow to (create window with default profile)
  tell current session of newWindow
    set name to \"%s - Claude\"
    write text \"cd %s%s && CLAUDE_CODE_SSE_PORT=%d ENABLE_IDE_INTEGRATION=true claude%s\"
    set bottomPane to (split horizontally with default profile)
  end tell
  tell bottomPane
    set name to \"%s - Shell\"
    write text \"cd %s%s\"
  end tell
end tell" name (shell-quote-argument dir) venv-source port claude-suffix name (shell-quote-argument dir) venv-source)))
      (do-applescript script)))

  (defun my/find-frame-for-project (project-dir)
    "Find the Emacs frame whose perspective matches PROJECT-DIR."
    (let ((project-name (file-name-nondirectory
                         (directory-file-name (expand-file-name project-dir)))))
      (cl-find-if (lambda (frame)
                    (ignore-errors
                      (string= (persp-name (persp-curr frame)) project-name)))
                  (frame-list))))

  (defun my/select-frame-for-diff (orig-fn arguments)
    "Advice to select the correct frame before opening a diff.
Finds the frame whose perspective matches the project owning the file."
    (let* ((old-file-path (alist-get 'old_file_path arguments))
           (session (claude-code-ide-mcp--find-session-for-file old-file-path))
           (project-dir (and session (claude-code-ide-mcp-session-project-dir session)))
           (target-frame (and project-dir (my/find-frame-for-project project-dir))))
      (when target-frame
        (select-frame-set-input-focus target-frame))
      (funcall orig-fn arguments)))

  (defun my/select-frame-for-file (orig-fn arguments)
    "Advice to select the correct frame before opening a file."
    (let* ((path (alist-get 'path arguments))
           (session (and path (claude-code-ide-mcp--find-session-for-file path)))
           (project-dir (and session (claude-code-ide-mcp-session-project-dir session)))
           (target-frame (and project-dir (my/find-frame-for-project project-dir))))
      (when target-frame
        (select-frame-set-input-focus target-frame))
      (funcall orig-fn arguments)))

  (advice-add 'claude-code-ide-mcp-handle-open-diff :around #'my/select-frame-for-diff)
  (advice-add 'claude-code-ide-mcp-handle-open-file :around #'my/select-frame-for-file)

  (defun my/claude-code-iterm ()
    "Open iTerm2 with Claude Code in the current project directory.
Also ensures a perspective exists for the current project and
starts the MCP WebSocket server for IDE integration."
    (interactive)
    (let* ((dir (or (projectile-project-root) default-directory))
           (name (if (projectile-project-root)
                     (projectile-project-name)
                   (file-name-nondirectory (directory-file-name dir))))
           (port (claude-code-ide-mcp-start dir)))
      ;; Ensure perspective for current project
      (when (and (fboundp 'persp-switch) (projectile-project-root))
        (persp-switch name))
      (my/iterm-project-window dir name port)))

  (defun my/open-project-with-claude-from-dir (project-dir &optional claude-args)
    "Open PROJECT-DIR in a new frame with Claude Code.
Creates a new Emacs frame with its own perspective, opens dired +
starts the MCP server, and spawns an iTerm2 window.
CLAUDE-ARGS is an optional string appended to the claude invocation."
    (let* ((project-dir (file-name-as-directory (expand-file-name project-dir)))
           (project-name (file-name-nondirectory (directory-file-name project-dir)))
           (port (claude-code-ide-mcp-start project-dir))
           (frame (make-frame '((display . "") (vertical-scroll-bars . nil)))))
      (select-frame-set-input-focus frame)
      (persp-switch project-name)
      (dired project-dir)
      (my/pyvenv-auto-activate)
      (my/iterm-project-window project-dir project-name port claude-args)))

  (defun my/open-project-with-claude ()
    "Open a project in a new frame with isolated buffers and Claude Code."
    (interactive)
    (let* ((projects (projectile-relevant-known-projects))
           (project (completing-read "Open project: " projects nil t)))
      (my/open-project-with-claude-from-dir project)))
  :bind
  (("C-c c c" . my/claude-code-iterm)
   ("C-c c p" . my/open-project-with-claude)
   ("C-c ."   . claude-code-ide-insert-at-mentioned)))

(use-package agent-shell
    :ensure t
    :ensure-system-package
    ;; Add agent installation configs here
    ((claude . "brew install claude-code")
     (claude-agent-acp . "npm install -g @zed-industries/claude-agent-acp")))

;;; Custom extras
(load-file "~/.emacs.d/fds-syntax.el")

;;; Custom themes
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("9f297216c88ca3f47e5f10f8bd884ab24ac5bc9d884f0f23589b0a46a608fe14"
     "88f7ee5594021c60a4a6a1c275614103de8c1435d6d08cc58882f920e0cec65e"
     "7a3f3282c4ce1edc3387deb6f72ed31026ab7dfdf4c25ddcfad9008d2a5a5574"
     default))
 '(package-selected-packages
   '(pyvenv all-the-icons neotree csv-mode move-text go-mode
	    exec-path-from-shell vterm docker company deadgrep
	    doom-modeline doom-themes lsp-mode lsp-pyright lsp-ui
	    magit markdown-mode rainbow-delimiters smartparens vertico))
 '(package-vc-selected-packages '()))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
