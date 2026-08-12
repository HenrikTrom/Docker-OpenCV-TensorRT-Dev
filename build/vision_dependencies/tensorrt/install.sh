#!/bin/bash
set -euo pipefail

if [ -z "${TENSORRT_VERSION:-}" ]; then
    echo "TENSORRT_VERSION is not set" >&2
    exit 1
fi

if [ -z "${CUDA_VERSION:-}" ]; then
    echo "CUDA_VERSION is not set" >&2
    exit 1
fi

cuda_parts="$(echo "${CUDA_VERSION}" | cut -d. -f1,2)"
expected_base="TensorRT-${TENSORRT_VERSION}.Linux.x86_64-gnu.cuda-${cuda_parts}"
expected_tar_tar="${expected_base}.tar.tar"
expected_tar_gz="${expected_base}.tar.gz"

if [ -f "${expected_tar_tar}" ] && [ -f "${expected_tar_gz}" ]; then
    echo "Found both ${expected_tar_tar} and ${expected_tar_gz}; keep only one archive" >&2
    exit 1
fi

archive_path=""
if [ -f "${expected_tar_tar}" ]; then
    archive_path="${expected_tar_tar}"
elif [ -f "${expected_tar_gz}" ]; then
    archive_path="${expected_tar_gz}"
else
    echo "Expected TensorRT archive not found." >&2
    echo "Expected one of:" >&2
    echo "  ${expected_tar_tar}" >&2
    echo "  ${expected_tar_gz}" >&2

    mapfile -t found_archives < <(find . -maxdepth 1 -type f \( -name 'TensorRT-*.tar.tar' -o -name 'TensorRT-*.tar.gz' \) -printf '%f\n' | sort)
    if [ "${#found_archives[@]}" -gt 0 ]; then
        echo "Found TensorRT archives with non-matching names:" >&2
        printf '  %s\n' "${found_archives[@]}" >&2
    else
        echo "No TensorRT archives were found in $(pwd)." >&2
    fi
    exit 1
fi

echo "Extracting ${archive_path}"
tar -xzvf "${archive_path}"
