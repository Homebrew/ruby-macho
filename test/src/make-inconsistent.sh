#!/usr/bin/env bash

main() {
  local use_dir

  for use_dir in "${@}"; do
    # we only want to build libinconsistent.dylib as a fat mach-o
    [[ "${use_dir}" = fat* ]] || continue
    inconsistent_for "${use_dir}"
  done
}

inconsistent_for() {
  # splits a fat directory spec like fat-i386-x86_64 into
  # its constituent arch(3) pairs (e.g., i386 and x86_64)
  local fat_dir="${1}"
  local split_fat_dir
  IFS=- read -a split_fat_dir <<<"${fat_dir#fat-}"

  # future versions of the test suite might have more than two architectures
  # in a fat file, but we only care about the first two here
  local arch1="${split_fat_dir[0]}"
  local arch2="${split_fat_dir[1]}"

  # order is arbitrary, as long as the libs chosen have different linkages
  local lib1="${arch1}/libhello.dylib"
  local lib2="${arch2}/libextrahello.dylib"

  [[ -f "${lib1}" ]] || die "Missing file: ${lib1}. Did you run make?"
  [[ -f "${lib2}" ]] || die "Missing file: ${lib2}. Did you run make?"

  echo "[+] Creating libinconsistent.dylib for ${fat_dir}"
  lipo -create "${lib1}" "${lib2}" -output "${fat_dir}/libinconsistent.dylib"
}

die() {
  echo "Error: ${*}" >&2
  exit 1
}

main "${@}"
