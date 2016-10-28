	.include "macros.inc"

    ; constants
	green_line = #$dc
    ghost_spr_offset = #$27
    text_spr_offset = #$18
    text_pos_x = #$15
    text_pos_y = #$28
	opnscrirq  = #$fa

    ghost_pos_x = #$5a ; initial x position
    ghost_pos_y = $8a ; initial y position
    ghost_enable = #$f0
    ghost_flicker = ghost_enable+3

    ; pointers
	color = $4000
    ghost_ctr = $9a
    sine_offset = $9b
    ghost_state = $9c

	*=$5000

	#disint

	lda #$00  ; colors
	sta $d021 ; background color
	sta $d020 ; border color

    lda ghost_flicker
    sta ghost_ctr ; turn the ghost off

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

    ; sprite options
    ldx #$ff
	stx $d01d ; width scaling
	stx $d017 ; height scaling

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
	ldy #<textline1
	ldx #>textline1
	lda #$00
	sty $0314
	stx $0315
	sta $d012

	#enint

;;; MAIN LOOP ;;;
	jmp *
;;; MAIN LOOP ;;;

; interrupt routines
textline1:
    ; open border
    lda $d011
    ora #%00001000
	sta $d011 ; set bit 3 of $d011

    lda #$00 ; black
    sta $d021

    ; save sprite state
    lda $d015
    sta ghost_state
    lda #%01111111
    sta $d015
    lda #%01100000
    sta $d010

	lda #$00
	sta $d020

    ; set first line of text sprites
	ldx #$00
    stx $d01c ; no sprite multicolor
    
    ; set sprite colors
    lda #$08
    sta $d027
    sta $d028
    sta $d029
    sta $d02a
    sta $d02b
    sta $d02c
    sta $d02d

    ; set sprite offsets
    ldx text_spr_offset
    stx $0ff8
    inx
    stx $0ff9
    inx
    stx $0ffa
    inx
    stx $0ffb
    inx
    stx $0ffc
    inx
    stx $0ffd
    inx
    stx $0ffe

    ; set sprite positions
    lda text_pos_x
    sta $d000
    lda text_pos_x+48
    sta $d002
    lda text_pos_x+48+48
    sta $d004
    lda text_pos_x+48+48+48
    sta $d006
    lda text_pos_x+48+48+48+48
    sta $d008
    lda (text_pos_x+48+48+48+48+48) % 256
    sta $d00a
    lda (text_pos_x+48+48+48+48+48+48) % 256
    sta $d00c

    lda text_pos_y
    sta $d001
    sta $d003
    sta $d005
    sta $d007
    sta $d009
    sta $d00b
    sta $d00d

	; load next interrupt
    lda #$35
	sta $d012
	ldx #<resetbg
	stx $0314
	ldy #>resetbg
	sty $0315

	; return from interrupt
	asl $d019
	#ret

resetbg:
    lda #$0f ; lightgrey
    sta $d021

	; load next interrupt
    lda text_pos_y+39
	sta $d012
	ldx #<textline2
	stx $0314
	ldy #>textline2
	sty $0315

	; return from interrupt
	asl $d019
	#ret

textline2:
    #stall 38

    ; set second line of text sprites
    ; set sprite positions
    lda text_pos_y+42
    sta $d001
    sta $d003
    sta $d005
    sta $d007
    sta $d009
    sta $d00b
    sta $d00d

    ; set sprite offsets
    ldx text_spr_offset+7
    stx $0ff8
    inx
    stx $0ff9
    inx
    stx $0ffa
    inx
    stx $0ffb
    inx
    stx $0ffc
    inx
    stx $0ffd
    inx
    stx $0ffe

	; load next interrupt
    lda text_pos_y+42+42
	sta $d012
	ldx #<set_ghost
	stx $0314
	ldy #>set_ghost
	sty $0315

	; return from interrupt
	asl $d019
	#ret

set_ghost:
    ldx #$00
	stx $d015 ; disable all sprites
	
    ; set up sprite scaling & enable them
	ldx #$ff
    stx $d01c ; sprite multicolor

    ; set sprite colors
    lda #$01
    sta $d025
    lda #$02
    sta $d026
    lda #$06
    sta $d027
    lda #$06
    sta $d028
    lda #$0f
    sta $d02a
    sta $d02b
    sta $d02d
    sta $d02e

    ldx ghost_spr_offset
    stx $0ff8
    inx
    stx $0ff9
    inx
    stx $0ffa
    inx
    stx $0ffb
    inx
    stx $0ffc
    inx
    stx $0ffd
    inx
    stx $0ffe
    inx
    stx $0fff

    lda ghost_pos_x
    sta $d000
    sta $d006
    sta $d00c
    lda ghost_pos_x+48
    sta $d002
    sta $d008
    sta $d00e
    lda ghost_pos_x+96
    sta $d004
    sta $d00a

    ; move ghost up and down
    ldy sine_offset
    lda sinetab,y
    sta $d001
    sta $d003
    sta $d005
    adc #41
    sta $d007
    sta $d009
    sta $d00b
    adc #41
    sta $d00d
    sta $d00f
    iny
    sty sine_offset

	; load next interrupt
    ; a contains the sine table offset
    sbc #83
    sta $d012
    ldx #<en_ghost
    stx $0314
    ldy #>en_ghost
    sty $0315
    
	; return from interrupt
	asl $d019
	#ret

en_ghost:
    ; restore sprite state
    lda ghost_state
    sta $d015
    lda #$00
    sta $d010

    ; ghost flicker routine
    ldx ghost_ctr
    dex 
    stx ghost_ctr
    bne ghost_next
    ldx #$00
	stx $d015 ; disable all sprites
    ldx ghost_flicker
    stx ghost_ctr

ghost_next:
    cpx ghost_enable
    bne nextint2

ghost_on:
    ldx #$ff
	stx $d015 ; enable all sprites

    ldx #$ff
    stx $d015

nextint2:
	ldx #<set_green
	stx $0314
	ldy #>set_green
	sty $0315
	lda green_line
	sta $d012

	; return from interrupt
	asl $d019
	#ret

set_green:
	lda #$05
	sta $d020

	; load next interrupt
	ldx #<opnscr
	stx $0314
	ldy #>opnscr
	sty $0315
	lda opnscrirq
	sta $d012

	; return from interrupt
	asl $d019
	#ret

; open the top & bottom screen borders
opnscr:	#stall 2
	lda $d011
    and #%11110111
	sta $d011 ; clear bit 3 + set bit 0 of $d011

    lda #$05 ; green
    sta $d021

	; load next interrupt
	ldx #<textline1
	stx $0314
	ldy #>textline1
	sty $0315
	lda #$05
	sta $d012

	; return from interrupt
	asl $d019
	#ret

sinetab:
	.byte ghost_pos_y + 6 * sin(range(256) * rad(360.0/128))

	*=$0c00
	.binary "data/bg.scr"

	*=$2000
	.binary "data/bg.map"

	*=color
	.binary "data/bg.col"

    *=$09C0
    .include "data/ghostie.spr"
    
    *=$0600
    .include "data/text.spr"
