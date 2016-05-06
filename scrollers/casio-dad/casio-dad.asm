	.include "macros.inc"

	; constants
	sineoff    = $20 ; sine table offset for sprites
	closescrirq= $00 ; raster lines for interrupts
	opnscrirq  = $fa
	topirq     = $05

	; ZP variables
	spr0i      = $fa ; sinetable indices for various sprites
	spr1i      = $fb
	spr2i      = $fc
	spr3i      = $fd

	* = $1000
	
	#disint
	#cls

	; set up sprites
	lda #$04 ; colors
	ldx #$00
	ldy #$0c
	sta $d020 ; background color
	sta $d021
	stx $d025
	sty $d026
	; set individual sprite colors
	lda #$03
	sta $d027
	sta $d02b
	lda #$0f
	sta $d029
	sta $d02a
	sta $d02d
	sta $d02e
	lda #$08
	sta $d028
	sta $d02c

	; pointers
	ldx #$20 ; initial ptr
	stx $07f8
	stx $07fc
	inx
	stx $07f9
	stx $07fd
	inx
	stx $07fa
	stx $07fe
	inx
	stx $07fb
	stx $07ff

	; positions
	lda #$20 ; XXX
	ldx #$0f
yloop:	sta $d000,x ; store y position in y coord registers
	dex
	dex
	bpl yloop 

	lda #$26
	sta $d000
	adc #$2f
	sta $d002
	sta $d004
	adc #$2f
	sta $d006
	adc #$2d
	sta $d008
	adc #$31
	sta $d00a
	sta $d00c
	adc #$2f
	sta $d00e

	; overflows
	lda #%10000000
	sta $d010

	lda #$ff
	sta $d017 ; scale x
	sta $d01d ; scale y
	sta $d01c ; multicolor mode
	sta $d015 ; enable sprites

	; clear border garbage
	lda #$00
	sta $3fff

	; initialize some indices
	sta spr0i
	adc #sineoff
	sta spr1i
	adc #sineoff
	sta spr2i
	adc #sineoff
	sta spr3i

	; set up character mode
	lda #$9f
	ldx #$08
	ldy #$14
	sta $d011
	stx $d016
	sty $d018

	; set up raster interrupt
	lda #<closescr
	ldx #>closescr
	ldy #closescrirq
	sta $0314
	stx $0315
	sty $d012

	#enint

;;; MAIN LOOP ;;;
mainlp:	jmp mainlp
;;; MAIN LOOP ;;;

	* = $1100

; jiggle the sprites around a bit
closescr:
	ldx spr0i
	lda sinetab,x
	sta $d001
	inx
	inx
	stx spr0i
	ldx spr1i
	lda sinetab,x
	sta $d003
	sta $d005
	sta $d007
	inx
	inx
	stx spr1i
	ldx spr2i
	lda sinetab,x
	sta $d009
	inx
	inx
	stx spr2i
	ldx spr3i
	lda sinetab,x
	sta $d00b
	sta $d00d
	sta $d00f
	inx
	inx
	stx spr3i

	lda #$1e
	sta $d011 ; set bit 3 of $d011
	lda #$00
	sta $d015 ; disable sprites

	lda #<top ; set up next interrupt
	ldx #>top
	ldy #topirq
	sta $0314
	stx $0315
	sty $d012
	asl $d019 ; ack interrupt
	#ret

top:
	lda #$ff
	sta $d015 ; enable sprites

	lda #<opnscr ; set up next interrupt
	ldx #>opnscr
	ldy #opnscrirq
	sta $0314
	stx $0315
	sty $d012
	asl $d019 ; ack interrupt
	#ret

; open the top & bottom screen borders
opnscr:	#stall 5
	lda $1c
	sta $d011 ; clear bit 3 + set bit 0 of $d011

	lda #<closescr ; set up next interrupt
	ldx #>closescr
	ldy #closescrirq
	sta $0314
	stx $0315
	sty $d012
	asl $d019 ; ack interrupt
	#ret

	* = $800
	.include "sprites/sprites.dat"
	* = $2000
sinetab:
	.byte 38 + 6 * sin(range(256) * rad(360.0/128))
