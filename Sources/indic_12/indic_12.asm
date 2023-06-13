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
;Инициализация указателя стека
ldi tmp, low(RAMEND)
out SPL, tmp
ldi tmp, high(RAMEND)
out SPH, tmp

;Инициализация PORTD как выход, на них сидят светодиоды.
ldi tmp, 0xff
out ddrd, tmp
out portd, tmp ;моргнем диодиками дабы сказать что мы живы.
;Инициализация PORTB0, PORTB1 как выходы. 
ldi tmp, 0x03
out ddrb,tmp
;И сразу поставим на лапках то что нужно, если бы все было в норме.
sbi portb, 0 ;1 на открытом коллекторе, открыли транзистор.
sbi portb, 1 ;установим на PB1 "1", вдруг там реле.

;Инициализация PORTC2 - пищалка
ldi tmp, 0x04
out ddrc, tmp


;Инициализация ADC
ldi tmp, 0xEC    ;делитель частоты 128
out adcsra, tmp
;Используем внутренний источник опорного напряжения 2.56в.
;Выравнивание по левому краю,вывод ADC3
ldi tmp, 0xe3
out admux, tmp

;Инициализируем 16 битный таймер счетчик
ldi tmp, 0x02  ;
out tccr1b, tmp ;ставим предделитель на 8

ldi tmp, 0x04
out timsk, tmp ;разрешаем прерывание от TC1

;Инициализируем TC0
ldi tmp, 0x01
out tccr0, tmp   ;подаем тактовую без делителя

ser tmp        ; включаем watchdog
out wdtcr,tmp  ;

sei

n: ;aналог loop в main()
nop
nop
nop
rjmp n

;прерывание от аналогово-цифрового преобразователя.
adc_ok: 
cli
wdr            ;
ser tmp        ; говорим watchdog-у что мы живы
out wdtcr, tmp  ;
in r0, adch   ;пришло прирывание,считали значение,ушли
sei
reti

;прерывание от Timer1
timer: 
wdr            ;
ser tmp        ; говорим watchdog-у что мы живы
out wdtcr, tmp  ;


ldi tmp, 0x02       ;это все нужно что бы пикало с паузами
cp tmp, r3          ;
breq out_sound
inc r3
rjmp out_sound2

out_sound:
clr r3
out_sound2:


ldi tmp1, 0xB0   ; задаем уровень при котором будет гореть 8й светодиод
ldi tmp2, 0x03   ; 3B0=944; 2.36в на лапе ADC и 13.8в на входе делителя.
rcall del_six
cp r0, tmp2
brcc eight

ldi tmp1, 0x8c    ; задаем уровень при котором будет гореть 7й светодиод
ldi tmp2, 0x03    ; 38С=908; 2.27в на лапе ADC и 13.3в на входе делителя.
rcall del_six
cp r0, tmp2
brcc seven

ldi tmp1, 0x64   ; задаем уровень при котором будет гореть 6й светодиод
ldi tmp2, 0x03   ; 364=868; 2.17в на лапе ADC и 12.7в на входе делителя.
rcall del_six
cp r0, tmp2
brcc six

ldi tmp1, 0x44   ; задаем уровень при котором будет гореть 5й светодиод
ldi tmp2, 0x03   ; 344=836; 2.09в на лапе ADC и 12.2в на входе делителя.
rcall del_six
cp r0, tmp2
brcc five

ldi tmp1, 0x20   ; задаем уровень при котором будет гореть 4й светодиод
ldi tmp2, 0x03    ; 320=800; 2.00в на лапе ADC и 11.7в на входе делителя. 
rcall del_six 
cp r0, tmp2
brcc four

ldi tmp1, 0xF4   ; задаем уровень при котором будет гореть 3й светодиод
ldi tmp2, 0x02   ; 2F4=756; 1.89в на лапе ADC и 11.1в на входе делителя. 
rcall del_six
cp r0, tmp2
brcc three

ldi tmp1, 0xcc    ; задаем уровень при котором будет гореть 2й светодиод 
ldi tmp2, 0x02    ; 2CC=716; 1.79в на лапе ADC и 10.5в на входе делителя.
rcall del_six
cp r0, tmp2
brcc two

ldi tmp1, 0x9c    ; задаем уровень при котором будет гореть 1й светодиод
ldi tmp2, 0x02    ; 29c=668; 1.67в на лапе ADC и 9.8в на входе делителя.
rcall del_six
cp r0, tmp2
brcc dead

ldi tmp1, 0x99     ; задаем уровень при котором нужно подавать управляющие импульсы на PB1,PB0
ldi tmp2, 0x02     ;299=665 ; 1.66 на лапе ADC, 9.7в на входе делителя.
rcall del_six
cp r0, tmp2
brcc blow
rjmp outspase2



eight:
;Cветим все светодиоды
ldi tmp, 0xff
out portd, tmp
rcall sound_off
rjmp outspase

seven:
  ldi tmp, 0x7f
  out portd, tmp
  rcall sound_off
  clr r7            ;разрешаем сработать "отключалке"
  rjmp outspase

six:
  ldi tmp, 0x3f
  out portd, tmp
  rcall sound_off
  clr r7            ;разрешаем сработать "отключалке"
  rjmp outspase

five:
  ldi tmp, 0x1f
  out portd, tmp
  rcall sound_off
  clr r7            ;разрешаем сработать "отключалке"
  rjmp outspase

four:
  ldi tmp, 0x0f
  out portd, tmp
  rcall sound_off
  clr r7            ;разрешаем сработать "отключалке"
  rjmp outspase

three:
  ldi tmp, 0x07
  out portd, tmp
  rcall sound_off
  clr r7            ;разрешаем сработать "отключалке"
  rjmp outspase

two: 
  ldi tmp, 0x03
  out portd, tmp
  ldi tmp, 0x05      ;включаем звук
  out timsk, tmp     ;
  clr r7            ;разрешаем сработать "отключалке"
  rjmp outspase

dead:
  ldi tmp, 0x01
  out portd, tmp
  ldi tmp, 0x05       ;включаем звук
  out timsk, tmp      ;
  rjmp outspase

blow:
  clr tmp
  out portd, tmp       ;тушим все светодиоды
  rcall sound_off
  rcall power_off  
  rjmp outspase


outspase2:            ;если напряжение ниже минимума прийдем сюда
clr tmp
out portd, tmp
rcall sound_off
rcall power_off


outspase:

reti


sound_off:
ldi tmp, 0x04   ;запрещяем прерывание TC0, тем самым выключаем звук
out timsk, tmp  ;
ret

del_six:     ;процедура приведения 12 разрядного числа к 8 разрядному;
ldi tmp, 0x06
k:
lsl tmp1
rol tmp2
dec tmp
brne k
ret

power_off:   ;процедура выключения питания
ldi tmp, 0x01  ;нужно для того что бы делать процедуру единоразово
cp tmp, r7     ;
breq outthis  ;
inc r7        ;

cbi portb, 0 ;открываем наш вывод с открытым колектором
cbi portb, 1 ;отключаем реле, если оно у нас есть

   ldi r19, 255    ;цикл задержки
m: ldi r20, 255
wdr            ;
ser tmp        ; говорим watchdog-у что мы живы
out wdtcr, tmp  ;
m1: dec r20
    brne m1
	dec r19
	brne m

	ldi r19, 255
nm:  dec r19
    brne nm 

sbi	 portb, 0  ; вернули как было.
sbi portb, 1   ;


outthis:

ret

;прерывание от Timer2
timer2:           ;формируем звук
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