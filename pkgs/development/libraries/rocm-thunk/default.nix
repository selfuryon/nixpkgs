{ lib, stdenv
, fetchFromGitHub
, writeScript
, cmake
, pkg-config
, libdrm
, numactl
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rocm-thunk";
  version = "5.4.0";

  src = fetchFromGitHub {
    owner = "RadeonOpenCompute";
    repo = "ROCT-Thunk-Interface";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-EU5toaKzVeZpdm/YhaQ0bXq0eoYwYQ5qGLUJzxgZVjE=";
  };

  preConfigure = ''
    export cmakeFlags="$cmakeFlags "
  '';

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ libdrm numactl ];

  # https://github.com/RadeonOpenCompute/ROCT-Thunk-Interface/issues/75
  postPatch = ''
    substituteInPlace libhsakmt.pc.in \
      --replace '$'{prefix}/@CMAKE_INSTALL_LIBDIR@ @CMAKE_INSTALL_FULL_LIBDIR@ \
      --replace '$'{prefix}/@CMAKE_INSTALL_INCLUDEDIR@ @CMAKE_INSTALL_FULL_INCLUDEDIR@
  '';

  postInstall = ''
    cp -r $src/include $out
  '';

  passthru.updateScript = writeScript "update.sh" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl jq common-updater-scripts
    version="$(curl ''${GITHUB_TOKEN:+"-u \":$GITHUB_TOKEN\""} -sL "https://api.github.com/repos/RadeonOpenCompute/ROCT-Thunk-Interface/tags" | jq '.[].name | split("-") | .[1] | select( . != null )' --raw-output | sort -n | tail -1)"
    update-source-version rocm-thunk "$version" --ignore-same-hash
  '';

  meta = with lib; {
    description = "Radeon open compute thunk interface";
    homepage = "https://github.com/RadeonOpenCompute/ROCT-Thunk-Interface";
    license = with licenses; [ bsd2 mit ];
    maintainers = with maintainers; [ lovesegfault ] ++ teams.rocm.members;
  };
})
