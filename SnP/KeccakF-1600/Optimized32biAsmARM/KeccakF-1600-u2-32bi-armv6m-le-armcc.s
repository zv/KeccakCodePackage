;
; Implementation by the Keccak, Keyak and Ketje Teams, namely, Guido Bertoni,
; Joan Daemen, Michaël Peeters, Gilles Van Assche and Ronny Van Keer, hereby
; denoted as "the implementer".
;
; For more information, feedback or questions, please refer to our websites:
; http://keccak.noekeon.org/
; http://keyak.noekeon.org/
; http://ketje.noekeon.org/
;
; To the extent possible under law, the implementer has waived all copyright
; and related or neighboring rights to the source code in this file.
; http://creativecommons.org/publicdomain/zero/1.0/
;

; WARNING: These functions work only on little endian CPU with ARMv6m architecture (ARM Cortex-M0, ...).

	PRESERVE8
	THUMB
	AREA    |.text|, CODE, READONLY

	; Credit: Henry S. Warren, Hacker's Delight, Addison-Wesley, 2002
	MACRO
	toBitInterleaving	$in0,$in1,$out0,$out1,$t,$tt,$pMask

	mov		$out0, $in0
	ldr		$t, [$pMask, #0]
	ands	$out0, $out0, $t
	lsrs	$t, $out0, #1
	orrs	$out0, $out0, $t
	ldr		$t, [$pMask, #4]
	ands	$out0, $out0, $t
	lsrs	$t, $out0, #2
	orrs	$out0, $out0, $t
	ldr		$t, [$pMask, #8]
	ands	$out0, $out0, $t
	lsrs	$t, $out0, #4
	orrs	$out0, $out0, $t
	ldr		$t, [$pMask, #12]
	ands	$out0, $out0, $t
	lsrs	$t, $out0, #8
	orrs	$out0, $out0, $t

	mov		$out1, $in1
	ldr		$t, [$pMask, #0]
	ands	$out1, $out1, $t
	lsrs	$t, $out1, #1
	orrs	$out1, $out1, $t
	ldr		$t, [$pMask, #4]
	ands	$out1, $out1, $t
	lsrs	$t, $out1, #2
	orrs	$out1, $out1, $t
	ldr		$t, [$pMask, #8]
	ands	$out1, $out1, $t
	lsrs	$t, $out1, #4
	orrs	$out1, $out1, $t
	ldr		$t, [$pMask, #12]
	ands	$out1, $out1, $t
	lsrs	$t, $out1, #8
	orrs	$out1, $out1, $t

	lsls	$out0, $out0, #16
	lsrs	$out0, $out0, #16
	lsls	$out1, $out1, #16
	orrs	$out0, $out0, $out1

	mov		$out1, $in0
	ldr		$t, [$pMask, #16]
	ands	$out1, $out1, $t
	lsls	$t, $out1, #1
	orrs	$out1, $out1, $t
	ldr		$t, [$pMask, #20]
	ands	$out1, $out1, $t
	lsls	$t, $out1, #2
	orrs	$out1, $out1, $t
	ldr		$t, [$pMask, #24]
	ands	$out1, $out1, $t
	lsls	$t, $out1, #4
	orrs	$out1, $out1, $t
	ldr		$t, [$pMask, #28]
	ands	$out1, $out1, $t
	lsls	$t, $out1, #8
	orrs	$out1, $out1, $t

	mov		$tt, $in1
	ldr		$t, [$pMask, #16]
	ands	$tt, $tt, $t
	lsls	$t, $tt, #1
	orrs	$tt, $tt, $t
	ldr		$t, [$pMask, #20]
	ands	$tt, $tt, $t
	lsls	$t, $tt, #2
	orrs	$tt, $tt, $t
	ldr		$t, [$pMask, #24]
	ands	$tt, $tt, $t
	lsls	$t, $tt, #4
	orrs	$tt, $tt, $t
	ldr		$t, [$pMask, #28]
	ands	$tt, $tt, $t
	lsls	$t, $tt, #8
	orrs	$tt, $tt, $t

	lsrs	$out1,$out1, #16
	lsrs	$tt, $tt, #16
	lsls	$tt, $tt, #16
	orrs	$out1,$out1,$tt
	MEND

	; Credit: Henry S. Warren, Hacker's Delight, Addison-Wesley, 2002
	MACRO
	fromBitInterleavingStep	$x, $t, $tt, $pMask, $maskofs, $shift

	; t = (x ^ (x >> shift)) & mask;  x = x ^ t ^ (t << shift);
	lsrs	$t, $x, #$shift
	eors	$t, $t, $x
	ldr		$tt, [$pMask, #$maskofs]
	ands	$t, $t, $tt
    eors	$x, $x, $t
	lsls	$t, $t, #$shift
    eors	$x, $x, $t
	MEND

	MACRO
	fromBitInterleaving		$x0, $x1, $t, $tt, $pMask
	movs	$t, $x0					; t = x0
	lsls	$x0, $x0, #16			; x0 = (x0 & 0x0000FFFF) | (x1 << 16);
	lsrs	$x0, $x0, #16
	lsls	$tt, $x1, #16
	orrs	$x0, $x0, $tt
	lsrs	$x1, $x1, #16			;	x1 = (t >> 16) | (x1 & 0xFFFF0000);
	lsls	$x1, $x1, #16
	lsrs	$t, $t, #16
	orrs	$x1, $x1, $t
	fromBitInterleavingStep	$x0, $t, $tt, $pMask, 0, 8
	fromBitInterleavingStep	$x0, $t, $tt, $pMask, 4, 4
	fromBitInterleavingStep	$x0, $t, $tt, $pMask, 8, 2
	fromBitInterleavingStep	$x0, $t, $tt, $pMask, 12, 1
	fromBitInterleavingStep	$x1, $t, $tt, $pMask, 0, 8
	fromBitInterleavingStep	$x1, $t, $tt, $pMask, 4, 4
	fromBitInterleavingStep	$x1, $t, $tt, $pMask, 8, 2
	fromBitInterleavingStep	$x1, $t, $tt, $pMask, 12, 1
	MEND

; --- offsets in state
_ba0	equ  0*4
_ba1	equ  1*4
_be0	equ  2*4
_be1	equ  3*4
_bi0	equ  4*4
_bi1	equ  5*4
_bo0	equ  6*4
_bo1	equ  7*4
_bu0	equ  8*4
_bu1	equ  9*4
_ga0	equ 10*4
_ga1	equ 11*4
_ge0	equ 12*4
_ge1	equ 13*4
_gi0	equ 14*4
_gi1	equ 15*4
_go0	equ 16*4
_go1	equ 17*4
_gu0	equ 18*4
_gu1	equ 19*4
_ka0	equ 20*4
_ka1	equ 21*4
_ke0	equ 22*4
_ke1	equ 23*4
_ki0	equ 24*4
_ki1	equ 25*4
_ko0	equ 26*4
_ko1	equ 27*4
_ku0	equ 28*4
_ku1	equ 29*4
_ma0	equ 30*4
_ma1	equ 31*4
_me0	equ 32*4
_me1	equ 33*4
_mi0	equ 34*4
_mi1	equ 35*4
_mo0	equ 36*4
_mo1	equ 37*4
_mu0	equ 38*4
_mu1	equ 39*4
_sa0	equ 40*4
_sa1	equ 41*4
_se0	equ 42*4
_se1	equ 43*4
_si0	equ 44*4
_si1	equ 45*4
_so0	equ 46*4
_so1	equ 47*4
_su0	equ 48*4
_su1	equ 49*4

; --- offsets on stack
mEs		equ	0		; Secondary state
mD		equ	25*2*4
mDo0	equ mD+0*4
mDo1	equ mD+1*4
mDu0	equ mD+2*4
mDu1	equ mD+3*4
mRC		equ mD+4*4
mRFU	equ mD+5*4
mSize	equ mD+6*4

; --- macros

	MACRO
	load	$reg, $stkIn, $offset
	if		$stkIn == 1
	ldr		$reg, [sp, #$offset]
	else
	if		$offset >= _ma0
	ldr		$reg, [r7, #$offset-_ma0]
	else
	ldr		$reg, [r0, #$offset]
	endif
	endif
	MEND

	MACRO
	store	$reg, $stkIn, $offset
	if		$stkIn == 0
	str		$reg, [sp, #$offset]
	else
	if		$offset >= _ma0
	str		$reg, [r7, #$offset-_ma0]
	else
	str		$reg, [r0, #$offset]
	endif
	endif
	MEND

	MACRO
	xor5	$stkIn, $result,$b,$g,$k,$m,$s
	load	$result, $stkIn, $b
	load	r6, $stkIn, $g
	eors	$result, $result, r6
	load	r6, $stkIn, $k
	eors	$result, $result, r6
	load	r6, $stkIn, $m
	eors	$result, $result, r6
	load	r6, $stkIn, $s
	eors	$result, $result, r6
	MEND

	MACRO
	te0m	$oD, $rCp0, $rCn1
	rors	$rCn1, $rCn1, r4
	eors	$rCn1, $rCn1, $rCp0
	str		$rCn1, [sp, #$oD]
	MEND

	MACRO
	te1m	$oD, $rCp1, $rCn0
	eors	$rCn0, $rCn0, $rCp1
	str		$rCn0, [sp, #$oD]
	MEND

	MACRO
	te0r	$rD, $rCp0, $rCn1
	rors	$rCn1, $rCn1, r4
	eors	$rCn1, $rCn1, $rCp0
	mov		$rD, $rCn1
	MEND

	MACRO
	te1r	$rD, $rCp1, $rCn0
	eors	$rCn0, $rCn0, $rCp1
	mov		$rD, $rCn0
	MEND

	MACRO	;// Theta Rho Pi  (1 half-lane)
	trp1	$stkIn, $b, $ofS, $orD, $fD, $rot
	load	$b, $stkIn, $ofS
	if 		$fD != 0
	mov		r6, $orD
	else
	ldr		r6, [sp, #$orD]
	endif
	eors	$b, $b, r6
	if		$rot != 0
	movs	r6, #32-$rot
	rors	$b, $b, r6
	endif
	MEND

	MACRO	;// Theta Rho Pi  (5 even half-lanes)
	trp5	$stkIn, $oS0, $orD0, $fD0, $oR0, $oS1, $orD1, $fD1, $oR1, $oS2, $orD2, $fD2, $oR2, $oS3, $orD3, $fD3, $oR3, $oS4, $orD4, $fD4, $oR4
    trp1	$stkIn, r1, $oS0, $orD0, $fD0, $oR0
    trp1	$stkIn, r2, $oS1, $orD1, $fD1, $oR1
    trp1	$stkIn, r3, $oS2, $orD2, $fD2, $oR2
    trp1	$stkIn, r4, $oS3, $orD3, $fD3, $oR3
    trp1	$stkIn, r5, $oS4, $orD4, $fD4, $oR4
	MEND

	MACRO	;// Chi Iota  (1 half-lane)
	chio1	$stkIn, $oOut, $ax0, $ax1, $ax2, $iota, $useax2
	if $useax2 != 0
	bics	$ax2, $ax2, $ax1			;// A[x+2] = A[x+2] & ~A[x+1]
	eors	$ax2, $ax2, $ax0			;// A[x+2] = A[x+2] ^ A[x]
	if $iota != 0xFF
	ldr		r1, [sp, #mRC]
	ldr		r4, [r1, #$iota]
	eors	$ax2, $ax2, r4
	endif
	store	$ax2, $stkIn, $oOut
	else
	mov		r6, $ax2					;// T1 = A[x+2]
	bics	r6, r6, $ax1				;// T1 = T1 & ~A[x+1]
	eors	r6, r6, $ax0				;// T1 = T1 ^ A[x]
	store	r6, $stkIn, $oOut
	endif
	MEND

	MACRO	;// Chi Iota  (5 half-lanes)
	chio5	$stkIn, $oOut, $iota
	chio1	$stkIn, $oOut+8*4, r5, r1, r2, 0xFF, 0
	chio1	$stkIn, $oOut+6*4, r4, r5, r1, 0xFF, 0
	chio1	$stkIn, $oOut+4*4, r3, r4, r5, 0xFF, 1
	chio1	$stkIn, $oOut+2*4, r2, r3, r4, 0xFF, 1
	chio1	$stkIn, $oOut+0*4, r1, r2, r3, $iota, 1
	MEND

	MACRO	;// Chi Iota  (5 half-lanes)
	Kround	$stkIn, $iota

	; prepare Theta
	movs	r4, #31

    xor5	$stkIn, r1, _be1, _ge1, _ke1, _me1, _se1
    xor5	$stkIn, r2, _bu0, _gu0, _ku0, _mu0, _su0
	mov		r6, r1
    te0r	r8, r2, r6

    xor5	$stkIn, r3, _bi1, _gi1, _ki1, _mi1, _si1
    te1m	mDo1, r3, r2

    xor5	$stkIn, r2, _ba0, _ga0, _ka0, _ma0, _sa0
    te0r	r10, r2, r3

    xor5	$stkIn, r3, _bo1, _go1, _ko1, _mo1, _so1
    te1m	mDu1, r3, r2

    xor5	$stkIn, r2, _be0, _ge0, _ke0, _me0, _se0
    te0r	r12, r2, r3

    xor5	$stkIn, r3, _bu1, _gu1, _ku1, _mu1, _su1
    te1r	r9, r3, r2

    xor5	$stkIn, r2, _bi0, _gi0, _ki0, _mi0, _si0
    te0m	mDo0, r2, r3

    xor5	$stkIn, r3, _ba1, _ga1, _ka1, _ma1, _sa1
    te1r	r11, r3, r2

    xor5	$stkIn, r2, _bo0, _go0, _ko0, _mo0, _so0
    te0m	mDu0, r2, r3
    te1r	lr, r1, r2

	trp5 	$stkIn, _bi0, r12, 1, 31, _go1, mDo1, 0, 28, _ku1, mDu1, 0, 20, _ma1, r9, 1, 21, _se0, r10, 1,  1
	chio5	$stkIn, _sa0, 0xFF
	trp5 	$stkIn, _bi1, lr, 1, 31, _go0, mDo0, 0, 27, _ku0, mDu0, 0, 19, _ma0, r8, 1, 20, _se1, r11, 1,  1
	chio5	$stkIn, _sa1, 0xFF

	trp5 	$stkIn, _bu1, mDu1, 0, 14, _ga0, r8, 1, 18, _ke0, r10, 1,  5, _mi1, lr, 1,  8, _so0, mDo0, 0, 28
	chio5	$stkIn,  _ma0, 0xFF
	trp5 	$stkIn, _bu0, mDu0, 0, 13, _ga1, r9, 1, 18, _ke1, r11, 1,  5, _mi0, r12, 1,  7, _so1, mDo1, 0, 28
	chio5	$stkIn,  _ma1, 0xFF

	trp5 	$stkIn, _be1, r11, 1,  1, _gi0, r12, 1,  3, _ko1, mDo1, 0, 13, _mu0, mDu0, 0,  4, _sa0, r8, 1,  9
	chio5	$stkIn, _ka0, 0xFF
	trp5 	$stkIn, _be0, r10, 1,  0, _gi1, lr, 1,  3, _ko0, mDo0, 0, 12, _mu1, mDu1, 0,  4, _sa1, r9, 1,  9
	chio5	$stkIn, _ka1, 0xFF

	trp5 	$stkIn, _bo0, mDo0, 0, 14, _gu0, mDu0, 0, 10, _ka1, r9, 1,  2, _me1, r11, 1, 23, _si1, lr, 1, 31
	chio5	$stkIn, _ga0, 0xFF
	trp5 	$stkIn, _bo1, mDo1, 0, 14, _gu1, mDu1, 0, 10, _ka0, r8, 1,  1, _me0, r10, 1, 22, _si0, r12, 1, 30
	chio5	$stkIn, _ga1, 0xFF 

	trp5 	$stkIn, _ba0, r8, 1,  0, _ge0, r10, 1, 22, _ki1, lr, 1, 22, _mo1, mDo1, 0, 11, _su0, mDu0, 0,  7
	chio5	$stkIn, _ba0, $iota+0
	trp5 	$stkIn, _ba1, r9, 1,  0, _ge1, r11, 1, 22, _ki0, r12, 1, 21, _mo0, mDo0, 0, 10, _su1, mDu1, 0,  7
	chio5	$stkIn, _ba1, $iota+4
	MEND

;----------------------------------------------------------------------------
;
; void KeccakF1600_Initialize( void )
;
	ALIGN
	EXPORT  KeccakF1600_Initialize
KeccakF1600_Initialize   PROC
	bx		lr
	ENDP

;----------------------------------------------------------------------------
;
; void KeccakF1600_StateInitialize(void *state)
;
	ALIGN
	EXPORT  KeccakF1600_StateInitialize
KeccakF1600_StateInitialize   PROC
	push	{r4 - r5}
	movs	r1, #0
	movs	r2, #0
	movs	r3, #0
	movs	r4, #0
	movs	r5, #0
	stmia	r0!, { r1 - r5 }
	stmia	r0!, { r1 - r5 }
	stmia	r0!, { r1 - r5 }
	stmia	r0!, { r1 - r5 }
	stmia	r0!, { r1 - r5 }
	stmia	r0!, { r1 - r5 }
	stmia	r0!, { r1 - r5 }
	stmia	r0!, { r1 - r5 }
	stmia	r0!, { r1 - r5 }
	stmia	r0!, { r1 - r5 }
	pop		{r4 - r5}
	bx		lr
	ENDP

;----------------------------------------------------------------------------
;
;	void KeccakF1600_StateComplementBit(void *state, unsigned int position)
;
	ALIGN
	EXPORT  KeccakF1600_StateComplementBit
KeccakF1600_StateComplementBit   PROC
	push	{r4, lr}
	movs	r3, #1
	ands	r3, r3, r1
	lsrs	r2, r1, #6
	lsls	r4, r3, #2
	adds	r0, r0, r4
	lsls	r4, r2, #3
	adds	r0, r0, r4
	lsls	r3, r1, #32-6
	lsrs	r3, r3, #32-5
	movs	r2, #1
	lsls	r2, r2, r3
	ldr		r3, [r0]
	eors	r3, r3, r2
	str		r3, [r0]
	pop		{r4, pc}
	bx		lr
	ENDP

;----------------------------------------------------------------------------
;
; void KeccakF1600_StateXORBytes(void *state, const unsigned char *data, unsigned int offset, unsigned int length)
;
	ALIGN
	EXPORT  KeccakF1600_StateXORBytes
KeccakF1600_StateXORBytes   PROC
	cmp		r3, #0									; if length != 0
	beq		KeccakF1600_StateXORBytes_Exit1
	push	{r4 - r6, lr}							; then
	mov		r4, r8
	mov		r5, r9
	mov		r6, r10
	push	{r4 - r7}
	lsrs	r4, r2, #3								; offset &= ~7
	lsls	r4, r4, #3
	adds	r0, r0, r4								; add whole lane offset to state pointer
	lsls	r2, r2, #29								; offset &= 7 (part not lane aligned)
	lsrs	r2, r2, #29
	beq		KeccakF1600_StateXORBytes_CheckLanes	; if offset != 0
	movs	r4, r3									; then, do remaining bytes in first lane
	movs	r5, #8
	subs	r5, r2									; max size in lane = 8 - offset
	cmp		r4, r5
	ble		KeccakF1600_StateXORBytes_BytesAlign
	movs	r4, r5
KeccakF1600_StateXORBytes_BytesAlign
	subs	r3, r3, r4								; size left
	mov		r10, r3
	movs	r3, r4
	adr		r7, KeccakF1600_StateXORBytes_ToBitInterleavingConstants
	bl		__KeccakF1600_StateXORBytesInLane
	mov		r3, r10
KeccakF1600_StateXORBytes_CheckLanes
	lsrs	r2, r3, #3								; if length >= 8
	beq		KeccakF1600_StateXORBytes_Bytes
	mov		r10, r3
	adr		r3, KeccakF1600_StateXORBytes_ToBitInterleavingConstants
	bl		__KeccakF1600_StateXORLanes
	mov		r3, r10
	lsls	r3, r3, #29
	lsrs	r3, r3, #29
KeccakF1600_StateXORBytes_Bytes
	cmp		r3, #0
	beq		KeccakF1600_StateXORBytes_Exit
	movs	r2, #0
	adr		r7, KeccakF1600_StateXORBytes_ToBitInterleavingConstants
	bl		__KeccakF1600_StateXORBytesInLane
KeccakF1600_StateXORBytes_Exit
	pop		{r4 - r7}
	mov		r8, r4
	mov		r9, r5
	mov		r10, r6
	pop		{r4 - r6, pc}
KeccakF1600_StateXORBytes_Exit1
	bx		lr
	nop
KeccakF1600_StateXORBytes_ToBitInterleavingConstants
	dcd		0x55555555
	dcd		0x33333333
	dcd		0x0F0F0F0F
	dcd		0x00FF00FF
	dcd		0xAAAAAAAA
	dcd		0xCCCCCCCC
	dcd		0xF0F0F0F0
	dcd		0xFF00FF00
	ENDP

;----------------------------------------------------------------------------
;
; __KeccakF1600_StateXORLanes
;
; Input:
;  r0 state pointer
;  r1 data pointer
;  r2 laneCount
;  r3 to bit interleaving constants pointer
;
; Output:
;  r0 state pointer next lane
;  r1 data pointer next byte to input
;
;  Changed: r2-r9
;
	ALIGN
__KeccakF1600_StateXORLanes   PROC
	lsls	r4, r1, #30
	bne		__KeccakF1600_StateXORLanes_LoopUnaligned
__KeccakF1600_StateXORLanes_LoopAligned
	ldmia	r1!, {r6,r7}
	mov		r8, r6
	mov		r9, r7
	toBitInterleaving	r8, r9, r6, r7, r5, r4, r3
	ldr     r5, [r0]
	eors	r6, r6, r5
	ldr     r5, [r0, #4]
	eors	r7, r7, r5
	stmia	r0!, {r6,r7}
	subs	r2, r2, #1
	bne		__KeccakF1600_StateXORLanes_LoopAligned
	bx		lr
__KeccakF1600_StateXORLanes_LoopUnaligned
	ldrb	r6, [r1, #0]
	ldrb	r4, [r1, #1]
	lsls	r4, r4, #8
	orrs	r6, r6, r4
	ldrb	r4, [r1, #2]
	lsls	r4, r4, #16
	orrs	r6, r6, r4
	ldrb	r4, [r1, #3]
	lsls	r4, r4, #24
	orrs	r6, r6, r4
	ldrb	r7, [r1, #4]
	ldrb	r4, [r1, #5]
	lsls	r4, r4, #8
	orrs	r7, r7, r4
	ldrb	r4, [r1, #6]
	lsls	r4, r4, #16
	orrs	r7, r7, r4
	ldrb	r4, [r1, #7]
	lsls	r4, r4, #24
	orrs	r7, r7, r4
	adds	r1, r1, #8
	mov		r8, r6
	mov		r9, r7
	toBitInterleaving	r8, r9, r6, r7, r5, r4, r3
	ldr     r5, [r0]
	eors	r6, r6, r5
	ldr     r5, [r0, #4]
	eors	r7, r7, r5
	stmia	r0!, {r6, r7}
	subs	r2, r2, #1
	bne		__KeccakF1600_StateXORLanes_LoopUnaligned
	bx		lr
	ENDP

;----------------------------------------------------------------------------
;
; __KeccakF1600_StateXORBytesInLane
;
; Input:
;  r0 state pointer
;  r1 data pointer
;  r2 offset in lane
;  r3 length
;  r7 to bit interleaving constants pointer
;
; Output:
;  r0 state pointer next lane
;  r1 data pointer next byte to input
;
;  Changed: r2-r9
;
	ALIGN
__KeccakF1600_StateXORBytesInLane   PROC
	movs	r4, #0
	movs	r5, #0
	push	{ r4 - r5 }
	add		r2, r2, sp
__KeccakF1600_StateXORBytesInLane_Loop
	ldrb	r5, [r1]
	strb	r5, [r2]
	adds	r1, r1, #1
	adds	r2, r2, #1
	subs	r3, r3, #1
	bne		__KeccakF1600_StateXORBytesInLane_Loop
	pop		{ r4 - r5 }
	mov		r8, r4
	mov		r9, r5
	toBitInterleaving	r8, r9, r4, r5, r6, r2, r7
	ldr     r6, [r0]
	eors	r4, r4, r6
	ldr     r6, [r0, #4]
	eors	r5, r5, r6
	stmia	r0!, { r4, r5 }
	bx		lr
	ENDP

;----------------------------------------------------------------------------
;
; void KeccakF1600_StateOverwriteBytes(void *state, const unsigned char *data, unsigned int offset, unsigned int length)
;
	ALIGN
	EXPORT  KeccakF1600_StateOverwriteBytes
KeccakF1600_StateOverwriteBytes   PROC
	cmp		r3, #0									; if length != 0
	beq		KeccakF1600_StateOverwriteBytes_Exit1
	push	{r4 - r6, lr}							; then
	mov		r4, r8
	mov		r5, r9
	mov		r6, r10
	push	{r4 - r7}
	lsrs	r4, r2, #3								; offset &= ~7
	lsls	r4, r4, #3
	adds	r0, r0, r4								; add whole lane offset to state pointer
	lsls	r2, r2, #29								; offset &= 7 (part not lane aligned)
	lsrs	r2, r2, #29
	beq		KeccakF1600_StateOverwriteBytes_CheckLanes	; if offset != 0
	movs	r4, r3									; then, do remaining bytes in first lane
	movs	r5, #8
	subs	r5, r2									; max size in lane = 8 - offset
	cmp		r4, r5
	ble		KeccakF1600_StateOverwriteBytes_BytesAlign
	movs	r4, r5
KeccakF1600_StateOverwriteBytes_BytesAlign
	subs	r3, r3, r4								; size left
	mov		r10, r3
	movs	r3, r4
	adr		r7, KeccakF1600_StateOverwriteBytes_ToBitInterleavingConstants
	bl		__KeccakF1600_StateOverwriteBytesInLane
	mov		r3, r10
KeccakF1600_StateOverwriteBytes_CheckLanes
	lsrs	r2, r3, #3								; if length >= 8
	beq		KeccakF1600_StateOverwriteBytes_Bytes
	mov		r10, r3
	adr		r3, KeccakF1600_StateOverwriteBytes_ToBitInterleavingConstants
	bl		__KeccakF1600_StateOverwriteLanes
	mov		r3, r10
	lsls	r3, r3, #29
	lsrs	r3, r3, #29
KeccakF1600_StateOverwriteBytes_Bytes
	cmp		r3, #0
	beq		KeccakF1600_StateOverwriteBytes_Exit
	movs	r2, #0
	adr		r7, KeccakF1600_StateOverwriteBytes_ToBitInterleavingConstants
	bl		__KeccakF1600_StateOverwriteBytesInLane
KeccakF1600_StateOverwriteBytes_Exit
	pop		{r4 - r7}
	mov		r8, r4
	mov		r9, r5
	mov		r10, r6
	pop		{r4 - r6, pc}
KeccakF1600_StateOverwriteBytes_Exit1
	bx		lr
	nop
KeccakF1600_StateOverwriteBytes_ToBitInterleavingConstants
	dcd		0x55555555
	dcd		0x33333333
	dcd		0x0F0F0F0F
	dcd		0x00FF00FF
	dcd		0xAAAAAAAA
	dcd		0xCCCCCCCC
	dcd		0xF0F0F0F0
	dcd		0xFF00FF00
	ENDP

;----------------------------------------------------------------------------
;
; __KeccakF1600_StateOverwriteLanes
;
; Input:
;  r0 state pointer
;  r1 data pointer
;  r2 laneCount
;  r3 to bit interleaving constants pointer
;
; Output:
;  r0 state pointer next lane
;  r1 data pointer next byte to input
;
;  Changed: r2-r9
;
	ALIGN
__KeccakF1600_StateOverwriteLanes   PROC
	lsls	r4, r1, #30
	bne		__KeccakF1600_StateOverwriteLanes_LoopUnaligned
__KeccakF1600_StateOverwriteLanes_LoopAligned
	ldmia	r1!, {r6,r7}
	mov		r8, r6
	mov		r9, r7
	toBitInterleaving	r8, r9, r6, r7, r5, r4, r3
	stmia	r0!, {r6,r7}
	subs	r2, r2, #1
	bne		__KeccakF1600_StateOverwriteLanes_LoopAligned
	bx		lr
__KeccakF1600_StateOverwriteLanes_LoopUnaligned
	ldrb	r6, [r1, #0]
	ldrb	r4, [r1, #1]
	lsls	r4, r4, #8
	orrs	r6, r6, r4
	ldrb	r4, [r1, #2]
	lsls	r4, r4, #16
	orrs	r6, r6, r4
	ldrb	r4, [r1, #3]
	lsls	r4, r4, #24
	orrs	r6, r6, r4
	ldrb	r7, [r1, #4]
	ldrb	r4, [r1, #5]
	lsls	r4, r4, #8
	orrs	r7, r7, r4
	ldrb	r4, [r1, #6]
	lsls	r4, r4, #16
	orrs	r7, r7, r4
	ldrb	r4, [r1, #7]
	lsls	r4, r4, #24
	orrs	r7, r7, r4
	adds	r1, r1, #8
	mov		r8, r6
	mov		r9, r7
	toBitInterleaving	r8, r9, r6, r7, r5, r4, r3
	stmia	r0!, {r6, r7}
	subs	r2, r2, #1
	bne		__KeccakF1600_StateOverwriteLanes_LoopUnaligned
	bx		lr
	ENDP

;----------------------------------------------------------------------------
;
; __KeccakF1600_StateOverwriteBytesInLane
;
; Input:
;  r0 state pointer
;  r1 data pointer
;  r2 offset in lane
;  r3 length
;  r7 to bit interleaving constants pointer
;
; Output:
;  r0 state pointer next lane
;  r1 data pointer next byte to input
;
;  Changed: r2-r9
;
	ALIGN
__KeccakF1600_StateOverwriteBytesInLane   PROC
	movs	r4, #0
	movs	r5, #0
	push	{ r4 - r5 }
	lsls	r6, r2, #2
	add		r2, r2, sp
	movs	r4, #0x0F						;r4 mask to wipe nibbles(bit interleaved bytes) in state
	lsls	r4, r4, r6
	movs	r6, r4
__KeccakF1600_StateOverwriteBytesInLane_Loop
	orrs	r6, r6, r4
	lsls	r4, r4, #4
	ldrb	r5, [r1]
	strb	r5, [r2]
	adds	r1, r1, #1
	adds	r2, r2, #1
	subs	r3, r3, #1
	bne		__KeccakF1600_StateOverwriteBytesInLane_Loop
	pop		{ r4 - r5 }
	mov		r8, r4
	mov		r9, r5
	toBitInterleaving	r8, r9, r4, r5, r3, r2, r7
	ldr     r3, [r0]
	bics	r3, r3, r6
	eors	r4, r4, r3
	ldr     r3, [r0, #4]
	bics	r3, r3, r6
	eors	r5, r5, r3
	stmia	r0!, { r4, r5 }
	bx		lr
	ENDP

;----------------------------------------------------------------------------
;
; void KeccakF1600_StateOverwriteWithZeroes(void *state, unsigned int byteCount)
;
	ALIGN
	EXPORT  KeccakF1600_StateOverwriteWithZeroes
KeccakF1600_StateOverwriteWithZeroes	PROC
	push	{r4 - r5}
	lsrs	r2, r1, #3
	beq		KeccakF1600_StateOverwriteWithZeroes_Bytes
	movs	r4, #0
	movs	r5, #0
KeccakF1600_StateOverwriteWithZeroes_LoopLanes
	stm		r0!, { r4, r5 }
	subs	r2, r2, #1
	bne		KeccakF1600_StateOverwriteWithZeroes_LoopLanes
KeccakF1600_StateOverwriteWithZeroes_Bytes
	lsls	r1, r1, #32-3
	beq		KeccakF1600_StateOverwriteWithZeroes_Exit
	lsrs	r1, r1, #32-3
	movs	r3, #0x0F						;r2 already zero, r3 = mask to wipe nibbles(bit interleaved bytes) in state
KeccakF1600_StateOverwriteWithZeroes_LoopBytes
	orrs	r2, r2, r3
	lsls	r3, r3, #4
	subs	r1, r1, #1
	bne		KeccakF1600_StateOverwriteWithZeroes_LoopBytes
	ldr		r4, [r0]
	ldr		r5, [r0, #4]
	bics	r4, r4, r2
	bics	r5, r5, r2
	stm		r0!, { r4, r5 }
KeccakF1600_StateOverwriteWithZeroes_Exit
	pop		{r4 - r5}
	bx		lr
	ENDP

;----------------------------------------------------------------------------
;
; void KeccakF1600_StateExtractBytes(void *state, const unsigned char *data, unsigned int offset, unsigned int length)
;
	ALIGN
	EXPORT  KeccakF1600_StateExtractBytes
KeccakF1600_StateExtractBytes   PROC
	cmp		r3, #0									; if length != 0
	beq		KeccakF1600_StateExtractBytes_Exit1
	push	{r4 - r6, lr}							; then
	mov		r4, r8
	push	{r4, r7}
	lsrs	r4, r2, #3								; offset &= ~7
	lsls	r4, r4, #3
	adds	r0, r0, r4								; add whole lane offset to state pointer
	lsls	r2, r2, #29								; offset &= 7 (part not lane aligned)
	lsrs	r2, r2, #29
	beq		KeccakF1600_StateExtractBytes_CheckLanes	; if offset != 0
	movs	r4, r3									; then, do remaining bytes in first lane
	movs	r5, #8
	subs	r5, r2									; max size in lane = 8 - offset
	cmp		r4, r5
	ble		KeccakF1600_StateExtractBytes_BytesAlign
	movs	r4, r5
KeccakF1600_StateExtractBytes_BytesAlign
	subs	r3, r3, r4								; size left
	mov		r8, r3
	movs	r3, r4
	adr		r7, KeccakF1600_StateExtractBytes_FromBitInterleavingConstants
	bl		__KeccakF1600_StateExtractBytesInLane
	mov		r3, r8
KeccakF1600_StateExtractBytes_CheckLanes
	lsrs	r2, r3, #3								; if length >= 8
	beq		KeccakF1600_StateExtractBytes_Bytes
	mov		r8, r3
	adr		r3, KeccakF1600_StateExtractBytes_FromBitInterleavingConstants
	bl		__KeccakF1600_StateExtractLanes
	mov		r3, r8
	lsls	r3, r3, #29
	lsrs	r3, r3, #29
KeccakF1600_StateExtractBytes_Bytes
	cmp		r3, #0
	beq		KeccakF1600_StateExtractBytes_Exit
	movs	r2, #0
	adr		r7, KeccakF1600_StateExtractBytes_FromBitInterleavingConstants
	bl		__KeccakF1600_StateExtractBytesInLane
KeccakF1600_StateExtractBytes_Exit
	pop		{r4,r7}
	mov		r8, r4
	pop		{r4 - r6, pc}
KeccakF1600_StateExtractBytes_Exit1
	bx		lr
	nop
KeccakF1600_StateExtractBytes_FromBitInterleavingConstants
    dcd		0x0000FF00
    dcd		0x00F000F0
    dcd		0x0C0C0C0C
    dcd		0x22222222
	ENDP

;----------------------------------------------------------------------------
;
; __KeccakF1600_StateExtractLanes
;
; Input:
;  r0 state pointer
;  r1 data pointer
;  r2 laneCount
;  r3 from bit interleaving constants pointer
;
; Output:
;  r0 state pointer next lane
;  r1 data pointer next byte to output
;
;  Changed: r2-r7
;
	ALIGN
__KeccakF1600_StateExtractLanes   PROC
	lsls	r4, r1, #30
	bne		__KeccakF1600_StateExtractLanes_LoopUnaligned
__KeccakF1600_StateExtractLanes_LoopAligned
	ldmia	r0!, {r6,r7}
	fromBitInterleaving	r6, r7, r5, r4, r3
	stmia	r1!, {r6,r7}
	subs	r2, r2, #1
	bne		__KeccakF1600_StateExtractLanes_LoopAligned
	bx		lr
__KeccakF1600_StateExtractLanes_LoopUnaligned
	ldmia	r0!, {r6,r7}
	fromBitInterleaving	r6, r7, r5, r4, r3
	strb	r6, [r1, #0]
	lsrs	r6, r6, #8
	strb	r6, [r1, #1]
	lsrs	r6, r6, #8
	strb	r6, [r1, #2]
	lsrs	r6, r6, #8
	strb	r6, [r1, #3]
	strb	r7, [r1, #4]
	lsrs	r7, r7, #8
	strb	r7, [r1, #5]
	lsrs	r7, r7, #8
	strb	r7, [r1, #6]
	lsrs	r7, r7, #8
	strb	r7, [r1, #7]
	adds	r1, r1, #8
	subs	r2, r2, #1
	bne		__KeccakF1600_StateExtractLanes_LoopUnaligned
	bx		lr
	ENDP

;----------------------------------------------------------------------------
;
; __KeccakF1600_StateExtractBytesInLane
;
; Input:
;  r0 state pointer
;  r1 data pointer
;  r2 offset in lane
;  r3 length
;  r7 from bit interleaving constants pointer
;
; Output:
;  r0 state pointer next lane
;  r1 data pointer next byte to output
;
;  Changed: r2-r7
;
	ALIGN
__KeccakF1600_StateExtractBytesInLane   PROC
	ldmia	r0!, {r4,r5}
	push	{r0, r3}
	fromBitInterleaving	r4, r5, r0, r3, r7
	pop		{r0, r3}
	push	{r4, r5}
	mov		r4, sp
	adds	r4, r4, r2
__KeccakF1600_StateExtractBytesInLane_Loop
	ldrb	r2, [r4]
	adds	r4, r4, #1
	strb	r2, [r1]
	adds	r1, r1, #1
	subs	r3, r3, #1
	bne		__KeccakF1600_StateExtractBytesInLane_Loop
	add		sp, #8
	bx		lr
	ENDP

;----------------------------------------------------------------------------
;
; void KeccakF1600_StateExtractAndXORBytes(void *state, const unsigned char *data, unsigned int offset, unsigned int length)
;
	ALIGN
	EXPORT  KeccakF1600_StateExtractAndXORBytes
KeccakF1600_StateExtractAndXORBytes   PROC
	cmp		r3, #0									; if length != 0
	beq		KeccakF1600_StateExtractAndXORBytes_Exit1
	push	{r4 - r6, lr}							; then
	mov		r4, r8
	push	{r4, r7}
	lsrs	r4, r2, #3								; offset &= ~7
	lsls	r4, r4, #3
	adds	r0, r0, r4								; add whole lane offset to state pointer
	lsls	r2, r2, #29								; offset &= 7 (part not lane aligned)
	lsrs	r2, r2, #29
	beq		KeccakF1600_StateExtractAndXORBytes_CheckLanes	; if offset != 0
	movs	r4, r3									; then, do remaining bytes in first lane
	movs	r5, #8
	subs	r5, r2									; max size in lane = 8 - offset
	cmp		r4, r5
	ble		KeccakF1600_StateExtractAndXORBytes_BytesAlign
	movs	r4, r5
KeccakF1600_StateExtractAndXORBytes_BytesAlign
	subs	r3, r3, r4								; size left
	mov		r8, r3
	movs	r3, r4
	adr		r7, KeccakF1600_StateExtractAndXORBytes_FromBitInterleavingConstants
	bl		__KeccakF1600_StateExtractAndXORBytesInLane
	mov		r3, r8
KeccakF1600_StateExtractAndXORBytes_CheckLanes
	lsrs	r2, r3, #3								; if length >= 8
	beq		KeccakF1600_StateExtractAndXORBytes_Bytes
	mov		r8, r3
	adr		r3, KeccakF1600_StateExtractAndXORBytes_FromBitInterleavingConstants
	bl		__KeccakF1600_StateExtractAndXORLanes
	mov		r3, r8
	lsls	r3, r3, #29
	lsrs	r3, r3, #29
KeccakF1600_StateExtractAndXORBytes_Bytes
	cmp		r3, #0
	beq		KeccakF1600_StateExtractAndXORBytes_Exit
	movs	r2, #0
	adr		r7, KeccakF1600_StateExtractAndXORBytes_FromBitInterleavingConstants
	bl		__KeccakF1600_StateExtractAndXORBytesInLane
KeccakF1600_StateExtractAndXORBytes_Exit
	pop		{r4,r7}
	mov		r8, r4
	pop		{r4 - r6, pc}
KeccakF1600_StateExtractAndXORBytes_Exit1
	bx		lr
	nop
KeccakF1600_StateExtractAndXORBytes_FromBitInterleavingConstants
    dcd		0x0000FF00
    dcd		0x00F000F0
    dcd		0x0C0C0C0C
    dcd		0x22222222
	ENDP

;----------------------------------------------------------------------------
;
; __KeccakF1600_StateExtractAndXORLanes
;
; Input:
;  r0 state pointer
;  r1 data pointer
;  r2 laneCount
;  r3 from bit interleaving constants pointer
;
; Output:
;  r0 state pointer next lane
;  r1 data pointer next byte to output
;
;  Changed: r2-r7
;
	ALIGN
__KeccakF1600_StateExtractAndXORLanes   PROC
	lsls	r4, r1, #30
	bne		__KeccakF1600_StateExtractAndXORLanes_LoopUnaligned
__KeccakF1600_StateExtractAndXORLanes_LoopAligned
	ldmia	r0!, {r6,r7}
	fromBitInterleaving	r6, r7, r5, r4, r3
	ldr		r5, [r1]
	eors	r6, r6, r5
	ldr		r5, [r1, #4]
	eors	r7, r7, r5
	stmia	r1!, {r6,r7}
	subs	r2, r2, #1
	bne		__KeccakF1600_StateExtractAndXORLanes_LoopAligned
	bx		lr
__KeccakF1600_StateExtractAndXORLanes_LoopUnaligned
	ldmia	r0!, {r6,r7}
	fromBitInterleaving	r6, r7, r5, r4, r3
	ldrb	r5, [r1, #0]
	eors	r5, r5, r6
	strb	r5, [r1, #0]
	lsrs	r6, r6, #8
	ldrb	r5, [r1, #1]
	eors	r5, r5, r6
	strb	r5, [r1, #1]
	lsrs	r6, r6, #8
	ldrb	r5, [r1, #2]
	eors	r5, r5, r6
	strb	r5, [r1, #2]
	lsrs	r6, r6, #8
	ldrb	r5, [r1, #3]
	eors	r5, r5, r6
	strb	r5, [r1, #3]
	ldrb	r5, [r1, #4]
	eors	r5, r5, r7
	strb	r5, [r1, #4]
	lsrs	r7, r7, #8
	ldrb	r5, [r1, #5]
	eors	r5, r5, r7
	strb	r5, [r1, #5]
	lsrs	r7, r7, #8
	ldrb	r5, [r1, #6]
	eors	r5, r5, r7
	strb	r5, [r1, #6]
	lsrs	r7, r7, #8
	ldrb	r5, [r1, #7]
	eors	r5, r5, r7
	strb	r5, [r1, #7]
	adds	r1, r1, #8
	subs	r2, r2, #1
	bne		__KeccakF1600_StateExtractAndXORLanes_LoopUnaligned
	bx		lr
	ENDP

;----------------------------------------------------------------------------
;
; __KeccakF1600_StateExtractAndXORBytesInLane
;
; Input:
;  r0 state pointer
;  r1 data pointer
;  r2 offset in lane
;  r3 length
;  r7 from bit interleaving constants pointer
;
; Output:
;  r0 state pointer next lane
;  r1 data pointer next byte to output
;
;  Changed: r2-r7
;
	ALIGN
__KeccakF1600_StateExtractAndXORBytesInLane   PROC
	ldmia	r0!, {r4,r5}
	push	{r0, r3}
	fromBitInterleaving	r4, r5, r0, r3, r7
	pop		{r0, r3}
	push	{r4, r5}
	mov		r4, sp
	adds	r4, r4, r2
__KeccakF1600_StateExtractAndXORBytesInLane_Loop
	ldrb	r2, [r4]
	adds	r4, r4, #1
	ldrb	r5, [r1]
	eors	r2, r2, r5
	strb	r2, [r1]
	adds	r1, r1, #1
	subs	r3, r3, #1
	bne		__KeccakF1600_StateExtractAndXORBytesInLane_Loop
	add		sp, #8
	bx		lr
	ENDP

;----------------------------------------------------------------------------
;
; void KeccakF1600_StatePermute( void *state )
;
	ALIGN
	EXPORT  KeccakF1600_StatePermute
KeccakF1600_StatePermute   PROC
	adr		r1, KeccakF1600_StatePermute_RoundConstantsWithTerminator
	b		KeccakP1600_StatePermute
	ENDP

	ALIGN
KeccakF1600_StatePermute_RoundConstantsWithTerminator
	;		0			1
	dcd		0x00000001,	0x00000000
	dcd		0x00000000,	0x00000089
	dcd		0x00000000,	0x8000008b
	dcd		0x00000000,	0x80008080

	dcd		0x00000001,	0x0000008b
	dcd		0x00000001,	0x00008000
	dcd		0x00000001,	0x80008088
	dcd		0x00000001,	0x80000082

	dcd		0x00000000,	0x0000000b
	dcd		0x00000000,	0x0000000a
	dcd		0x00000001,	0x00008082
	dcd		0x00000000,	0x00008003

	dcd		0x00000001,	0x0000808b
	dcd		0x00000001,	0x8000000b
	dcd		0x00000001,	0x8000008a
	dcd		0x00000001,	0x80000081

	dcd		0x00000000,	0x80000081
	dcd		0x00000000,	0x80000008
	dcd		0x00000000,	0x00000083
	dcd		0x00000000,	0x80008003

	dcd		0x00000001,	0x80008088
	dcd		0x00000000,	0x80000088
	dcd		0x00000001,	0x00008000
	dcd		0x00000000,	0x80008082

	dcd		0x000000FF	;terminator

;----------------------------------------------------------------------------
;
; void KeccakP1600_StatePermute( void *state, void * rc )
;
	ALIGN
KeccakP1600_StatePermute   PROC
	push	{ r4 - r6, lr }
	mov		r2, r8
	mov		r3, r9
	mov		r4, r10
	mov		r5, r11
	mov		r6, r12
	push	{ r2 - r7 }
	sub		sp, #mSize
	movs	r7, #_ma0
	adds	r7, r7, r0
KeccakP1600_StatePermute_RoundLoop
	str		r1, [sp, #mRC]
	Kround	0, 0
	Kround	1, 8
	adds	r1, r1, #2*8		; Update pointer RC
	ldr		r6, [r1]			; Check terminator
	cmp		r6, #0xFF
	beq		KeccakP1600_StatePermute_Done
	ldr		r6, =KeccakP1600_StatePermute_RoundLoop+1
	bx		r6
	LTORG
KeccakP1600_StatePermute_Done
	add		sp, #mSize
	pop		{ r1 - r5, r7 }
	mov		r8, r1
	mov		r9, r2
	mov		r10, r3
	mov		r11, r4
	mov		r12, r5
	pop		{ r4 - r6, pc }
	ENDP

;----------------------------------------------------------------------------
;
; Keccak_SnP_InterleaveByteAsm
; in:  r1   byte to be interleaved
;
; out: r9	Least significant interleaved byte
;      r10  Most significant interleaved byte
;
; changed: r2, r3
;
	ALIGN
Keccak_SnP_InterleaveByteAsm	PROC
	movs	r2, #0x55			; even bits
	ands	r2, r2, r1
	lsrs	r3, r2, #1
	orrs	r2, r2, r3

	movs	r3, #0x33
	ands	r2, r2, r3
	lsrs	r3, r2, #2
	orrs	r2, r2, r3

	lsls	r2, r2, #32-4
	lsrs	r2, r2, #32-4
	mov		r9, r2

	movs	r2, #0xAA			; odd bits
	ands	r2, r2, r1
	lsls	r3, r2, #1
	orrs	r2, r2, r3

	movs	r3, #0xCC
	ands	r2, r2, r3
	lsls	r3, r2, #2
	orrs	r2, r2, r3
	lsrs	r2, r2, #4
	mov		r10, r2

	bx		lr
	ENDP

;----------------------------------------------------------------------------
;
; size_t KeccakF1600_SnP_FBWL_Absorb(	void *state, unsigned int laneCount, unsigned char *data,
;										size_t dataByteLen, unsigned char trailingBits )
;
	ALIGN
	EXPORT	KeccakF1600_SnP_FBWL_Absorb
KeccakF1600_SnP_FBWL_Absorb	PROC
	push	{ r4 - r6, lr }
	mov		r4, r8
	mov		r5, r9
	mov		r6, r10
	push	{ r4 - r7 }
	mov		r6, r2							; r6 data pointer
	mov		r8, r2							; r8 initial data pointer
	lsrs	r3, r3, #3						; r7 nbrLanes = dataByteLen / SnP_laneLengthInBytes
	subs	r7, r3, r1						; if (nbrLanes >= laneCount)
	bcc		KeccakF1600_SnP_FBWL_Absorb_Exit
	mov		r4, r0
	mov		r5, r1
	ldr		r1, [sp, #(8+0)*4]				; Bit Interleave trailingBits
	bl		Keccak_SnP_InterleaveByteAsm
KeccakF1600_SnP_FBWL_Absorb_Loop
	mov		r1, r8
	mov		r2, r9
	push	{r1, r2}
	push	{r3, r4, r5, r7}
	mov		r1, r6
	mov		r2, r5
	adr		r3, KeccakF1600_SnP_FBWL_Absorb_ToBitInterleavingConstants
	bl		__KeccakF1600_StateXORLanes
	mov		r6, r1							; save updated data pointer
	pop		{r3, r4, r5, r7}
	pop		{r1, r2}
	mov		r8, r1
	mov		r9, r2
	ldr		r1, [r0, #0]					; xor bit interleaved trailing bits
	mov		r2, r9
	eors	r1, r1, r2
	str		r1, [r0, #0]
	ldr		r1, [r0, #4]
	mov		r2, r10
	eors	r1, r1, r2
	str		r1, [r0, #4]
	mov		r0, r4
	bl		KeccakF1600_StatePermute
	subs	r7, r7, r5						; nbrLanes -= laneCount
	bcs		KeccakF1600_SnP_FBWL_Absorb_Loop
KeccakF1600_SnP_FBWL_Absorb_Exit
	mov		r0, r8							; processed = data pointer - initial data pointer
	subs	r6, r6, r0
	mov		r0, r6
	pop		{ r4 - r7 }
	mov		r8, r4
	mov		r9, r5
	mov		r10, r6
	pop		{ r4 - r6, pc }
KeccakF1600_SnP_FBWL_Absorb_ToBitInterleavingConstants
	dcd		0x55555555
	dcd		0x33333333
	dcd		0x0F0F0F0F
	dcd		0x00FF00FF
	dcd		0xAAAAAAAA
	dcd		0xCCCCCCCC
	dcd		0xF0F0F0F0
	dcd		0xFF00FF00
	ENDP

;----------------------------------------------------------------------------
;
; size_t KeccakF1600_SnP_FBWL_Squeeze( void *state, unsigned int laneCount, unsigned char *data, size_t dataByteLen )
;
	ALIGN
	EXPORT	KeccakF1600_SnP_FBWL_Squeeze
KeccakF1600_SnP_FBWL_Squeeze	PROC
	push	{ r4 - r6, lr }
	mov		r4, r8
	mov		r5, r9
	mov		r6, r10
	push	{ r4 - r7 }
	mov		r6, r2							; r6 data pointer
	mov		r8, r2							; r8 initial data pointer
	lsrs	r3, r3, #3						; r7 nbrLanes = dataByteLen / SnP_laneLengthInBytes
	subs	r7, r3, r1						; if (nbrLanes >= laneCount)
	bcc		KeccakF1600_SnP_FBWL_Squeeze_Exit
	mov		r5, r1
KeccakF1600_SnP_FBWL_Squeeze_Loop
	bl		KeccakF1600_StatePermute
	push	{r0, r3, r5, r7}
	mov		r1, r6
	mov		r2, r5
	adr		r3, KeccakF1600_SnP_FBWL_Squeeze_FromBitInterleavingConstants
	bl		__KeccakF1600_StateExtractLanes
	mov		r6, r1							; save updated data pointer
	pop		{r0, r3, r5, r7}
	subs	r7, r7, r5						; nbrLanes -= laneCount
	bcs		KeccakF1600_SnP_FBWL_Squeeze_Loop
KeccakF1600_SnP_FBWL_Squeeze_Exit
	mov		r0, r8							; processed = data pointer - initial data pointer
	subs	r6, r6, r0
	mov		r0, r6
	pop		{ r4 - r7 }
	mov		r8, r4
	mov		r9, r5
	mov		r10, r6
	pop		{ r4 - r6, pc }
	nop
KeccakF1600_SnP_FBWL_Squeeze_FromBitInterleavingConstants
    dcd		0x0000FF00
    dcd		0x00F000F0
    dcd		0x0C0C0C0C
    dcd		0x22222222
	ENDP

;----------------------------------------------------------------------------
;
; size_t KeccakF1600_SnP_FBWL_Wrap( void *state, unsigned int laneCount, const unsigned char *dataIn,
;										unsigned char *dataOut, size_t dataByteLen, unsigned char trailingBits )
;
	ALIGN
	EXPORT	KeccakF1600_SnP_FBWL_Wrap
KeccakF1600_SnP_FBWL_Wrap	PROC
	push	{ r4 - r6, lr }
	mov		r4, r8
	mov		r5, r9
	mov		r6, r10
	push	{ r4 - r7 }
	mov		r6, r2							; r6 dataIn pointer
	mov		r8, r2							; r8 initial dataIn pointer
	ldr		r7, [sp, #(8+0)*4]
	lsrs	r7, r7, #3						; r7 nbrLanes = dataByteLen / SnP_laneLengthInBytes
	subs	r7, r7, r1						; if (nbrLanes >= laneCount)
	bcc		KeccakF1600_SnP_FBWL_Wrap_Exit
	mov		r4, r3							; r4 dataOut pointer
	mov		r5, r1							; r5 laneCount
	ldr		r1, [sp, #(8+1)*4]				; Bit Interleave trailingBits
	bl		Keccak_SnP_InterleaveByteAsm
KeccakF1600_SnP_FBWL_Wrap_Loop
	mov		r1, r8
	mov		r2, r9
	push	{r1, r2}
	push	{r3, r4, r5, r7}
	mov		r1, r6
	mov		r2, r5
	adr		r3, KeccakF1600_SnP_FBWL_Wrap_ToBitInterleavingConstants
	bl		__KeccakF1600_StateXORLanes
	mov		r6, r1							; save updated dataIn pointer
	pop		{r3, r4, r5, r7}
	pop		{r1, r2}
	mov		r8, r1
	mov		r9, r2
	lsls	r2, r5, #3
	subs	r0, r0, r2
	push	{r3, r5, r6, r7}
	mov		r1, r4
	mov		r2, r5
	adr		r3, KeccakF1600_SnP_FBWL_Wrap_FromBitInterleavingConstants
	bl		__KeccakF1600_StateExtractLanes
	pop		{r3, r5, r6, r7}
	mov		r4, r1							; save updated dataOut pointer
	ldr		r1, [r0, #0]					; xor bit interleaved trailing bits
	mov		r2, r9
	eors	r1, r1, r2
	str		r1, [r0, #0]
	ldr		r1, [r0, #4]
	mov		r2, r10
	eors	r1, r1, r2
	str		r1, [r0, #4]
	lsls	r2, r5, #3
	subs	r0, r0, r2
	bl		KeccakF1600_StatePermute
	subs	r7, r7, r5						; nbrLanes -= laneCount
	bcs		KeccakF1600_SnP_FBWL_Wrap_Loop
KeccakF1600_SnP_FBWL_Wrap_Exit
	mov		r0, r8							; processed = dataIn pointer - initial dataIn pointer
	subs	r6, r6, r0
	mov		r0, r6
	pop		{ r4 - r7 }
	mov		r8, r4
	mov		r9, r5
	mov		r10, r6
	pop		{ r4 - r6, pc }
KeccakF1600_SnP_FBWL_Wrap_ToBitInterleavingConstants
	dcd		0x55555555
	dcd		0x33333333
	dcd		0x0F0F0F0F
	dcd		0x00FF00FF
	dcd		0xAAAAAAAA
	dcd		0xCCCCCCCC
	dcd		0xF0F0F0F0
	dcd		0xFF00FF00
KeccakF1600_SnP_FBWL_Wrap_FromBitInterleavingConstants
    dcd		0x0000FF00
    dcd		0x00F000F0
    dcd		0x0C0C0C0C
    dcd		0x22222222
	ENDP

;----------------------------------------------------------------------------
;
; size_t KeccakF1600_SnP_FBWL_Unwrap( void *state, unsigned int laneCount, const unsigned char *dataIn,
;										unsigned char *dataOut, size_t dataByteLen, unsigned char trailingBits)
;
	ALIGN
	EXPORT	KeccakF1600_SnP_FBWL_Unwrap
KeccakF1600_SnP_FBWL_Unwrap	PROC
	push	{ r4 - r6, lr }
	mov		r4, r8
	mov		r5, r9
	mov		r6, r10
	push	{ r4 - r7 }
	mov		r6, r2							; r6 dataIn pointer
	mov		r8, r2							; r8 initial dataIn pointer
	ldr		r7, [sp, #(8+0)*4]
	lsrs	r7, r7, #3						; r7 nbrLanes = dataByteLen / SnP_laneLengthInBytes
	subs	r7, r7, r1						; if (nbrLanes >= laneCount)
	bcs		KeccakF1600_SnP_FBWL_Unwrap_Start
	b		KeccakF1600_SnP_FBWL_Unwrap_Exit
KeccakF1600_SnP_FBWL_Unwrap_Start
	mov		r4, r11
	mov		r5, r12
	push	{ r4 - r5 }
	mov		r4, r3							; r4 dataOut pointer
	mov		r5, r1							; r5 laneCount
	ldr		r1, [sp, #(10+1)*4]				; Bit Interleave trailingBits
	bl		Keccak_SnP_InterleaveByteAsm
KeccakF1600_SnP_FBWL_Unwrap_Loop
	mov		lr, r5
	adr		r3, KeccakF1600_SnP_FBWL_Unwrap_BitInterleavingConstants
	b		KeccakF1600_SnP_FBWL_Unwrap_LanesLoop
	nop
KeccakF1600_SnP_FBWL_Unwrap_BitInterleavingConstants
	dcd		0x55555555						; to BI
	dcd		0x33333333
	dcd		0x0F0F0F0F
	dcd		0x00FF00FF
	dcd		0xAAAAAAAA
	dcd		0xCCCCCCCC
	dcd		0xF0F0F0F0
	dcd		0xFF00FF00

    dcd		0x0000FF00						; from BI
    dcd		0x00F000F0
    dcd		0x0C0C0C0C
    dcd		0x22222222
KeccakF1600_SnP_FBWL_Unwrap_DataInUnaligned
	ldrb	r1, [r6, #0]
	ldrb	r5, [r6, #1]
	lsls	r5, r5, #8
	orrs	r1, r1, r5
	ldrb	r5, [r6, #2]
	lsls	r5, r5, #16
	orrs	r1, r1, r5
	ldrb	r5, [r6, #3]
	lsls	r5, r5, #24
	orrs	r1, r1, r5

	ldrb	r2, [r6, #4]
	ldrb	r5, [r6, #5]
	lsls	r5, r5, #8
	orrs	r2, r2, r5
	ldrb	r5, [r6, #6]
	lsls	r5, r5, #16
	orrs	r2, r2, r5
	ldrb	r5, [r6, #7]
	lsls	r5, r5, #24
	orrs	r2, r2, r5
	adds	r6, r6, #8
	b		KeccakF1600_SnP_FBWL_Unwrap_ToInterleave
KeccakF1600_SnP_FBWL_Unwrap_LanesLoop
	push	{r5, r7}

	lsls	r2, r6, #30
	bne		KeccakF1600_SnP_FBWL_Unwrap_DataInUnaligned
KeccakF1600_SnP_FBWL_Unwrap_LoopAligned
	ldmia	r6!, {r1,r2}
KeccakF1600_SnP_FBWL_Unwrap_ToInterleave
	mov		r11, r1
	mov		r12, r2
	toBitInterleaving	r11, r12, r1, r2, r5, r7, r3
	ldr     r5, [r0]
	ldr     r7, [r0, #4]
	stmia	r0!, { r1, r2 }
	eors	r1, r1, r5
	eors	r2, r2, r7

	adds	r3, r3, #8*4		;todo: can be avoided
	fromBitInterleaving	r1, r2, r5, r7, r3
	subs	r3, r3, #8*4		;todo: can be avoided
	lsls	r5, r4, #30
	bne		KeccakF1600_SnP_FBWL_Unwrap_DataOutUnaligned
	stmia	r4!, {r1,r2}
KeccakF1600_SnP_FBWL_Unwrap_NextLane
	pop		{r5, r7}
	mov		r1, lr
	subs	r1, r1, #1
	beq		KeccakF1600_SnP_FBWL_Unwrap_LanesDone
	mov		lr, r1
	b		KeccakF1600_SnP_FBWL_Unwrap_LanesLoop
KeccakF1600_SnP_FBWL_Unwrap_LanesDone
	ldr		r1, [r0, #0]					; xor bit interleaved trailing bits
	mov		r2, r9
	eors	r1, r1, r2
	str		r1, [r0, #0]
	ldr		r1, [r0, #4]
	mov		r2, r10
	eors	r1, r1, r2
	str		r1, [r0, #4]
	lsls	r2, r5, #3
	subs	r0, r0, r2
	bl		KeccakF1600_StatePermute
	subs	r7, r7, r5						; nbrLanes -= laneCount
	bcc		KeccakF1600_SnP_FBWL_Unwrap_Done
	b		KeccakF1600_SnP_FBWL_Unwrap_Loop
KeccakF1600_SnP_FBWL_Unwrap_Done
	pop		{ r4 - r5 }
	mov		r11, r4
	mov		r12, r5
KeccakF1600_SnP_FBWL_Unwrap_Exit
	mov		r0, r8							; processed = dataIn pointer - initial dataIn pointer
	subs	r6, r6, r0
	mov		r0, r6
	pop		{ r4 - r7 }
	mov		r8, r4
	mov		r9, r5
	mov		r10, r6
	pop		{ r4 - r6, pc }
KeccakF1600_SnP_FBWL_Unwrap_DataOutUnaligned
	strb	r1, [r4, #0]
	lsrs	r1, r1, #8
	strb	r1, [r4, #1]
	lsrs	r1, r1, #8
	strb	r1, [r4, #2]
	lsrs	r1, r1, #8
	strb	r1, [r4, #3]
	strb	r2, [r4, #4]
	lsrs	r2, r2, #8
	strb	r2, [r4, #5]
	lsrs	r2, r2, #8
	strb	r2, [r4, #6]
	lsrs	r2, r2, #8
	strb	r2, [r4, #7]
	adds	r4, r4, #8
	b		KeccakF1600_SnP_FBWL_Unwrap_NextLane
	nop
	ENDP

	END
