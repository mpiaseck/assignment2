;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname play-pause) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require rsound)
(require 2htdp/image)
(require 2htdp/universe)

(define SR 44100)
(define (s sec) (* SR sec))
(define (both a b) b)
(define END-TIME (* 25 44100))
(define START-TIME (* 0 44100))

(define snd (rs-read/clip "/Users/Matt/Google Drive/Cal Poly/CPE/Assignment 2/revolution.wav"
              START-TIME END-TIME))

;; a frame is a nonnegative integer

;; a world is (make-world frame frame boolean), representing
;; the frame at which to continue playing, and the
;; pstream time at which to play it, and whether it's playing
(define-struct system (world1 world2 world3 world4))
(define-struct world1 (play-head next-start playing?))
(define-struct world2 (play-head next-start playing?))
(define-struct world3 (play-head next-start playing?))
(define-struct world4 (play-head next-start playing?))
(define INITIAL-WORLD (make-world1 0 (s 0.5) false))
(define INITIAL-SYSTEM (make-system (make-world1 0 (s 0.5) false) 
                                     (make-world2 0 (s 0.5) false) 
                                     (make-world3 0 (s 0.5) false) 
                                     (make-world4 0 (s 0.5) false)))


;; PLAYING SOUNDS

;; how much of the song to play each time?
(define PLAY-CHUNK (round (s 0.1)))
;; how far ahead of time should we queue sounds?
(define LEAD-FRAMES (round (s 0.05)))

;; the pstream that we're going to use:
(define ps (make-pstream))


;; given the current pstream time and the next
;; time to play, return true if it's time to play
;; frame frame -> boolean
(define (time-to-play? cur next)
  (< (- next cur) LEAD-FRAMES))


;; queue a sound if it's time, and advance the
;; world and the playhead
;; number world -> world
(define (maybe-play-chunk cur w)
  (local [(define next-start (world1-next-start w))]
    (cond [(time-to-play? cur next-start)
           (local [(define playhead (if (< (world1-play-head w) END-TIME) (world1-play-head w) 0))
                   (define next-playhead (+ playhead PLAY-CHUNK))]
             (both (pstream-queue ps
                                  (clip snd playhead next-playhead)
                                  next-start)
                   (make-world1 next-playhead 
                               (+ next-start PLAY-CHUNK)
                               (world1-playing? w))))]
          [else w])))

;; call maybe-play-chunk if song is not paused
(define (maybe-maybe-play-chunk cur w)
  (cond [(world1-playing? w) (maybe-play-chunk cur w)]
        [else w]))

;; the on-tick function. calls maybe-play-chunk.
;; world -> world
(define (tock w)
  (maybe-maybe-play-chunk (pstream-current-frame ps) w))


;; THE GRAPHICS / UI 

(define WORLD-WIDTH 650)
(define WORLD-HEIGHT 650)
(define SLIDER-WIDTH (- WORLD-WIDTH 150))

;; draw a blank scene with a play head and a play/pause button
;; world -> scene
(define (draw-world w)
  (draw-play
   w
   (place-image (rectangle 10 100 "solid" "black")
                (+ 150
                   (* SLIDER-WIDTH (/ (world1-play-head w) (rs-frames snd))))
                100
                (place-image (rectangle 500 100 "outline" "black") 400 100
                (place-image (rectangle 500 100 "outline" "black") 400 250
                (place-image (rectangle 500 100 "outline" "black") 400 400
                (place-image (rectangle 500 100 "outline" "black") 400 550
                (empty-scene WORLD-WIDTH WORLD-HEIGHT))))))))


;; draw the appropriate play/pause shape on a scene
;; world scene -> scene
(define (draw-play w scene)
       (place-image (circle 50 (if (not (world1-playing? w)) "outline" "solid") 
                            (if (not (world1-playing? w)) "black" "blue")) 75 100
       (place-image (circle 50 (if (not (world1-playing? w)) "outline" "solid") 
                            (if (not (world1-playing? w)) "black" "red")) 75 250
       (place-image (circle 50 (if (not (world1-playing? w)) "outline" "solid") 
                            (if (not (world1-playing? w)) "black" "purple")) 75 400
       (place-image (circle 50 (if (not (world1-playing? w)) "outline" "solid") 
                            (if (not (world1-playing? w)) "black" "green")) 75 550
                    scene))))
  )
  


;; change the world when a key is pressed
;; world number number event frame -> world
(define (keh-wrapper w key cur-time)
  (cond [(key=? key "1")
         (make-world1
          (world1-play-head w)
          (max (world1-next-start w)
               cur-time)
          (not (world1-playing? w)))]
        ;; some other kind of event:
        [else w]))

;; deliver the current time to the key handler along
;; with its other arguments
;; -- this function exists to isolate the inner function
;; from the effects of a hidden input, the current time.
;; world number number event -> world
(define (keh w key)
  (keh-wrapper w key (pstream-current-frame ps)))

(big-bang INITIAL-WORLD
          [to-draw draw-world]
          [on-tick tock]
          [on-key keh])