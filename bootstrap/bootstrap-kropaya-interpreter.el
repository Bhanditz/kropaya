;;; -*- coding: utf-8; lexical-binding: t; -*-

(require 'cl-lib)

;; Parsing

; A parser takes (text pos data) and returns a parser-result.
(cl-defstruct parser-result pos data (match? t) (decoration nil))

;Combinators take one or more parsers and return a parser
(defun alt (&rest parsers)
  (lambda (text pos data)
    (let* ((base-result (make-parser-result :pos pos :data data :match? nil))
           (result base-result))
      (cl-loop 
        for parser in parsers
        if
          (parser-result-match? result)
          return result
        unless
          (parser-result-match? result)
          do (setq result base-result)
        do (let ((intermediate-result (funcall parser text pos data)))
             (setq result intermediate-result))
        finally (return result)
      ))))

(defun opt (parser)
  (lambda (text pos data) (
    (let ((result (funcall parser text pos data)))
      (if (parser-result-match? result)
        (result)
        (make-parser-result :pos pos :data data))))))

(defun seq (&rest parsers)
  (lambda (text pos data)
    (let* ((result (make-parser-result :pos pos :data data)))
      (cl-loop 
        for parser in parsers
        unless
          (parser-result-match? result)
          return result
        do (setq result (funcall parser text (parser-result-pos result) (parser-result-data result)))
        finally (return result)
      ))))

;;(setq foo (lambda (text pos struct) (princ "Foo: <") (princ text) (princ pos) (princ struct) (princ ">\n") (make-parser-result :pos pos :data struct :decoration "ffffooooo")))
;;(setq goo (lambda (text pos struct) (princ "Goo: <") (princ text) (princ pos) (princ struct) (princ ">\n") (make-parser-result :pos pos :data struct :decoration "ggggooooo" :match? nil)))
;;
;;(print "About to call seq(foo).")
;;
;;(princ (funcall (seq foo) "abcde" 2 '()))
;;
;;(print "About to call seq(foo, goo).")
;;
;;(princ (funcall (seq foo goo) "abcde" 2 '()))
;;
;;(print "About to call seq(goo, foo).")
;;
;;(princ (funcall (seq goo foo) "abcde" 2 '()))
;;
;;(print "About to call seq(goo).")
;;
;;(princ (funcall (seq goo) "abcde" 2 '()))

;;(defun pos-to-line-number (text pos)
;;  ())


;; Pattern matching + destructuring

;; Builder

(defun make-primitive (tag val)
    (list tag val))

;; Sum and product pairs are an alist of labe
(defun make-type-row (kind pairs)
  (make-primitive kind pairs))

(defun make-sum (pair)
  (make-primitive 'sum pair))

(defun make-product (pairs)
  (make-primitive 'product pairs))

(defun make-module (name quantifiers forest)
  (make-primitive 'module `((name . ,name) (quantifiers . ,quantifiers) (forest . ,forest))))

;(setq prelude (make-module 'prelude '() '()))
;
;(print prelude)
;(print (cadr prelude))
;
;(print (assq 'name (cadr prelude)))

;; AST

;; Read
;; Eval
;; Print
;; Runloop
;; Universe
;; Mirror

;; Prelude

; Load prelude + add edges as needed
