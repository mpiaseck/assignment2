;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname play-pause) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require rsound)
(require 2htdp/image)
(require 2htdp/universe)

(define SR 44100)
(define (s sec) (* SR sec))
(define (both a b) b)

(define snd (rs-read/clip "/Users/Matt/Google Drive/Cal Poly/CPE/Lab 4/revolution.wav"
              (* 0 44100) (* 105 44100)))

;; a frame is a nonnegative integer

;; a world is (make-world frame frame boolean), representing
;; the frame at which to continue playing, and the
;; pstream time at which to play it, and whether it's playing
(define-struct world (play-head next-start playing?))
(define INITIAL-WORLD (make-world 0 (s 0.5) false))


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

(check-expect (time-to-play? 44100 44200) #t)
(check-expect (time-to-play? 44100 48200) #f)



;; queue a sound if it's time, and advance the
;; world and the playhead
;; number world -> world
(define (maybe-play-chunk cur w)
  (local [(define next-start (world-next-start w))]
    (cond [(time-to-play? cur next-start)
           (local [(define playhead (world-play-head w))
                   (define next-playhead (+ playhead PLAY-CHUNK))]
             (both (pstream-queue ps
                                  (clip snd playhead next-playhead)
                                  next-start)
                   (make-world next-playhead 
                               (+ next-start PLAY-CHUNK)
                               (world-playing? w))))]
          [else w])))

;; should play 1/10 of a second of sound from 10 seconds into the sound
(check-expect (maybe-play-chunk 30 (make-world (s 10) 1000 true))
              (make-world (+ (s 10) PLAY-CHUNK)
                          (+ 1000 PLAY-CHUNK)
                          true))

;; call maybe-play-chunk if song is not paused
(define (maybe-maybe-play-chunk cur w)
  (cond [(world-playing? w) (maybe-play-chunk cur w)]
        [else w]))

(check-expect (maybe-maybe-play-chunk 30 (make-world (s 10) 1000 false))
              (make-world (s 10) 1000 false))

;; the on-tick function. calls maybe-play-chunk.
;; world -> world
(define (tock w)
  (maybe-maybe-play-chunk (pstream-current-frame ps) w))


;; THE GRAPHICS / UI 

(define WORLD-WIDTH 600)
(define WORLD-HEIGHT 100)
(define TRIANGLE-SIDE 100)
(define SLIDER-WIDTH (- WORLD-WIDTH TRIANGLE-SIDE))

;; the "play" triangle
(define PLAY-IMG
  (rotate
   -90
   (triangle TRIANGLE-SIDE "solid" "pink")))

;; the "pause" rectangles
(define PAUSE-IMG
  (beside
   (rectangle (/ TRIANGLE-SIDE 4)
              TRIANGLE-SIDE
              "solid"
              "red")
   (rectangle (/ TRIANGLE-SIDE 8)
              1
              "solid"
              "white")
   (rectangle (/ TRIANGLE-SIDE 4)
              TRIANGLE-SIDE
              "solid"
              "red")))

;; draw a blank scene with a play head and a play/pause button
;; world -> scene
(define (draw-world w)
  (draw-play
   w
   (place-image (rectangle 10 WORLD-HEIGHT "solid" "black")
                (+ TRIANGLE-SIDE
                   (* SLIDER-WIDTH (/ (world-play-head w) (rs-frames snd))))
                50
                (empty-scene WORLD-WIDTH WORLD-HEIGHT))))


;; draw the appropriate play/pause shape on a scene
;; world scene -> scene
(define (draw-play w scene)
  (cond [(world-playing? w) 
         (place-image
          PLAY-IMG
          (/ TRIANGLE-SIDE 2)
          (/ WORLD-HEIGHT 2)
          scene)]
        [else 
         (place-image
          PAUSE-IMG
          (/ TRIANGLE-SIDE 2)
          (/ WORLD-HEIGHT 2)
          scene)]))

(check-expect (draw-play (make-world (s 1) (s 2) true)
                         (empty-scene WORLD-WIDTH WORLD-HEIGHT))
              (place-image
               PLAY-IMG
               (/ TRIANGLE-SIDE 2)
               (/ WORLD-HEIGHT 2)
               (empty-scene WORLD-WIDTH WORLD-HEIGHT)))
(check-expect (draw-play (make-world (s 1) (s 2) false)
                         (empty-scene WORLD-WIDTH WORLD-HEIGHT))
              (place-image
               PAUSE-IMG
               (/ TRIANGLE-SIDE 2)
               (/ WORLD-HEIGHT 2)
               (empty-scene WORLD-WIDTH WORLD-HEIGHT)))

;; change the world when a key is pressed
;; world number number event frame -> world
(define (keh-wrapper w key cur-time)
  (cond [(key=? key " ")
         (make-world
          (world-play-head w)
          (max (world-next-start w)
               cur-time)
          (not (world-playing? w)))]
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

(draw-world (make-world (s 1) (s 2) true))