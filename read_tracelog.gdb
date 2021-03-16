

define dump_tracelog
     set $index = btrace_context_global->file_type_gl.file_index
     dump binary memory /tmp/gdb_core_extracted.bin btrace_context_global->file_type_gl.files[$index].mmap_buffer btrace_context_global->file_type_gl.files[$index].mmap_buffer+btrace_context_global->file_type_gl.files[$index].file_size_in_bytes
     shell /auto/binos-tools/bin/btdecode /tmp/gdb_core_extracted.bin > /tmp/gdb_core_extracted.btrace
     output "less /tmp/gdb_core_extracted.btrace"
     echo
end

define read_tracelog
     set $index = btrace_context_global->file_type_gl.file_index
     dump binary memory /tmp/gdb_core_extracted.bin btrace_context_global->file_type_gl.files[$index].mmap_buffer btrace_context_global->file_type_gl.files[$index].mmap_buffer+btrace_context_global->file_type_gl.files[$index].file_size_in_bytes
     shell btdecode /tmp/gdb_core_extracted.bin
end
