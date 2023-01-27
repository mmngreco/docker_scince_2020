FROM alpine@sha256:c0d488a800e4127c334ad20d61d7bc21b4097540327217dfab52262adc02380c
RUN apk add --no-cache innoextract bash curl findutils
COPY scince_2020.sh /scince_2020.sh
RUN chmod +x /scince_2020.sh && mkdir -p /scince_2020 && adduser -D scince && chown -R scince /scince_2020
USER scince
ENTRYPOINT ["/scince_2020.sh"]
