_faas() 
{
    local cur prev hosts devices suggestions device_suggestions
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    hosts="$(virsh list --all --name)"
    devices="$(lspci -d 10ee: | grep \\.0 | awk '{print substr($0,0,2);}' | tr '\n' ' ' | head -c -1)"

    case $COMP_CWORD in
    1)
        COMPREPLY=( $(compgen -W "${hosts}" -- ${cur}) )
        return 0
        ;;
    2)
		if [ "${COMP_WORDS[0]}" == "./detach.sh" ]; then
			# only return attached devices
			devices=$(virsh dumpxml $prev | grep '<hostdev' -A 5 | grep "function='0x1'" | grep -v "type" | tr -s ' ' | cut -d' ' -f4 | cut -d= -f2 | awk '{print substr($0,4,2);}')
		fi
        suggestions=( $(compgen -W "${devices}" -- ${cur}) )
        ;;
    esac
	if [ "${#suggestions[@]}" == "1" ] || [ ! -f /opt/xilinx/xrt/bin/xbutil ] ; then
		COMPREPLY=("${suggestions[@]}")
	else
		# more than one suggestions resolved,
		# respond with the full device suggestions
		declare -a device_suggestions
		for ((dev=0;dev<${#suggestions[@]};dev++)); do
			#device_suggestions="$device_suggestions\n$dev $(/opt/xilinx/xrt/bin/xbutil scan | grep ":$dev:")"
			device_suggestions+=("${suggestions[$dev]}-->$(/opt/xilinx/xrt/bin/xbutil scan | grep ":${suggestions[$dev]}:" | xargs echo -n)")
		done
		COMPREPLY=("${device_suggestions[@]}")
	fi


}
complete -F _faas ./attach.sh
complete -F _faas ./detach.sh

