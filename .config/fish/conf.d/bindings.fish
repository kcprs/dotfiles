fish_vi_key_bindings
set fish_sequence_key_delay_ms 500

# Modified from original bind for escape
bind -M insert j,k \n\ \ \ \ \ \ \ \ if\ commandline\ -P\n\ \ \ \ \ \ \ \ \ \ \ \ commandline\ -f\ cancel\n\ \ \ \ \ \ \ \ else\n\ \ \ \ \ \ \ \ \ \ \ \ set\ fish_bind_mode\ default\n\ \ \ \ \ \ \ \ \ \ \ \ if\ test\ \(count\ \(commandline\ --cut-at-cursor\ \|\ tail\ -c2\)\)\ !=\ 2\n\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ commandline\ -f\ backward-char\n\ \ \ \ \ \ \ \ \ \ \ \ end\n\ \ \ \ \ \ \ \ \ \ \ \ commandline\ -f\ repaint-mode\n\ \ \ \ \ \ \ \ end\n\ \ \ \

bind -M insert ctrl-p up-or-search
bind -M insert ctrl-n down-or-search
bind -M insert ctrl-y accept-autosuggestion
