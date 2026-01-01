#!/bin/sh
set -e

# Source environment variables if file exists
DEFAULT=/etc/default/fluentd
if [ -r "${DEFAULT}" ]; then
    set -o allexport
    # shellcheck source=/dev/null
    . "${DEFAULT}"
    set +o allexport
fi

# If the user has supplied only arguments, append them to `fluentd` command
if [ "${1#-}" != "$1" ]; then
    set -- fluentd "$@"
fi

# If user does not supply config file or plugins, use the defaults
if [ "$1" = "fluentd" ]; then
    if ! echo "$@" | grep -qE ' -c| --config'; then
        set -- "$@" --config "/fluentd/etc/${FLUENTD_CONF:-fluent.conf}"
    fi

    if ! echo "$@" | grep -qE ' -p| --plugin'; then
        set -- "$@" --plugin /fluentd/plugins
    fi

    # fluent-plugin-elasticsearch specifics: load sniffer class
    SIMPLE_SNIFFER=$(gem contents fluent-plugin-elasticsearch 2>/dev/null | grep elasticsearch_simple_sniffer.rb || true)
    if [ -n "${SIMPLE_SNIFFER}" ] && [ -f "${SIMPLE_SNIFFER}" ]; then
        set -- "$@" -r "${SIMPLE_SNIFFER}"
    fi
fi

exec "$@"