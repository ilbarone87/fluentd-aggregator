ARG BASE_IMAGE=fluent/fluentd:v1.19.1-debian-2.1
FROM ${BASE_IMAGE}

LABEL maintainer="ricsanfre" \
      description="Fluentd aggregator with Elasticsearch, Prometheus, and Loki plugins" \
      org.opencontainers.image.source="https://github.com/ricsanfre/fluentd-aggregator"

# Switch to root to install dependencies
USER root

# Install plugins in a single layer to minimize image size
RUN set -eux; \
    buildDeps="sudo make gcc g++ libc-dev"; \
    apt-get update; \
    apt-get install -y --no-install-recommends ${buildDeps}; \
    gem install --no-document \
        elasticsearch:9.2.0 \
        fluent-plugin-elasticsearch:6.0.0 \
        fluent-plugin-prometheus:2.2.1 \
        fluent-plugin-record-modifier:2.2.1 \
        fluent-plugin-grafana-loki:1.2.20; \
    gem sources --clear-all; \
    SUDO_FORCE_REMOVE=yes apt-get purge -y --auto-remove \
        -o APT::AutoRemove::RecommendsImportant=false \
        ${buildDeps}; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

# Copy configuration files
COPY --chown=fluent:fluent conf/fluent.conf /fluentd/etc/
COPY --chown=fluent:fluent conf/forwarder.conf /fluentd/etc/
COPY --chown=fluent:fluent conf/prometheus.conf /fluentd/etc/

# Copy entrypoint script
COPY --chown=fluent:fluent entrypoint.sh /fluentd/entrypoint.sh
RUN chmod +x /fluentd/entrypoint.sh

# Environment variables
ENV FLUENTD_OPT="" \
    FLUENTD_CONF="fluent.conf"

# Switch to non-root user for security
USER fluent

ENTRYPOINT ["tini", "--", "/fluentd/entrypoint.sh"]
CMD ["fluentd"]
