;IR code
;LABEL F
;LINK 
;STOREI 2 $T1
;LEI $P1 $T1 label1
;STOREI 1 $T2
;SUBI $P1 $T2 $T3
;PUSH 
;PUSH $T3
;JSR F
;POP 
;POP $T4
;STOREI $T4 $L1
;STOREI 2 $T5
;SUBI $P1 $T5 $T6
;PUSH 
;PUSH $T6
;JSR F
;POP 
;POP $T7
;STOREI $T7 $L2
;ADDI $L1 $L2 $T8
;STOREI $T8 $T9
;STOREI $T9 $R
;RET
;LABEL label1
;STOREI 0 $T10
;NEI $P1 $T10 label2
;STOREI 0 $T11
;STOREI $T11 $T12
;STOREI $T12 $R
;RET
;JUMP label3
;LABEL label2
;STOREI 1 $T13
;STOREI $T13 $T14
;STOREI $T14 $R
;RET
;LABEL label3
;LABEL main
;LINK 
;WRITES input
;READI $L1
;PUSH 
;PUSH $L1
;JSR F
;POP 
;POP $T1
;STOREI $T1 $L3
;WRITEI $L3
;STOREI 0 $T2
;STOREI $T2 $T3
;STOREI $T3 $R
;RET
;tiny code
str input "Please input an integer number: "
str space " "
str eol "\n"
push
push r0
push r1
push r2
push r3
jsr main
sys halt
label F 
link 16
move $-3 r0
move 2 r0
move $6 r1
cmpi r1 r0
move r0 $-3
move r1 $6
jle label1
move $-4 r0
move 1 r0
move $6 r1
move $-5 r2
move r1 r2
subi r0 r2
push
push r2
push r0
push r1
push r2
push r3
jsr F
pop r3
pop r2
pop r1
pop r0
pop
move $-6 r0
pop r0
move $-1 r2
move r0 r2
move $-7 r0
move 2 r0
move $-8 r3
move r1 r3
subi r0 r3
push
push r3
push r0
push r1
push r2
push r3
jsr F
pop r3
pop r2
pop r1
pop r0
pop
move $-9 r0
pop r0
move $-2 r3
move r0 r3
move $-10 r0
move r2 r0
addi r3 r0
move $-11 r2
move r0 r2
move r2 $7
move r1 $6
unlnk
ret
label label1 
move $-12 r0
move 0 r0
move $6 r1
cmpi r1 r0
move r0 $-12
move r1 $6
jne label2
move $-13 r0
move 0 r0
move $-14 r1
move r0 r1
move r1 $7
unlnk
ret
jmp label3 
label label2 
move $-15 r0
move 1 r0
move $-16 r1
move r0 r1
move r1 $7
unlnk
ret
label label3 
label main 
link 17
sys writes input
move $-1 r0
sys readi r0
push
push r0
push r0
push r1
push r2
push r3
jsr F
pop r3
pop r2
pop r1
pop r0
pop
move $-4 r0
pop r0
move $-3 r1
move r0 r1
sys writei r1
move $-5 r0
move 0 r0
move $-6 r1
move r0 r1
move r1 $6
unlnk
ret
end
