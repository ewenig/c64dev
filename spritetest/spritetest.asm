	.include "macros.inc"

	; sprite coordinate constants
	ymin = #$36
	ymax = #$ce
	xmin = #$18 ; w/o high bit set
	xmax = #$28 ; with high bit set
	masks = $60 ; sprite masks are $60 - 6b
	xpos = $6c
	ypos = $6d

	* = $1000

	; prepare for interrupts
	sei ;disable interrupts
	lda #$7f
	ldx #$01
	sta $dc0d ;disable CIA1
	sta $dd0d ;disable CIA2
	stx $d01a ;enable raster interrupt

	lda #<rastint ;low byte of raster interrupt routine
	ldy #>rastint
	ldx #$00 ; where to trigger the interrupt first
	sta $0314
	sty $0315
	stx $d012

	; set up character mode
	lda #$1b
	ldx #$08
	ldy #$14
	sta $d011
	stx $d016
	sty $d018

	; set up sprite pointers & color
	ldx #$0B ; pointer for sprite
	ldy #$08 ; counter for sprite pointers
ptrlp:	lda #$05 ; palette code for green
	sta $d026,y ; store color
	txa
	sta $07f7,y ; store pointer
	tax
	dey
	bpl ptrlp

	; set up sprite scaling & enable them
	ldx #%00111111
	stx $d01d ; width scaling
	stx $d017 ; height scaling
	stx $d015 ; enable sprites

	; set sprite locations
	lda #$1b ; X coord starting point
	sta $d000
	lda #$4f
	sta $d002
	lda #$84
	sta $d004
	lda #$b9
	sta $d006
	lda #$ee
	sta $d008
	lda #$25
	sta $d00a
	lda #%00100000
	sta $d010 ; high bits of the X coords - madness!!!

	lda ymin ; high Y coord
	ldy #$09 ; # of times to loop
loclp:	adc #$40
	sta $d000,y
	dey
	dey
	dey
	dey
	bpl loclp

	; store high Y coord for later
	sta $1410

	lda ymax ; low Y coord
	ldy #$0b ; # of times to loop
loclp2:	sbc #$40
	sta $d000,y
	dey
	dey
	dey
	dey
	bpl loclp2

	; store low Y coord for later
	sta $1412

	; initialize masks
	lda #$01
	sta masks
	sta masks+1
	lda #$02
	sta masks+2
	sta masks+3
	lda #$04
	sta masks+4
	sta masks+5
	lda #$08
	sta masks+6
	sta masks+7
	lda #$10
	sta masks+8
	sta masks+9
	lda #$20
	sta masks+10
	sta masks+11

	; store initial positions
	lda #%00010111
	sta xpos
	lda #%00111010
	sta ypos

	; set background colors
	ldx #$0D
	ldy #$0A
	stx $d020
	sty $d021

	#cls ; clear the screen

	; write some text
	ldx #$0f ; # of characters to write
txtloop:
	lda message,x
	sta $045c,x
	dex
	bpl txtloop

	; store seed for color rotation
	ldx #$07
	stx $1400

	lda $dc0d ;ack CIA1
	lda $dd0d ;ack CIA2
	asl $d019 ;ack raster interrupt
	cli ;enable interrupts

;;; MAIN LOOP ;;;
mainloop:
	jmp mainloop
;;; MAIN LOOP ;;;

rastint:
	dec $fd
	dec $fd
	dec $fd
	dec $fd
	dec $fd
	dec $fd
	dec $fd
	bne *+5
	; increase border color
	inc $d020

	; rotate text color
	ldy $1400 ; base color
	ldx #$0f ; # of bytes to write to memory
colorloop:
	dey
	tya
	cmp $d021 ; make sure characters are visible
	beq colorloop
	inc $d020
	sta $d85c,x
	tay
	dex
	bpl colorloop
	sty $1400

	; fuck with Y coords
	ldx #$0b
yloop:	ldy masks,x
	tya
	and ypos
	beq upward
	tya
	ldy $d000,x
	iny ; move downward
	; chg state if necessary
	cpy ymax
	bne ynext
	eor #$ff
	and ypos
	sta ypos
	jmp ynext
upward:	tya
	ldy $d000,x
	dey ; move upward
	; chg state if necessary
	cpy ymin
	bne ynext
	ora ypos
	sta ypos
ynext:	tya
	sta $d000,x
	dex
	dex
	bpl yloop

	; fuck with X coords
	ldx #$0a
xloop:	ldy masks,x
	tya
	and xpos
	bne leftwd
	; move rightward
	tya
	and $d010
	bne hibit
	ldy $d000,x
	iny
	tya
	sta $d000,x
	cpy #$00
	bne xnext
shibit:	lda masks,x ; set high bit of the current xpos
	ora $d010
	sta $d010
	jmp xnext
hibit:	ldy $d000,x
	iny
	tya
	sta $d000,x
	; chg state if necessary
	cpy xmax
	bne xnext
	lda masks,x
	ora xpos
	sta xpos
	jmp xnext
leftwd:	tya
	and $d010
	beq lobit
	ldy $d000,x
	dey
	tya
	sta $d000,x
	cpy #$ff
	bne xnext
uhibit:	lda masks,x ; unset high bit of the current xpos
	eor #$ff
	and $d010
	sta $d010
	jmp xnext
lobit:	ldy $d000,x
	dey
	tya
	sta $d000,x
	; chg state if necessary
	cpy xmin
	bne xnext
	lda masks,x
	eor #$ff
	and xpos
	sta xpos
xnext:	dex
	dex
	bpl xloop

	asl $d019 ; ack raster interrupt
	#ret

message:
	.enc screen
	.text "*** weed lol ***" ; message to display

	* = $800
spritedata:
	.include "spritetest.dat" ; sprite data
