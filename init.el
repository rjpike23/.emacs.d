;;; Externalize customizations
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

;;; Editor defaults
(add-to-list 'load-path "~/.emacs.d/lisp")
(setq auto-save-default nil)
(setq make-backup-files nil)
(setq visible-bell 1)
(setq gc-cons-threshold (* 16 1024 1024))
(setq read-process-output-max (* 4 1024 1024))
(setq-default indent-tabs-mode nil)
(setq-default truncate-lines t)
(setq-default show-paren-mode t)
(setq-default size-indication-mode t)
(global-auto-revert-mode t)
(add-to-list 'default-frame-alist '(background-color . "ivory"))

;;; Config package manager
(require 'package)
(add-to-list 'package-archives
             '("gnu" . "http://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)
(package-install-selected-packages)

;;; Projectile
(require 'projectile)
(define-key projectile-mode-map (kbd "C-c C-p") 'projectile-command-map)
(projectile-mode +1)

;;; Purpose
(require 'window-purpose)
(purpose-mode)
(add-to-list 'purpose-user-mode-purposes '(flycheck-error-list-mode . fc-err))
;; Slime/cider both use a lot of buffers. Registering purposes using these
;; regexes allow us to create dedicated purposes for the repls.
(add-to-list 'purpose-user-regexp-purposes '("slime\\-[^r].*" . slime))
(add-to-list 'purpose-user-regexp-purposes '("slime\\-r.*" . cl-repl))
(add-to-list 'purpose-user-regexp-purposes '("cider\\-[^r].*". cider))
(add-to-list 'purpose-user-regexp-purposes '("cider\\-r.*" . clj-repl))
(purpose-compile-user-configuration)

;;; Completion and ido
(require 'company)
(require 'ido)
(require 'flx-ido)
(require 'smex)
(ido-mode t)
(ido-everywhere t)
(flx-ido-mode t)
(setq ido-enable-flex-matching t)
(setq ido-use-faces nil)
(smex-initialize)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

;;; Flycheck
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

(setq-default flycheck-disabled-checkers
              (append flycheck-disabled-checkers
                      '(javascript-jshint)
                      '(lsp-ui)))
(flycheck-add-mode 'javascript-eslint 'web-mode)

;;; Specific mode customizations below...
(defun prog-mode-custom ()
  "My generic programming mode customizations."
  (rainbow-delimiters-mode)
  (turn-on-diff-hl-mode)
  (diff-hl-flydiff-mode))

(add-hook 'prog-mode-hook 'prog-mode-custom)

;;; Lisp (elisp + Common Lisp) customizations.
(setq inferior-lisp-program "sbcl")
(setq slime-contribs '(slime-fancy slime-company))

(defun lisp-mode-custom ()
  "Lisp Mode customizations."
  (enable-paredit-mode)
  (company-mode)
  (company-quickhelp-mode 1)
  (local-set-key (kbd "TAB") #'company-indent-or-complete-common))

(add-hook 'emacs-lisp-mode-hook #'lisp-mode-custom)
(add-hook 'lisp-mode-hook #'lisp-mode-custom)
(add-hook 'slime-repl-mode-hook #'lisp-mode-custom)
(add-hook 'clojure-mode-hook #'lisp-mode-custom)
(add-hook 'cider-mode-hook #'lisp-mode-custom)
(add-hook 'cider-repl-mode-hook #'lisp-mode-custom)

;;; JavaScript customizations
(require 'lsp-mode)
(require 'web-mode)
(require 'smartparens)
(lsp-register-client
 (make-lsp-client :new-connection (lsp-stdio-connection
                                   (lambda ()
                                     `(,lsp-clients-typescript-server
                                       ,@lsp-clients-typescript-server-args)))
                  :activation-fn (lambda (filename major-mode)
                                   (and (string-suffix-p ".js" filename t)
                                        (string-suffix-p ".ts" filename t)
                                        (eq major-mode 'web-mode)))
                  :priority -1
                  :ignore-messages '("readFile .*? requested by TypeScript but content not available")
                  :server-id 'web-mode-jsts))

(defun javascript-mode-custom ()
  "Javascript customizations."
  (flymake-mode -1)
  (yas-minor-mode)
  (smartparens-mode)
  (sp-use-paredit-bindings)
  (lsp)
  (flycheck-add-next-checker 'lsp 'javascript-eslint))

(add-hook 'javascript-mode-hook #'javascript-mode-custom)
(add-hook 'web-mode-hook #'javascript-mode-custom)
(add-hook 'typescript-mode-hook #'javascript-mode-custom)
(setq web-mode-content-types-alist '(("jsx" . "\\.js[x]?\\'") ("tsx" . "\\.ts[x]?]]'")))
(setq web-mode-enable-auto-quoting nil)
(add-to-list 'auto-mode-alist '("\\.jsx?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.json\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tsx?\\'" . web-mode))

;;; Java customizations
(require 'dap-mode)
(require 'dap-java)
(require 'lsp-java)

(defun java-mode-custom ()
  "Java mode customizations."
  (lsp))

(add-hook 'java-mode-hook #'java-mode-custom)

;;; Python customizations
(require 'lsp-python-ms)
(require 'dap-python)
(require 'conda)
(setq lsp-python-ms-auto-install-server t)
(custom-set-variables '(conda-anaconda-home (expand-file-name "~/../../miniconda3")))
(setq conda-env-home-directory (expand-file-name "~/../../miniconda3"))

(defun python-mode-custom ()
  "Python customizations."
  (conda-env-initialize-eshell)
  (lsp))

(add-hook 'python-mode-hook #'python-mode-custom)

;; ## added by OPAM user-setup for emacs / base ## 56ab50dc8996d2bb95e7856a6eddb17b ## you can edit, but keep this line
(require 'opam-user-setup "~/.emacs.d/opam-user-setup.el")
;; ## end of OPAM user-setup addition for emacs / base ## keep this line
