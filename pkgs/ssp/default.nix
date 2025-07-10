{
  lib,
  fetchzip,
  makeDesktopItem,
  symlinkJoin,
  writeShellScriptBin,
  gamemode,
  winetricks,
  wine,
  wineFlags ? "",
  pname ? "ssp",
  location ? "$HOME/Games/${pname}",
  tricks ? ["cjkfonts"],
  preCommands ? "",
  postCommands ? "",
}: let
  version = "2_6_98f";

  src = fetchzip {
    url = "https://sspnormal.shillest.net/archive/ssp_${version}.zip";
    hash = "sha256-M1mWEpNZp0v6W9xL13BelRDzwXrWigi2MQMJ5Wup1m0=";
    stripRoot = false;
  };

  # concat winetricks args
  tricksFmt = with builtins;
    if (length tricks) > 0
    then concatStringsSep " " tricks
    else "-V";

  script = writeShellScriptBin pname ''
    export WINEPREFIX="${location}"

    PATH=$PATH:${wine}/bin:${winetricks}/bin
    FOLDER="$WINEPREFIX/drive_c/Program Files/ssp"

    if [ ! -d "$WINEPREFIX" ]; then
      # install tricks
      winetricks -q ${tricksFmt}
      wineserver -k

      cp -r "${src}" "$FOLDER"
    fi

    ${preCommands}

    wine ${wineFlags} "$FOLDER/ssp.exe" "$@"
    wineserver -w

    ${postCommands}
  '';

  desktopItems = makeDesktopItem {
    name = pname;
    exec = "${script}/bin/${pname}";
    icon = "${src}/emily4/ghost/master/icon.ico";
    comment = "SSP";
    desktopName = "SSP";
    categories = ["Game"];
  };
in
  symlinkJoin {
    name = pname;
    paths = [
      desktopItems
      script
    ];
    meta = {
      description = "Desktop agent platform compatible with Ukagaka";
      homepage = "https://ssp.shillest.net/";
      license = lib.licenses.unfree;
      platforms = ["x86_64-linux"];
    };
  }
