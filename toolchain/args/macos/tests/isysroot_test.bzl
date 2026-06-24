"""Regression test: the macOS toolchain must pass -isysroot.

A bare --sysroot is overridden by the SDKROOT/DEVELOPER_DIR env vars on Darwin,
so without -isysroot an executor or CI exporting them redirects clang to the host
Xcode SDK and breaks hermeticity. -isysroot wins over SDKROOT.
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

def _isysroot_present_test_impl(ctx):
    env = analysistest.begin(ctx)
    compiles = [a for a in analysistest.target_actions(env) if a.mnemonic == "CppCompile"]
    asserts.true(env, len(compiles) > 0, "expected a CppCompile action")
    asserts.true(
        env,
        "-isysroot" in compiles[0].argv,
        "macOS CppCompile must pass -isysroot; argv = %s" % compiles[0].argv,
    )
    return analysistest.end(env)

isysroot_present_test = analysistest.make(
    _isysroot_present_test_impl,
    config_settings = {
        "//command_line_option:platforms": [str(Label("//platforms:macos_aarch64"))],
    },
)
