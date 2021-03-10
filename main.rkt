#lang racket/gui
;Ignorați următoarele linii de cod. Conțin import-uri și export-uri necesare checker-ului.

(require 2htdp/image)
(require 2htdp/universe)
(require lang/posn)

(require "random.rkt")
(require "abilities.rkt")
(require "constants.rkt")
;---------------------------------------checker_exports------------------------------------------------
(provide next-state)
(provide next-state-bird)
(provide next-state-bird-onspace)
(provide change)

(provide get-pipes)
(provide get-pipe-x)
(provide next-state-pipes)
(provide add-more-pipes)
(provide clean-pipes)
(provide move-pipes)

(provide invalid-state?)
(provide check-ground-collision)
(provide check-pipe-collisions)

(provide draw-frame)

(provide get-initial-state)
(provide get-bird)
(provide get-bird-y)
(provide get-bird-v-y)

; pipe
(provide get-pipes)
(provide get-pipe-x)

; score25
(provide get-score)

(provide get-abilities)
(provide get-abilities-visible)
(provide get-abilities-active)
; variables
(provide get-variables)
(provide get-variables-gravity)
(provide get-variables-momentum)
(provide get-variables-scroll-speed)

;---------------------------------------checker_exports------------------------------------------------
; Checker-ul contine un numar de teste, fiecare cu numele sau. In acest fisier veti gasi comentarii
; care incep cu TODO %nume_test, unde trebuie sa modificati sau sa implementati o functie, pentru
; a trece testul %nume_test.
;
;Initial state
; Primul pas pe care trebuie sa il facem este sa cream starea initiala a jocului.
; Aceasta va fi salvata in (get-initial-state), si trebuie sa incapsuleze toate informatiile
; necesare jocului, si anume: informatii despre pasare, despre pipes si despre powerups.
; Recomandam ca in pasare, sa retineti, printre altele, informatii despre y-ul curent
; si viteza pe y
; Pe parcursul temei, in state, salvati coordonatele colturilor din stanga sus ale obiectelor.
; Aceasta va face mai usoara atat logica miscarii obiectelor, cat si testarea cerintelor.
; Toate coordonatele oferite in comentarii sau in fisierul constants.rkt, se refera la
; coltul din stanga sus ale obiectelor!
;Inițial state
; Primul pas pe care trebuie să îl facem este să creăm starea inițială a jocului.
; Aceasta va fi salvată în (get-initial-state), și trebuie să incapsuleze toate informațiile
; necesare jocului, și anume: informații despre pasăre, despre pipes și, pentru bonus,
; despre powerups și despre variabilele de mediu.
; Recomandăm ca în pasăre, să rețineți, printre altele, informații despre y-ul curent
; și viteză pe y.
; Pe parcursul temei, în state, salvați coordonatele colțurilor din stânga sus ale obiectelor.
; Aceasta va face mai ușoară atât logică mișcării obiectelor, cât și testarea cerințelor.
; Toate coordonatele oferite în comentarii sau în fișierul variables.rkt se referă la
; colțul din stânga sus ale obiectelor!

;TODO 1
; După ce definiți structurile lui (get-initial-state) și a păsării, introduceți în prima
; pe cea din urmă. Colțul din stânga sus a păsării se va află inițial la:
;    y = bird-inițial-y
; și x = bird-x.
; (get-initial-state) va fi o funcție care va returna starea inițială a jocului.
(define-struct birdy (y x v-y) #:transparent)

(define-struct mypipe (gap-y x) #:transparent)

(define-struct pipes (list mypipe) #:transparent)

;(define-struct myscore (scor) #:transparent) ;am definit si scorul

;;;;;STRUCTURA MEA PT STATE  ; am bagat scor ca variabila simpla
(define-struct mystate (birdy pipes myscore) #:transparent) ; cand bag si pipe decomentez
;(define-struct mystate (birdy pipes) #:transparent)
;(define-struct mystate (birdy) #:transparent)


        ;(define initial-bird (birdy bird-initial-y  bird-x 0)) ;viteza pasarii initial e 0
;(bird-y initial-bird)

         ;(define initial-pipe (mypipe (+ added-number (random random-threshold)) scene-width))

        ;(define initial-pipes (list initial-pipe)) ;;ca sa mearga pe checker 

;(define initial-score (myscore 0))
;(myscore-scor initial-score)

;(define initial-state (mystate initial-bird initial-pipes)) ; si aici decom!!
      ;(define initial-state (mystate initial-bird initial-pipes 0))

;(equal? (mystate-myscore initial-state) 0)
;(define initial-state (mystate initial-bird))
;TODO 8
; În starea jocului, trebuie să păstrăm informații despre pipes. Pe parcursul jocului,
; pipe-urile se vor schimba, unele vor fi șterse și vor fi adăugate altele.
; După ce definiți structura pentru pipe și pentru mulțimea de pipes din stare,
; adăugați primul pipe în starea jocului. Acesta se va află inițial în afară ecranului.
; Celelalte pipe-uri vor fi adăugate ulterior, poziționându-le după acest prim pipe.
; Atenție! Fiecare pipe este format din 2 părți, cea superioară și cea inferioară,
; acestea fiind despărțite de un gap de înălțime pipe-self-gap.
; Colțul din stânga sus al gap-ului dintre componentele primului pipe se va afla inițial la:
;    y = (+ added-number (random random-threshold)), pentru a da un element de noroc jocului,
; și x = scene-width,
; pentru a-l forța să nu fie inițial pe ecran.
; Atenție! Recomandăm să păstrați în stare colțul din stânga sus al chenarului lipsa
; dintre cele 2 pipe-uri!

;TODO 16
; Vrem o modalitate de a păstra scorul jocului. După ce definiți structura
; acestuia, adăugați scorul inițial, adică 0, în starea inițială a jocului.
; Atenție get-initial-state trebuie sa fie o funcție
; și trebuie apelată în restul codului.
(define (get-initial-state)
  (mystate (birdy bird-initial-y bird-x 0)
           (list (mypipe (+ added-number (random random-threshold)) scene-width))
           0)
  )
  

;TODO 2
; După aceasta, implementați un getter care extrage din structura voastră
; pasărea, și un al doilea getter care extrage din structura pasăre
; y-ul curent pe care se află această.
(define (get-bird state)
 (define birdy (mystate-birdy state))
  birdy)
(define (get-bird-y bird)
  (define y (birdy-y bird))
  y)

;TODO 3
; Trebuie să implementăm logică gravitației. next-state-bird va primi drept
; parametri o structură de tip pasăre, și gravitația(un număr real). Aceasta va adaugă
; pozitiei pe y a păsării viteza acesteia pe y, si va adaugă vitezei pe y a păsării,
; gravitația.


(define (next-state-bird bird gravity)
  (match-let ([(birdy y _ v-y) bird])
    (struct-copy birdy bird [y (+ y v-y)] [v-y (+ v-y gravity)])
 
  ))

  
;(next-state-bird initial-bird initial-gravity)

;TODO 4
; După aceasta, implementati un getter care extrage din structura voastră
; viteza pe y a păsării.
(define (get-bird-v-y bird)
   (define v-y (birdy-v-y bird))
  v-y)

;TODO 6
; Dorim să existe un mod prin care să imprimăm păsării un impuls.
; Definiți funcția next-state-bird-onspace care va primi drept parametri
; o structură de tip pasăre, momentum(un număr real), și va schimba viteza
; pe y a păsării cu -momentum.
(define (next-state-bird-onspace bird momentum)
  (match-let ([(birdy _ _ v-y) bird])
    (struct-copy birdy bird [v-y (* -1 momentum)])))

; Change
; Change va fi responsabil de input-ul de la tastatură al jocului.
;TODO 7
; Acesta va primi drept parametri o structură de tip stare, și tasta pe
; care am apăsat-o. Aceasta va imprimă păsării momentum-ul, apelând
; funcția next-state-bird-onspace. Pentru orice altă tasta, starea rămâne aceeași.
(define (change current-state pressed-key)
   ;(define changed-state (current-state (next-state-bird-onspace
                                      ;(get-bird curent-state) initial-momentum)))
   
  (cond [(key=? pressed-key " ") (struct-copy mystate current-state
                                              [birdy (next-state-bird-onspace (get-bird current-state) initial-momentum)])]
        [else current-state]))

;TODO 9
; După ce ați definit structurile pentru mulțimea de pipes și pentru un singur pipe,
; implementați getterul get-pipes, care va extrage din starea jocului mulțimea de pipes,
; sub formă de lista.
(define (get-pipes state)
  ;(mystate-pipes state)
  ; daca pipeurile sunt deja lista o intoarce daca nu face o lista cu ele pe care
  ; o intoarce
  (if (list? (mystate-pipes state))
      (mystate-pipes state)
      (list (mystate-pipes state))))

;TODO 10
; Implementați get-pipe-x ce va extrage dintr-o singură structura de tip pipe, x-ul acesteia.
(define(get-pipe-x pipe)
  (mypipe-x pipe))

;TODO 11
; Trebuie să implementăm logica prin care se mișcă pipes.
; Funcția move-pipes va primi drept parametri mulțimea pipe-urilor din stare
; și scroll-speed(un număr real). Aceasta va scădea din x-ul fiecărui pipe
; scroll-speed-ul dat.
(define (move-pipes pipes scroll-speed)
   ;(if (list? pipes)    ;am adaugat iful asta in plus
  (map (lambda (pipe)
         (struct-copy mypipe pipe [x (- (get-pipe-x pipe) scroll-speed)])) pipes)
  ;(struct-copy mypipe pipes [x (- (get-pipe-x pipes) scroll-speed)])
  ;))
  )

;TODO 12
; Vom implementa logica prin care pipe-urile vor fi șterse din stare. În momentul
; în care colțul din DREAPTA sus al unui pipe nu se mai află pe ecran, acesta trebuie
; șters.
; Funcția va primi drept parametru mulțimea pipe-urilor din stare.
;
; Hint: cunoaștem lățimea unui pipe, pipe-width
;;;;;;;;;;;;;;
; sa ma uit si mai incolo la functia asta
; !!!!!! sterg pipe daca x egal cu -(pipe-width)
(define (clean-pipes pipes)
                                        ; aici tre sa mai scriu, intreab-o pe Ioana de conditia de la todo-ul asta
     (filter (lambda (pipe)                             ; despre cum apelezi alea 3 functii, si despre cum faci calculul ala pipe-width + etc   
            (> (get-pipe-x pipe) (* -1 pipe-width)))
          pipes))



;TODO 13
; Vrem să avem un sursa continuă de pipe-uri.
; Implementati funcția add-more-pipes, care va primi drept parametru mulțimea pipe-urilor
; din stare și, dacă avem mai puțin de no-pipes pipe-uri, mai adăugăm una la mulțime,
; având x-ul egal cu pipe-width + pipe-gap + x-ul celui mai îndepărtat pipe, în raport
; cu pasărea.
(define (add-more-pipes pipes)
  (cond
    ((< (length pipes) no-pipes) (cons (mypipe (+ added-number (random random-threshold)) (+ (get-pipe-x (first pipes)) pipe-width pipe-gap)) pipes))
    (else pipes)
    ))

;TODO 14
; Vrem ca toate funcțiile implementate anterior legate de pipes să fie apelate
; de către next-state-pipes.
; Aceasta va primi drept parametri mulțimea pipe-urilor și scroll-speed-ul,
; și va apela cele trei funcții implementate anterior, în această ordine:
; move-pipes, urmat de clean-pipes, urmat de add-more pipes.
(define (next-state-pipes pipes scroll-speed)
   (add-more-pipes (clean-pipes (move-pipes pipes scroll-speed))) ;am schimbat aici

  ;(move-pipes pipes scroll-speed)
  ;(clean-pipes pipes)
  ;(add-more-pipes pipes)

  ;(move-pipes (clean-pipes (add-more-pipes pipes)) scroll-speed)
  )

;TODO 17
; Creați un getter ce va extrage scorul din starea jocului.
(define (get-score state)
  (mystate-myscore state))

;TODO 19
; Vrem să creăm logica coliziunii cu pământul.
; Implementati check-ground-collision, care va primi drept parametru
; o structura de tip pasăre, și returnează true dacă aceasta are coliziune
; cu pământul.
;
; Hint: știm înălțimea păsării, bird-height, și y-ul pământului, ground-y.
; Coliziunea ar presupune ca un colț inferior al păsării să aibă y-ul
; mai mare sau egal cu cel al pământului.
(define (check-ground-collision bird)
  (if (>= (+ (get-bird-y bird) bird-height) ground-y)
      #t
      #f)
 )

; invalid-state?
; invalid-state? îi va spune lui big-bang dacă starea curentă mai este valida,
; sau nu. Aceasta va fi validă atât timp cât nu avem coliziuni cu pământul
; sau cu pipes.
; Aceasta va primi ca parametru starea jocului.

;TODO 20
; Vrem să integrăm verificarea coliziunii cu pământul în invalid-state?.

;TODO 22
; Odată creată logică coliziunilor dintre pasăre și pipes, vrem să integrăm
; funcția nou implementată în invalid-state?.
(define (invalid-state? state)
  (cond
    ;daca sunt coliziiuni cu pamantul --> #f
    ((equal? (check-ground-collision (get-bird state)) #t) #t)
    ;tre sa bag si coliziunea cu pipeurile
    ((equal? (check-pipe-collisions (get-bird state) (get-pipes state)) #t) #t)
    ;daca nu exista niciun fel de coliziune --> #t
    (else #f))
  )

;TODO 21
; Odată ce am creat pasărea, pipe-urile, scor-ul și coliziunea cu pământul,
; următorul pas este verificarea coliziunii dintre pasăre și pipes.
; Implementati funcția check-pipe-collisions care va primi drept parametri
; o structură de tip pasăre, mulțimea de pipes din stare, și va returna
; true dacă există coliziuni, și false în caz contrar. Reiterând,
; fiecare pipe este format din 2 părți, cea superioară și cea inferioară,
; acestea fiind despărțite de un gap de înălțime pipe-self-gap. Pot există
; coliziuni doar între pasăre și cele două părți. Dacă pasărea se află în
; chenarul lipsă, nu există coliziune.
;
; Hint: Vă puteți folosi de check-collision-rectangle, care va primi drept parametri
; colțul din stânga sus și cel din dreapta jos ale celor două dreptunghiuri
; pe care vrem să verificăm coliziunea.

; verific daca pasarea se loveste 
(define (check-upper-collisions bird pipes)
   (foldr (lambda (a b)
            (or a b)) #f
          
           (map (lambda (pipe)
          (check-collision-rectangles (make-posn (mypipe-x pipe) 0)   ; A1
                    (make-posn (+ (mypipe-x pipe) pipe-width) (mypipe-gap-y pipe))  ; A2
                    (make-posn (birdy-x bird) (get-bird-y bird)) ; B1
                    (make-posn (+ (birdy-x bird) bird-width) (+ (get-bird-y bird) bird-height))
                              )) pipes)    )
 
  )
(define (check-lower-collisions bird pipes)
   (foldr (lambda (a b)
            (or a b)) #f
          
           (map (lambda (pipe)
          (check-collision-rectangles (make-posn (mypipe-x pipe) (+ (mypipe-gap-y pipe) pipe-self-gap))   ; A1
                    (make-posn (+ (mypipe-x pipe) pipe-width) scene-height)  ; A2
                    (make-posn (birdy-x bird) (get-bird-y bird)) ; B1
                    (make-posn (+ (birdy-x bird) bird-width) (+ (get-bird-y bird) bird-height))  ; B2
                              )) pipes)    )
 
  )


;(define test-pipes (list (pipe )))
(define (check-pipe-collisions bird pipes)

  (if (or (check-upper-collisions bird pipes)
          (check-lower-collisions bird pipes))
      #t
      #f
      )
  )

(define (check-collision-rectangles A1 A2 B1 B2)
  (match-let ([(posn AX1 AY1) A1]
              [(posn AX2 AY2) A2]
              [(posn BX1 BY1) B1]
              [(posn BX2 BY2) B2])
    (and (< AX1 BX2) (> AX2 BX1) (< AY1 BY2) (> AY2 BY1))))

;Next-state
; Next-state va fi apelat de big-bang la fiecare cadru, pentru a crea efectul de
; animație. Acesta va primi ca parametru o structură de tip stare, și va întoarce
; starea corespunzătoare următorului cadru.

;TODO 5
; Trebuie să integrăm funcția implementată anterior, și anume next-state-bird,
; în next-state.

;TODO 15
; Vrem să implementăm logică legată de mișcarea, ștergerea și adăugarea pipe-urilor
; în next-state. Acesta va apela next-state-pipes pe pipe-urile din starea curentă.

;TODO 18
; Vrem ca next-state să incrementeze scorul cu 0.1 la fiecare cadru.
(define (next-state state)
    ;(next-state-pipes (mystate-pipes state) initial-scroll-speed)
 ;(define next (mystate (next-state-bird (get-bird state) initial-gravity) (mystate-pipes state)))
  (define next (mystate (next-state-bird (get-bird state) initial-gravity)
                        (next-state-pipes (mystate-pipes state) initial-scroll-speed)
                        (+ (mystate-myscore state) 0.1)))
  next
  ;(next-state-pipes (mystate-pipes (mystate (next-state-bird (get-bird state) initial-gravity) (mystate-pipes state))) initial-scroll-speed)
 )

;(define current-state (next-state-bird state-birdy gravity) (nex)))

; draw-frame
; draw-frame va fi apelat de big-bang dupa fiecare apel la next-state, pentru a afisa cadrul curent.
;TODO 23
; Fiecare cadru va fi desenat in urmatorul mod:
; bird peste ground, peste scor, peste pipes, peste empty-scene.
;
; Hint: score-to-image primeste un numar real si intoarce scor-ul sub forma de imagine;
; Scor-ul îl puteți plasa direct la coordonatele date, fără a mai face translatiile menționate mai jos.
; Noi tinem minte coltul din stanga sus al imaginii, insa, la suprapunerea unei imagini A peste o alta imagine,
; coordonatele unde plasam imaginea A reprezinta centrul acesteia. Trebuie facute translatiile de la coltul din stanga
; sus la centrul imaginilor.
; Variabile folosite in aceasta functie:
; bird -> bird-width si bird-height
; ground -> ground-y si ground-height, acesta va acoperi intreaga latime a ecranului
; scor -> text-x si text-y
; pipes -> pipe-width si pipe-height
(define bird-image (rectangle bird-width bird-height  "solid" "yellow"))
(define ground-image (rectangle scene-width ground-height "solid" "brown"))
(define initial-scene (rectangle scene-width scene-height "solid" "white"))

(define text-family (list "Gill Sans" 'swiss 'normal 'bold #f))
(define (score-to-image x)
(if SHOW_SCORE
	(apply text/font (~v (round x)) 24 "indigo" text-family)
	empty-image))

(define (draw-frame state)
  
  (place-image
   bird-image ;pun pasarea
    (+ (birdy-x (get-bird state)) (quotient bird-width 2)) ;x
    (+ (get-bird-y (get-bird state))  (quotient bird-height 2)) ;y

     (place-image
         ground-image ; pun pamantul
         (quotient scene-width 2)
         (- scene-height (quotient ground-height 2))
        
     ;initial-scene ;aici place-pipes
         
         (place-image
              (score-to-image (mystate-myscore state)) ; pun scor
              text-x
              text-y
          
              (place-pipes (get-pipes state) initial-scene) ; pun pipes
     )))
  )
(define pipe-image (rectangle pipe-width pipe-height "solid" "green"))
;(define gap-image (rectangle pipe-width pipe-self-gap "solid" "white"))
; Folosind `place-image/place-images` va poziționa pipe-urile pe scenă.
(define (place-pipes pipes scene) 
            (cond [(null? pipes) scene]
                  [else (place-one-pipe
                         (first pipes)
                         (place-pipes (rest pipes) scene)
                         )
                   ]
                  )
       )
(define (place-one-pipe pipe scene)
  (place-image pipe-image 
               ; pipe de sus
               (+ (get-pipe-x pipe) (quotient pipe-width 2)) ;x
               (- (mypipe-gap-y pipe) (quotient pipe-height 2)) ;y
               
               ; pipe de jos  
               (place-image pipe-image
                     (+ (get-pipe-x pipe) (quotient pipe-width 2)) ;x
                     (+ (mypipe-gap-y pipe) pipe-self-gap (quotient pipe-height 2)) ;y
                     
                            
               scene
               ))
  )


; Bonus
; Completați abilities.rkt mai întâi, aceste funcții căt, apoi legați
; această funcționalitate la jocul inițial.


; Abilitatea care va încetini timpul va dura 10 de secunde, va avea imaginea (hourglass "mediumseagreen")
; va avea inițial poziția null si va modifica scrolls-speed dupa formulă
; scroll-speed = max(5, scroll-speed - 1)
(define slow-ability 'your-code-here)

; Abilitatea care va accelera timpul va dura 30 de secunde, va avea imaginea (hourglass "tomato")
; va avea inițial poziția null si va modifica scrolls-speed dupa formulă
; scroll-speed = scroll-speed + 1
(define fast-ability 'your-code-here)

; lista cu toate abilităţile posibile în joc
(define ABILITIES (list fast-ability slow-ability))


(define get-variables 'your-code-here)
(define get-variables-gravity 'your-code-here)
(define get-variables-momentum 'your-code-here)
(define get-variables-scroll-speed 'your-code-here)

; Întoarce abilităţile din stare, cu o reprezentare
; intermediară care trebuie să conțină două liste:
;  - lista abilităţilor vizibile (încarcate în scenă dar nu neaparat vizibile pe ecran).
;  - lista abilităţilor activate (cu care pasărea a avut o coloziune).
(define (get-abilities x) null)

; Întoarce abilităţile vizibile din reprezentarea intermediară.
(define (get-abilities-visible x) null)

; Întoarce abilităţile active din reprezentarea intermediară.
(define (get-abilities-active x) null)

; Șterge din reprezentarea abilităţilor vizibile pe cele care nu mai sunt vizibile.
; echivalent cu clean-pipes.
(define (clean-abilities abilities)
	'your-code-here)


; Muta abilităţile vizibile spre stanga.
; echivalent cu move-pipes.
(define (move-abilities abilities scroll-speed)
	'your-code-here)


; Scurge timpul pentru abilităţile activate și le sterge pe cele care au expirat.
; Puteți să va folosiți de variabila globală fps.
(define (time-counter abilities)
	'your-code-here)

; Generează următoarele abilitați vizibile.
; *Atentie* La orice moment pe scena trebuie să fie exact DISPLAYED_ABILITIES
; abilităţi vizibile
; Folosiți funcția fill-abilities din abilities.rkt cât si cele scrise mai sus:
; move-abilities, clean-abilities, time-counter, etc..
(define (next-abilities-visible visible scroll-speed)
	'your-code-here)

; Generează structura intermediară cu abilități.
; Observați ca nu există next-abilities-active aceastea sunt acele abilităti
; întoarse next-abilities-visible care au o coliziune cu pasărea.
; Puteti folosi `filer`/`filter-not` ca sa verificați ce abilităti au și abilitați
; nu au coliziuni cu pasărea sau puteti folosi `partition`
(define (next-abilities abilities bird scroll-speed)
	'your-code-here)

; Dând-use variabilele actuale și abilitațile calculați care vor
; variabile finale folosite în joc
; Folositi compose-abilities
; Atenție când apelați `next-variables` în next-state dați ca paremetru
; initial-variables și nu variabilele aflate deja în stare
; In felul acesta atunci când
(define (next-variables variables abilities)
  'your-code-here)


; Folosind `place-image/place-images` va poziționa abilităţile vizibile la ability pos.
(define (place-visible-abilities abilities scene)
	'your-code-here)

; Folosind `place-image/place-images` va poziționa abilităţile active
; în partea de sus a ecranului lângă scor.
; Imaginiile vor scalate cu un factor de 0.75 și așezate plecând
; de la ability-posn (constantă globală) cu spații de 50 de px.
; Imaginea cu indexul i va fi așezată la (ability-posn.x - 50*i, ability-posn.y)
(define (place-active-abilities abilities scene)
	'your-code-here)

(module+ main
	(big-bang (get-initial-state)
	 [on-tick next-state (/ 1.0 fps)]
	 [to-draw draw-frame]
	 [on-key change]
	 [stop-when invalid-state?]
	 [close-on-stop #t]
	 [record? #f]))
