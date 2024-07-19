// Find if match is included in the arr
function in_array(match, arr) = search(match, arr)[0] != undef;

// Remove duplicates from arr
function unique(arr, newArr = [], i = 0) =
    (i == len(arr)
         ? newArr
         : unique(arr,
                  in_array(arr[i], newArr) ? newArr : concat(newArr, arr[i]),
                  i + 1));

echo("ORI:", [ 1, 2, 2, 3, 4, 4, 4, 5, 10 ]);
echo("DUP:", unique([ 1, 2, 2, 3, 4, 4, 4, 5, 10 ]));