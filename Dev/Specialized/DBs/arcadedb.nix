{ stdenv, lib, fetchzip, jre_headless, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "arcadedb";
  version = "26.4.2";

  src = fetchzip {
    url = "https://github.com/ArcadeData/arcadedb/releases/download/${version}/arcadedb-${version}.tar.gz";
    hash = "sha256-SYxBrxiehVE/DRQx39EOuhi06VhJepGaOUmxpxn3fl4=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/opt/arcadedb
    cp -r * $out/opt/arcadedb

    # The server.sh script expects arcadedb-server.jar (without version suffix).
    # Create a symlink to the actual versioned JAR.
    ln -sf $out/opt/arcadedb/lib/arcadedb-server-${version}.jar \
           $out/opt/arcadedb/lib/arcadedb-server.jar

    # We do NOT set ARCADEDB_HOME here; the service will set it appropriately.
    # Instead, just ensure the script can be called with the correct Java.
    mkdir -p $out/bin
    makeWrapper $out/opt/arcadedb/bin/server.sh $out/bin/arcadedb-server \
      --set JAVA_HOME "${jre_headless}" \
      --prefix PATH : "${jre_headless}/bin"
  '';

  meta = with lib; {
    description = "ArcadeDB Multi-Model NoSQL Database";
    homepage = "https://arcadedb.com";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}