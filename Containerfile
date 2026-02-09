FROM registry.access.redhat.com/ubi8:8.10

# ---- metadata you can standardize ----
LABEL \
  name="ubi8-8.10-hardened-base" \
  vendor="kelleyblackmore" \
  version="0.0.1" \
  release="2026-02-06" \
  summary="Hardened UBI8 base for downstream application images" \
  description="Patched, non-root ready, cache-cleaned, OpenShift-friendly permissions"

# ---- safety defaults ----
ENV \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8 \
  TZ=UTC

# ---- patch + minimal deps you actually want in a base ----
# Keep this list tiny. Many teams only need ca-certificates + tzdata.
# hadolint ignore=DL3041,SC3040
RUN /bin/bash -o pipefail -c 'set -eux; \
    dnf -y update; \
    dnf -y install \
      ca-certificates \
      tzdata \
      jq \
      vim-minimal; \
    dnf -y clean all; \
    rm -rf /var/cache/dnf /var/cache/yum; \
    rm -rf /tmp/* /var/tmp/*'

# ---- copy and execute STIG hardening scripts ----
COPY scripts/ /tmp/stig-scripts/
# hadolint ignore=SC3040
RUN /bin/bash -o pipefail -c 'set -eux; \
    chmod +x /tmp/stig-scripts/*.sh; \
    /tmp/stig-scripts/apply-all-stig.sh; \
    rm -rf /tmp/stig-scripts'

# ---- create a non-root user (OpenShift-friendly) ----
# Notes:
# - Fixed UID is good for non-OpenShift environments.
# - For OpenShift, also make files group-owned by 0 and chmod g=u, so random UID in group 0 can write.
ARG APP_UID=10001
ARG APP_GID=0
ARG APP_USER=appuser
ARG APP_HOME=/app

# hadolint ignore=SC3040
RUN /bin/bash -o pipefail -c 'set -eux; \
    mkdir -p "${APP_HOME}"; \
    # Create user with nologin; if group 0 exists (it will), use it.
    useradd \
      --uid "${APP_UID}" \
      --gid "${APP_GID}" \
      --home-dir "${APP_HOME}" \
      --no-create-home \
      --shell /sbin/nologin \
      "${APP_USER}"; \
    chown -R "${APP_UID}:${APP_GID}" "${APP_HOME}"; \
    chmod -R g=u "${APP_HOME}"'

# ---- runtime defaults ----
WORKDIR /app
USER 10001

# Keep entrypoint neutral for a base image.
# Downstream images should set ENTRYPOINT/CMD.
CMD ["/bin/sh", "-lc", "echo 'Hardened base image: override CMD/ENTRYPOINT in downstream image.' && sleep 3600"]