;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname play-pause2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require rsound)
(require 2htdp/image)
(require 2htdp/universe)

(define SR 44100)
(define (s sec) (* SR sec))
(define (both a b) b)
(define END-TIME1 (s 12))
(define END-TIME2 (s 7))
(define END-TIME3 (s 20))
(define END-TIME4 (s 23))

(define snd1 (rs-read/clip "/Users/Matt/Google Drive/Cal Poly/CPE/Assignment 2/ghost-piano_4bar.wav"
             0 END-TIME1))
(define snd2 (rs-read/clip "/Users/Matt/Google Drive/Cal Poly/CPE/Assignment 2/cinematic-boom.wav"
             0 END-TIME2))
; still trying to figure out what's wrong with this code
#;(define snd3 (rs-read/clip "/Users/Matt/Google Drive/Cal Poly/CPE/Assignment 2/cellos.wav"
             0 END-TIME3))
(define snd4 (rs-read/clip "/Users/Matt/Google Drive/Cal Poly/CPE/Assignment 2/guitar-ominous.wav"
             0 END-TIME4))

;; a world is (make-world frame frame boolean), representing
;; the frame at which to continue playing, and the
;; pstream time at which to play it, and whether it's playing
(define-struct system (world1 world2 world3 world4))
(define-struct world (play-head next-start playing?))
(define INITIAL-WORLD1 (make-world 0 (s 0.5) false))
(define INITIAL-WORLD2 (make-world 0 (s 0.5) false))
(define INITIAL-WORLD3 (make-world 0 (s 0.5) false))
(define INITIAL-WORLD4 (make-world 0 (s 0.5) false))
(define INITIAL-SYSTEM (make-system INITIAL-WORLD1
                                    INITIAL-WORLD2
                                    INITIAL-WORLD3
                                    INITIAL-WORLD4))


;; -----PLAYING SOUNDS------------------------

;; how much of the song to play each time?
(define PLAY-CHUNK (round (s 0.1)))
;; how far ahead of time should we queue sounds?
(define LEAD-FRAMES (round (s 0.05)))

;; the pstreams that we're going to use:
(define ps1 (make-pstream))
(define ps2 (make-pstream))
(define ps3 (make-pstream))
(define ps4 (make-pstream))


;; given the current pstream time and the next
;; time to play, return true if it's time to play
;; frame frame -> boolean
(define (time-to-play? cur next)
  (< (- next cur) LEAD-FRAMES))


;; queue a sound if it's time, and advance the
;; world and the playhead
;; number world -> world
(define (maybe-play-chunk cur w)
  (local [(define next-start (world-next-start (system-world1 w)))]
    (cond [(time-to-play? cur next-start)
           (local [(define playhead (if (< (world-play-head (system-world1 w)) END-TIME1) (world-play-head (system-world1 w)) 0))
                   (define next-playhead (+ playhead PLAY-CHUNK))]
             (both (pstream-queue ps1
                                  (clip snd1 playhead next-playhead)
                                  next-start)
                   (make-system (make-world next-playhead 
                               (+ next-start PLAY-CHUNK)
                               (world-playing? (system-world1 w))) (system-world2 w) (system-world3 w) (system-world4 w))))]
          [else w])))

;; call maybe-play-chunk if song is not paused
(define (maybe-maybe-play-chunk cur w)
  (cond [(world-playing? (system-world1 w)) (maybe-play-chunk cur w)]
        [else w]))

;; the on-tick function. calls maybe-play-chunk.
;; world -> world
(define (tock w)
  (maybe-maybe-play-chunk (pstream-current-frame ps1) w))


;; -----THE GUI-------------------------- 

(define WORLD-WIDTH 650)
(define WORLD-HEIGHT 650)
(define SLIDER-WIDTH (- WORLD-WIDTH 150))

;; draw a blank scene with a 4 play heads and 4 play/pause circles
;; world -> scene
(define (draw-world w)
  (draw-play
   w
   (place-image (rectangle 10 100 "solid" "black")
                (+ 150
                   (* SLIDER-WIDTH (/ (world-play-head (system-world1 w)) (rs-frames snd1))))
                100
                (place-image (rectangle 500 100 "outline" "black") 400 100
                (place-image (rectangle 500 100 "outline" "black") 400 250
                (place-image (rectangle 500 100 "outline" "black") 400 400
                (place-image (rectangle 500 100 "outline" "black") 400 550
                (empty-scene WORLD-WIDTH WORLD-HEIGHT))))))))


;; draw the appropriate play/pause shapes on a scene
;; world scene -> scene
(define (draw-play w scene)
       (place-image (circle 50 (if (not (world-playing? (system-world1 w))) "outline" "solid") 
                            (if (not (world-playing? (system-world1 w))) "black" "blue")) 75 100                                                                        
       (place-image (circle 50 (if (not (world-playing? (system-world2 w))) "outline" "solid") 
                            (if (not (world-playing? (system-world2 w))) "black" "red")) 75 250
       (place-image (circle 50 (if (not (world-playing? (system-world3 w))) "outline" "solid") 
                            (if (not (world-playing? (system-world3 w))) "black" "purple")) 75 400
       (place-image (circle 50 (if (not (world-playing? (system-world4 w))) "outline" "solid") 
                            (if (not (world-playing? (system-world4 w))) "black" "green")) 75 550
                    scene))))
  )
  


;; change the world when a key is pressed
;; world number number event frame -> world
(define (keh-wrapper w key cur-time)
  (cond [(key=? key "1")
         (make-system (make-world
          (world-play-head (system-world1 w))
          (max (world-next-start (system-world1 w))
               cur-time)
          (not (world-playing? (system-world1 w)))) (system-world2 w) (system-world3 w) (system-world4 w))]
        [(key=? key "2")
         (make-system (system-world1 w) (make-world
          (world-play-head (system-world2 w))
          (max (world-next-start (system-world2 w))
               cur-time)
          (not (world-playing? (system-world2 w)))) (system-world3 w) (system-world4 w))]
        [(key=? key "3")
         (make-system (system-world1 w) (system-world2 w) (make-world
          (world-play-head (system-world3 w))
          (max (world-next-start (system-world3 w))
               cur-time)
          (not (world-playing? (system-world3 w)))) (system-world4 w))]
        [(key=? key "4")
         (make-system (system-world1 w) (system-world2 w) (system-world3 w) (make-world
          (world-play-head (system-world4 w))
          (max (world-next-start (system-world4 w))
               cur-time)
          (not (world-playing? (system-world4 w)))))]
        ;; some other kind of event:
        [else w]))

;; deliver the current time to the key handler along
;; with its other arguments
;; -- this function exists to isolate the inner function
;; from the effects of a hidden input, the current time.
;; world number number event -> world
(define (keh w key)
  (keh-wrapper w key (pstream-current-frame ps1)))

(big-bang INITIAL-SYSTEM
          [to-draw draw-world]
          [on-tick tock]
          [on-key keh])