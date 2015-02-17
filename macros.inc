; disable interrupts
disint	.macro
	sei ; set interrupt mask
	lda #$7f
	ldx #$01
	sta $dc0d ; disable CIA1
	sta $dd0d ; disable CIA2
	stx $d01a ; enable raster interrupt
	.endm

; re-enable interrupts
enint	.macro
	lda $dc0d ; ack CIA1
	lda $dd0d ; ack CIA2
	asl $d019 ; ack raster interrupt
	cli ; enable interrupts
	.endm


; return from interrupt
ret	.macro
	pla
	tay
	pla
	tax
	pla
	rti ; return from raster interrupt
	.endm

; generate arbitrary amount of NOOPs
stall	.macro
	.rept \1
	nop
	.next
	.endm

; clear the screen
cls	.macro
	lda #$20
	ldx #$00
clearloop:
	sta $0400,x
	sta $0500,x
	sta $0600,x
	sta $0700,x
	dex
	bne clearloop
	.endm

; clear bitmap memory
clb	.macro
	lda #$00
	ldy #$00
	sty $fd
	ldx \1+$20
outerloop:
	dex
	stx $fe
	ldy #$00
clearloop:
	sta ($fd),y
	dey
	bne clearloop
	cpx \1
	bne outerloop
	.endm

; custom INC and DEC routines to avoid phantom store instruction problem
; warning: these routines ruin the X register
finc	.macro
	ldx \1
	inx
	stx \1
	.endm
fdec	.macro
	ldx \1
	dex
	stx \1
	.endm

; advance to next line
; ruins accumulator
nextln	.macro
	lda $d012
	and $d011
	.rept 5
	asl
	.next
	cmp #%11100000
	beq badln1
	#stall \1
badln1:	nop
	.endm
