# ----------------------------------
# Ziqi Tan 
# memos1
# Created on Feb 25, 2020
# -----------------------------------

.text	        # .text section
.global _start	# start entry
.code16		    # code will be run in 16-bit mode.

# ------------------------------------------------------------------------
_start:
    # When the BIOS finds such a boot sector, 
    # it is loaded into memory at 0x0000:0x7c00 (segment 0, address 0x7c00);
    # some BIOS' load to **0x7c0:0x0000** (segment 0x07c0, offset 0).
    movw	$0x07C0, %AX
	movw	%AX, %DS		# lodsb need this, and we insert the string in code segment
	movw	%AX, %ES
	movw	%AX, %SS
	# CS will be loaded 0x07C0
	
    # clear SI and DI
	xorw	%SI, %SI	# DS : SI
	xorw	%DI, %DI

	# movw	$0x1000, %AX		# init bp, sp to 0x1000
	# movw	%AX, %BP
	# movw	%AX, %SP

    call print_Welcome
	call print_line
	call get_memory_map
	call print_memory_map
    jmp .
# -------------------------------------------------------------------------


# -----------------------------------------------------------------------
print_Welcome:
	leaw 	welcome_string, %SI    # SI for address of the string
                                # lea (load effective address) instruction is used to 
                                # put a memory address into the destination.
	movw 	welcome_string_len, %CX    # CX stores the length of the string
	call 	print_string

	call 	get_memory_size

	leaw 	memory_unit, %SI
	movw 	len_memory_unit, %CX
	call 	print_string
    
	ret


# -----------------------------------------------------------------------
print_string:
	lodsb   # Load byte at address DS:SI into AL
	
    pushw   %AX    # save AH
    
    # call BIOS interrupts
    movb 	$0x0E, %AH		
	int 	$0x10
        # INT 10
        # Function: Teletype output
        # Function code: AH = 0E H
        # Parameters: AL = Character, BH = Page Number, BL = Color
    
    popw    %AX    # retrieve AH
        
	loop 	print_string

	ret

# ---------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------
print_line:
	pushw %AX			# save AX, BX
	pushw %BX

	movw $0x0e0d, %AX	# 0x0d carriage return (CR)
	movw $0x07, %BX		# BX controls the color
	int $0x10
	
	movw $0x0e0a, %AX	# 0x0a new line (NL)
	movw $0x07, %BX		
	int $0x10

	popw %BX
	popw %AX			# retrieve AX, BX

	ret
# ---------------------------------------------------------------

# ------------------------------------------------------------
get_memory_size:
    # BIOS interrupt
    movw    $0xE801, %AX
    int     $0x15
    # Typical Output:
    # AX = CX = extended memory between 1M and 16M, in K (max 3C00h = 15MB)
    # BX = DX = extended memory above 16M, in 64K blocks

	cmpb    $0x86, %AH
	je 		E801_ERROR			# if E801 does not work, return ;

	cmpb 	$0x80, %AH
	je		E801_ERROR			# if E801 does not work, return ;

    addw 	$0x400, %AX			# ax add 1MB
	shll 	$6, %EBX	  		# bx times 64
	addl 	%EAX, %EBX			# ax + bx
	shrl 	$10, %EBX			# convert KB to MB
	
	movl 	$memory_size, %ESI	# put the address of memory_size in SI
	movl	%EBX, (%ESI) 		# put the answer to memory_size
								# () means that we use SI as an address
	
	call 	print_2_word 			# print the data in address of memory_size

E801_ERROR: 
	ret    

# The return answer is two-word-long.
memory_size: .word 0
			 .word 0

# ---------------------------------------------------------------------

# -----------------------------------------------------------------------
# Function: print 32-bit binary number in hexadecimal form.
# The data should be store in (%ESI) in advanced.
print_2_word:
	pushl	%ecx				# protect CX
	movl	$4, %ecx			# loop counter: read 8 bits in each iteration
	addl	$3, %esi			# first one byte on highest address
do_print_32:
	movb 	(%esi), %al 		# four bits on left
	shrb	$4, %al
	call 	print_hex_digit

	movb	(%esi), %al  		# four bits on right
	call 	print_hex_digit

	decl	%esi
	loop 	do_print_32

	addl	$5, %esi
	popl 	%ecx				# retrive CX
	ret

# -------------------------------------------------------------------------
print_hex_digit:
	
	pushl	%eax
	pushl 	%ebx

	andb	$0x0f, %al  		# mask higher 4 bits
	addb 	$0x30, %al 			# convert 0~9 to '0'~'9'
	cmpb 	$0x39, %al			# compare with '9'
	jle		do_print_hex		# if <= '9', print. else, convert to 'A'
	addb 	$0x07, %al

do_print_hex:
	movb	$0x0e, %ah 			# int10 0x3 display char and move cursor
	movb	$0x00, %bh 			# page number
	movb	$0x0c, %bl 			# color

	int   	$0x10 				

	popl 	%ebx
	popl 	%eax 

	ret

# -----------------------------------------------------------
	.set	MMARD_SIZE, 20			# memory map address range descriptor size
	.set 	magic_number, 0x534d4150
# eax for counter, es:si for buffer
get_memory_map:
	pushl	%ebp
	pushl	%esp

	# TODO: For the first call to the function, point ES:DI at the destination buffer for the list.
	xorl	%EBX, %EBX 				# clear EBX
	xorw	%BP, %BP 			# BP keeps an entry count
	movl	$MMARD_SIZE, %ECX 		# set ECX to 24
	movl	$magic_number, %EDX 	# magic number
								
	movl	$buffer, %edi 		# EDI for return buffer
	
	# Use INT 15, AX = E820 to get memory map
	movl	$0xE820, %EAX 		
	int 	$0x15

	# If the first call to the function is successful,
	# EAX will be set to magic_number,
	# and the carry flag will be clear.	

	jc		E802_ERR					# jump if CF = 1
	cmpl	$magic_number, %EAX 	
	jne 	E802_ERR					# jump if not equal (ZF=0)

E802_next_call:
	# EBX will be set to some non-zero value, 
	# which must be preserved for the next call to the function.
	test	%EBX, %EBX 			# ebx & ebx == 0
	je 		E802_END 			# jump if equal (ZF=1)
	
	# For the subsequent calls to the function: 
	# increment DI by your list entry size, 
	# reset EAX to 0xE820, and ECX to 24.
	# When you reach the end of the list, EBX may reset to 0.

	incw	%BP				 	# increment entry count
	addl	$MMARD_SIZE, %EDI 	# increase return address

	movl	$0xe820, %EAX 		# reset EAX to 0xE820
	movl	$MMARD_SIZE, %ECX 	
	int 	$0x15 				# next call
	jmp 	E802_next_call		# loop until ebx = 0

E802_END:
	xorl	%eax, %eax 			# reset
 	movw 	%bp, %ax 			# copy counter to ax
 	movl 	$buffer, %esi 		# copy address to esi
 	clc 						# clear CF
 	popl 	%esp
 	popl 	%ebp
E802_ERR:
 	ret

# -----------------------------------------------------------------------
# es:si for begin address, eax for count
print_memory_map:
	pushl 	%esi

entry_loop:
	pushl	%EAX				# save counter

	# print 'Memory Range ['
	pushl	%ESI		
	leaw 	memory_range_string, %SI
	movw 	len_memory_range_string, %CX
	call 	print_string		
	popl	%ESI

	movb 	$0x03, %ah 			# int10 0x3 read cursor position
	movb 	$0x00, %bh
	int 	$0x10

	call 	print_2_word 			# print base address

	# print ':'
	movb $':', %AL
	movb $0x0e, %AH
	int $0x10 					# int10 0xe print ':'

	addl	$16, %esi 			# move to the base address of the next entry 
	call 	print_2_word 			# print end address
	
	pushl	%esi
	leaw 	str_type, %SI
	movw 	len_type, %CX
	call 	print_string 		# print '] State:'
	popl	%esi

	subl	$8, %esi 			# move back to the type of current entry
	movl	(%esi), %eax 		# read the type into eax

	pushl	%esi
	cmp 	$0x02, %eax 		# compare to 2
	je 		state2
	leaw 	str_state1, %SI
	movw 	state1_len, %CX
	jmp 	state_con

state2: 
	leaw 	str_state2, %SI
	movw 	state2_len, %CX

state_con:
	call 	print_string 		# print the type
	popl	%esi

	addl	$4, %esi 			# move to the begining of the next entry

	call 	print_line 			

	popl	%eax
	decl 	%eax
	cmpl 	$0, %eax 			# loop counter compare to 0
	jge		entry_loop

	popl	%esi

	ret
# -------------------------------------------------------------------------

# Constant strings
# --------------------------------------------------------------------------------------
welcome_string: 	  .ascii "MemOS 1: Welcome *** System Memory is: 0x"
	# .ascii expects zero or more string literals separated by commas. 
	# It assembles each string (with no automatic trailing zero byte) into consecutive addresses.
welcome_string_len: 	  .word  . - welcome_string    
	# . is the current address

memory_unit: .ascii " MB  "
len_memory_unit: .word	 . - memory_unit

memory_range_string: 	.ascii	"Memory Range ["
len_memory_range_string: 	.word  	. - memory_range_string

str_type: 	.ascii 	"] Type: "
len_type: 	.word  	. - str_type

str_state1:	.ascii	"Free Memory"
state1_len:	.word	. - str_state1

str_state2:	.ascii	"Reserved Memory"
state2_len: .word	. - str_state2

# This is going to be in our MBR for Bochs.
# -------------------------------------------------------
    # 512 bytes
	.org 0x1FE

    # bootable signature
	.byte 0x55
	.byte 0xAA

# ------------------------------------------------------
# This 

buffer:
	.fill 	20 * MMARD_SIZE, 1 
	.set	buffer_len, . - buffer
