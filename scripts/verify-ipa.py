"""Inspect our arm64 iphoneos IPA without executing or signing its binary."""
import json
import pathlib
import plistlib
import struct
import sys
import zipfile


def verify(ipa_path):
    with zipfile.ZipFile(ipa_path) as archive:
        root = "Payload/FitFlow.app/"
        info = plistlib.loads(archive.read(root + "Info.plist"))
        if info.get("CFBundleSupportedPlatforms") != ["iPhoneOS"]:
            raise ValueError("IPA must contain an iPhoneOS product, not a simulator app")
        executable = info["CFBundleExecutable"]
        if not executable or pathlib.PurePosixPath(executable).name != executable:
            raise ValueError("Unexpected executable name")
        binary = archive.read(root + executable)
        if len(binary) < 32:
            raise ValueError("Truncated Mach-O header")
        magic, cpu_type, _, file_type, ncmds, sizeofcmds, _, _ = struct.unpack_from("<8I", binary)
        if magic != 0xFEEDFACF or cpu_type != 0x0100000C or file_type != 2:
            raise ValueError("Expected an arm64 Mach-O executable")
        commands_end = 32 + sizeofcmds
        if commands_end > len(binary):
            raise ValueError("Invalid Mach-O command table")
        offset = 32
        platforms = []
        for _ in range(ncmds):
            if offset + 8 > commands_end:
                raise ValueError("Truncated Mach-O load command")
            command, size = struct.unpack_from("<II", binary, offset)
            if size < 8 or offset + size > commands_end:
                raise ValueError("Invalid Mach-O load command size")
            if command == 0x32:  # LC_BUILD_VERSION
                if size < 24:
                    raise ValueError("Truncated LC_BUILD_VERSION")
                platforms.append(struct.unpack_from("<I", binary, offset + 8)[0])
            offset += size
        if offset != commands_end or platforms != [2]:  # PLATFORM_IOS, not IOSSIMULATOR (7)
            raise ValueError("Binary is not built for iPhone devices")
        if any(name.endswith("/embedded.mobileprovision") for name in archive.namelist()):
            raise ValueError("Unexpected provisioning profile in unsigned distribution")
        return {
            "ipa": str(ipa_path),
            "bundle_identifier": info["CFBundleIdentifier"],
            "minimum_ios": info["MinimumOSVersion"],
            "architecture": "arm64",
            "platform": "iPhoneOS",
            "signing": "requires your own certificate and provisioning profile",
        }


if __name__ == "__main__":
    print(json.dumps(verify(sys.argv[1]), ensure_ascii=False, indent=2))
