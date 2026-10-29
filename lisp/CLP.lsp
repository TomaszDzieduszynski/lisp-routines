;;; ==========================================================================
;;; CLP - draw a polyline that closes itself
;;; Command: CLP
;;; Version: 1.1.0 (2026)
;;;
;;; Starts the PLINE command. When you finish the polyline (Enter), it is
;;; closed automatically, so there is no need to pick the first point again
;;; or type C.
;;;
;;; Copyright (C) 2025-2026 Tomasz "bzqp" Dzieduszyński
;;; https://github.com/TomaszDzieduszynski/lisp-routines
;;; Free software under the GNU GPL v3 or later, WITHOUT ANY WARRANTY.
;;; Full license text: https://www.gnu.org/licenses/gpl-3.0.txt
;;; ==========================================================================

(defun c:CLP (/ prevEnt lastEnt elist)
  ;; Starts the PLINE command and ensures the polyline is closed after creation.

  (setq prevEnt (entlast))  ;; Remember the last object before drawing

  (command "_.PLINE")  ;; Start the PLINE command
  (while (eq (getvar "CMDNAMES") "PLINE") (command PAUSE))  ;; Allow user to complete the polyline

  ;; Get the last created entity (the newly drawn polyline)
  (setq lastEnt (entlast))

  (cond
    ;; Nothing new was drawn (e.g. Enter before the first point):
    ;; leave the previously drawn objects alone
    ((or (null lastEnt) (equal lastEnt prevEnt))
     (princ "\nNo polyline drawn.")
    )
    ;; Not a polyline
    ((not (eq (cdr (assoc 0 (setq elist (entget lastEnt)))) "LWPOLYLINE"))
     (princ "\nError: No polyline detected!")
    )
    ;; Already closed (C typed while drawing): nothing to do
    ((= 1 (logand 1 (cdr (assoc 70 elist))))
     (princ "\nPolyline already closed.")
    )
    ;; Close the polyline
    (T
     (command "_.PEDIT" lastEnt "_C" "")
     (princ "\nPolyline automatically closed.")  ;; Notify the user
    )
  )

  (princ)  ;; Suppresses extra command line output
)

(princ "\nCLP loaded. Type CLP to draw a closed polyline.")
(princ)
