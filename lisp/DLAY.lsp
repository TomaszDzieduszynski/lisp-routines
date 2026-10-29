;;; ==========================================================================
;;; DLAY - Double LayOff: hide the layer of a clicked object, also in XREFs
;;; Command: DLAY
;;; Version: 1.1.0 (2026)
;;;
;;; Click objects one by one; the layer of each is hidden immediately.
;;; Uses nentsel to look inside XREFs and nested blocks and find the layer
;;; the clicked object really shows on. Press Enter or Esc to finish.
;;;   - On a layout (paper space or inside a viewport): the layer is frozen
;;;     in the current viewport (VPLAYER).
;;;   - In model space: the layer is turned off.
;;;
;;; Written as a workaround for LAYOFF working incorrectly in layout
;;; viewports in GstarCAD. In AutoCAD, LAYOFF already does this well.
;;;
;;; Copyright (C) 2026 Tomasz "bzqp" Dzieduszyński
;;; https://github.com/TomaszDzieduszynski/lisp-routines
;;; Free software under the GNU GPL v3 or later, WITHOUT ANY WARRANTY.
;;; Full license text: https://www.gnu.org/licenses/gpl-3.0.txt
;;; ==========================================================================

(defun C:DLAY (/ ent matrix pickresult lay done)

  (defun get-true-layer (pickresult / ent-list subent subents)
    ;; nentsel returns: (ename point matrix subentlist)
    ;; subentlist is ordered innermost parent first, XREF insert is always last.
    ;;
    ;; 1 parent   -> entity directly inside XREF -> use entity's own layer
    ;; 2+ parents -> block(s) nested inside XREF -> use subentlist[length-2]:
    ;;               the element just before the XREF (= topmost block in XREF,
    ;;               i.e. the one the user actually clicked on).
    ;;
    ;; Examples:
    ;;   Door   (2 parents): subentlist = [door-insert("XREF|Doors"), XREF]
    ;;                       length-2 = 0 -> "XREF|Doors"
    ;;   Shower (3 parents): subentlist = [part-insert("0"), shower("XREF|Sanitary"), XREF]
    ;;                       length-2 = 1 -> "XREF|Sanitary"
    (setq subent  (nth 0 pickresult))  ; innermost entity ename
    (setq subents (nth 3 pickresult))  ; parent block inserts list (nil if not nested)
    (if (and subents (> (length subents) 1))
      (cdr (assoc 8 (entget (nth (- (length subents) 2) subents))))  ; topmost block in XREF
      (cdr (assoc 8 (entget subent)))                                 ; entity's own layer
    )
  )

  (defun vp-cycle-freeze (layname)
    (command "_.VPLAYER" "_F" layname "" "")
    (command "_.VPLAYER" "_T" layname "" "")
    (command "_.VPLAYER" "_F" layname "" "")
  )

  (defun layoff-standard (layname / layer_obj)
    (setq layer_obj (tblobjname "LAYER" layname))
    (if layer_obj
      (vla-put-LayerOn (vlax-ename->vla-object layer_obj) :vlax-false)
    )
  )

  ;; -- Main ------------------------------------------------------------------
  (vl-load-com)
  (setq done nil)

  (princ "\nSelect object to freeze its layer (Enter to quit): ")

  (while (not done)
    (setq pickresult (nentsel "\nSelect object: "))
    (if (null pickresult)
      ;; Enter or right-click - exit loop
      (setq done T)
      (progn
        (setq lay (get-true-layer pickresult))
        (if lay
          (progn
            (if (= (getvar "TILEMODE") 0)
              ;; Layout context (paper space or inside viewport)
              (progn
                (vp-cycle-freeze lay)
                (princ (strcat "\nLayer '" lay "' viewport-frozen."))
              )
              ;; Model space - standard layer off
              (progn
                (layoff-standard lay)
                (princ (strcat "\nLayer '" lay "' turned off."))
              )
            )
          )
          (princ "\nCould not determine layer.")
        )
      )
    )
  )

  (princ)
)

(princ "\nDLAY loaded. Type DLAY to hide layers by clicking objects.")
(princ)
