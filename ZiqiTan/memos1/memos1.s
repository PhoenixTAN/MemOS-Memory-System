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

    welcome_string: 	  .ascii "MemOS 1: Welcome *** System Memory is: 0x"
    # .ascii expects zero or more string literals separated by commas. 
    # It assembles each string (with no automatic trailing zero byte) into consecutive addresses.

    welcome_string_len: 	  .word  . - welcome_string    # . is the current address
    memory_unit: .ascii " MB  "
    len_memory_unit: .word	 . - memory_unit

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

    addw 	$0x400, %ax			# ax add 1MB
	shll 	$6, %ebx	  		# bx times 64
	addl 	%EAX, %ebx			# ax + bx
	shrl 	$10, %ebx			# convert KB to MB
	
	movl 	$memory_size, %esi	# put the address of memory_size in SI
	movl	%ebx, (%esi) 		# put the answer to memory_size
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
print_heximal:

	ret

# This is going to be in our MBR for Bochs.
# -------------------------------------------------------
    # 512 bytes
	.org 0x1FE

    # bootable signature
	.byte 0x55
	.byte 0xAA

# ------------------------------------------------------


