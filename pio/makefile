.PHONY: %

%: %.asm
	/Users/yamato/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Kata\ Hemisphere/Private/Computing/zebra/Software/zasm/zasm -ywuz $@.asm && \
	minipro -p 28C256 -uP -w $@.rom -s 
	@echo "\n$@ programmed.\n"
