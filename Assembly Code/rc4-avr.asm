.include "m32def.inc"
.def i = r17
.def keylen = r18
.def key0 = r19
.def key1 = r20
.def key2 = r21
.def key3 = r22
.def key4 = r8
.def keytemp = r23
.def temp = r24
.def bit = r25 ;hold extracted bit
.def j = r30
.def counter = r31
.def temp2 = r16
ldi key0,'p'
ldi key1,'r'
ldi key2,'i'
ldi key3,'v'
ldi temp,'8'
mov key4,temp
ldi keylen,5
ldi r16,0x8
out sph,r16
ldi r16,0x5f
out spl,r16

ldi r16,0x00
mov XL,r16
ldi r16,0x2
mov XH,r16

ldi r16,0
ldi i,0
ldi j,0
ldi counter,0
ldi XH,high(0x200)
ldi XL,low(0x200)
ldi YH,high(0x200)
ldi temp,'i'
sts 0x300,temp
ldi temp,'u'
sts 0x301,temp
ldi temp,'t'
sts 0x302,temp
ldi temp,'9'
sts 0x303,temp
ldi temp,'1'
sts 0x304,temp
;//Main Body
call initialize
call keysch
call pseudo
call encode
endddd:rjmp endddd
;//
initialize : ;initializing
init:

	st X+,r16
	inc r16
	cpi r16,255
	breq second
	rjmp init
second:
	st X,r16
	ret

keysch:
	ldi XL,low(0x200)
	ldi i,0
	ldi j,0
	lol:
	cpi counter,255
	breq keyend
	ld temp,X+
	add j,temp
	mov i,counter
	call mod
	call findbit
	add j,keytemp
	mov YL,j
	ld temp2,Y
	st Y,temp
	mov YL,counter
	st Y,temp2
	inc counter
	rjmp lol
keyend:
	ld temp,X
	add j,temp
	mov i,counter
	call mod
	call findbit
	add j,keytemp
	mov YL,j
	ld temp2,Y
	st Y,temp
	mov YL,counter
	st Y,temp2
ret

mod: ; calcualte i mod keylen
	cp i,keylen
	brlo return
	sub i,keylen
	rjmp mod
return : ret

findbit: ;extracting key[i mod keylen]
	cpi i,0
	breq bytee0
	cpi i,1
	breq bytee1
	cpi i,2
	breq bytee2
	cpi i,3
	breq bytee3
	cpi i,4
	breq bytee4
 bytee0:
 	mov keytemp,key0
 	ret
 bytee1:
 	mov keytemp,key1
 	ret
 bytee2:
 	mov keytemp,key2
 	ret
 bytee3:
 	mov keytemp,key3
 	ret
 bytee4:
 	mov keytemp,key4
 	ret
pseudo:
	ldi i,0
	ldi j,0
againn:
	cpi i,5
	breq retur
	inc i;i:=(i+1)%256
	mov XL,i
	ld temp,X
	add j,temp
	mov YL,j
	ld temp2,Y
	st Y,temp
	mov YL,i
	st Y,temp2
	add temp,temp2
	mov XL,temp
	ld temp,X
	ldi YL,0x1F ;so that -> 0x31F +1 = 0x320
	ldi YH,0x3 ; 0x31F
	add YL,i ; 0x320 :D
	st Y,temp
	ldi YH,0x2
	rjmp againn
	retur:ret
encode: ; encoding the plain-text with keystream and store it into 0x400 -> 0x404
	lds temp,0x320 ; load first byte of keystream
	lds temp2,0x300 ; load first byte of plain-text
	eor temp,temp2 ; XORing
	sts 0x400,temp ; storing
	;//
	lds temp,0x321
	lds temp2,0x301
	eor temp,temp2
	sts 0x401,temp
	lds temp,0x322
	lds temp2,0x302
	eor temp,temp2
	sts 0x402,temp
	lds temp,0x323
	lds temp2,0x303
	eor temp,temp2
	sts 0x403,temp
	lds temp,0x324
	lds temp2,0x304
	eor temp,temp2
	sts 0x404,temp
	ret

; :)
