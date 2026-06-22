# DOTNET_ROOT is used by the Roslyn language server in Zed.
# Keep startup quiet on machines where dotnet is unavailable.
function reset_dotnet_root --description 'Reset DOTNET_ROOT based on dotnet CLI availability'
    set -e DOTNET_ROOT

    if not command -sq dotnet
        return 0
    end

    set -l sdk_paths (dotnet --list-sdks 2>/dev/null | string replace -rf '^.*\[(.*)\]$' '$1')
    set -l sdk_path $sdk_paths[-1]

    if test -z "$sdk_path"
        return 0
    end

    set -l dotnet_root (string replace -r '/sdk/?$' '' -- $sdk_path)

    if test -d "$dotnet_root"
        set -gx DOTNET_ROOT $dotnet_root
    end
end

reset_dotnet_root
