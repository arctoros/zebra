.PHONY: %

%: %.asm
	/Users/yamato/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Kata\ Hemisphere/Private/Computing/zebra/Software/rasm/rasm $@.asm -o $@ && \
	minipro -p 28C256 -uP -w $@.bin -s 
	@echo "\n$@ programmed.\n"
