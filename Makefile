SHELL=bash
.SECONDEXPANSION:

help:
	@echo "Three commands:"
	@echo "   make generate_data # using the commands in parameters.txt to create folders with synthetic networks in them"

generate_data:
	set -e; cat parameters.txt | egrep '^[^#]' | while read dir K O E rest; do mkdir -p $$dir; pushd $$dir; python ../synth_blocks.py $$K $$O $$E; popd; done

sbm=/home/aaronmcdaid/Code/MyCode/SBM/sbm
ULIMIT=ulimit -v 4000000 -t 18000

%/_sbm: args=$(shell echo "$*" | tr / '\n' | tail -n1 | tr _ ' ' | sed -re 's/--GT/--GT ..\/..\/GT.vector/' )
%/_sbm: directory=$*
%/_sbm:
	@mkdir -p "${directory}"
	@test -d "${directory}"
	cd "${directory}" && ${time.txt} ${sbm} --git-version ../../edge_list.txt -z z ${args} > stdout.txt 2>stderr.txt
	cd "${directory}" && numEsts=$$(< stdout.txt egrep Iteration       | cut -d, -f4 | wc -l); < stdout.txt egrep Iteration       | tail -n $$((numEsts / 2))  | cut -f6- | tr -d Ka-z:' ' | cut -f1 | sort -g | uniq -c | sed -re 's/^ *//' > k1.txt
	cd "${directory}" && numEsts=$$(< stdout.txt egrep Iteration       | cut -d, -f4 | wc -l); < stdout.txt egrep Iteration       | tail -n $$((numEsts / 2))  | cut -f6- | tr -d Ka-z:' ' | cut -f2 | sort -g | uniq -c | sed -re 's/^ *//' > k0.txt
	touch "$@"
