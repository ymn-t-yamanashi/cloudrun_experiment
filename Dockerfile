FROM elixir:1.17.2

ARG APP_NAME=cloudrun_experiment
ARG PHOENIX_SUBDIR=.
ENV MIX_ENV=prod REPLACE_OS_VARS=true TERM=xterm
WORKDIR /opt/app
RUN apt update 

#     && apt --no-cache --update 
RUN apt install -y nodejs npm 
RUN mix local.rebar --force && mix local.hex --force
COPY . .
ENV MIX_ENV="prod" 

RUN mix do deps.get, deps.compile, compile
RUN mix phx.digest
#RUN cd ${PHOENIX_SUBDIR}/assets \

#     && npm install \
#     && ./node_modules/brunch/bin/brunch build -p \
#     && cd .. \
#     && mix phx.digest

RUN mix release 
#--verbose 
#\
RUN mv _build/prod/rel/${APP_NAME} /opt/release \
   && mv /opt/release/bin/${APP_NAME} /opt/release/bin/start_server

FROM elixir:1.17.2
RUN apt update
RUN apt install -y bash openssl ca-certificates
#bash openssl-dev ca-certificates

# RUN apk update && apk --no-cache --update add bash openssl-dev ca-certificates

#RUN addgroup -g 1000 appuser && \
#     adduser -S -u 1000 -G appuser appuser

RUN mkdir -p /opt/app/var
RUN chown nobody /opt/app/var

USER nobody

ENV MIX_ENV="prod"

# ENV MIX_ENV=prod REPLACE_OS_VARS=true
WORKDIR /opt/app
COPY --from=0 /opt/release .

# ENV RUNNER_LOG_DIR /var/log
CMD ["/opt/app/bin/start_server", "start"]