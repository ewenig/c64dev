ret	.macro
	pla
	tay
	pla
	tax
	pla
	rti ; return from raster interrupt
	.endm

stall	.macro
	.rept \1
	nop
	.next
	.endm

cls	.macro
	;clear the screen
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
