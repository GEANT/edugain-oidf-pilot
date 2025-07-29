#!/usr/bin/bash

cd caddy && docker compose up -d && cd ..
cd ta && docker compose up -d && cd ..
cd ia1 && docker compose up -d && cd ..
cd ia2 && docker compose up -d && cd ..
cd rp1 && docker compose up -d && cd ..
