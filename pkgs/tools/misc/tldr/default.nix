{ lib, stdenv, fetchFromGitHub, curl, libzip, pkg-config, installShellFiles }:

stdenv.mkDerivation rec {
  pname = "tldr";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "tldr-pages";
    repo = "tldr-cpp-client";
    rev = "v${version}";
    sha256 = "sha256-ZNUW2PebRUDLcZ2/dXClXqf8NUjgw6N73h32PJ8iwmM=";
  };

  buildInputs = [ curl libzip ];
  nativeBuildInputs = [ pkg-config installShellFiles ];

  makeFlags = ["CC=${stdenv.cc.targetPrefix}cc" "LD=${stdenv.cc.targetPrefix}cc" "CFLAGS="];

  installFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    installShellCompletion --cmd tldr autocomplete/complete.{bash,fish,zsh}
  '';

  meta = with lib; {
    description = "Simplified and community-driven man pages";
    longDescription = ''
      tldr pages gives common use cases for commands, so you don't need to hunt
      through a man page for the correct flags.
    '';
    homepage = "http://tldr-pages.github.io";
    license = licenses.mit;
    maintainers = with maintainers; [ taeer carlosdagos ];
    platforms = platforms.all;
  };
}
