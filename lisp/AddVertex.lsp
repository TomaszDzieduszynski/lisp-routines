;;; ==========================================================================
;;; AddVertex - extend a polyline by adding a vertex at either end
;;; Command: ADDVERTEX
;;; Version: 1.3.0 (2026)
;;;
;;; Extends an LWPOLYLINE (or a LINE, converted automatically) by adding a
;;; vertex at the end closer to the picked point. Arc segments (bulges) are
;;; kept on the right segments when adding at either end. The polyline stays
;;; selected, so running ADDVERTEX again keeps extending it.
;;;
;;; Note: may work inconsistently across AutoCAD and GstarCAD versions.
;;;
;;; Copyright (C) 2025-2026 Tomasz "bzqp" Dzieduszyński
;;; https://github.com/TomaszDzieduszynski/lisp-routines
;;; Free software under the GNU GPL v3 or later, WITHOUT ANY WARRANTY.
;;; Full license text: https://www.gnu.org/licenses/gpl-3.0.txt
;;; ==========================================================================

;;; -- av:read-verts ----------------------------------------------------------
;;; Parse raw entget list -> (coords bulges)
;;; coords = flat list (x0 y0 x1 y1 ...)
;;; bulges = one value per vertex (0.0 when code 42 absent)
;;; DXF layout per vertex: (10 . (x y z)) then optionally (42 . bulge)
(defun av:read-verts (elist / pair code pt coords bulges pendingBulge started)
  (setq coords       '()
        bulges        '()
        pendingBulge  0.0
        started       nil)
  (foreach pair elist
    (setq code (car pair))
    (cond
      ((= code 10)
       ;; flush bulge accumulated for the PREVIOUS vertex
       (if started
         (setq bulges (append bulges (list pendingBulge)))
       )
       (setq pt           (cdr pair)   ; (x y z)
             coords       (append coords (list (car pt) (cadr pt)))
             pendingBulge 0.0
             started      T)
      )
      ((= code 42)
       (setq pendingBulge (cdr pair))
      )
    )
  )
  ;; flush last vertex bulge
  (if started
    (setq bulges (append bulges (list pendingBulge)))
  )
  (list coords bulges)
)

;;; -- av:write-verts ---------------------------------------------------------
;;; Rebuild entget list with new coords+bulges.
;;; - Updates group code 90 (vertex count)
;;; - Replaces all 10/42 pairs with the new vertex data
;;; - Omits 42 when bulge is 0.0 (matches AutoCAD convention)
(defun av:write-verts (elist newCoords newBulges
                       / pair code result nv injected idx x y b)
  (setq result   '()
        nv       (/ (length newCoords) 2)
        injected nil)
  (foreach pair elist
    (setq code (car pair))
    (cond
      ;; Update vertex count
      ((= code 90)
       (setq result (append result (list (cons 90 nv))))
      )
      ;; On first 10/42: inject all new vertices, then ignore remaining old ones
      ((or (= code 10) (= code 42))
       (if (not injected)
         (progn
           (setq idx 0)
           (while (< idx nv)
             (setq x (nth (* idx 2)       newCoords)
                   y (nth (+ (* idx 2) 1) newCoords)
                   b (nth idx             newBulges))
             ;; code 10 value must be a 3-element list (x y z)
             (setq result (append result (list (cons 10 (list x y 0.0)))))
             (if (/= b 0.0)
               (setq result (append result (list (cons 42 b))))
             )
             (setq idx (1+ idx))
           )
           (setq injected T)
         )
         ;; else: old vertex entry - discard
       )
      )
      ;; Keep everything else unchanged
      (T
       (setq result (append result (list pair)))
      )
    )
  )
  result
)

;;; -- c:AddVertex ------------------------------------------------------------

(defun c:AddVertex (/ ss sel entType elist vertData coords bulges nVerts
                      startPt endPt pt newCoords newBulges newElist
                      oldCmdEcho prependFlag)

  ;; -- 1. Resolve selection --------------------------------------------------
  ;; Priority: a) pickfirst  b) last used  c) prompt

  (setq ss  (ssget "I" '((0 . "LWPOLYLINE,LINE")))
        sel nil)

  (cond
    (ss
      (setq sel (ssname ss 0)))
    ((and *AddVertex_LastEnt* (entget *AddVertex_LastEnt*))
      (setq sel *AddVertex_LastEnt*
            ss  (ssadd sel)))
    (T
      (setq sel (car (entsel "\nSelect polyline or line: ")))
      (if sel
        (setq ss (ssadd sel))
        (progn (princ "\nNo entity selected.") (exit))
      )
    )
  )

  (if (not sel) (progn (princ "\nNo entity.") (exit)))

  ;; -- 2. Convert LINE -> LWPOLYLINE if needed --------------------------------

  (setq entType (cdr (assoc 0 (entget sel))))

  (if (equal entType "LINE")
    (progn
      (princ "\nLine detected - converting to polyline...")
      (setq oldCmdEcho (getvar "CMDECHO"))
      (setvar "CMDECHO" 0)
      (command "_.PEDIT" sel "_Y" "")
      (setvar "CMDECHO" oldCmdEcho)
      (setq sel     (entlast)
            ss      (ssadd sel)
            entType (cdr (assoc 0 (entget sel))))
      (if (not (equal entType "LWPOLYLINE"))
        (progn (princ "\nConversion to polyline failed.") (exit))
      )
      (princ "\nLine converted to polyline.")
    )
  )

  (if (not (equal entType "LWPOLYLINE"))
    (progn (princ "\nNot a polyline or line.") (exit))
  )

  ;; -- 3. Read vertices and bulges -------------------------------------------

  (setq elist    (entget sel)
        vertData (av:read-verts elist)
        coords   (car  vertData)
        bulges   (cadr vertData)
        nVerts   (/ (length coords) 2))

  (if (= nVerts 0) (progn (princ "\nEmpty polyline.") (exit)))

  ;; -- 4. Determine ends -----------------------------------------------------

  (setq startPt (list (nth 0 coords) (nth 1 coords))
        endPt   (list (nth (- (length coords) 2) coords)
                      (nth (- (length coords) 1) coords)))

  ;; -- 5. Pick new point -----------------------------------------------------

  (setq pt (getpoint "\nPick location to extend to: "))
  (if (not pt) (progn (princ "\nCancelled.") (exit)))

  ;; -- 6. Build new vertex lists ---------------------------------------------
  ;;
  ;; Bulge[i] describes the segment from vertex i to vertex i+1.
  ;;
  ;; APPEND (closer to end):
  ;;   New vertex at tail. Append 0.0 bulge. All existing indices unchanged.
  ;;
  ;; PREPEND (closer to start):
  ;;   New vertex at head. Prepend 0.0 bulge for the new segment (new -> old v0).
  ;;   Existing bulges shift right by 1, keeping every curve on its correct segment.

  (setq prependFlag (< (distance pt startPt) (distance pt endPt)))

  (if prependFlag
    (progn
      (setq newCoords (cons (car pt) (cons (cadr pt) coords)))
      (setq newBulges (cons 0.0 bulges))
    )
    (progn
      (setq newCoords (append coords (list (car pt) (cadr pt))))
      (setq newBulges (append bulges '(0.0)))
    )
  )

  ;; -- 7. Write back via entmod ----------------------------------------------

  (setq newElist (av:write-verts elist newCoords newBulges))
  (entmod newElist)
  (entupd sel)

  ;; -- 8. Chain: store entity and restore pickfirst --------------------------

  (setq *AddVertex_LastEnt* sel)
  (sssetfirst nil ss)

  (princ)
)

(princ "\nAddVertex loaded. Type ADDVERTEX to extend a polyline.")
(princ)
