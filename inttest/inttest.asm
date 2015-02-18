	.include "macros.inc"

	* = $1000

	; set up the shit
	sei ;disable interrupts
	lda #$7f
	ldx #$01
	sta $dc0d ;disable CIA1
	sta $dd0d ;disable CIA2
	stx $d01a ;enable raster interrupt

	lda #$1b
	ldx #$08
	ldy #$14
	sta $d011
	stx $d016
	sty $d018

	;for consistency's sake
	ldx #$06
	stx $d020
	stx $d021

	lda #<firint ;low byte of raster interrupt routine
	ldy #>firint
	ldx #$80 ; where to trigger the interrupt first
	sta $0314
	sty $0315
	stx $d012

	ldx #$00
	stx $141a ;first color to set the bar to
	ldy #$ff
	sty $141c ;init the counter

    #cls ;clear the screen

	;write some text
	ldy #$07 ;character color
	ldx #$0f ;# of bytes to write to screen memory
txtloop:
	dey
	tya
	cmp $d020
	beq txtloop
	sta $d800,x
	tay
	lda message,x
	sta $0400,x
	dex
	bpl txtloop

	lda $dc0d ;ack CIA1
	lda $dd0d ;ack CIA2
	asl $d019 ;ack raster interrupt
	cli ;enable interrupts

mainloop:
	jmp mainloop ;repeat

rastint: ;raster interrupt routine
	inc $d020
	inc $d021
	ldx $d012 ;get the current raster line (the one that raised interrupt)
	ldy #$11
rloop:	inx ;increase x by 0x11
	dey
	bne rloop
	stx $d012 ;set the next raster interrupt line
	asl $d019 ;ack raster interrupt
	#ret

firint: ;first interrupt
	;should we run at all?
	ldx $141c
	dex
	stx $141c
	beq goahead
	#ret ;let's not run
goahead:     ;let's run
	ldx $141a
	inx
	;#stall 10
	stx $d020
	stx $d021
	stx $141a
	lda #<secint
	ldx #>secint
	ldy #$83
	sta $0314
	stx $0315
	sty $d012
	ldx #$ff
	stx $141c ;reset the counter
	asl $d019 ;ack raster interrupt
	#ret

secint: ;second interrupt!!
	ldx #$06
	#stall 53
	stx $d020
	stx $d021
	lda #<firint
	ldx #>firint
	ldy #$80
	sta $0314
	stx $0315
	sty $d012
	asl $d019 ;ack raster interrupt
	#ret

message:
	.enc screen
	.text " introducing...."
