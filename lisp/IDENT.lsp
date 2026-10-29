;;; ==========================================================================
;;; IDENT - show the layer of a clicked object, also inside XREFs
;;; Command: IDENT
;;; Version: 1.0.0 (2025)
;;;
;;; Click objects one by one; the layer name of each is printed on the
;;; command line immediately. Uses nentsel, so it reads the layer of the
;;; object itself even inside XREFs and blocks. Press Enter or Esc to finish.
;;;
;;; Copyright (C) 2025 Tomasz "bzqp" Dzieduszyński
;;; https://github.com/TomaszDzieduszynski/lisp-routines
;;; Free software under the GNU GPL v3 or later, WITHOUT ANY WARRANTY.
;;; Full license text: https://www.gnu.org/licenses/gpl-3.0.txt
;;; ==========================================================================

(defun C:IDENT (/ pickresult lay)

  (defun get-true-layer (pickresult)
    (cdr (assoc 8 (entget (nth 0 pickresult))))
  )

  (princ "\nSelect object to identify its layer (Enter to quit): ")

  (while
    (progn
      (setq pickresult (nentsel "\nSelect object: "))
      pickresult
    )
    (setq lay (get-true-layer pickresult))
    (if lay
      (princ (strcat "\nLayer: " lay))
      (princ "\nCould not determine layer.")
    )
  )

  (princ)
)

(princ "\nIDENT loaded. Type IDENT to use.")
(princ)
