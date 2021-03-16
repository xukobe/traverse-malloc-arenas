define -read-writer-nodes
    set $first_node = $arg0
    set $cur_node = $first_node
    print $cur_node
    print *$cur_node
    while ($cur_node.next != $first_node)
        set $cur_node = $cur_node.next
        print $cur_node
        print *$cur_node
    end
end
