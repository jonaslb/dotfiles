function gabbr --argument-names alias cmd
    abbr -a $alias git $cmd
end

gabbr gco checkout
gabbr gc commit
gabbr gst status
gabbr gsw switch
gabbr gl log
gabbr gps push
gabbr gpl pull
gabbr ga add
gabbr gd diff
gabbr gbr branch
gabbr grb rebase
gabbr grs reset
gabbr gmg merge
functions -e gabbr

