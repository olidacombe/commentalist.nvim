.PHONY: lint pre-commit test

lint: # nvim_map(l)
	luacheck lua/commentalist

test: # nvim_map(t)
	nvim --headless \
	-u tests/init.lua \
	-c "PlenaryBustedDirectory tests/plenary { minimal_init = 'tests//init.lua' }"

pre-commit: # nvim_map(pc)
	        pipx run pre-commit install
