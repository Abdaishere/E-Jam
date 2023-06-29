FROM rust as builder

RUN USER=root cargo new --bin e-jam-api
WORKDIR /e-jam-api
COPY ./Cargo.lock ./Cargo.lock
RUN cargo build --release
RUN rm src/*.rs

ADD . ./
RUN rm ./target/release/deps/e_jam_api*
RUN cargo build --release


FROM debian:buster-slim
ARG APP=/usr/src/app

RUN apt-get update \
    && apt-get install -y ca-certificates tzdata \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 8084

ENV TZ=Etc/UTC \
    APP_USER=appuser

RUN groupadd $APP_USER \
    && useradd -g $APP_USER $APP_USER \
    && mkdir -p ${APP}

COPY --from=builder /e-jam-api/target/release/e-jam-api ${APP}/e-jam-api
COPY ./logger.yml ${APP}/logger.yml

RUN chown -R $APP_USER:$APP_USER ${APP}

USER $APP_USER
WORKDIR ${APP}

RUN ls -lah
RUN chmod a+x e-jam-api
CMD ["./e-jam-api", "0.0.0.0"]