"Install toolchain dependencies"

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@build_bazel_rules_nodejs//:index.bzl", "yarn_install")
load(":mock_io_bazel_rules_closure.bzl", "mock_io_bazel_rules_closure")

def npm_bazel_labs_dependencies():
    """
    Fetch our transitive dependencies.

    If the user wants to get a different version of these, they can just fetch it
    from their WORKSPACE before calling this function, or not call this function at all.
    """

    _maybe(
        http_archive,
        name = "com_github_grpc_grpc_web",
        sha256 = "8d9b1e9b839a5254aa79cb4068b05fdb6e1de5637c1b8551f95144159a4801f2",
        strip_prefix = "grpc-web-1.2.0",
        urls = [
            "https://github.com/grpc/grpc-web/archive/1.2.0.tar.gz",
        ],
    )

    http_archive(
        name = "rules_proto",
        sha256 = "83c8798f5a4fe1f6a13b5b6ae4267695b71eed7af6fbf2b6ec73a64cf01239ab",
        strip_prefix = "rules_proto-b22f78685bf62775b80738e766081b9e4366cdf0",
        urls = [
            "https://github.com/bazelbuild/rules_proto/archive/b22f78685bf62775b80738e766081b9e4366cdf0.tar.gz",
        ],
    )

    _maybe(
        mock_io_bazel_rules_closure,
        name = "io_bazel_rules_closure",
    )

    yarn_install(
        name = "build_bazel_rules_typescript_grpc_web_compiletime_deps",
        package_json = Label("//packages/labs/grpc_web:package.json"),
        yarn_lock = Label("//packages/labs/grpc_web:yarn.lock"),
        # Do not symlink node_modules as when used in downstream repos we should not create
        # node_modules folders in the external repository. This is
        # not supported by managed_directories.
        symlink_node_modules = False,
    )

def _maybe(repo_rule, name, **kwargs):
    if name not in native.existing_rules():
        repo_rule(name = name, **kwargs)
