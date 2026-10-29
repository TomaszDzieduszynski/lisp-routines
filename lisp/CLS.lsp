;;; ==========================================================================
;;; CLS - close polylines and splines
;;; Command: CLS
;;; Version: 1.1.0 (2026)
;;;
;;; Click a polyline or spline to close it, or click empty space to start a
;;; selection window and close every polyline and spline inside it.
;;; Already closed objects and objects on locked layers are counted and
;;; reported. One Ctrl+Z undoes the whole command.
;;;
;;; Copyright (C) 2025-2026 Tomasz "bzqp" Dzieduszyński
;;; https://github.com/TomaszDzieduszynski/lisp-routines
;;; Free software under the GNU GPL v3 or later, WITHOUT ANY WARRANTY.
;;; Full license text: https://www.gnu.org/licenses/gpl-3.0.txt
;;; ==========================================================================

(vl-load-com)

;;; -- cls:close-spline -------------------------------------------------------
;;; Close a spline. Tries the ActiveX Closed2 property first,
;;; falls back to SPLINEDIT if that property isn't available.
(defun cls:close-spline (obj / r echo)
  (setq r (vl-catch-all-apply 'vlax-put-property (list obj 'Closed2 :vlax-true)))
  (if (vl-catch-all-error-p r)
    (progn
      (setq echo (getvar "CMDECHO"))
      (setvar "CMDECHO" 0)
      (vl-catch-all-apply
        'command
        (list "_.SPLINEDIT" (vlax-vla-object->ename obj) "_Close" "_eXit")
      )
      (setvar "CMDECHO" echo)
    )
  )
  (= (vla-get-Closed obj) :vlax-true)
)

;;; -- c:CLS ------------------------------------------------------------------

(defun c:CLS (/ doc ss i obj name ok done already failed)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (princ "\nSelect a polyline to close (or click empty space to draw a selection window): ")
  ;; "_:S" = single selection: one pick, or one window/crossing started
  ;; by clicking empty space. Filter keeps only polylines and splines.
  (setq ss (ssget "_:S" '((0 . "LWPOLYLINE,POLYLINE,SPLINE"))))
  (if (not ss)
    (princ "\nNo polylines selected.")
    (progn
      (vla-StartUndoMark doc)
      (setq i 0 done 0 already 0 failed 0)
      (repeat (sslength ss)
        (setq obj  (vlax-ename->vla-object (ssname ss i))
              name (vla-get-ObjectName obj)
              i    (1+ i))
        (cond
          ;; Skip meshes (polyface/polygon mesh are also POLYLINE entities)
          ((not (member name '("AcDbPolyline" "AcDb2dPolyline" "AcDb3dPolyline" "AcDbSpline"))))
          ((= (vla-get-Closed obj) :vlax-true)
           (setq already (1+ already)))
          (t
           (setq ok
             (if (eq name "AcDbSpline")
               (cls:close-spline obj)
               (not (vl-catch-all-error-p
                      (vl-catch-all-apply 'vla-put-Closed (list obj :vlax-true))))
             )
           )
           (if ok
             (setq done (1+ done))
             (setq failed (1+ failed))   ; e.g. object on a locked layer
           )
          )
        )
      )
      (vla-EndUndoMark doc)
      (princ (strcat "\nClosed: " (itoa done)
                     (if (> already 0) (strcat "  |  Already closed: " (itoa already)) "")
                     (if (> failed 0) (strcat "  |  Could not close (locked layer?): " (itoa failed)) "")))
    )
  )
  (princ)
)

(princ "\nCLS loaded. Type CLS to close polylines.")
(princ)
