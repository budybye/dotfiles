# Vite+ environment setup (https://viteplus.dev)
set -l __vp_idx (contains -i -- $HOME/.config/vite-plus/bin $PATH)
and set -e PATH[$__vp_idx]
set -gx PATH $HOME/.config/vite-plus/bin $PATH

# Shell function wrapper: intercepts `vp env use` to eval its stdout,
# which sets/unsets VITE_PLUS_NODE_VERSION in the current shell session.
function vp
    if test (count $argv) -ge 2; and test "$argv[1]" = "env"; and test "$argv[2]" = "use"
        if contains -- -h $argv; or contains -- --help $argv
            command vp $argv; return
        end
        set -lx VITE_PLUS_ENV_USE_EVAL_ENABLE 1
        set -l __vp_out (command vp $argv); or return $status
        eval $__vp_out
    else
        command vp $argv
    end
end
