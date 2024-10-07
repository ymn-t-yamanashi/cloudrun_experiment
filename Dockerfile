FROM elixir:1.17.2

ARG APP_NAME=cloudrun_experiment
ARG PHOENIX_SUBDIR=.
ENV MIX_ENV=prod REPLACE_OS_VARS=true TERM=xterm
WORKDIR /opt/app
RUN apt update 

RUN apt install -y nodejs npm 
RUN mix local.rebar --force && mix local.hex --force
COPY . .
ENV MIX_ENV="prod" 

RUN mix do deps.get, deps.compile
RUN mix phx.digest
RUN mix assets.deploy
RUN mix compile

RUN mix release 

RUN mv _build/prod/rel/${APP_NAME} /opt/release \
   && mv /opt/release/bin/${APP_NAME} /opt/release/bin/start_server

FROM elixir:1.17.2
RUN apt update
RUN apt install -y bash openssl ca-certificates

RUN mkdir -p /opt/app/var
RUN chown nobody /opt/app/var

USER nobody

ENV MIX_ENV="prod"

WORKDIR /opt/app
COPY --from=0 /opt/release .

CMD ["/opt/app/bin/start_server", "start"]