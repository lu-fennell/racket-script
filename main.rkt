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
  racket/format
  
  shell/pipeline
  (for-syntax shell/pipeline))

(provide
 (all-from-out shell/pipeline)
 ;; Pipeline/command utilities
 continue-on-error
 run-pipeline/script
 $>
 run-pipeline/script/out
 $$>
 run-pipeline/script/success?
 ?>
 and/success/script
 &&
 or/success/script
 ||

 ;; Path utilities
 +/+
 build-path-home
 ~/
 )

;; When true, $> will not throw an exception when the pipeline fails.
;; In the (inverse) spirit of bash's "set -e"
(define continue-on-error (make-parameter #f))

;; A wrapper around "run-pipeline" which sets
;; status-and? to #t and throws an error when the pipeline fails
(define (run-pipeline/script
         #:in [in (current-input-port)]	 	 	 	 
         #:out [out (current-output-port)]	 	 	 	 
         #:default-err [default-err (current-error-port)]	 	 	 	 
         #:end-exit-flag [end-exit-flag #t]	 	 	 	 
         #:status-and? [status-and? #t]	 	 	 	 
         #:background? [bg? #f]
         . specs)
  (define status (apply run-pipeline
                        #:in in	 	 	 	 
                        #:out out	 	 	 	 
                        #:default-err default-err	 	 	 	 
                        #:end-exit-flag end-exit-flag	 	 	 	 
                        #:status-and? status-and?	 	 	 	 
                        #:background? bg?
                        specs
                        ))
  (unless (or (pipeline-success? status) (continue-on-error))
    ;; TODO: the error message should be more like the one of run-pipeline/out
    (error (~a "Pipeline " (~s specs) " failed: " status)))
  status)

;; a wrapper around run-pipeline/script
(define $> run-pipeline/script)


;; Like run-pipeline/script but don't error out on unsuccessful pipelines
(define (run-pipeline/script/success?
         #:in [in (current-input-port)]	 	 	 	 
         #:out [out (current-output-port)]	 	 	 	 
         #:default-err [default-err (current-error-port)]	 	 	 	 
         #:end-exit-flag [end-exit-flag #t]	 	 	 	 
         #:status-and? [status-and? #t]	 	 	 	 
         #:background? [bg? #f]
         . specs)
  (define status (apply run-pipeline
                        #:in in	 	 	 	 
                        #:out out	 	 	 	 
                        #:default-err default-err	 	 	 	 
                        #:end-exit-flag end-exit-flag	 	 	 	 
                        #:status-and? status-and?	 	 	 	 
                        #:background? bg?
                        specs
                        ))
  
  (pipeline-success? status))

;; Alias for run-pipeline/script/success?
(define ?> run-pipeline/script/success?)

;; Version of and/sucess that works with $> (by setting continue-on-error to #t)
(define-syntax-rule (and/success/script pipelines ...)
  (parameterize ([continue-on-error #t])
    (and/success pipelines ...)))

;; an alias for and/success/script
(define-syntax-rule (&& pipelines ...) (and/success/script pipelines ...))

;; Version of or/sucess that works with $> (by setting continue-on-error to #t)
(define-syntax-rule (or/success/script pipelines ...)
  (parameterize ([continue-on-error #t])
    (or/success pipelines ...)))

(define-syntax-rule (|| pipelines ...) (or/success/script pipelines ...))

;; "run-pipeline/out" with convenience modifiers
;; TODO: what's up with stderror redirection?
;; #:mod is one of '(lines trim concat raw)
(define (run-pipeline/script/out #:mod [mod 'trim]	 	 	 	 
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

;; Alias for run-pipeline/script/out
(define $$> run-pipeline/script/out)

;; Path utilities (UNIX!) ;;;;;;;;;;;;;;;;;;;;;;
;; TODO: document that I don't care about windows atm

;; an alias for "build-path"
;; TODO: check that we do not concatenate absolute paths
(define +/+ build-path)

;; like build path, but simplify first component (i.e. makes it absolute, even if it does not exist)
;; TODO: not quite sure what I want here..
(define (// path . paths)
  (apply build-path (simplify-path path) paths))

(define (build-path-home . paths)
  (apply +/+ (find-system-path 'home-dir) paths))

(define ~/ build-path-home)

;; TODO: what else? drop a path left and right?

;; Env utilities 



(module+ test
  ;; Tests to be run with raco test
  )


(module+ main
  ;; Main entry point, executed when run with the `racket` executable or DrRacket.
  )
