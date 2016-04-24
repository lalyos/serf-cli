#!/bin/bash

#set -eo pipefail
if [[ "$TRACE" ]]; then
    : ${START_TIME:=$(date +%s)}
    export START_TIME
    export PS4='+ [TRACE $BASH_SOURCE:$LINENO][ellapsed: $(( $(date +%s) -  $START_TIME ))] '
    set -x
fi

msgpack() {
    local msgfile=$(mktemp)
    echo "$*" > $msgfile
    msgpack-cli encode $msgfile
}

addr_to_ip() {
    echo -n "AAAAAAAAAAAAAP//wKgBbQ==" \
        | base64 -D \
        | xxd -s +12 -p \
        | while read -n2 num; do
            [[ "$num" ]] && echo -n "$((0x${num}))."
          done
}

cmd_handshake() {
  cat <<EOF
{"Command":"handshake","Seq":1}{"Version":1}
EOF
}

cmd_members() {
  cat <<EOF
{"Command":"members","Seq":2}
EOF
}

cmd_members_filtered() {
  cat <<EOF
{"Command":"members-filtered","Seq":2}{"Name":"","Status":"","Tags":{}}
EOF
}

cmd_event() {
  declare event=${1:-sample}
  cat <<EOF
{"Command":"event","Seq":2}{"Coalesce":true,"Name":"${event}","Payload":null}
EOF
}

cmd_stream() {
  cat <<EOF
{"Command":"stream","Seq":2}
EOF
}

serf_members_filtered() {
    (
      msgpack-cli encode <( cmd_handshake )
      sleep 1
      msgpack-cli encode <( cmd_members_filtered )
    ) | nc 127.0.0.1 7373
}

serf_members() {
    (
      msgpack-cli encode <( cmd_handshake )
      sleep 1
      msgpack-cli encode <( cmd_members )
    ) | nc 127.0.0.1 7373
}

serf_stream() {
    (
      msgpack-cli encode <( cmd_handshake )
      sleep 1
      msgpack-cli encode <( cmd_stream )
    ) | nc 127.0.0.1 7373
}

serf_event() {
    (
      msgpack-cli encode <( cmd_handshake )
      sleep 1
      msgpack-cli encode <( cmd_event $1 )
    ) | nc 127.0.0.1 7373
}

members_bin() {
  #echo -n 82a7436f6d6d616e64a968616e647368616b65a35365710181a756657273696f6e01 | xxd -r -p > c1
  #echo -n 82a7436f6d6d616e64b06d656d626572732d66696c7465726564a35365710283a44e616d65a0a6537461747573a0a45461677380 | xxd -r -p > c2

  local respfile=$(mktemp)
  (
     xxd -p -r <<< 82a7436f6d6d616e64a968616e647368616b65a35365710181a756657273696f6e01
     sleep 1
     xxd -p -r <<< 82a7436f6d6d616e64b06d656d626572732d66696c7465726564a35365710283a44e616d65a0a6537461747573a0a45461677380
  ) | nc 127.0.0.1 7373 > $respfile
  msgpack-cli decode $respfile | jq
}


main() {
    local cmd=$1
    shift
    msgpack-cli decode <( serf_${cmd} $@ ) | jq
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@" || true
