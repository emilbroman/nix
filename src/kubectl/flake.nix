{
  outputs = {self}: {
    home-module = {pkgs, ...}: {
      home.packages = with pkgs; let
        kubectx = writeShellScriptBin "kubectx" ''
          kubeconfig="$HOME/.kube/config"
          yq=${lib.getExe yq-go}
          ctx=$($yq '.contexts[].name' "$kubeconfig" | sort | ${lib.getExe fzf})
          chmod 600 "$kubeconfig"
          $yq -i ".current-context = \"$ctx\"" "$kubeconfig"
          chmod 400 "$kubeconfig"
        '';
        kubeconfig-gen = writeShellScriptBin "kubeconfig-gen" ''
          kubeconfig="$HOME/.kube/config"
          yq=${lib.getExe yq-go}
          chmod 600 "$kubeconfig"
          $yq ea -P '. as $item ireduce ({}; . *+ $item)' "$kubeconfig.d"/* > "$kubeconfig"
          ${lib.getExe kubectx}
        '';
      in [
        kubeconfig-gen
        kubectx
        kubectl
      ];
    };
  };
}
