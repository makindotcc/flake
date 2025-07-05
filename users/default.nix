{
  names =
    let
      entries = builtins.readDir ./.;
    in
    entries |> builtins.attrNames |> builtins.filter (name: entries.${name} == "directory");
}
