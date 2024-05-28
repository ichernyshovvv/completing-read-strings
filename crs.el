;;; crs.el --- Read strings in the minibuffer, with completion -*- lexical-binding: t; -*-

;; Copyright (C) 2024  Ilya Chernyshov

;; Author: Ilya Chernyshov <ichernyshovvv@gmail.com>
;; Version: 0.1-pre
;; Package-Requires: ((emacs "29.1"))
;; Keywords: completion, minibuffer, multiple elements, matching
;; URL: https://github.com/ichernyshovvv/crs

;;; License:

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

;; USAGE:

;; (crs "PROMPT: " '("first" "sec,ond" "third"))

;; <return> - add a candidate to the list of chosen
;; C-<backspace> - delete the last chosen candidate
;; C-<return> - exit completion, return the list of chosen

;;; Code:

(defun crs-erase ()
  "Erase the last chosen candidate from the list."
  (interactive)
  (throw 'crs 'erase))

(defun crs-end ()
  "Finish reading of candidate strings."
  (interactive)
  (throw 'crs 'end))

(define-minor-mode crs-minor-mode
  "Toggle crs minor mode."
  :keymap
  (define-keymap
    "C-<backspace>" #'crs-erase
    "C-<return>" #'crs-end))

(defun crs--read (prompt collection &optional list-of-chosen predicate
                         require-match initial-input hist def
                         inherit-input-method)
  (minibuffer-with-setup-hook #'crs-minor-mode
    (catch 'crs
      (completing-read
       (concat prompt
               (when list-of-chosen
                 (concat
                  "[" (string-join
                       (reverse list-of-chosen)
                       (propertize "," 'face 'error))
                  "] ")))
       collection predicate require-match initial-input
       hist def inherit-input-method))))

;;;###autoload
(defun crs (prompt collection &optional predicate require-match initial-input
                   hist def inherit-input-method)
  "Read multiple strings in the minibuffer, with completion.
The arguments are the same as those of `completing-read'.

\\<minibuffer-local-must-match-map>
To select the matched completion candidate, press \\[minibuffer-complete-and-exit].
\\<crs-minor-mode-map>
To erase the last chosen candidate, press \\[crs-erase]
To finish reading, press \\[crs-end].
This function returns a list of the strings that were read,
with empty strings removed."
  (let (list-of-chosen done)
    (while (not done)
      (pcase (crs--read prompt collection list-of-chosen predicate require-match
                        initial-input hist def inherit-input-method)
        (`erase
         (when list-of-chosen
           (push (pop list-of-chosen) collection)))
        (`end (setq done t))
        ((and chosen _)
         (push chosen list-of-chosen)
         (setq collection (remove chosen collection)))))
    (or list-of-chosen def)))

(put 'minibuffer-complete-and-exit :advertised-binding [?\C-m])

(provide 'crs)

;;; crs.el ends here
