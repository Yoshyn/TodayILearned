# Generate a wordlist

----
## What is Crunch?
see [Sourceforge](https://sourceforge.net/projects/crunch-wordlist/)

> Crunch is a wordlist generator where you can specify a standard character set or a character set you specify. crunch can generate all possible combinations and permutations..

----
## Example usage with crunch


    crunch <min-len> <max-len> [<charset string>] [-o <output_file>]

    kali ❯❯❯ crunch 2 5 abcdef -o ./crunch_sample
    Crunch will now generate the following amount of data: 54108 bytes
    0 MB
    0 GB
    0 TB
    0 PB
    Crunch will now generate the following number of lines: 9324

    crunch: 100% completed generating output

    kali ❯❯❯  cat crunch_sample | head -5
    aa
    ab
    ac
    ad
    ae
    ...

Here is the available charset :

    hex-lower [0123456789abcdef]
    hex-upper [0123456789ABCDEF]
    numeric [0123456789]
    numeric-space [0123456789 ]
    symbols14 [!@#$%^&*()-_+=]
    symbols14-space [!@#$%^&*()-_+= ]
    symbols-all [!@#$%^&*()-_+=~`[]{}|\:; »<>,.?/]
    symbols-all-space [!@#$%^&*()-_+=~`[]{}|\:; »<>,.?/ ]
    ualpha [ABCDEFGHIJKLMNOPQRSTUVWXYZ]
    ualpha-space [ABCDEFGHIJKLMNOPQRSTUVWXYZ ]
    ualpha-numeric [ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789]
    ualpha-numeric-space [ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ]
    ualpha-numeric-symbol14 [ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_+=]
    ualpha-numeric-symbol14-space [ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_+= ]
    ualpha-numeric-all [ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_+=~`[]{}|\:; »<>,.?/]
    ualpha-numeric-all-space [ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_+=~`[]{}|\:; »<>,.?/ ]
    lalpha [abcdefghijklmnopqrstuvwxyz]
    lalpha-space [abcdefghijklmnopqrstuvwxyz ]
    lalpha-numeric [abcdefghijklmnopqrstuvwxyz0123456789]
    lalpha-numeric-space [abcdefghijklmnopqrstuvwxyz0123456789 ]
    lalpha-numeric-symbol14 [abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()-_+=]
    lalpha-numeric-symbol14-space [abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()-_+= ]
    lalpha-numeric-all [abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()-_+=~`[]{}|\:; »<>,.?/]
    lalpha-numeric-all-space [abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()-_+=~`[]{}|\:; »<>,.?/ ]
    mixalpha [abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ]
    mixalpha-space [abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ]
    mixalpha-numeric [abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789]
    mixalpha-numeric-space [abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ]
    mixalpha-numeric-symbol14 [abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_+=]
    mixalpha-numeric-symbol14-space [abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_+= ]
    mixalpha-numeric-all [abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_+=~`[]{}|\:; »<>,.?/]
    mixalpha-numeric-all-space [abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_+=~`[]{}|\:; »<>,.?/ ]

Check the manpage example for generation. It's well documented

----
## Sources
* [kali.org](https://www.kali-linux.fr/hacking/generer-un-dico)
* [securitynewspaper.com](https://www.securitynewspaper.com/2018/11/28/create-your-own-wordlist-with-crunch)
* [crunch-wordlist](https://sourceforge.net/projects/crunch-wordlist/)
