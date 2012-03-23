SHELL=bash
.SECONDEXPANSION:

help:
	@echo "Three commands, to be run in order:"
	@echo "   make generate_data # using the commands in parameters.txt to create folders with synthetic networks in them"
	@echo "   make run_sbm       # for each folder that is specified in parameters.txt, run the SBM for 10,000 iterations."
	@echo "   make make_table    # print the runtime and number of iterations until the correct result is reached."

generate_data:
	set -e; cat parameters.txt | egrep '^[^#]' | while read dir K O E rest; do mkdir -p $$dir; pushd $$dir; python ../synth_blocks.py $$K $$O $$E; popd; done

run_sbm:
	@echo "You can change the number passed to -j to control the numbers of parallel processes used by make. See the make man page."
	set -e; cat parameters.txt | egrep '^[^#]' | while read dir rest; do test -f $$dir/GT.vector; test -f $$dir/edge_list.txt; echo "$$dir"/sbm/_--GT_-ds_-i100000_--print_100/_sbm; done | xargs ${MAKE} -k -j2 # -j2 means to use two processes

sbm=/home/aaronmcdaid/Code/MyCode/SBM/sbm
ULIMIT=ulimit -v 4000000 -t 18000
time.txt=nice -n20 time -p -o time.txt --

%/_sbm: args=$(shell echo "$*" | tr / '\n' | tail -n1 | tr _ ' ' | sed -re 's/--GT/--GT ..\/..\/GT.vector/' )
%/_sbm: directory=$*
%/_sbm:
	@mkdir -p "${directory}"
	@test -d "${directory}"
	cd "${directory}" && ${time.txt} ${sbm} --git-version ../../edge_list.txt -z z ${args} > stdout.txt 2>stderr.txt
	cd "${directory}" && numEsts=$$(< stdout.txt egrep Iteration       | cut -d, -f4 | wc -l); < stdout.txt egrep Iteration       | tail -n $$((numEsts / 2))  | cut -f6- | tr -d Ka-z:' ' | cut -f1 | sort -g | uniq -c | sed -re 's/^ *//' > k1.txt
	cd "${directory}" && numEsts=$$(< stdout.txt egrep Iteration       | cut -d, -f4 | wc -l); < stdout.txt egrep Iteration       | tail -n $$((numEsts / 2))  | cut -f6- | tr -d Ka-z:' ' | cut -f2 | sort -g | uniq -c | sed -re 's/^ *//' > k0.txt
	touch "$@"

make_table:
	set -e; cat parameters.txt | egrep '^[^#]' | while read dir K O E rest; do echo == $$K ==; std=$${dir}/sbm/_--GT_-ds_-i100000_--print_100/stdout.txt; cat $${std} | egrep '^Iteration:.*sizes:'$$K'([[:space:]][0-9]+)(\1)*$$' -B1 | head -n2; cat $$std | egrep '^Iteration:' | tail -n100 | cut -d: -f3 | cut -f1 | sort -g | uniq -c; cat $$std | egrep NMI=100 | tail -n100 | cut -d= -f2 | sort -g | uniq -c ; done
