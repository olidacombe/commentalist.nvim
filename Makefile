.PHONY: test

lint:
	luacheck lua/commentalist

test:
	nvim --headless --noplugin \
	-u scripts/minimal_init.vim \
	-c "PlenaryBustedDirectory tests/plenary { minimal_init = './scripts/minimal_init.vim' }"
