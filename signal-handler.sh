#!/bin/sh

_reload() { 
    echo "Caught SIGHUP signal, reloading Caddy"
    caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile
    _wait
}

_passthrough_trap() {
    sig=$1
    echo "Caught signal $1, passing to Caddy"
    kill -s $sig $child
    _wait
}

_setup_traps() {
    func=$1; shift
    for sig ; do
        trap "$func $sig" "$sig"
    done
}

_wait() {
    echo "Waiting for Caddy to exit, or to receive signal"
    wait "$child"
}

trap _reload HUP
_setup_traps _passthrough_trap TERM QUIT INT

echo "Starting Caddy in background";
$@ &

child=$!
_wait
