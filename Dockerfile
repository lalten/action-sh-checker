FROM alpine:3.16.0
LABEL "name"="sh-checker"
LABEL "maintainer"="Luiz Muller <contact@luizm.dev>"

ARG shfmt_version=3.6.0
ARG shellcheck_version=0.9.0
ARG gh_version=2.23.0
ARG jq_version=1.6

RUN apk add --no-cache bash git jq curl checkbashisms xz \
    && apk add --no-cache --virtual .build-deps tar
RUN wget "https://github.com/mvdan/sh/releases/download/v${shfmt_version}/shfmt_v${shfmt_version}_linux_amd64" -O /usr/local/bin/shfmt \
    && chmod +x /usr/local/bin/shfmt
RUN wget "https://github.com/koalaman/shellcheck/releases/download/v${shellcheck_version}/shellcheck-v${shellcheck_version}.linux.x86_64.tar.xz"  -O- | tar xJ -C /usr/local/bin/ --strip-components=1 --wildcards '*/shellcheck' \
    && chmod +x /usr/local/bin/shellcheck
RUN curl -fsSL "https://github.com/cli/cli/releases/download/v${gh_version}/gh_${gh_version}_linux_amd64.tar.gz" | tar xz -C /usr/local/ --strip-components=1
RUN curl -fsSL "https://github.com/stedolan/jq/releases/download/jq-${jq_version}/jq-linux64" -o /usr/local/bin/jq \
    && chmod +x /usr/local/bin/jq
RUN apk del --no-cache .build-deps && rm -rf /tmp/*

# https://github.com/actions/runner-images/issues/6775#issuecomment-1410270956
RUN git config --system --add safe.directory /github/workspace

COPY shellcheck-json1-problem-matcher.json /shellcheck-json1-problem-matcher.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
