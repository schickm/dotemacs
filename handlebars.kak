# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*\.(hbs) %{
    set buffer filetype handlebars
}

addhl -group / regions -default raw handlebars \
	comment {{!-- --}} '' \
    expression {{ }} ''

addhl -group /handlebars/raw ref html
addhl -group /handlebars/comment fill comment

%sh{
	hbs_identifier="\w+(?:-\w+)*"
	hbs_value="\w+(?:\.\w+)*"
	hbs_exp_start="\{\{"
	hbs_exp_end="\}\}"
	printf %s "
		addhl -group /handlebars/expression regex \h*$hbs_identifier 0:identifier
        addhl -group /handlebars/expression regex $hbs_exp_start[#/]?(${hbs_identifier}) 1:keyword 
        addhl -group /handlebars/expression regex \h*(${hbs_identifier})= 1:attribute
        addhl -group /handlebars/expression regex \h*(${hbs_identifier})=(${hbs_identifier}) 1:attribute 2:identifier
	"
}
# addhl -group /handlebars/expression regex \h*(\w+(?:-\w+)*)= 1:attribute
addhl -group /handlebars/expression regex \h+(as)\h+(?<!\|)(\|\h*(?:\w+)(?:\h*(?:\w+))*\h*\|)(?!\|) 1:identifier 2:identifier
addhl -group /handlebars/expression regions content \
    string '"' (?<!\\)(\\\\)*"      '' \
    string "'" "'"                  ''
addhl -group /handlebars/expression/content/string fill string
# addhl -group /handlebars/expression regex \h*(\w+(?:-\w+))=(\w+) 1:keyword 2:value

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾
hook -group handlebars-highlight global WinSetOption filetype=handlebars %{ addhl ref handlebars }
hook -group handlebars-highlight global WinSetOption filetype=(?!handlebars).* %{ rmhl handlebars }
