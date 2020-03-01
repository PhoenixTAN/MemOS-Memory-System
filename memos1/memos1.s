# ----------------------------------
# Jiaqian Sun, Ziqi Tan 
# memos1
# Created on Feb 25, 2020
# -----------------------------------

.text	        # .text section
.global _start	# start entry
.code16		    # code will be run in 16-bit mode.
# -----------------------------------------------------------------------------------
_start:
	# When the BIOS finds such a boot sector, 
    # it is loaded into memory at 0x0000:0x7c00 (segment 0, address 0x7c00);
    # some BIOS' load to **0x7c0:0x0000** (segment 0x07c0, offset 0).
	movw 	$0x7C0, %DX
	movw 	%DX, %DS
	movw 	%DX, %ES

	# print welcome string
	leaw 	msg_welcome, %SI
	movw 	len_welcome, %CX
	call 	print_mesg

	# print memory size
	call 	get_memory_size
	call 	print_line

	# print memory map
	call 	get_memory_map

	jmp .	# dead loop

	# Constant strings
	msg_welcome: 	  .ascii 	"MemOS 1: Welcome *** System Memory (in MB) is : 0x"
	len_welcome: 	  .word  	. - msg_welcome
# -----------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------
get_memory_size:  
	pushw 	%AX					# protect AX
	# BIOS interrupt
    movw    $0xE801, %AX
    int     $0x15
    # Typical Output:
    # AX = CX = extended memory between 1M and 16M, in K (max 3C00h = 15MB)
    # BX = DX = extended memory above 16M, in 64K blocks

	cmpb    $0x86, %AH
	je 		E801_END			# if E801 does not work, return ;
	cmpb 	$0x80, %AH
	je		E801_END			# if E801 does not work, return ;

    addw 	$0x400, %AX			# AX add 1MB
	shll 	$6, %EBX	  		# BX times 64
	addl 	%EBX, %EAX			# AX <- AX + BX
	shrl 	$10, %EAX			# convert KB to MB
	
	call 	print_32 			# print the data in address of msg_memory
	popw 	%AX					# protect AX
E801_END:
	ret    
# ---------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
get_memory_map:
	# For the first call to the function, 
	# point ES:DI at the destination buffer for the list.
	xorl 	%EBX, %EBX			# clear EBX
	xorl 	%EBP, %EBP			

	movl 	$0x534d4150, %EDX	# magic number
	movl 	$buffer, %EDI
	movl 	$20, %ECX

	movl 	$0xE820, %EAX
	int 	$0x15				# INT 15, AX = E820 to get memory map
	
	# If the first call to the function is successful,
	# EAX will be set to magic_number,
	# and the carry flag will be clear.
	jc		E802_END			# jump if CF = 1
	cmpl 	%EAX, %EDX
	jne 	E802_END			# jump if not equal (ZF=0)

E802_next_call:
	# EBX will be set to some non-zero value, 
	# which must be preserved for the next call to the function.
	# When you reach the end of the list, EBX may reset to 0.
	call 	print_memory_map_entry
	test 	%EBX, %EBX			# EBX & EBX == 0
	je 		E802_END			# jump if equal (ZF=1)

	addl 	$20, %EDI	
	movl 	$20, %ECX

	movl 	$0xE820, %EAX
	int 	$0x15				# INT 15, AX = E820 to get memory map

	loop 	E802_next_call
	
	call print_line
	call print_line
E802_END:
	ret
# ---------------------------------------------------------------------------------

# ----------------------------------------------
# print the return value in ES:DI
# Data structure of an entry (20 bytes in all):
# 	first 64 bits: Base address
# 	second 64 bits: Length of "region"
# 	next 32 bits: Region "type":
# 			Type 1: Usable RAM
# 			Type 2: Reserved
print_memory_map_entry:
	pushl 	%EAX			# protect AX, EX, DI
	pushl	%ECX
	pushl 	%EDI

	# print "Address range: [ "		
	leaw 	str_addr_range, %SI
	movw 	len_str_addr_range, %CX
	call 	print_mesg
	
	# print base address
	movl	(%EDI), %EAX		
	call 	print_32

	# print '~'
	movb 	$'~', %AL
	movb 	$0x0E, %AH
	int 	$0x10

	# print length
	movl	(%EDI), %EAX		# base address in EAX
	subl	$0x01, %EAX		
	addl 	$8, %EDI
	addl	(%EDI), %EAX		# length in (%EDI)
	call 	print_32

	# print type
	addl 	$8, %EDI
	movl	(%EDI), %EAX
	cmpl 	$0x0002, %EAX
	je		print_reserved_type

	leaw 	free_type, %SI
	movw 	len_free_type, %CX
	jmp		print_end
print_reserved_type:
	leaw 	reserved_type, %SI
	movw 	len_reserved_type, %CX
print_end:
	call 	print_mesg
	call 	print_line	
	popl 	%EDI
	popl	%ECX
	popl	%EAX				# protect AX, CX, DI
	ret
	
	# Constant string:
	str_addr_range:	  		.ascii 		"Address range: ["
	len_str_addr_range: 	.word 		. - str_addr_range
	free_type: 	  			.ascii 		"] -> Free"
	len_free_type: 	  		.word  		. - free_type
	reserved_type: 	  		.ascii 		"] -> Reserved"
	len_reserved_type: 		.word  		. - reserved_type
# -----------------------------------------------------------------

# --------------------------------------------------------------
# function: print a string in (%DS:SI).
print_mesg:
	pushw 	%AX			# protect AX
print_AL:
	lodsb				# Load byte at address DS:SI into AL
						# SI will increment automatically
	movb 	$0x0E, %AH
	int 	$0x10		# INT 10
        				# Function: Teletype output
        				# Function code: AH = 0E H
        				# Parameters: AL = Character, BH = Page Number, BL = Color   	
	loop 	print_AL
	popw 	%AX			# retrieve AX
	ret
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# print Hex in AL
print:	
	pushw 	%DX	# protect DX
	# print Hex in AX[7..4]
	movb 	%AL, %DL	# save AL in DL
	shrb 	$4, %AL		# AL shift right for 4 bits
	cmpb 	$10, %AL	# compare 10 with al
	jge 	1f			# if 10 >= %al, then jump foward to segment 1
	addb 	$48, %AL	# convert 0~9 to '0'~'9'
	jmp 	2f
1:	addb 	$55, %AL	# convert 10~15 to 'A'~'F'
	
	# call BIOS interrupt		
2:	movb 	$0x0E, %AH
	int 	$0x10
	
	# print Hex in AX[3..0]
	movb 	%DL, %AL
	andb 	$0x0f, %AL
	cmpb 	$10, %AL
	jge 	1f
	addb 	$48, %AL
	jmp 	2f
1:	addb 	$55, %AL	

	# call BIOS interrupt	
2:	movb 	$0x0E, %AH
	int 	$0x10
	
	popw 	%DX		# protect DX
	
	ret
# ----------------------------------------------------------
print_16:
	pushl 	%EAX
	shr 	$8, %AX	
	call 	print			# print EAX[15..8]

	popl 	%EAX
	call 	print			# print AX[7..0]
	ret
# ----------------------------------------------------------
print_32:
	pushl 	%EAX		
	shrl 	$16, %EAX
	call 	print_16	# print EAX[31..16]

	popl 	%EAX
	call 	print_16	# print EAX[0..15]
	ret
# ----------------------------------------------------------
print_line:
	movw 	$0x0e0d, %AX	# CR carriage return 
	int 	$0x10

	movw 	$0x0e0a, %AX	# LF new line
	int 	$0x10
	ret
# ----------------------------------------------------------

# -----------------------------------------------------------
# set up bootable signature
	.org 	0x1FE		# 510 bytes
	.byte 	0x55
	.byte 	0xAA
# -------------------------------------------------------------
# 					repeat, size bytes, value
buffer:		.fill 		1 * 20, 0
#----------------------------------------------------------
