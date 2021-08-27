```
Usage:
    roll.pl [OPTION]... [DICE]...

Options:
    DICE can take different forms. The general form is \d*(d\d+)? (example:
    "4d8" or "d20"). DICE can also be a numeric constant.

    A "+" character can be used to concatenate dice types (example:
    "2d6+d8+2" will roll d6, d6, d8, and add 2)

    --char-5e
        Sets options for rolling a D&D 5th Edition character's ability
        scores. Equivalent to "--discard-low=1 --discard-high=0 --no-total
        --throws=6 4d6".

    --discard-low=NUM, --discard-high=NUM
        Discard the lowest or highest NUM dice from each throw.

    --throws=NUM
        Roll all dice NUM times.

    --total, --no-total
        Turn on or off display of a total. By default no total is shown if
        there's only one roll.

    --help
        Display this help and exit.
```
