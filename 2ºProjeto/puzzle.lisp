;;;; puzzle.lisp
;;;; Funcoes especificas ao dominio do jogo Dots and Boxes
;;;; Autor: Daniel Baptista, Rafael Silva

;;;;;;;;;;;;;;;;;;
;;; Tabuleiros ;;;
;;;;;;;;;;;;;;;;;;
(defun tabuleiro-inicial ()
  "Retorna um tabuleiro 5x6 (5 caixas na vertical por 6 caixas na horizontal)"
  '((
    ((0 0 0 0 0 0) (0 0 0 0 0 0) (0 0 0 0 0 0) (0 0 0 0 0 0) (0 0 0 0 0 0) (0 0 0 0 0 0))
    ((0 0 0 0 0) (0 0 0 0 0) (0 0 0 0 0) (0 0 0 0 0) (0 0 0 0 0) (0 0 0 0 0) (0 0 0 0 0))
    ) (0 0)))

(defun tabuleiro-teste ()
  "Retorna um tabuleiro 2x2 usado para testes"
  '((
    ((1 0) (0 0) (0 0))
    ((1 0) (1 0) (0 0))
    ) (0 0)))

;;;;;;;;;;;;;;;;;;
;;; Selectores ;;;
;;;;;;;;;;;;;;;;;;
(defun no-tabuleiro (no)
  (first no))

(defun no-caixas (no)
  (second no))

(defun get-arcos-horizontais (tabuleiro-estado)
  "Retorna os arcos horizontais de um tabuleiro"
  (first tabuleiro-estado))

(defun get-arcos-verticais (tabuleiro-estado)
  "Retorna os arcos verticais de um tabuleiro"
  (second tabuleiro-estado))

(defun get-arco-na-posicao (pos-lista-arcos pos-arco arcos)
  "Retorna o arco numa posicao passada por argumento de uma lista de arcos horizontais ou verticais"
  (nth (1- pos-arco) (nth (1- pos-lista-arcos) arcos)))

;;;;;;;;;;;;;;;;;;
;;; Operadores ;;;
;;;;;;;;;;;;;;;;;;
(defun operadores ()
 "Cria uma lista com todos os operadores do problema das vasilhas."
 (list 'arco-horizontal 'arco-vertical))

(defun arco-horizontal (pos-lista-arcos pos-arco tabuleiro-estado &optional (x 1))
  "Coloca um arco horizontal num tabuleiro, na posicao passada por argumento"
  (let* ((arcos-hor (car tabuleiro-estado))
        (linhas (length arcos-hor))
        (colunas (length (car arcos-hor))))
    (cond ((or (> pos-lista-arcos linhas)(> pos-arco colunas)) NIL)
          ((/= 0 (get-arco-na-posicao pos-lista-arcos pos-arco arcos-hor)) NIL)
          (t (cons (arco-na-posicao pos-lista-arcos pos-arco arcos-hor x) (cdr tabuleiro-estado))))))

(defun arco-vertical (pos-lista-arcos pos-arco tabuleiro-estado &optional (x 1))
  "Coloca um arco vertical num tabuleiro, na posicao passada por argumento"
  (let* ((arcos-ver (cadr tabuleiro-estado))
        (linhas (length arcos-ver))
        (colunas (length (car arcos-ver))))
    (cond ((or (> pos-lista-arcos linhas)(> pos-arco colunas)) NIL)
          ((/= 0 (get-arco-na-posicao pos-lista-arcos pos-arco arcos-ver)) NIL)
          (t (cons (car tabuleiro-estado) (cons (arco-na-posicao pos-lista-arcos pos-arco arcos-ver x) nil))))))

;;;;;;;;;;;;;;;;;;;;;;;;
;;; Fun��o avalia��o ;;;
;;;;;;;;;;;;;;;;:;;;;;;;
;;Fun��o de avalia��o
;;+10 por cada caixa do MAX(Computador)
;;-10 por cada caixa do MIN(Adversario)
;;+5 por cada caixa com 3 lados fechados
;;-5 por cada caixa com 2 lados fechados
(defun avaliacao (no)
  (+ (* 5 (contar-caixas-n-lados (no-tabuleiro no) 3)) (* -5 (contar-caixas-n-lados (no-tabuleiro no) 2)) (* 10 (second (no-caixas no))) (* -10 (first (no-caixas no)))))

;;;;;;;;;;;;;;;;;;
;;; Sucessores ;;;
;;;;;;;;;;;;;;;;;;
(defun novo-sucessor (no l i operador jogador)
  (let* ((novo-estado (funcall operador l i (no-tabuleiro no) jogador))     
         (novas-caixas (let ((caixas (jogada-caixa-fechadas no novo-estado)))
                         (cond ((/= caixas 0) (cond ((= jogador 1) (list (+ caixas (first (no-caixas no))) (second (no-caixas no))))
                                                    (t (list (first (no-caixas no)) (+ caixas (second (no-caixas no)))))))
                               (t (no-caixas no))))))
    (list novo-estado novas-caixas)))

;;(sucessores (tabuleiro-teste) (operadores) 2)
(defun sucessores (no operadores jogador)
  (let* ((arcos-hor (get-arcos-horizontais (no-tabuleiro no)))
         (arcos-vert (get-arcos-verticais (no-tabuleiro no)))
         (l-maximo (max (length arcos-hor) (length arcos-vert)))
         (i-maximo (max (length (car arcos-hor)) (length (car arcos-vert)))))
    (labels ((iterar-tabuleiro (l i)
               (cond ((> l l-maximo) NIL)
                     ((> i i-maximo) (iterar-tabuleiro (1+ l) 1))
                     (t (append (mapcar (lambda (op) (novo-sucessor no l i op jogador)) operadores) (iterar-tabuleiro l (1+ i)))))))
      (iterar-tabuleiro 1 1))))

;;;;;;;;;;;;;;;;;;;;;;;;
;; Fun��es auxiliares ;;
;;;;;;;;;;;;;;;;;;;;;;;;
(defun substituir (indice lista &optional (x 1))
  "Dada uma lista e um indice, substitui o valor nessa posicao por outro passado por argumento"
  (cond ((null lista) nil)
        ((= (1- indice) 0) (cons x (substituir (1- indice) (cdr lista) x)))
        (t (cons (car lista) (substituir (1- indice) (cdr lista) x)))))

(defun arco-na-posicao (pos-lista-arcos pos-arco lista-arcos &optional (x 1))
  "Insere um arco nos arcos horizontais ou verticais de um tabuleiro, na posicao escolhida"
  (cond ((= (1- pos-lista-arcos) 0) (cons (substituir pos-arco (car lista-arcos) x) (cdr lista-arcos)))
        (t (cons (car lista-arcos) (arco-na-posicao (1- pos-lista-arcos) pos-arco (cdr lista-arcos) x)))))

;;Teste:(tabuleiro-preenchidop (no-tabuleiro (tabuleiro-teste)))
;;Resultado: NIL
(defun tabuleiro-preenchidop (estado)
  (let* ((arcos-hor (get-arcos-horizontais estado))
         (arcos-vert (get-arcos-verticais estado))
         (num-arcos-hor (length arcos-hor))
         (num-arcos-vert (length arcos-vert))
         (indice-a-usar (max num-arcos-hor num-arcos-vert)))
    (labels ((ver-tabuleiro (l c)
               (cond ((> l indice-a-usar) T)
                     (t (let ((valor-arco-hor (get-arco-na-posicao l c arcos-hor))
                              (valor-arco-vert (get-arco-na-posicao l c arcos-vert)))
                          (cond ((or (eq valor-arco-hor 0)(eq valor-arco-vert 0)) NIL)
                                ((= c indice-a-usar) (ver-tabuleiro (1+ l) 1))
                                (t (ver-tabuleiro l (1+ c)))))))))
      (ver-tabuleiro 1 1))))

(defun obter-jogada-atraves-estado-final (estado-inicial estado-final jogador)
  (let* ((arcos-hor (get-arcos-horizontais (no-tabuleiro estado-inicial)))
         (arcos-vert (get-arcos-verticais (no-tabuleiro estado-inicial)))
         (l-maximo (max (length arcos-hor) (length arcos-vert)))
         (i-maximo (max (length (car arcos-hor)) (length (car arcos-vert)))))
    (labels ((iterar-tabuleiro (l i)
               (let ((jogadas (mapcar (lambda (op) (novo-sucessor estado-inicial l i op jogador)) (operadores))))
                 (cond ((equal estado-final (first jogadas)) (list l i 'arco-horizontal))
                       ((equal estado-final (second jogadas)) (list l i 'arco-vertical))
                       ((> l l-maximo) NIL)
                       ((> i i-maximo) (iterar-tabuleiro (1+ l) 1))
                       (t (iterar-tabuleiro l (1+ i)))))))
      (iterar-tabuleiro 1 1))))

(defun vencedor (caixas)
  (cond ((> (first caixas) (second caixas)) "Jogador 1")
        ((< (first caixas) (second caixas)) "Jogador 2")
        (t "Empate")))

(defun contar-caixas-n-lados (estado num-lados &optional (l 1) (i 1))
  (let* ((arcos-hor (get-arcos-horizontais estado))
         (arcos-vert (get-arcos-verticais estado))
         (num-total-arcos-hor (1- (length arcos-hor)))
         (num-total-indices-hor (length (car arcos-hor))))
    (labels ((iterar-tabuleiro (l i)
               (cond ((> l num-total-arcos-hor) 0)
                     (t (let ((caixa (estado-caixap arcos-hor arcos-vert num-lados l i)))
                          (cond ((and caixa (= i num-total-indices-hor)) (+ 1 (iterar-tabuleiro (1+ l) 1)))
                                (caixa (+ 1 (iterar-tabuleiro l (1+ i))))
                                ((= i num-total-indices-hor) (iterar-tabuleiro (1+ l) 1))
                                (t (iterar-tabuleiro l (1+ i)))))))))
      (iterar-tabuleiro l i))))

(defun estado-caixap(arcos-hor arcos-vert num-lados l i)
  (let* ((lado-1 (get-arco-na-posicao l i arcos-hor))
         (lado-2 (get-arco-na-posicao (1+ l) i arcos-hor))
         (lado-3 (get-arco-na-posicao i l arcos-vert))
         (lado-4 (get-arco-na-posicao (1+ i) l arcos-vert))
         (num-lados-atual (apply '+ (mapcar (lambda (lado)
                                              (cond ((/= 0 lado) 1)
                                                    (t 0)))
                                            (list lado-1 lado-2 lado-3 lado-4)))))
    (= num-lados-atual num-lados)))

(defun selecionar-jogada-avaliacao (estado func-avaliacao avaliacao)
  (first (reduce 'append (mapcar (lambda (sucessor) 
                                   (cond ((and (= (funcall func-avaliacao sucessor) avaliacao)(not (null (no-tabuleiro sucessor)))) (list sucessor))
                                         (t NIL)))
                                 (sucessores estado (operadores) 2)))))

(defun jogada-caixa-fechadap (estado-antigo estado-novo)
  (let ((num-caixas-antigo (apply '+ (no-caixas estado-antigo)))
        (num-caixas-novo (contar-caixas-n-lados estado-novo 4)))
    (cond ((/= num-caixas-antigo num-caixas-novo) T)
          (t NIL))))

(defun jogada-caixa-fechadas (estado-antigo estado-novo)
  (let ((num-caixas-antigo (apply '+ (no-caixas estado-antigo)))
        (num-caixas-novo (contar-caixas-n-lados estado-novo 4)))
    (cond ((/= num-caixas-antigo num-caixas-novo) (- num-caixas-novo num-caixas-antigo))
          (t 0))))
