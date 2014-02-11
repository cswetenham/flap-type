all: out.nes

out.nes: out.asm
	nesasm out.asm

out.asm: name.bas ascii.chr
	nbasic name.bas -o out.asm

ascii.chr: ascii.bmp
	bmp2chr ascii.bmp ascii.chr
