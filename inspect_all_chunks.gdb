define -mem-heap-dump-chunk
  printf "%#016x: ", $mem_addr
  printf "%016lu %016lu   %#02x ", ((long *)$mem_addr)[0], ((long *)$mem_addr)[1] & ~3, ((long*)$mem_addr)[1] & 3
  printf "%016x %016x\n", ((long *)$mem_addr)[2], ((long *)$mem_addr)[3]
  set $mem_addr = $mem_addr + ((long *)$mem_addr)[1] & ~3
end
document -mem-heap-dump-chunk
!!! FOR INTERNAL USE ONLY - DO NOT CALL !!!
end

define -mem-heap-dump-arena
    set $mem_addr = $arg0
    printf "Chunk address     prev_size        size             flags data (fw + bk)\n"
    while $mem_addr < $arg1
        if $mem_addr == $top_chunk
            printf "Top-most chunk\n"
        end
        -mem-heap-dump-chunk
    end
end
document -mem-heap-dump-arena
!!! FOR INTERNAL USE ONLY - DO NOT CALL !!!
end

define -find-chunk-for-address
    -main-arena-heap-setup
    set $mem_addr = $chunks_start
    while $mem_addr < $chunks_end
        if $mem_addr == $top_chunk
            printf "Top-most chunk\n"
        end
        set $mchunk_size = ((mchunkptr)$mem_addr).mchunk_size
        set $mchunk_real_size = (*(long*)$size) & ~7
        set $next_mem_addr = $mem_addr + $mchunk_real_size
        if 
    end
end

define -main-arena-heap-setup
    set $arena_ptr = (char *)&main_arena
    set $arena_sz = sizeof(main_arena)
    set $top_chunk = main_arena.top
    if $top_chunk == 0
        printf "Top chunk is 0\n"
    end
    set $max_system_mem = main_arena.max_system_mem
    set $system_mem = main_arena.system_mem
    set $chunks_start = mp_.sbrk_base
    set $chunks_end = $chunks_start + $system_mem
    printf "Arena at %#016lx\n", $arena_ptr
    printf "System_mem=%i KB, max_system_mem=%i KB\n", $system_mem/1024, $max_system_mem/1024
end


define -mem-heap-dump
    set $arena_index = 0
    set $arena_ptr   = (char *)&main_arena
    if $argc == 1
        # User provided struct malloc_state size.
        set $arena_sz = $arg0
    else
        # Rely on DWARF or hope.
        set $arena_sz = sizeof(main_arena)
    end

    while ($arena_ptr && ($arena_index == 0 || $arena_ptr != (char *)&main_arena))
        # if pointer to top chunk is null, there's no arena allocated. bail out.
        set $top_chunk = *(long *)($arena_ptr + 0xb * sizeof(void *))
        if $top_chunk == 0
            return
        end

        set $max_system_mem = *(long *)($arena_ptr + $arena_sz - sizeof(void *))
        set $system_mem     = *(long *)($arena_ptr + $arena_sz - 2 * sizeof(void *))
        set $next_arena     = *(long *)($arena_ptr + $arena_sz - 3 * sizeof(void *))

        if $arena_index == 0
            # Start with sbrk_base.
            # Replace with [10] if on (glibc >= 2.19)
            set $chunks_start = ((long *) &(mp_.sbrk_base))
            set $chunks_end = $chunks_start + $system_mem
        else
            set $chunks_start = ((long)$arena_ptr & 0xfffffffffff00000) + $arena_sz
            set $chunks_end = ((long)$arena_ptr & 0xfffffffffff00000) + $system_mem
        end

        set $arena_index++
        printf "Arena #%i at %#016lx : ", $arena_index, $arena_ptr
        printf "system_mem=%i KB, max_system_mem=%i KB\n", $system_mem/1024, $max_system_mem/1024
        -mem-heap-dump-arena $chunks_start $chunks_end
        set $arena_ptr = (char *) $next_arena
    end
end
document -mem-heap-dump
Print all glibc arenas in use. User can provide the size of struct malloc_state
in case no type information is available.
Usage: -mem-heap-dump struct_malloc_state_size
end
