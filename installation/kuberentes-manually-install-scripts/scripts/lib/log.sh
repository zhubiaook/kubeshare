#!/bin/bash

# --- helper functions for logs ---

info() {
  echo '[INFO] ' "$@"
}

warn() {
  echo '[WARN] ' "$@"
}

error() {
  echo '[ERROR] ' "$@"
}

fatal() {
  echo '[FATAL] ' "$@"
  exit 1
}

