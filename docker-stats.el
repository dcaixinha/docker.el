;;; docker-stats.el --- Emacs interface to docker-stats  -*- lexical-binding: t -*-

;; Author: Daniel Caixinha <daniel@caixinha.pt>

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;;; Code:

(require 's)
(require 'dash)
(require 'json)
(require 'tablist)
(require 'transient)

(require 'docker-core)
(require 'docker-utils)

(defgroup docker-stats nil
  "Docker stats customization group."
  :group 'docker)

(defun docker-stats-stream ()
  "Return th data for `tabulated-list-entries'."
  (let* ((fmt "table {{.ID}}\t{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}\t{{.PIDs}}"))
    (docker-run-docker "stats --no-stream " (docker-stats-arguments) (format "--format=\"%s\"" fmt))))

(defun docker-stats-arguments ()
  "Return the latest used arguments in the `docker-stats' transient."
  (car (alist-get 'docker-stats transient-history)))

(transient-define-prefix docker-stats ()
  "Transient for seeing stats."
  :man-page "docker-stats"
  ["Arguments"
   ("a" "All" "--all")
   ("f" "Format" "--format" read-string)
   ("s" "Don't Stream" "--no-stream")
   ("t" "Don't truncate" "--no-trunc")]
  ["Actions"
   ("s" "Stats" tablist-revert)])

(transient-define-prefix docker-stats-help ()
  "Help transient for docker stats."
  ["Docker stats help"
   ("s" "Stats"   docker-stats-stream)])

(defvar docker-stats-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "?" 'docker-stats-help)
    (define-key map "s" 'docker-stats-stream)
    map)
  "Keymap for `docker-stats-mode'.")

;;;###autoload
(defun docker-stats ()
  "See docker stats."
  (interactive)
  (docker-utils-pop-to-buffer "*docker-stats*")
  (docker-stats-stream))

;; (define-derived-mode docker-image-mode tabulated-list-mode "Images Menu"
;;   "Major mode for handling a list of docker images."
;;   (setq tabulated-list-format [("Repository" 30 t)("Tag" 20 t)("Id" 16 t)("Created" 23 t)("Size" 10 docker-image-human-size-predicate)])
;;   (setq tabulated-list-padding 2)
;;   (setq tabulated-list-sort-key docker-image-default-sort-key)
;;   (add-hook 'tabulated-list-revert-hook 'docker-image-refresh nil t)
;;   (tabulated-list-init-header)
;;   (tablist-minor-mode))

(provide 'docker-stats)

;;; docker-stats.el ends here
