#!/usr/bin/env bash

# This script automatically generates the `main-desktop.png` image as well as
# all the different sized versions of the logos. In order for it to work, you
# will need to have `ImageMagick Command-Line Tools` installed.
# http://www.imagemagick.org/script/command-line-tools.php.

# Usage: ./generate-images.sh [dir] [dir] ...
#   e.g: ./generate-images.sh chrome archive/slik ...

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

declare groupImgName="main-desktop"

declare -a imgGroup=(
    "chrome"
    "firefox"
    "internet-explorer"
    "opera"
    "safari"
)

declare -a imgSizes=(
    '16x16'
    '24x24'
    '32x32'
    '48x48'
    '64x64'
    '128x128'
    '256x256'
    '512x512'
)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

generate_group_img() {

    local generateGroupImg="false"
    declare -a tmp=()

    # do not generate new group image if none of composing images are modified
    while [ $# -ne 0 ] && [ "$generateGroupImg" != "true" ]; do
        if [[ "${imgGroup[*]}" =~ "$1" ]]; then
            generateGroupImg="true"
        fi
        shift
    done

    if [ "$generateGroupImg" == "true" ]; then

        for i in ${imgGroup[@]}; do
            tmp+=("../$i/$i.png")
        done

        # `convert` command options:
        # http://www.imagemagick.org/script/convert.php#options

        convert "${tmp[@]}" \
            -background transparent \
            -gravity center \
            -resize 512x512 \
            -extent 562x562 \
            +append \
            "../$groupImgName.png" \
        && print_success_msg "  [create]" "../$groupImgName.png"

    fi
}

generate_imgs() {

    local basename='', imgDirs='', path=''

    imgDirs=($@)

    for i in ${imgDirs[@]}; do

        path=${i%/*}
        basename=$(basename $i)

        if [ "$path" == "$basename" ]; then
            path="$basename/$basename"
        else
            path="$path/$basename/$basename"
        fi

        # remove outdated images
        rm ../${path}_* &> /dev/null

        # generate the different sized versions of an image
        for s in ${imgSizes[@]}; do
            convert "../${path}.png" \
                    -background transparent \
                    -gravity center \
                    -resize "$s" \
                    "../${path}_$s.png" \
            && print_success_msg "  [create]" "../${path}_$s.png"
        done

    done

}

is_installed() {
    printf "$( [[ -x "$(command -v "$1")" ]] && printf "1" || printf "0" )"
    #                                       installed ──┘             │
    #                                                 not installed ──┘
}

print_error_msg() {
    print_msg "[0;31m$1[0m"
}

print_msg() {
    printf "  %s\n" "$1"
}

print_success_msg() {
    print_msg "[0;32m$1[0m $2"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {
    if [ $(is_installed "convert") -eq 1 ]; then
        if [ $# -ne 0 ]; then

            print_msg ""
            print_success_msg "Generate images"
            print_msg ""

            generate_group_img $@ \
                && generate_imgs $@ \
                && (
                    print_msg ""
                    print_success_msg "Done! 🍻 "
                    print_msg ""
                )
        fi
    else
        print_error_msg "Please install ImageMagick Command-Line Tools!"
    fi
}

main $@
