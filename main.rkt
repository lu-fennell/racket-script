#lang racket/base

(module+ test
  (require rackunit))

;; Notice
;; To install (from within the package directory):
;;   $ raco pkg install
;; To install (once uploaded to pkgs.racket-lang.org):
;;   $ raco pkg install <<name>>
;; To uninstall:
;;   $ raco pkg remove <<name>>
;; To view documentation:
;;   $ raco docs <<name>>
;;
;; For your convenience, we have included a LICENSE.txt file, which links to
;; the GNU Lesser General Public License.
;; If you would prefer to use a different license, replace LICENSE.txt with the
;; desired license.
;;
;; Some users like to add a `private/` directory, place auxiliary files there,
;; and require them in `main.rkt`.
;;
;; See the current version of the racket style guide here:
;; http://docs.racket-lang.org/style/index.html

;; Code here

(require
  racket/match
  racket/string
  
  shell/pipeline
         (for-syntax shell/pipeline))

(provide
 (all-from-out shell/pipeline)
 $>
 $$>
 )

;; An alias for "run-pipeline"
(define $> run-pipeline)

;; "run-pipeline/out" with convenience modifiers
;; TODO: what's up with stderror redirection?
;; #:mod is one of '(lines trim concat raw)
(define ($$> #:mod [mod 'trim]	 	 	 	 
             #:end-exit-flag [end-exit-flag #t]	 	 	 	 
             #:status-and? [status-and? #f]	 	 	 	 
             . specs
             )
  (define raw-out
    (apply run-pipeline/out specs
         #:end-exit-flag end-exit-flag	 	 	 	 
         #:status-and? status-and?	 	 	 	 
         ))
  (match mod
    ['raw raw-out]
    ['lines (string-split raw-out "\n")]
    ['trim (string-trim raw-out)]
    ['concat (string-join (string-split raw-out "\n") " ")]
    [f #:when (procedure? f) (f raw-out)]))


;; Path utilities (UNIX!) ;;;;;;;;;;;;;;;;;;;;;;
;; TODO: document that I don't care about windows atm

;; an alias for "build-path"
;; TODO: check that we do not concatenate absolute paths
(define +/+ build-path)

;; like build path, but simplify first component (i.e. makes it absolute, even if it does not exist)
;; TODO: not quite sure what I want here..
(define (// path . paths)
  (apply build-path (simplify-path path) paths))

(define (~/ . paths)
  (apply +/+ (find-system-path 'home-dir) paths))

;; TODO: what else? drop a path left and right?

;; Env utilities 



(module+ test
  ;; Tests to be run with raco test
  )


(module+ main
  ;; Main entry point, executed when run with the `racket` executable or DrRacket.
  )
