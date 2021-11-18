
(define (quasiquote-helper tail x)
  (cond ((null? x) (reverse! tail))
        ((not (pair? x)) (list 'QUOTE x))
        ((eq? 'UNQUOTE (car x)) (car (cdr x)))
        ((eq? 'UNQUOTESPLICE (car x)) (error "invalid place"))
        ((and (pair? (car x))
              (eq? (car (car x)) 'UNQUOTESPLICE))

         (quasiquote-helper (reverse-append! (car (cdr (car x))) tail) (cdr x))
         )
        (else
          (quasiquote-helper (cons (quasiquote-helper '() (car x)) tail)
                              (cdr x)))

          ))

(define-macro quasiquote
              (lambda (x)
                (display x)
                (newline)
                (quasiquote-helper '() x)
                ))


(display  (macroexpand '`(1 ,x 3)))
(newline)
;(display  (macroexpand '`(1 ,@(2 2) 3)))



(define-macro do2
  (lambda (vars loop-check loop)
    (let ((names '())
          (inits '())
          (steps '())
          (func (gensym)))

    (for-each (lambda (var) 
                (push (car var) names)
                (set! var (cdr var))
                (push (car var) inits)
                (set! var (cdr var))
                (push (car var) steps))
              vars)

    (display loop-check)
    (newline)

    `((lambda (,func)
        (begin
          (set! ,func (lambda ,names
                        (if ,(car loop-check)
                            ,(car (cdr loop-check))
                            ,(cons 'BEGIN (list loop (cons func steps)))   
                            ))) 
          ,(cons func inits)
          )) '())
    )))

(display (macroexpand '(do2 ((i 0 (+ i 1))) 
                           ((> i 0) 'done)
                                    '())))

(newline)
(newline)

(define (cond-helper clauses)
  (if (null? clauses)
      '()
      (if (eq? (car (car clauses)) 'ELSE)
          (list 'BEGIN (cdr (car clauses)))
          (list 'IF
                (car (car clauses))
                (cons 'BEGIN (cdr (car clauses)))
                (cond-helper (cdr clauses))))))


(define-macro cond2
   (lambda clauses
     (begin
     (for-each (lambda (clause)
                 (if (null? (cdr clause))
                     (error "(cond (pred expression...)...)"))
                 ) clauses)
     (cond-helper clauses))))

(display (macroexpand '(cond2 ((= i 0) 'ZERO) ((= i 1) 'ONE) (else 'BIG) )))
(newline)
(display (macroexpand '(cond2 ((= i 0) 'ZERO) ((= i 1) 'ONE)  )))
(newline)
(display (macroexpand '(cond2 ((= i 0)) ((= i 1) 'ONE)  )))



