.PHONY: INDEX.md
INDEX.md:
	echo > $@
	for i in *; do \
		case $$i in *~) continue;; \
		esac; \
		echo "[$$i](https://github.com/r3n/rebol.org/blob/master/scripts/$$i)  " >> $@; \
	done
