.PHONY: clean all run

run: out.nes
	fceux out.nes

clean:
	rm *.nes *.asm *.chr

all: out.nes

out.nes: out.asm
	nesasm out.asm

out.asm: header.bas main.bas common.bas footer.bas ascii.chr
	nbasic header.bas main.bas common.bas footer.bas -o out.asm

ascii.chr: ascii.bmp
	bmp2chr ascii.bmp ascii.chr
