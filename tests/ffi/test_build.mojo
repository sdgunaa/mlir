from mlir.ffi.build import download, _ensure_cache_dir, _get_cache_dir
from os import unlink
from pathlib import Path
from testing import assert_true


fn test_real_download() raises:
    _ensure_cache_dir()

    # Small, stable test file (few KB, no rate limit issues)
    var test_url = (
        "https://raw.githubusercontent.com/llvm/llvm-project/main/README.md"
    )
    var out_file = _get_cache_dir() / "download_test.txt"

    if out_file.exists():
        unlink(out_file)

    download(test_url, out_file)

    assert_true(out_file.exists(), "Downloaded file does not exist")
    print("Downloaded file to:", out_file)

    var content = out_file.read_text()
    assert_true(len(content) > 0, "Downloaded file is empty")

    # Optional sanity check
    assert_true(content.__contains__("LLVM"), "Unexpected file contents")
    print("Downloaded file contents are valid: ", content, "...")
    unlink(out_file)


def main():
    test_real_download()
