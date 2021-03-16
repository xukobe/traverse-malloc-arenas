macro define offsetof(t, f) &((t *) 0)->f

define -bin-at
    set $m = $arg0
    set $i = $arg1
    set $offset = offsetof(struct malloc_chunk,fd)
    set $ret = (mbinptr)((char*)&(main_arena->bins[(($i)-1)*2])-(int)$offset)
    printf "$ret = %p\n", $ret
end

define -traverse-bin-fd
    set $first_chunk = $arg0
    set $cur_chunk = $first_chunk
    if ($cur_chunk == 0x0)
        return
    end
    while ($cur_chunk->fd != $first_chunk)
        printf "%p.", $cur_chunk
        # print *$cur_chunk
        set $cur_chunk = $cur_chunk->fd
    end
    printf "%p.", $cur_chunk
    # print *$cur_chunk
end

define -traverse-bin-bk
    set $last_chunk = $arg0
    set $cur_chunk = $last_chunk
    if ($cur_chunk == 0x0)
        return
    end
    while ($cur_chunk->bk != $last_chunk)
        printf "%p.", $cur_chunk
        # print *$cur_chunk
        set $cur_chunk = $cur_chunk->bk
    end
    printf "%p.", $cur_chunk
    # print *$cur_chunk
end

define -traverse-fast-bin
    set $first_chunk = $arg0
    set $cur_chunk = $first_chunk
    while ($cur_chunk != 0x0)
        printf "%p.", $cur_chunk
        # print *$cur_chunk
        set $cur_chunk = $cur_chunk->fd
    end
end

define -traverse-arena
    set $arena_ptr = $arg0
    # traverse fastbins
    set $fast_index = 0
    # There are 10 fast bins in total
    while($fast_index < 10)
        printf "Fastbin %d:", $fast_index
        set $fb = $arena_ptr.fastbinsY[$fast_index]
        if ($fb != 0x0)
            -traverse-fast-bin $fb
        end
        printf "\n"
        set $fast_index = $fast_index + 1
    end

    # traverse bins
    set $bin_index = 0
    # There are 126 bins in total
    while ($bin_index < 126)
        printf "Bin %d:", $bin_index
        set $bin = $arena_ptr.bins[$bin_index]
        if ($bin != 0x0)
            -traverse-bin-fd $bin
        end
        if ($bin != 0x0)
            -traverse-bin-bk $bin
        end
        printf "\n"
        set $bin_index = $bin_index + 1
    end
end

define -traverse-all-arenas
    set $cur_arena = &main_arena
    print "Main arena"
    -traverse-arena *$cur_arena
    while($cur_arena->next != &main_arena)
        set $cur_arena = $cur_arena->next
        print "Additional Arena"
        -traverse-arena *$cur_arena
    end
end
