{ pkgs ? import <nixpkgs> {} }:
# Mostly taken from the cinny nix package
let
  # Destructure the necessary dependencies from pkgs
  inherit (pkgs) stdenv lib dpkg fetchurl autoPatchelfHook glib-networking libayatana-appindicator openssl webkitgtk_4_1 wrapGAppsHook libcanberra-gtk3;
in
stdenv.mkDerivation rec {
  name = "drop-oss-app";
  version = "0.3.3";

  src = fetchurl {
    url = "https://github.com/Drop-OSS/drop-app/releases/download/v${version}/Drop.Desktop.Client_${version}_amd64.deb";
    sha256 = "sha256-w9pnYds8m8DASzCDN3Bp+UF1CcrW24G274OLVdnzIkI=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = [
    glib-networking
    openssl
    webkitgtk_4_1
    wrapGAppsHook
    libayatana-appindicator
    pkgs.gdk-pixbuf
    pkgs.gtk3
    libcanberra-gtk3
    pkgs.mesa
    pkgs.xorg.libX11
    pkgs.xorg.libXext
  ];

  unpackCmd = "dpkg-deb -x $curSrc source";
  installPhase = "mv usr $out";

  postFixup = ''
    # Ensure libraries get injected
    local libPath=${lib.makeLibraryPath buildInputs}

    wrapProgram $out/bin/drop-app \
      --set LD_LIBRARY_PATH "$libPath"
  '';

  meta = with lib; {
    description = " The desktop companion app for Drop. It acts a download client, game launcher and game distribution endpoint for Drop. ";
    homepage = "https://droposs.org";
    maintainers = [ "quexeky" ];
    license = licenses.agpl3Only;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = platforms.linux;
    mainProgram = "drop-app";
  };
}
