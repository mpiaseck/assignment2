(require rsound)
(require rsound/piano-tones)

;hitting any keys in any order should toggle the appropriate circles
;world -> outputs circles
(define (gui_circle w) 
      (place-image (circle 50 (if (= (first w) 0) "outline" "solid") (if (= (first w) 0) "black" "blue")) 100 100
                   (place-image (rectangle 700 100 "outline" "black") 550 100
       (place-image (circle 50 (if (= (second w) 0) "outline" "solid") (if (= (second w) 0) "black" "red")) 100 250
                    (place-image (rectangle 700 100 "outline" "black") 550 250
       (place-image (circle 50 (if (= (third w) 0) "outline" "solid") (if (= (third w) 0) "black" "purple")) 100 400
                    (place-image (rectangle 700 100 "outline" "black") 550 400
       (place-image (circle 50 (if (= (fourth w) 0) "outline" "solid") (if (= (fourth w) 0) "black" "green")) 100 550
                    (place-image (rectangle 700 100 "outline" "black") 550 550
                    (empty-scene 1000 650)))))))))
        )

;hitting any keys in any order should toggle the appropriate circles
;world key -> world
  (define (onkey w key)
    (cond [(and (= (first w) 1) (key=? key "1")) (list 0 (second w) (third w) (fourth w))]
          [(and (= (second w) 1) (key=? key "2")) (list (first w) 0 (third w) (fourth w))]
          [(and (= (third w) 1) (key=? key "3")) (list (first w) (second w) 0 (fourth w))]
          [(and (= (fourth w) 1) (key=? key "4")) (list (first w) (second w) (third w) 0)]
          [(key=? key "1") (list 1 (second w) (third w) (fourth w))]
          [(key=? key "2") (list (first w) 1 (third w) (fourth w))]
          [(key=? key "3") (list (first w) (second w) 1 (fourth w))]
          [(key=? key "4") (list (first w) (second w) (third w) 1)]
          [(key=? key " ") (list 0 0 0 0)]
          [else w]
          )
    )
   
  #;(define (tock w)
    )
  
  (big-bang (list 0 0 0 0)
            [on-key onkey]
            [to-draw gui_circle]
            ;[on-tick tock 1/28]
            )




