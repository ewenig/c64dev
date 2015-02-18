	.include "macros.inc"

	ptrstate = $07f8
	pos = $f0
	ofstate = $f1
	ofmask = $f2
	* = $1000

	#disint
	#cls

	; set up character mode
	lda #$1b
	ldx #$08
	ldy #$14
	sta $d011
	stx $d016
	sty $d018

	; setup raster irq
	lda #$00
	ldx #<rasirq
	ldy #>rasirq
	sta $d012
	stx $0314
	sty $0315

	; set up position registers
	sta pos     ; x/y position register
	sta ofstate ; offset position register
	lda #$01
	sta ofmask  ; offset mask

	; set up sprite pointer
	lda #$05
	sta ptrstate
	
	; set up sprite positioning
	ldx #$a0
	ldy #$80
	stx $d000
	sty $d001

	; set up sprite colors
	lda #$01
	sta $d01c ; multicolor mode
	lda #$00  ; black
	ldx #$03  ; cyan
	ldy #$0e  ; lightblue
	sta $d025
	stx $d026
	sty $d027

	; enable sprite 0
	lda #%00000001
	sta $d01d ; width scaling
	sta $d017 ; height scaling
	sta $d015 ; enable sprites

	; re-enable interrupts
	#enint

;;; MAIN LOOP ;;;
main:	jmp main
;;; MAIN LOOP ;;;

rasirq:	ldx ptrstate ; change sprite pointer
	inx
	cpx #$2b
	bne *+4
	ldx #$20     ; reset the pointer state
	stx ptrstate

	ldx pos      ; sprite position state
	lda xpos,x   ; next x position (low 8 bits)
	ldy ypos,x   ; next y position
	sta $d000
	sty $d001
	inx
	inx
	stx pos      ; increment sprite position

	ldx ofmask   ; offset mask
	ldy ofstate  ; offset state
	lda xof,y    ; current offset byte
	and ofstate
	beq chibit
shibit:	lda #$01     ; set high bit of x position
	.byte $2c    ; hack to skip the next instruction
chibit: lda #$00     ; clear high bit of x position
	sta $d010 
	txa
	asl          ; << ofmask
	asl          ; << ofmask
	bne sofmsk
	lda #$01     ; reset ofmask
	ldx ofstate
	inx
	cpx #$20
	bne sofste
	ldx #$00     ; reset ofstate
sofste:	stx ofstate
sofmsk:	sta ofmask

	asl $d019 ; ack irq
	#ret

	; data portion
xpos:	.include "xpos.dat"
xof:	.include "xoverflow.dat"
ypos:	.include "ypos.dat"

	; sprite portion
	* = $800 ; memory location of first sprite
	.include "spritedata/donut1.dat"
	.include "spritedata/donut2.dat"
	.include "spritedata/donut3.dat"
	.include "spritedata/donut4.dat"
	.include "spritedata/donut5.dat"
	.include "spritedata/donut6.dat"
	.include "spritedata/donut7.dat"
	.include "spritedata/donut8.dat"
	.include "spritedata/donut9.dat"
	.include "spritedata/donut10.dat"
	.include "spritedata/donut11.dat"
