	.include "macros.inc"

	color = $4000
	green_line = #$dc

	*=$1000

	#disint

	lda #$00  ; colors
	sta $d021 ; background color
	sta $d020 ; border color

	; bank switch screen memory to $0000
	lda $dd00
	ora #%00000011
	sta $dd00

    ; bitmap memory at $3800
	; screen memory at $0c00
	lda #%00111000
	sta $d018
	lda $d016
	ora #%00010000 ; multicolor mode
	sta $d016

	; set d011 for bitmap mode
	lda $d011
	and #%10111111
	ora #%00100000
	sta $d011
	
	; set colors
	ldx #$0f
	stx $d021

	; load color table into color memory
	ldx #$00
col_loop:
	lda color,x
	sta $d800,x
	lda color+$100,x
	sta $d900,x
	lda color+$200,x
	sta $da00,x
	lda color+$300,x
	sta $db00,x
	inx
	bne col_loop

    lda #$01
    sta $d01a ; enable raster interrupt
	lda $d011
	and #%01111111
	sta $d011 ; clear high bit of IRQ

	; set up raster interrupt
	ldy #<set_black
	ldx #>set_black
	lda #$00
	sty $0314
	stx $0315
	sta $d012

	#enint

;;; MAIN LOOP ;;;
	jmp *
;;; MAIN LOOP ;;;

; interrupt routines
set_green:
	lda #$05
	sta $d020

	; load next interrupt
	ldx #<set_black
	stx $0314
	ldy #>set_black
	sty $0315
	lda #$00
	sta $d012

	; return from interrupt
	asl $d019
	#ret

set_black:
	lda #$00
	sta $d020

	; load next interrupt
	ldx #<set_green
	stx $0314
	ldy #>set_green
	sty $0315
	lda green_line
	sta $d012

	; return from interrupt
	asl $d019
	#ret

	*=$0c00
	.binary "data/bg.scr"

	*=$2000
	.binary "data/bg.map"

	*=color
	.binary "data/bg.col"

