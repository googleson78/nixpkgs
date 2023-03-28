{
  runCommand,
  stack,
}:
let
  nixpkgsStack = stack;
  officialStack =
    # TODO: not sure how to do multiple platforms, static is only for linux
    # alternatively, we can just restrict this to linux, testing on linux should be enough
    fetchTarball "https://github.com/commercialhaskell/stack/releases/download/v${stack.version}/stack-${stack.version}-linux-x86_64-static.tar.gz";
in
runCommand "test-haskell-writers" {} ''
  get_hpack_version () {
    "''${1}" --version | sed 's/.*hpack-\([0-9.]*\)/\1/'
  };

  official_stack_hpack_version=$(get_hpack_version ${officialStack}/stack)
  # TODO: can I instead get this from the derivation?
  nixpkgs_stack_hpack_version=$(get_hpack_version ${nixpkgsStack}/bin/stack)

  if [ "''${official_stack_hpack_version}" != "''${nixpkgs_stack_hpack_version}" ]
  then
    echo nixpkgs stack hpack version mismatch with official stack bindists:
    echo Expected: official bindists stack hpack version: "''${official_stack_hpack_version}"
    echo Got: nixpkgs stack hpack version: "''${nixpkgs_stack_hpack_version}"
    exit 1
  fi

  touch $out
''
