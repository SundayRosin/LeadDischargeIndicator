/*
 * indic_12.asm
 *
 *  Created: 27.10.2011 13:27:19
 */ 

.def tmp=r16
.def tmp1=r17
.def tmp2=r18

.cseg 
.org 0
 rjmp init

.org 0x006
reti
.org 0x007
reti
.org 0x008  ;Timer/Counter1 Overflow
rjmp timer
.org 0x009  ;Timer/Counter0 Overflow
rjmp timer2
.org 0x00E  ;ADC Conversion Complete
rjmp adc_ok   
   
.cseg

init:
;������������� ��������� �����
ldi tmp, low(RAMEND)
out SPL, tmp
ldi tmp, high(RAMEND)
out SPH, tmp

;������������� PORTD ��� �����, �� ��� ����� ����������.
ldi tmp, 0xff
out ddrd, tmp
out portd, tmp ;������� ��������� ���� ������� ��� �� ����.
;������������� PORTB0, PORTB1 ��� ������. 
ldi tmp, 0x03
out ddrb,tmp
;� ����� �������� �� ������ �� ��� �����, ���� �� ��� ���� � �����.
sbi portb, 0 ;1 �� �������� ����������, ������� ����������.
sbi portb, 1 ;��������� �� PB1 "1", ����� ��� ����.

;������������� PORTC2 - �������
ldi tmp, 0x04
out ddrc, tmp


;������������� ADC
ldi tmp, 0xEC    ;�������� ������� 128
out adcsra, tmp
;���������� ���������� �������� �������� ���������� 2.56�.
;������������ �� ������ ����,����� ADC3
ldi tmp, 0xe3
out admux, tmp

;�������������� 16 ������ ������ �������
ldi tmp, 0x02  ;
out tccr1b, tmp ;������ ������������ �� 8

ldi tmp, 0x04
out timsk, tmp ;��������� ���������� �� TC1

;�������������� TC0
ldi tmp, 0x01
out tccr0, tmp   ;������ �������� ��� ��������

ser tmp        ; �������� watchdog
out wdtcr,tmp  ;

sei

n: ;a����� loop � main()
nop
nop
nop
rjmp n

;���������� �� ���������-��������� ���������������.
adc_ok: 
cli
wdr            ;
ser tmp        ; ������� watchdog-� ��� �� ����
out wdtcr, tmp  ;
in r0, adch   ;������ ����������,������� ��������,����
sei
reti

;���������� �� Timer1
timer: 
wdr            ;
ser tmp        ; ������� watchdog-� ��� �� ����
out wdtcr, tmp  ;


ldi tmp, 0x02       ;��� ��� ����� ��� �� ������ � �������
cp tmp, r3          ;
breq out_sound
inc r3
rjmp out_sound2

out_sound:
clr r3
out_sound2:


ldi tmp1, 0xB0   ; ������ ������� ��� ������� ����� ������ 8� ���������
ldi tmp2, 0x03   ; 3B0=944; 2.36� �� ���� ADC � 13.8� �� ����� ��������.
rcall del_six
cp r0, tmp2
brcc eight

ldi tmp1, 0x8c    ; ������ ������� ��� ������� ����� ������ 7� ���������
ldi tmp2, 0x03    ; 38�=908; 2.27� �� ���� ADC � 13.3� �� ����� ��������.
rcall del_six
cp r0, tmp2
brcc seven

ldi tmp1, 0x64   ; ������ ������� ��� ������� ����� ������ 6� ���������
ldi tmp2, 0x03   ; 364=868; 2.17� �� ���� ADC � 12.7� �� ����� ��������.
rcall del_six
cp r0, tmp2
brcc six

ldi tmp1, 0x44   ; ������ ������� ��� ������� ����� ������ 5� ���������
ldi tmp2, 0x03   ; 344=836; 2.09� �� ���� ADC � 12.2� �� ����� ��������.
rcall del_six
cp r0, tmp2
brcc five

ldi tmp1, 0x20   ; ������ ������� ��� ������� ����� ������ 4� ���������
ldi tmp2, 0x03    ; 320=800; 2.00� �� ���� ADC � 11.7� �� ����� ��������. 
rcall del_six 
cp r0, tmp2
brcc four

ldi tmp1, 0xF4   ; ������ ������� ��� ������� ����� ������ 3� ���������
ldi tmp2, 0x02   ; 2F4=756; 1.89� �� ���� ADC � 11.1� �� ����� ��������. 
rcall del_six
cp r0, tmp2
brcc three

ldi tmp1, 0xcc    ; ������ ������� ��� ������� ����� ������ 2� ��������� 
ldi tmp2, 0x02    ; 2CC=716; 1.79� �� ���� ADC � 10.5� �� ����� ��������.
rcall del_six
cp r0, tmp2
brcc two

ldi tmp1, 0x9c    ; ������ ������� ��� ������� ����� ������ 1� ���������
ldi tmp2, 0x02    ; 29c=668; 1.67� �� ���� ADC � 9.8� �� ����� ��������.
rcall del_six
cp r0, tmp2
brcc dead

ldi tmp1, 0x99     ; ������ ������� ��� ������� ����� �������� ����������� �������� �� PB1,PB0
ldi tmp2, 0x02     ;299=665 ; 1.66 �� ���� ADC, 9.7� �� ����� ��������.
rcall del_six
cp r0, tmp2
brcc blow
rjmp outspase2



eight:
;C����� ��� ����������
ldi tmp, 0xff
out portd, tmp
rcall sound_off
rjmp outspase

seven:
  ldi tmp, 0x7f
  out portd, tmp
  rcall sound_off
  clr r7            ;��������� ��������� "����������"
  rjmp outspase

six:
  ldi tmp, 0x3f
  out portd, tmp
  rcall sound_off
  clr r7            ;��������� ��������� "����������"
  rjmp outspase

five:
  ldi tmp, 0x1f
  out portd, tmp
  rcall sound_off
  clr r7            ;��������� ��������� "����������"
  rjmp outspase

four:
  ldi tmp, 0x0f
  out portd, tmp
  rcall sound_off
  clr r7            ;��������� ��������� "����������"
  rjmp outspase

three:
  ldi tmp, 0x07
  out portd, tmp
  rcall sound_off
  clr r7            ;��������� ��������� "����������"
  rjmp outspase

two: 
  ldi tmp, 0x03
  out portd, tmp
  ldi tmp, 0x05      ;�������� ����
  out timsk, tmp     ;
  clr r7            ;��������� ��������� "����������"
  rjmp outspase

dead:
  ldi tmp, 0x01
  out portd, tmp
  ldi tmp, 0x05       ;�������� ����
  out timsk, tmp      ;
  rjmp outspase

blow:
  clr tmp
  out portd, tmp       ;����� ��� ����������
  rcall sound_off
  rcall power_off  
  rjmp outspase


outspase2:            ;���� ���������� ���� �������� ������� ����
clr tmp
out portd, tmp
rcall sound_off
rcall power_off


outspase:

reti


sound_off:
ldi tmp, 0x04   ;��������� ���������� TC0, ��� ����� ��������� ����
out timsk, tmp  ;
ret

del_six:     ;��������� ���������� 12 ���������� ����� � 8 ����������;
ldi tmp, 0x06
k:
lsl tmp1
rol tmp2
dec tmp
brne k
ret

power_off:   ;��������� ���������� �������
ldi tmp, 0x01  ;����� ��� ���� ��� �� ������ ��������� �����������
cp tmp, r7     ;
breq outthis  ;
inc r7        ;

cbi portb, 0 ;��������� ��� ����� � �������� ����������
cbi portb, 1 ;��������� ����, ���� ��� � ��� ����

   ldi r19, 255    ;���� ��������
m: ldi r20, 255
wdr            ;
ser tmp        ; ������� watchdog-� ��� �� ����
out wdtcr, tmp  ;
m1: dec r20
    brne m1
	dec r19
	brne m

	ldi r19, 255
nm:  dec r19
    brne nm 

sbi	 portb, 0  ; ������� ��� ����.
sbi portb, 1   ;


outthis:

ret

;���������� �� Timer2
timer2:           ;��������� ����
ldi tmp, 0x01
cp tmp, r3
breq out1
clr r3

clr tmp;
out portd, tmp

out2:
sbi portc, 2

ldi tmp, 0x01 
cp tmp, r2
breq out3
inc r2
rjmp out1

out3:
clr r2

cbi portc, 2

clr r1
out1:

reti