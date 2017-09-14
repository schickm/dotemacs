# fuzzy find using git
def git-edit -allow-override -params 1 -shell-candidates %{ git ls-files } %{ edit %arg{1} }

# edit with alt-p
map global normal <a-p> ':git-edit '
map global insert <a-p> '<esc>:git-edit '

# save/save all with alt-s/alt-S
map global normal <a-s> ':w<ret>'
map global insert <a-s> '<esc>:w<ret>'
map global normal <a-S> ':wa<ret>'
map global insert <a-S> '<esc>:wa<ret>'

# show git branch in modeline
set global modelinefmt '⎇ %opt{modeline_git_branch}  %val{bufname} %val{cursor_line}:%val{cursor_char_column} {{context_info}} {{mode_info}} - %val{client}@[%val{session}]'

# global 4 space indent
set global indentwidth 4
set global aligntab false

# always use git grep
set global grepcmd 'git grep -n'

# always use spaces for tab key
# map global insert <tab> '<a-;><gt>'
# map global insert <backtab> '<a-;><lt>'

# easy access to editing my kakrc
def kakrc -allow-override -docstring "open kakrc in a less fastidious way" %{
    edit %sh{ echo ${XDG_CONFIG_HOME:-${HOME}/.config}/kak/kakrc }
}

def gti -allow-override -params 0..1 \
    -docstring "gti \"<command>\": utility wrapper that runs gti commands in main service" %{ %sh{
     output=$(mktemp -d -t kak-gti.XXXXXXXX)/fifo
     mkfifo ${output}
     if [ $# -gt 0 ]; then
         ( docker exec -i main perl -MGTI=1 -e "$@" > ${output} 2>&1 ) > /dev/null 2>&1 < /dev/null &
     else
         ( docker exec -i main perl -MGTI=1 -e "${kak_selection}" > ${output} 2>&1 ) > /dev/null 2>&1 < /dev/null &
     fi
     # Open the file in Kakoune and add a hook to remove the fifo
     echo "edit! -fifo %{output} *buffer-name*
           hook buffer BufClose .* %{ nop %sh{ rm -r $(dirname ${output}} }"
}}

def ide -allow-override %{
    rename-client main
    set global jumpclient main

    new rename-client tools
    set global toolsclient tools

    new rename-client docs
    set global docsclient docs
}

# autoload all my stuff
%sh{
    autoload() {
        dir=$1
        for rcfile in ${dir}/*.kak; do
            if [ -f "$rcfile" ]; then
                echo "try %{ source '${rcfile}' } catch %{ echo -debug Autoload: could not load '${rcfile}' }";
            fi
        done
        for subdir in ${dir}/*; do
            if [ -d "$subdir" ]; then
                autoload $subdir
            fi
        done
    }

	autoload ~/vc/dotfiles/kak
}

# map jj to esc
hook global InsertChar j %{ try %{
  exec -draft hH <a-k>jj<ret> d
  exec <esc>
}}

# replace fresh tabs with spaces
hook global WinCreate .* %{
    hook window InsertChar \t %{ exec -draft -itersel h@ }
    # show line numbers on all files
    addhl number_lines
    search-highlighting-enable
}

# center when matching

hook global BufCreate .*\.jshintrc %{
	set buffer filetype json
}

# use editor config on load
hook global BufCreate .* %{editorconfig-load}


# do syntax highlighting for perl modules as well
hook global BufCreate .*\.[(?:pm)t] %{
    set buffer filetype perl
}

# Face customizations
face GitDiffFlags default
face MatchingChar red,white+b

# Show git gutter always
hook global WinCreate .* %{
	git show-diff
    addhl show_matching
}

hook global NormalIdle .* %{
	git update-diff
}

# linting
hook global WinSetOption filetype=javascript %{
	%sh{
		log () {
			echo "echo -debug \"$1\""
        }

        gnureadlink() {
            if hash greadlink 2>/dev/null; then
                greadlink "$@"
            else
                readlink "$@"
            fi
        }

        find_in_closest_parent_dir() {
            filename=$1
            path=$2
            while [[ $path != "/" ]]
            do
        	out=$(find $path -maxdepth 1 -mindepth 1 -name $filename)

        	if [[ -n $out ]] 
                then 
                    echo "$path/$filename"
        	    break
        	fi

                path=$(gnureadlink -f $path/..)
            done
        }
		target_dir=$(dirname $kak_buffile)
    	jshint_path=$(find_in_closest_parent_dir .jshintrc ${target_dir})

    	echo "set buffer lintcmd 'jshint --config $jshint_path --reporter ~/vc/dotfiles/kak/jshint-reporter.js'"
    }
	lint-enable
	lint

	hook window BufWritePost .* %{
		lint
	}
}

def github-blame -allow-override -docstring 'Open blame on github for current file and line' %{ %sh{
    local_branch_name=$(git name-rev --name-only HEAD)
    remote_name=$(git config branch.$local_branch_name.remote || echo "origin")
    remote_branch_name=$(git config branch.$local_branch_name.merge | sed 's|refs/heads/||')
    repo_url=$(git config remote.$remote_name.url)
    repo_url=$(echo "$repo_url" | sed 's/^git@//; s/:/\//; s/\.git$//')
    line_number=$(echo "$kak_selection_desc" | sed -n 's/^.*,\([[:digit:]]*\).*$/\1/p')
    open "https://$repo_url/blame/$remote_branch_name/$kak_bufname#L$line_number"
}}

def prettier-format -allow-override -docstring 'Format file with prettier' %{ %sh{
    prettier --tab-width 4 --single-quote --trailing-comma es5 --write $kak_buffile 2>&1
}}

def -allow-override \
    -docstring 'Switch back and forth between ember template and associated route/component' \
    ember-jump  %{ %sh{

    subdir=$(echo "${kak_bufname}" | sed -n 's/^app\/\([[:alpha:]\-]*\)\/.*$/\1/p')
    item_path=$(echo "${kak_bufname}" | sed -n 's/^app\/[[:alpha:]\-]*\/\(.*$\)/\1/p')

    echo "echo '${item_path}'";
}}
# /tmp/ranger-files is populated by ranger --choosefiles
def ranger2 -allow-override -docstring 'Open files previously chosen by ranger' %{ %sh{
    while read f; do
        echo "edit $f;"
    done < '/tmp/ranger-files'
}}
map global user r :ranger<ret>

def suspend2 -allow-override -params 1 %{ %sh{
    kill -SIGTSTP $PPID
    echo "$1"
}}
