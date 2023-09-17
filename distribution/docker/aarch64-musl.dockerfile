FROM registry.gitlab.b-data.ch/ghc/ghc4pandoc:9.4.5 as bootstrap

RUN cabal update

# Install packages
WORKDIR /elm
COPY elm.cabal ./

ENV CABALOPTS="-f-export-dynamic -fembed_data_files --enable-executable-static -j4"
ENV GHCOPTS="-j4 +RTS -A256m -RTS -split-sections -optc-Os -optl=-pthread"

RUN cabal build $CABALOPTS --ghc-options="$GHCOPTS" --only-dependencies

# Import source code
COPY builder builder
COPY compiler compiler
COPY reactor reactor
COPY terminal terminal
COPY LICENSE ./

RUN cabal build $CABALOPTS --ghc-options="$GHCOPTS"
RUN cp `cabal list-bin .` ./elm
RUN strip elm
