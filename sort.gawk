{
    ++ctr 
    sizes[ctr] = $2 
    paths[ctr] = $1 
    table[$2] = $1
} END {
    n = asort(sizes)
    for (ind in sizes) {
        key = sizes[ind]
        val = table[key]
        print val
    }
}
