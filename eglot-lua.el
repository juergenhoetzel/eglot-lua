;;; eglot-lua.el --- Lua eglot integration                     -*- lexical-binding: t; -*-

;; Copyright (C) 2019  Jürgen Hötzel

;; Author: Jürgen Hötzel <juergen@archlinux.org>
;; Package-Requires: ((eglot "1.4"))
;; Keywords: languages

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Lua eglot introduced

;;; Code:

(require 'eglot)
(require 'gnutls)

(defgroup eglot-lua nil
  "LSP support for the Lua Programming Language, using the Emmy Lua Language Server."
  :link '(url-link "https://github.com/EmmyLua/EmmyLua-LanguageServer")
  :group 'eglot)

(defcustom eglot-lua-server-install-dir
  (locate-user-emacs-file "EmmyLua-LanguageServer/")
  "Install directory for LanguageServer."
  :group 'eglot-lua
  :risky t
  :type 'directory)

(defcustom eglot-lua-server-version "0.3.0"
  "Emmy Lua version."
  :group 'eglot-lua
  :risky t
  :type 'string)

(defun eglot-lua--jar ()
  "Return Emmy Lua JAR path."
  (file-truename (concat eglot-lua-server-install-dir (format "EmmyLua-LS-all-%s.jar" eglot-lua-server-version))))

(defun eglot-lua--maybe-install ()
  "Downloads Emmy Lua, and set `eglot-lua-server-install-dir'."
  (make-directory eglot-lua-server-install-dir eglot-lua-server-install-dir)
  (let ((url (format "https://github.com/EmmyLua/EmmyLua-LanguageServer/releases/download/%s/EmmyLua-LS-all.jar" eglot-lua-server-version))
	(newname (eglot-lua--jar))
	(gnutls-algorithm-priority
	 (if (and (not gnutls-algorithm-priority)
		  (boundp 'libgnutls-version)
		  (>= libgnutls-version 30603)
		  (version<= emacs-version "26.2"))
	     "NORMAL:-VERS-TLS1.3"
	   gnutls-algorithm-priority)))
    (unless (file-exists-p newname)
      (url-copy-file url newname t))))

(defun eglot-lua (interactive)
  "Ensure Emmy Lua is installed when called INTERACTIVE.
Return `eglot' contact when Emmy is installed."
  (unless (or (file-exists-p (eglot-lua--jar)) (not interactive))
    (eglot-lua--maybe-install))
  (when (file-exists-p (eglot-lua--jar))
    `("java" "-cp" ,(eglot-lua--jar) "com.tang.vscode.MainKt")))

(add-to-list 'eglot-server-programs `(lua-mode . eglot-lua))

(provide 'eglot-lua)
;;; eglot-lua.el ends here


