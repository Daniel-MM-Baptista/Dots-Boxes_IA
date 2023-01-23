;;;; procura.lisp
;;;; Funcoes dos metodos de procura
;;;; Autor: Daniel Baptista, Rafael Silva

;;;;;;;;;;;;;;
;; Closures ;;
;;;;;;;;;;;;;;
(let ((x 0)(alfa -99999) (beta 99999)(cortes-alfa 0)(cortes-beta 0)(nos-analisados 0))
  (defun set-alfa (valor)
    (setq alfa valor))
  (defun set-beta (valor)
    (setq beta valor))

  (defun get-alfa ()
    alfa)
  (defun get-beta ()
    beta)
  (defun get-nos-analisados ()
    nos-analisados)
  (defun get-cortes-alfa ()
    cortes-alfa)
  (defun get-cortes-beta ()
    cortes-beta)

  (defun inc-nos-analisados ()
    (setq nos-analisados (1+ nos-analisados)))
  (defun inc-cortes-alfa ()
    (setq cortes-alfa (1+ cortes-alfa)))
  (defun inc-cortes-beta ()
    (setq cortes-beta (1+ cortes-beta)))

  (defun reset-alfa-beta ()
    (set-alfa 0)
    (set-beta 0))
  (defun reset-estatisticas ()
    (setq cortes-alfa 0)
    (setq cortes-beta 0)
    (setq nos-analisados 0))
  )

;;;;;;;;;;;;;;;;;;;;;;;;
;; Fun��es auxiliares ;;
;;;;;;;;;;;;;;;;;;;;;;;;

(defun filtrar-nos-filhos (nos)
  (reduce 'append (mapcar (lambda (no)
                            (cond((null (no-tabuleiro no)) NIL)
                                 (t (list no))))
                          nos)))

;;;;;;;;;;;;;;;;;;;;;;;;
;; Metodos de procura ;;
;;;;;;;;;;;;;;;;;;;;;;;;
;;Teste: (alfabeta (tabuleiro-teste) (operadores) 'sucessores 'avaliacao 2 2)
;;Resultado: 5
(defun alfabeta (no operadores sucessores avaliacao profundidade jogador)
  (format t "alfa ~A ~%" (get-alfa))
  (format t "beta ~A ~%" (get-beta))
  (format t "jogador ~A ~% " jogador)
  (format t "estado ~A ~% " no)
  (format t "avaliacao ~A ~%" (avaliacao-teste no jogador))
  (format t "~%")
  (labels ((maximizar (nos &optional (valor -10000000))
             (cond ((null nos) valor)
                   (t (let ((temp-valor (max valor (alfabeta (car nos) operadores sucessores avaliacao (1- profundidade) (trocar-jogador jogador)))))
                        (inc-nos-analisados)
                        (set-alfa (max (get-alfa) temp-valor))
                        (cond ((> (get-alfa) (get-beta))
                               (inc-cortes-beta)
                               temp-valor)
                              (t (maximizar (cdr nos) temp-valor)))))))
           (minimizar (nos &optional (valor 10000000))
             (cond ((null nos) valor)
                   (t (let ((temp-valor (min valor (alfabeta (car nos) operadores sucessores avaliacao (1- profundidade) (trocar-jogador jogador)))))
                        (inc-nos-analisados)
                        (set-beta (min (get-beta) temp-valor))
                        (cond ((< (get-beta) (get-alfa))
                               (inc-cortes-alfa)
                               temp-valor)
                              (t (minimizar (cdr nos) temp-valor))))))))
    (cond ((or (= 0 profundidade) (tabuleiro-preenchidop (no-tabuleiro no))) (avaliacao-teste no jogador))
          (t (let ((nos-filhos (filtrar-nos-filhos (sucessores no operadores jogador))))
               (cond ((= jogador 2) (maximizar nos-filhos))
                     (t (minimizar nos-filhos))))))))
