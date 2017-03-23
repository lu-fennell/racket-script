#lang info
(define collection "script")
(define deps '("base"
               "rackunit-lib"
	       "shell-pipeline"
	       ))
(define build-deps '("scribble-lib" "racket-doc"))
(define scribblings '(("scribblings/script.scrbl" ())))
(define pkg-desc "Utilities for bash-like scripting in racket")
(define version "0.0")
(define pkg-authors '(lu-fennell))
