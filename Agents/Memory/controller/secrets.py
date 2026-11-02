"""OS secret store for per-agent tokens. Never print values. Never write tokens.env."""

from __future__ import annotations

import os
import sys
from pathlib import Path

SERVICE = "dev.gemlarin.memory-controller"
_ALLOWED_LOADERS = {
    "memory_ctl.py",
    "install_memory.py",
    "cli.py",
    "__main__.py",
}


def _allow_secret_load() -> bool:
    name = Path(sys.argv[0]).name
    if name in {"-c", ""}:
        return False
    return name in _ALLOWED_LOADERS


def load_token(account: str) -> str:
    if not _allow_secret_load():
        raise PermissionError("Tokens load only through memory_ctl.py")
    token = _backend_get(account)
    if not token:
        raise PermissionError("No token in the OS secret store")
    return token


def store_token(account: str, token: str) -> None:
    if not token:
        raise ValueError("Empty token")
    _backend_set(account, token)


def shred_file(path: Path) -> None:
    path = Path(path)
    if not path.exists():
        return
    size = max(path.stat().st_size, 64)
    with path.open("wb") as handle:
        handle.write(os.urandom(size))
        handle.flush()
        os.fsync(handle.fileno())
    path.unlink(missing_ok=True)


def parse_tokens_env(path: Path, names: list[str]) -> dict[str, str]:
    raw: dict[str, str] = {}
    for line in Path(path).read_text(encoding="utf-8").splitlines():
        if "=" not in line or line.lstrip().startswith("#"):
            continue
        key, value = line.split("=", 1)
        raw[key.strip()] = value
    tokens = {}
    for name in names:
        key = f"MEMORY_AGENT_{name.upper()}"
        if raw.get(key):
            tokens[name] = raw[key]
    return tokens


def _backend_get(account: str) -> str:
    if sys.platform == "darwin":
        return _darwin_get(account)
    if os.name == "nt":
        return _windows_get(account)
    return _linux_get(account)


def _backend_set(account: str, token: str) -> None:
    if sys.platform == "darwin":
        _darwin_set(account, token)
        return
    if os.name == "nt":
        _windows_set(account, token)
        return
    _linux_set(account, token)


def _darwin_lib():
    import ctypes
    import ctypes.util

    path = ctypes.util.find_library("Security")
    if not path:
        raise RuntimeError("Security.framework not found")
    lib = ctypes.cdll.LoadLibrary(path)
    lib.SecKeychainFindGenericPassword.argtypes = [
        ctypes.c_void_p,
        ctypes.c_uint32,
        ctypes.c_char_p,
        ctypes.c_uint32,
        ctypes.c_char_p,
        ctypes.POINTER(ctypes.c_uint32),
        ctypes.POINTER(ctypes.c_void_p),
        ctypes.POINTER(ctypes.c_void_p),
    ]
    lib.SecKeychainFindGenericPassword.restype = ctypes.c_int32
    lib.SecKeychainAddGenericPassword.argtypes = [
        ctypes.c_void_p,
        ctypes.c_uint32,
        ctypes.c_char_p,
        ctypes.c_uint32,
        ctypes.c_char_p,
        ctypes.c_uint32,
        ctypes.c_void_p,
        ctypes.POINTER(ctypes.c_void_p),
    ]
    lib.SecKeychainAddGenericPassword.restype = ctypes.c_int32
    lib.SecKeychainItemDelete.argtypes = [ctypes.c_void_p]
    lib.SecKeychainItemDelete.restype = ctypes.c_int32
    lib.SecKeychainItemFreeContent.argtypes = [ctypes.c_void_p, ctypes.c_void_p]
    lib.SecKeychainItemFreeContent.restype = ctypes.c_int32
    return ctypes, lib


def _darwin_get(account: str) -> str:
    ctypes, lib = _darwin_lib()
    service = SERVICE.encode("utf-8")
    acct = account.encode("utf-8")
    length = ctypes.c_uint32(0)
    data = ctypes.c_void_p()
    status = lib.SecKeychainFindGenericPassword(
        None,
        len(service),
        service,
        len(acct),
        acct,
        ctypes.byref(length),
        ctypes.byref(data),
        None,
    )
    if status != 0 or not data.value:
        return ""
    try:
        raw = ctypes.string_at(data.value, length.value)
        return raw.decode("utf-8")
    finally:
        lib.SecKeychainItemFreeContent(None, data)


def _darwin_set(account: str, token: str) -> None:
    ctypes, lib = _darwin_lib()
    service = SERVICE.encode("utf-8")
    acct = account.encode("utf-8")
    item = ctypes.c_void_p()
    found = lib.SecKeychainFindGenericPassword(
        None,
        len(service),
        service,
        len(acct),
        acct,
        None,
        None,
        ctypes.byref(item),
    )
    if found == 0 and item.value:
        lib.SecKeychainItemDelete(item)
    blob = token.encode("utf-8")
    status = lib.SecKeychainAddGenericPassword(
        None,
        len(service),
        service,
        len(acct),
        acct,
        len(blob),
        blob,
        None,
    )
    if status != 0:
        raise RuntimeError(f"Keychain write failed ({status})")


def _windows_get(account: str) -> str:
    import ctypes
    from ctypes import wintypes

    cred = ctypes.c_void_p()
    advapi32 = ctypes.windll.advapi32
    target = f"{SERVICE}/{account}"
    if not advapi32.CredReadW(target, 1, 0, ctypes.byref(cred)):
        return ""

    class CREDENTIAL(ctypes.Structure):
        _fields_ = [
            ("Flags", wintypes.DWORD),
            ("Type", wintypes.DWORD),
            ("TargetName", wintypes.LPWSTR),
            ("Comment", wintypes.LPWSTR),
            ("LastWritten", wintypes.FILETIME),
            ("CredentialBlobSize", wintypes.DWORD),
            ("CredentialBlob", ctypes.POINTER(ctypes.c_char)),
            ("Persist", wintypes.DWORD),
            ("AttributeCount", wintypes.DWORD),
            ("Attributes", ctypes.c_void_p),
            ("TargetAlias", wintypes.LPWSTR),
            ("UserName", wintypes.LPWSTR),
        ]

    try:
        rec = ctypes.cast(cred, ctypes.POINTER(CREDENTIAL)).contents
        raw = ctypes.string_at(rec.CredentialBlob, rec.CredentialBlobSize)
        return raw.decode("utf-8")
    finally:
        advapi32.CredFree(cred)


def _windows_set(account: str, token: str) -> None:
    import ctypes
    from ctypes import wintypes

    class CREDENTIAL(ctypes.Structure):
        _fields_ = [
            ("Flags", wintypes.DWORD),
            ("Type", wintypes.DWORD),
            ("TargetName", wintypes.LPWSTR),
            ("Comment", wintypes.LPWSTR),
            ("LastWritten", wintypes.FILETIME),
            ("CredentialBlobSize", wintypes.DWORD),
            ("CredentialBlob", ctypes.c_void_p),
            ("Persist", wintypes.DWORD),
            ("AttributeCount", wintypes.DWORD),
            ("Attributes", ctypes.c_void_p),
            ("TargetAlias", wintypes.LPWSTR),
            ("UserName", wintypes.LPWSTR),
        ]

    blob = token.encode("utf-8")
    buf = ctypes.create_string_buffer(blob)
    rec = CREDENTIAL()
    rec.Type = 1
    rec.TargetName = f"{SERVICE}/{account}"
    rec.UserName = account
    rec.CredentialBlobSize = len(blob)
    rec.CredentialBlob = ctypes.cast(buf, ctypes.c_void_p)
    rec.Persist = 2
    if not ctypes.windll.advapi32.CredWriteW(ctypes.byref(rec), 0):
        raise RuntimeError("Credential Manager write failed")


def _linux_get(account: str) -> str:
    import shutil
    import subprocess

    if not shutil.which("secret-tool"):
        return ""
    proc = subprocess.run(
        ["secret-tool", "lookup", "service", SERVICE, "account", account],
        capture_output=True,
        text=True,
        check=False,
    )
    return (proc.stdout or "").rstrip("\n")


def _linux_set(account: str, token: str) -> None:
    import shutil
    import subprocess

    if not shutil.which("secret-tool"):
        raise RuntimeError("Install secret-tool (libsecret) or set MEMORY_AGENT_TOKEN in the process environment")
    proc = subprocess.run(
        [
            "secret-tool",
            "store",
            "--label",
            f"{SERVICE} {account}",
            "service",
            SERVICE,
            "account",
            account,
        ],
        input=token,
        capture_output=True,
        text=True,
        check=False,
    )
    if proc.returncode != 0:
        raise RuntimeError("secret-tool store failed")
