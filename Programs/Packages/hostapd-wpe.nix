{
  lib

, libnl
, stdenv
, fetchurl

, sqlite
, openssl
, pkg-config
, makeWrapper

}:

#! REPO contains C code so stdenv is needed
stdenv.mkDerivation rec {
  pname = "hostapd-wpe";
  version = "2.11";

  src = fetchurl {
    url = "https://w1.fi/releases/hostapd-${version}.tar.gz";
    sha256 = "sha256-Kz+stjL9T2XjL0v4Kna0tyxQH5laT2LjMCGf567RdHo=";
  };

  nativeBuildInputs = [
      pkg-config
      makeWrapper
    ];

  buildInputs = [
      libnl
      sqlite
      openssl
    ];

  postPatch = ''
    cd hostapd
    cp defconfig .config
    sed -i 's/#CONFIG_DRIVER_NL80211=y/CONFIG_DRIVER_NL80211=y/' .config
    sed -i 's/#CONFIG_LIBNL32=y/CONFIG_LIBNL32=y/' .config
    sed -i 's/#CONFIG_WPS=y/CONFIG_WPS=y/' .config
    sed -i 's/#CONFIG_IEEE80211N=y/CONFIG_IEEE80211N=y/' .config
    sed -i 's/#CONFIG_IEEE80211AC=y/CONFIG_IEEE80211AC=y/' .config
    sed -i 's/#CONFIG_EAP_PWD=y/CONFIG_EAP_PWD=y/' .config

    # WPE specific configurations
    echo "CONFIG_WPE=y" >> .config
    echo "CONFIG_SUITEB192=y" >> .config

    # Manual patching
    sed -i '/#ifndef CONFIG_NO_STDOUT_DEBUG/a #ifndef CONFIG_WPE\n#define CONFIG_WPE\n#endif' ../src/utils/wpa_debug.c
    sed -i '/for_n_entries: 4 bytes/a \\twpa_printf(MSG_INFO, "WPE: EAP Request, Identity");' ../src/eap_server/eap_server.c
    sed -i '/eap_type == EAP_TYPE_MSCHAPV2/a \\t\twpa_printf(MSG_INFO, "WPE: EAP Request, MSCHAPv2");' ../src/eap_server/eap_server_mschapv2.c

    # Add WPE functionality to main.c
    cat << EOF >> main.c

    #ifdef CONFIG_WPE
    #include "../src/wpe/wpe.h"
    #endif

    EOF

    sed -i '/if (!daemonize)/i\
    #ifdef CONFIG_WPE\
    \twpa_printf(MSG_INFO, "WPE: Initializing...");\
    \twpe_init();\
    #endif' main.c
  '';

  buildPhase = "make";

  installPhase = ''
    mkdir -p $out/bin
    cp hostapd hostapd_cli $out/bin

    cat << EOF > $out/bin/hostapd-wpe
    #!/bin/sh
    $out/bin/hostapd "\$@"
    EOF

    chmod +x $out/bin/hostapd-wpe
    wrapProgram $out/bin/hostapd-wpe --prefix PATH : $out/bin
  '';

  meta = with lib; {
    homepage = "https://w1.fi/hostapd";
    description = "Hostapd with WPE functionality (manually patched)";
    mainProgram = "hostapd-wpe";

    maintainers = with maintainers; [ Masrkai ];
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
